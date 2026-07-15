# Rails Anti-Patterns Reference

Detailed checks for `agent-rails.md` Categories 4-8. Read only the matched section — see Detection Table in `agent-rails.md`.

## 1. ViewComponent / Component Contract Violations

**Severity:** CRITICAL

**What:** Component (ViewComponent, React, any reusable component w/ explicit params contract) adds new required param; not all call sites updated.

**Impact:** Argument error at runtime, or worse — silent feature regression if framework tolerates missing param.

**Check:**

```bash
# Find components whose constructor changed to add a required param
grep -A5 "def initialize" app/components/**/*.rb

# Find all render sites for that component
grep -rn "render.*ComponentName" app/
```

Look for newly added required keyword arg (`param_name:`) with no default, then verify every render call site (diff + wider codebase if shared) was updated.

**Flag if:** required param added but ≥1 call site not updated.

---

## 2. Config Mismatch Between Sources

**Severity:** MAJOR

**What:** Same config value (host, URL, API key, feature flag) defined in two places (e.g. Ruby initializer + JS config); diff changes one, not both.

**Impact:** Behavior diverges across environments or server/client code.

**Check:** If diff touches both `config/initializers/*.rb` and `app/javascript/**/*.js` (or equivalent):

```bash
grep -E "host|url|key|token|api" config/initializers/<file>
grep -E "host|url|key|token|api" app/javascript/<file>
```

Compare values for matching keys.

**Flag if:** same key, different values across Ruby/JS.

---

## 3. Test Quality Issues

**Severity:** MAJOR

**What:** Tests pass but don't verify claimed behavior — false confidence. Four sub-patterns:

### 3a. Fragile Regex HTML Matching

```bash
grep -n "expect.*match(/.*<" spec/
```

**Flag:** regex matching HTML tags/attrs directly in assertion.

**Fix — parse instead of regex:**

```ruby
# Bad - fragile, breaks on any markup reformatting
expect(response.body).to match(/name="[^"]*\[width\]"[^>]*value="large"/)

# Good - parse and assert on the parsed structure
doc = Nokogiri::HTML(response.body)
width_field = doc.at_css('input[name*="[width]"]')
expect(width_field['value']).to eq('large')
```

### 3b. Hand-Rolled HTML/JSON Bypassing Real Render

```bash
grep -n "<<-HTML\|<<~HTML" spec/
```

**Flag:** inline HTML/JSON strings instead of real component/view render path — passes even when real render is broken.

**Fix:** use real component factories/render helpers.

### 3c. Soft Assertions

```bash
grep -n "expect.*> 0\|expect.*>= 1" spec/
```

**Flag:** generic threshold (`expect(height).to be > 0`) when expected value is known/specific. A bug producing `0` instead of `195` still passes `> 0`. Assert the specific range (e.g. `> 150`).

### 3d. Tests That Bypass the Feature Under Test

```bash
grep -B3 "drag\|drop" spec/ | grep "click"
```

**Flag:** test sets up state via unrelated action instead of triggering the feature itself — e.g. manually clicking a toggle before testing hover-to-open, never exercising the hover trigger.

**Flag if:** any of the four sub-patterns found in changed specs.

---

## 4. Transaction Boundaries with External Services

**Severity:** CRITICAL

**What:** External API call (payment processor, cloud storage, any HTTP call) inside a DB transaction block.

**Impact:** Rollback undoes DB changes but not the external side effect — orphaned external resources (e.g. Stripe customer with no local record).

**Check:**

```bash
grep -A20 "ActiveRecord::Base.transaction\|transaction do" app/ | \
  grep -E "Stripe::|AWS::|S3\.|HTTP\.|Faraday|RestClient|Net::HTTP|HTTParty"
```

**Flag if:** external service call found inside transaction block.

**Fix:**

```ruby
# Bad - external call inside the transaction
ActiveRecord::Base.transaction do
  user = User.create!(...)
  Stripe::Customer.create(...)  # orphaned if user.create! raises after this
end

# Good - move the external call outside the transaction
user = User.create!(...)
customer = Stripe::Customer.create(...)

# Or - explicit cleanup if the external call must happen inside
ActiveRecord::Base.transaction do
  user = User.create!(...)
  customer = Stripe::Customer.create(...)
  # ...
rescue => e
  Stripe::Customer.delete(customer.id) if customer
  raise
end
```

---

## 5. Business Logic in Views/ERB Templates

**Severity:** MAJOR

**What:** Sorting/filtering/calculations done directly in ERB instead of model scope or helper.

**Impact:** Not reusable, harder to test in isolation, breaks presentation/logic separation — duplicated view logic drifts out of sync.

**Check:**

```bash
grep -rn "\.sort_by\|\.select {|\.reject {|\.find {" app/views/
grep -rn "\.sum\|\.count\|\.average\|\.maximum\|\.minimum" app/views/
```

**Flag if:** business logic found in view layer.

**Fix:**

```ruby
# Bad - app/views/payments/index.html.erb
<% @user.payments.sort_by(&:paid_at).reverse.each do |payment| %>

# Good - app/models/user.rb
has_many :payments, -> { order(paid_at: :desc) }, dependent: :destroy

# View becomes:
<% @user.payments.each do |payment| %>
```
