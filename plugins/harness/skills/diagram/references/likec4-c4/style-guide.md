# LikeC4 Style Guide

## Color Palette

### Named Colors (Built-In)

| Name       | Usage                                   |
|------------|-----------------------------------------|
| `primary`  | Key/focal elements in the diagram       |
| `secondary`| Supporting elements (data stores, queues)|
| `muted`    | Background/external/less important      |
| `amber`    | Actors, human users                     |
| `green`    | Healthy, active, confirmed elements     |
| `sky`      | Infrastructure, cloud services          |
| `red`      | Errors, deprecated, danger              |
| `slate`    | Neutral container backgrounds           |

### Custom Colors

Define additional colors with hex values in `specification`:

```likec4
specification {
  color brand     #0f172a
  color accent    #6366f1
  color highlight #f59e0b
  color subtle    #e2e8f0
}
```

Use custom colors anywhere a color is referenced:

```likec4
element component {
  style {
    color brand
  }
}
```

---

## Shape Types

| Shape        | Usage                        | Keyword       |
|--------------|------------------------------|---------------|
| Rectangle    | Default — services, modules  | `rectangle`   |
| Person       | Human actors and users       | `person`      |
| Browser      | Web applications, SPAs       | `browser`     |
| Mobile       | iOS/Android applications     | `mobile`      |
| Storage      | Databases, object stores     | `storage`     |
| Queue        | Message queues, event buses  | `queue`       |
| Cylinder     | Alias for storage            | `cylinder`    |

```likec4
specification {
  element user    { style { shape person   } }
  element webApp  { style { shape browser  } }
  element mobile  { style { shape mobile   } }
  element db      { style { shape storage  } }
  element bus     { style { shape queue    } }
}
```

---

## Icons

Icons use a `provider:name` format. Supported providers include `aws`, `azure`, `gcp`, `tech`, and `simple`.

```likec4
specification {
  element lambda {
    style {
      icon aws:lambda
    }
  }

  element rds {
    style {
      icon aws:rds
      shape storage
    }
  }

  element k8s {
    style {
      icon tech:kubernetes
    }
  }

  element react {
    style {
      icon tech:react
      shape browser
    }
  }
}
```

---

## Opacity

Controls element transparency. Useful for de-emphasizing external or out-of-scope elements.

```likec4
specification {
  element externalSystem {
    style {
      opacity 20%
    }
  }
}
```

Valid values: any percentage from `0%` (invisible) to `100%` (fully opaque). Default is `100%`.

---

## Style Predicates in Views

Styles can be applied inside `views { }` blocks to override specification defaults for a specific view.

### Style a Specific Element

```likec4
views {
  view contextDiagram {
    include *

    style paymentGateway {
      color muted
      opacity 30%
    }
  }
}
```

### Style Multiple Named Elements

```likec4
views {
  view containers {
    include *

    style database, eventBus {
      color secondary
    }
  }
}
```

### Style All Visible Elements

```likec4
views {
  view greyScale {
    include *

    style * {
      color muted
      opacity 60%
    }
  }
}
```

### Style by Element Kind

```likec4
views {
  view byKind {
    include *

    style element.kind == actor {
      color amber
      shape person
    }

    style element.kind == database {
      color secondary
      shape storage
    }
  }
}
```

### Style by Tag

```likec4
views {
  view byTag {
    include *

    style element.tag == #external {
      color muted
      opacity 30%
    }

    style element.tag == #deprecated {
      color red
      opacity 40%
    }
  }
}
```

---

## Relationship Styling

Relationships are styled in `specification`, not in `views`:

```likec4
specification {
  relationship sync {
    color primary
    line solid
  }

  relationship async {
    color secondary
    line dashed
  }

  relationship deprecated {
    color red
    line dotted
  }
}
```

Relationship line styles: `solid`, `dashed`, `dotted`.

---

## Global Styles Block

The `global { }` block applies style predicates to all views simultaneously, avoiding repetition:

```likec4
global {
  // All actors are amber persons across every view
  style element.kind == actor {
    color amber
    shape person
  }

  // External systems are muted everywhere
  style element.tag == #external {
    color muted
    opacity 25%
  }

  // Deprecated elements flagged red at half opacity
  style element.tag == #deprecated {
    color red
    opacity 40%
  }
}
```

View-level style blocks override `global` styles for that view.

---

## Technology Labels

The `technology` property adds a subtitle label beneath the element name. It does not affect styling but appears in rendered diagrams.

```likec4
model {
  api = container 'API Service' {
    technology 'Node.js / Express'
  }

  db = container 'Primary DB' {
    technology 'PostgreSQL 15'
    style { shape storage }
  }
}
```

---

## Style Application Order (Precedence)

From lowest to highest priority:

1. `specification { element kind { style { } } }` — kind-level defaults
2. `global { style ... }` — global overrides
3. `views { view X { style ... } }` — per-view overrides
4. `model { element { style { } } }` — inline element overrides (highest)

Inline element styles always win over view-level and global styles.
