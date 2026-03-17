#!/usr/bin/env bash
#
# validate-skills.sh — Deterministic structural and trigger validation for skill definitions.
#
# Checks 8 categories of rules against skills under plugins/*/skills/ and scenario
# files under tests/scenarios/. Produces TAP-like output (ok/not ok with test numbers).
#
# Dependencies: yq (mikefarah/yq v4+), grep, wc
# No network calls. No claude CLI invocations.
#
# Exit 0 if all checks pass; non-zero if any check fails.

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
readonly PLUGIN_SKILLS_DIRS=("${PROJECT_ROOT}/plugins/praxis/skills" "${PROJECT_ROOT}/plugins/harness/skills")
readonly SCENARIOS_DIR="${PROJECT_ROOT}/tests/scenarios"
readonly RUBRICS_DIR="${PROJECT_ROOT}/tests/rubrics"

readonly MAX_DESCRIPTION_LENGTH=1024
readonly MAX_SKILL_LINES=300

# ---------------------------------------------------------------------------
# TAP output helpers
# ---------------------------------------------------------------------------

# Global test counter — incremented by pass/fail helpers.
TEST_NUMBER=0
FAILURES=0

# pass — emit a TAP "ok" line and increment the test counter.
# Args: $1 description string
pass() {
    TEST_NUMBER=$(( TEST_NUMBER + 1 ))
    printf 'ok %d - %s\n' "${TEST_NUMBER}" "$1"
}

# fail — emit a TAP "not ok" line, increment the test counter, and record the failure.
# Args: $1 description string
fail() {
    TEST_NUMBER=$(( TEST_NUMBER + 1 ))
    FAILURES=$(( FAILURES + 1 ))
    printf 'not ok %d - %s\n' "${TEST_NUMBER}" "$1"
}

# diag — emit a TAP diagnostic comment (shown after a not-ok line for context).
# Args: $1 diagnostic message
diag() {
    printf '#   %s\n' "$1"
}

# ---------------------------------------------------------------------------
# Utility helpers
# ---------------------------------------------------------------------------

# extract_frontmatter_field — use yq to read a single scalar field from SKILL.md YAML front-matter.
# Globals: none
# Args: $1 field name (yq expression, e.g. '.name'), $2 path to SKILL.md
# Outputs: field value on stdout; empty string if absent or null
extract_frontmatter_field() {
    local field_expr="$1"
    local skill_file="$2"
    local value
    value=$(yq --front-matter=extract "${field_expr}" "${skill_file}" 2>/dev/null) || true
    # yq outputs "null" for missing fields; normalise to empty string
    if [[ "${value}" == "null" ]]; then
        value=""
    fi
    printf '%s' "${value}"
}

# extract_frontmatter_array — emit each element of a YAML array on its own line.
# Args: $1 field expression (e.g. '.triggers[]'), $2 path to SKILL.md
extract_frontmatter_array() {
    local field_expr="$1"
    local skill_file="$2"
    yq --front-matter=extract "${field_expr}" "${skill_file}" 2>/dev/null || true
}

# skill_has_frontmatter — return 0 if SKILL.md has a non-empty YAML front-matter block.
# Args: $1 path to SKILL.md
skill_has_frontmatter() {
    local skill_file="$1"
    # A valid front-matter block starts on line 1 with "---".
    local first_line
    first_line=$(head -n 1 "${skill_file}")
    [[ "${first_line}" == "---" ]]
}

# ---------------------------------------------------------------------------
# Check implementations
# ---------------------------------------------------------------------------

# check_skill_structure — Check 1 & 4.
# Validates that each skill directory contains SKILL.md with valid YAML front-matter
# providing non-empty name, description, triggers, and allowed-tools. Also verifies
# that the frontmatter `name` matches the directory name (Check 4).
check_skill_structure() {
    local skills_dir skill_dir skill_name skill_file fm_name fm_description fm_allowed_tools trigger_count

    for skills_dir in "${PLUGIN_SKILLS_DIRS[@]}"; do
    for skill_dir in "${skills_dir}"/*/; do
        [[ -d "${skill_dir}" ]] || continue
        skill_name=$(basename "${skill_dir}")
        skill_file="${skill_dir}SKILL.md"

        # Check SKILL.md file exists
        if [[ ! -f "${skill_file}" ]]; then
            fail "skill/${skill_name}: SKILL.md exists"
            diag "No SKILL.md found at ${skill_file}"
            continue
        fi
        pass "skill/${skill_name}: SKILL.md exists"

        # Check front-matter block is present
        if ! skill_has_frontmatter "${skill_file}"; then
            fail "skill/${skill_name}: SKILL.md has YAML front-matter"
            diag "Front-matter block (---) not found on line 1 of ${skill_file}"
            # Cannot parse fields without front-matter — skip remaining checks for this skill
            continue
        fi
        pass "skill/${skill_name}: SKILL.md has YAML front-matter"

        # Check 'name' field is present
        fm_name=$(extract_frontmatter_field '.name' "${skill_file}")
        if [[ -z "${fm_name}" ]]; then
            fail "skill/${skill_name}: frontmatter has 'name' field"
            diag "Missing or empty 'name' field in ${skill_file}"
        else
            pass "skill/${skill_name}: frontmatter has 'name' field"
        fi

        # Check 'description' field is present
        fm_description=$(extract_frontmatter_field '.description' "${skill_file}")
        if [[ -z "${fm_description}" ]]; then
            fail "skill/${skill_name}: frontmatter has 'description' field"
            diag "Missing or empty 'description' field in ${skill_file}"
        else
            pass "skill/${skill_name}: frontmatter has 'description' field"
        fi

        # Check 'triggers' array is present (non-empty)
        trigger_count=$(yq --front-matter=extract '.triggers | length' "${skill_file}" 2>/dev/null || echo 0)
        if [[ "${trigger_count}" -eq 0 ]]; then
            fail "skill/${skill_name}: frontmatter has non-empty 'triggers' array"
            diag "Missing or empty 'triggers' field in ${skill_file}"
        else
            pass "skill/${skill_name}: frontmatter has non-empty 'triggers' array"
        fi

        # Check 'allowed-tools' field is present
        fm_allowed_tools=$(extract_frontmatter_field '.["allowed-tools"]' "${skill_file}")
        if [[ -z "${fm_allowed_tools}" ]]; then
            fail "skill/${skill_name}: frontmatter has 'allowed-tools' field"
            diag "Missing or empty 'allowed-tools' field in ${skill_file}"
        else
            pass "skill/${skill_name}: frontmatter has 'allowed-tools' field"
        fi

        # Check 4: frontmatter 'name' matches directory name
        if [[ -z "${fm_name}" ]]; then
            # Already reported missing name above — skip consistency check
            continue
        fi
        if [[ "${fm_name}" != "${skill_name}" ]]; then
            fail "skill/${skill_name}: frontmatter name matches directory name"
            diag "frontmatter name='${fm_name}' but directory name='${skill_name}' in ${skill_file}"
        else
            pass "skill/${skill_name}: frontmatter name matches directory name"
        fi
    done
    done
}

# check_description_constraints — Check 2.
# description must be < MAX_DESCRIPTION_LENGTH chars and must not contain XML angle brackets.
check_description_constraints() {
    local skills_dir skill_dir skill_name skill_file fm_description desc_length

    for skills_dir in "${PLUGIN_SKILLS_DIRS[@]}"; do
    for skill_dir in "${skills_dir}"/*/; do
        [[ -d "${skill_dir}" ]] || continue
        skill_name=$(basename "${skill_dir}")
        skill_file="${skill_dir}SKILL.md"
        [[ -f "${skill_file}" ]] || continue

        fm_description=$(extract_frontmatter_field '.description' "${skill_file}")
        [[ -z "${fm_description}" ]] && continue  # Already reported in check_skill_structure

        # Length check
        desc_length=${#fm_description}
        if [[ ${desc_length} -ge ${MAX_DESCRIPTION_LENGTH} ]]; then
            fail "skill/${skill_name}: description length < ${MAX_DESCRIPTION_LENGTH} chars"
            diag "description is ${desc_length} chars in ${skill_file}"
        else
            pass "skill/${skill_name}: description length < ${MAX_DESCRIPTION_LENGTH} chars"
        fi

        # No XML angle brackets
        if echo "${fm_description}" | grep -q '[<>]'; then
            fail "skill/${skill_name}: description contains no XML angle brackets"
            diag "description contains '<' or '>' in ${skill_file}"
        else
            pass "skill/${skill_name}: description contains no XML angle brackets"
        fi
    done
    done
}

# check_trigger_validation — Check 3.
# Each trigger must be multi-word (contains at least one space character).
check_trigger_validation() {
    local skills_dir skill_dir skill_name skill_file trigger single_word_found trigger_count

    for skills_dir in "${PLUGIN_SKILLS_DIRS[@]}"; do
    for skill_dir in "${skills_dir}"/*/; do
        [[ -d "${skill_dir}" ]] || continue
        skill_name=$(basename "${skill_dir}")
        skill_file="${skill_dir}SKILL.md"
        [[ -f "${skill_file}" ]] || continue

        trigger_count=$(yq --front-matter=extract '.triggers | length' "${skill_file}" 2>/dev/null || echo 0)
        [[ "${trigger_count}" -eq 0 ]] && continue  # Already reported in check_skill_structure

        single_word_found=0
        while IFS= read -r trigger; do
            [[ -z "${trigger}" ]] && continue
            # A multi-word trigger must contain at least one space
            if [[ "${trigger}" != *" "* ]]; then
                if [[ ${single_word_found} -eq 0 ]]; then
                    fail "skill/${skill_name}: all triggers are multi-word (no single-word triggers)"
                    single_word_found=1
                fi
                diag "single-word trigger '${trigger}' in ${skill_file}"
            fi
        done < <(extract_frontmatter_array '.triggers[]' "${skill_file}")

        if [[ ${single_word_found} -eq 0 ]]; then
            pass "skill/${skill_name}: all triggers are multi-word (no single-word triggers)"
        fi
    done
    done
}

# check_line_count — Check 5.
# SKILL.md must be <= MAX_SKILL_LINES lines.
check_line_count() {
    local skills_dir skill_dir skill_name skill_file line_count

    for skills_dir in "${PLUGIN_SKILLS_DIRS[@]}"; do
    for skill_dir in "${skills_dir}"/*/; do
        [[ -d "${skill_dir}" ]] || continue
        skill_name=$(basename "${skill_dir}")
        skill_file="${skill_dir}SKILL.md"
        [[ -f "${skill_file}" ]] || continue

        line_count=$(wc -l < "${skill_file}" | tr -d ' ')
        if [[ ${line_count} -gt ${MAX_SKILL_LINES} ]]; then
            fail "skill/${skill_name}: SKILL.md <= ${MAX_SKILL_LINES} lines"
            diag "${skill_file} has ${line_count} lines (limit: ${MAX_SKILL_LINES})"
        else
            pass "skill/${skill_name}: SKILL.md <= ${MAX_SKILL_LINES} lines"
        fi
    done
    done
}

# check_trigger_phrase_matching — Check 6.
# For each scenario YAML, each positive trigger phrase must contain at least one word
# that appears in the corresponding skill's description. This verifies that the scenario
# and skill description share vocabulary — a weak sanity check that the scenario targets
# the right skill.
check_trigger_phrase_matching() {
    local scenario_file scenario_skill skill_file skill_description lower_desc
    local phrase lower_phrase word lower_word match_found skills_dir

    for scenario_file in "${SCENARIOS_DIR}"/*.yaml; do
        [[ -f "${scenario_file}" ]] || continue
        scenario_skill=$(yq '.skill' "${scenario_file}" 2>/dev/null) || continue
        [[ "${scenario_skill}" == "null" || -z "${scenario_skill}" ]] && continue

        # Search for the skill across all plugin directories
        skill_file=""
        for skills_dir in "${PLUGIN_SKILLS_DIRS[@]}"; do
            if [[ -f "${skills_dir}/${scenario_skill}/SKILL.md" ]]; then
                skill_file="${skills_dir}/${scenario_skill}/SKILL.md"
                break
            fi
        done
        if [[ -z "${skill_file}" ]]; then
            diag "scenario $(basename ${scenario_file}): skill '${scenario_skill}' not found in any plugin — skipping trigger matching"
            continue
        fi

        skill_description=$(extract_frontmatter_field '.description' "${skill_file}")
        if [[ -z "${skill_description}" ]]; then
            diag "scenario $(basename ${scenario_file}): skill description is empty — skipping trigger matching"
            continue
        fi

        lower_desc=$(printf '%s' "${skill_description}" | tr '[:upper:]' '[:lower:]')

        while IFS= read -r phrase; do
            [[ -z "${phrase}" ]] && continue

            match_found=0
            # Read words into an array for safe iteration
            read -ra phrase_words <<< "${phrase}"
            for word in "${phrase_words[@]}"; do
                lower_word=$(printf '%s' "${word}" | tr '[:upper:]' '[:lower:]')
                # Strip trailing punctuation that would prevent word-boundary matching
                lower_word="${lower_word//[.,!?;:]/}"
                [[ -z "${lower_word}" ]] && continue
                if echo "${lower_desc}" | grep -qw "${lower_word}"; then
                    match_found=1
                    break
                fi
            done

            if [[ ${match_found} -eq 1 ]]; then
                pass "scenario/${scenario_skill}: positive trigger phrase vocabulary matches description: '${phrase}'"
            else
                fail "scenario/${scenario_skill}: positive trigger phrase vocabulary matches description: '${phrase}'"
                diag "No word from phrase '${phrase}' found in description '${skill_description}'"
            fi
        done < <(yq '.triggering.positive[]' "${scenario_file}" 2>/dev/null)
    done
}

# check_scenario_yaml_schema — Check 7.
# Each scenario YAML must contain required top-level fields: skill, category,
# triggering.positive (non-empty array), triggering.negative (non-empty array),
# and functional (non-empty array).
check_scenario_yaml_schema() {
    local scenario_file scenario_name skill_val category_val pos_count neg_count func_count

    for scenario_file in "${SCENARIOS_DIR}"/*.yaml; do
        [[ -f "${scenario_file}" ]] || continue
        scenario_name=$(basename "${scenario_file}")

        skill_val=$(yq '.skill' "${scenario_file}" 2>/dev/null || echo "null")
        category_val=$(yq '.category' "${scenario_file}" 2>/dev/null || echo "null")
        pos_count=$(yq '.triggering.positive | length' "${scenario_file}" 2>/dev/null || echo 0)
        neg_count=$(yq '.triggering.negative | length' "${scenario_file}" 2>/dev/null || echo 0)
        func_count=$(yq '.functional | length' "${scenario_file}" 2>/dev/null || echo 0)

        # 'skill' field
        if [[ "${skill_val}" == "null" || -z "${skill_val}" ]]; then
            fail "scenario/${scenario_name}: required field 'skill' is present"
        else
            pass "scenario/${scenario_name}: required field 'skill' is present"
        fi

        # 'category' field
        if [[ "${category_val}" == "null" || -z "${category_val}" ]]; then
            fail "scenario/${scenario_name}: required field 'category' is present"
        else
            pass "scenario/${scenario_name}: required field 'category' is present"
        fi

        # 'triggering.positive' non-empty array
        if [[ "${pos_count}" -eq 0 ]]; then
            fail "scenario/${scenario_name}: 'triggering.positive' is a non-empty array"
        else
            pass "scenario/${scenario_name}: 'triggering.positive' is a non-empty array (${pos_count} entries)"
        fi

        # 'triggering.negative' non-empty array
        if [[ "${neg_count}" -eq 0 ]]; then
            fail "scenario/${scenario_name}: 'triggering.negative' is a non-empty array"
        else
            pass "scenario/${scenario_name}: 'triggering.negative' is a non-empty array (${neg_count} entries)"
        fi

        # 'functional' non-empty array
        if [[ "${func_count}" -eq 0 ]]; then
            fail "scenario/${scenario_name}: 'functional' is a non-empty array"
        else
            pass "scenario/${scenario_name}: 'functional' is a non-empty array (${func_count} entries)"
        fi
    done
}

# check_rubric_completeness — Check 8.
# Every skill that has a scenario file must have an entry in the rubric file that
# corresponds to the scenario's category. Category-to-rubric mapping:
#   structured-output -> tests/rubrics/structured-output.md
#   behavioral        -> tests/rubrics/behavioral.md
# An "entry" is any line in the rubric file that contains the skill name.
check_rubric_completeness() {
    local scenario_file scenario_skill scenario_category rubric_file

    for scenario_file in "${SCENARIOS_DIR}"/*.yaml; do
        [[ -f "${scenario_file}" ]] || continue
        scenario_skill=$(yq '.skill' "${scenario_file}" 2>/dev/null || echo "null")
        scenario_category=$(yq '.category' "${scenario_file}" 2>/dev/null || echo "null")

        [[ "${scenario_skill}" == "null" || -z "${scenario_skill}" ]] && continue
        [[ "${scenario_category}" == "null" || -z "${scenario_category}" ]] && continue

        # Derive rubric file path from category name
        rubric_file="${RUBRICS_DIR}/${scenario_category}.md"

        if [[ ! -f "${rubric_file}" ]]; then
            fail "scenario/${scenario_skill}: rubric file '${scenario_category}.md' exists for category '${scenario_category}'"
            diag "Expected rubric at ${rubric_file}"
            continue
        fi

        # Check that the skill name appears somewhere in the rubric file
        if grep -qi "${scenario_skill}" "${rubric_file}"; then
            pass "scenario/${scenario_skill}: has entry in ${scenario_category}.md rubric"
        else
            fail "scenario/${scenario_skill}: has entry in ${scenario_category}.md rubric"
            diag "No mention of '${scenario_skill}' found in ${rubric_file}"
        fi
    done
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
    # Verify required tooling is available
    if ! command -v yq > /dev/null 2>&1; then
        printf 'Bail out! Required tool '"'"'yq'"'"' not found on PATH\n'
        exit 1
    fi

    printf '# validate-skills.sh — skill structure and trigger validation\n'
    printf '# Project root: %s\n' "${PROJECT_ROOT}"
    printf '# Skills dirs:  %s\n' "${PLUGIN_SKILLS_DIRS[*]}"
    printf '#\n'

    # Run checks in the order specified in the task brief
    printf '# --- Check 1 & 4: Skill structure and name consistency ---\n'
    check_skill_structure

    printf '# --- Check 2: Description constraints ---\n'
    check_description_constraints

    printf '# --- Check 3: Trigger validation (multi-word) ---\n'
    check_trigger_validation

    printf '# --- Check 5: SKILL.md line count ---\n'
    check_line_count

    printf '# --- Check 6: Trigger phrase vocabulary matching ---\n'
    check_trigger_phrase_matching

    printf '# --- Check 7: Scenario YAML schema ---\n'
    check_scenario_yaml_schema

    printf '# --- Check 8: Rubric completeness ---\n'
    check_rubric_completeness

    # TAP plan line (emitted at end once we know total)
    printf '1..%d\n' "${TEST_NUMBER}"
    printf '#\n'

    if [[ ${FAILURES} -eq 0 ]]; then
        printf '# Result: PASS — all %d checks passed\n' "${TEST_NUMBER}"
        exit 0
    else
        printf '# Result: FAIL — %d of %d checks failed\n' "${FAILURES}" "${TEST_NUMBER}"
        exit 1
    fi
}

main "$@"
