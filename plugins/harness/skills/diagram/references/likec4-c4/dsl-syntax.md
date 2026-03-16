# LikeC4 DSL Syntax Reference

## File Format

LikeC4 models are written in `.likec4` or `.c4` files. All files in a project directory are merged into one unified model — you can split the model across multiple files freely.

---

## Four Top-Level Blocks

```
specification { ... }   // Define element kinds, relationship kinds, tags, colors
model { ... }           // Declare architecture elements and their relationships
views { ... }           // Define visualizations (projections of the model)
global { ... }          // Shared style predicates applied across views
```

---

## 1. `specification { }` — Vocabulary Definition

Defines the custom vocabulary used in `model { }` and `views { }`.

### Custom Colors

```likec4
specification {
  color primary   #2563eb
  color secondary #7c3aed
  color success   #16a34a
  color warning   #d97706
  color danger    #dc2626
}
```

### Element Kinds

```likec4
specification {
  element actor {
    notation "Person or system user"
    style {
      shape person
      color amber
    }
  }

  element system {
    notation "Software System"
    style {
      opacity 10%
      color secondary
    }
  }

  element container {
    notation "Container (app, service, DB)"
    style {
      color primary
    }
  }

  element component {
    notation "Component within a container"
  }

  element database {
    notation "Data store"
    style {
      shape storage
      icon aws:rds
    }
  }

  element queue {
    notation "Message queue or event bus"
    style {
      shape queue
    }
  }

  element webApp {
    notation "Browser-based UI"
    style {
      shape browser
    }
  }

  element mobileApp {
    notation "Mobile application"
    style {
      shape mobile
    }
  }
}
```

### Relationship Kinds

```likec4
specification {
  relationship uses
  relationship publishes {
    line dashed
    color muted
  }
  relationship consumes {
    line dotted
  }
  relationship calls {
    color primary
  }
}
```

### Tags

```likec4
specification {
  tag deprecated
  tag experimental
  tag external
  tag internal
}
```

---

## 2. `model { }` — Architecture Elements

### Declaring Elements

```likec4
model {
  // Syntax: identifier = kind 'Display Name' { ... }
  customer = actor 'Customer' {
    description 'End user of the platform'
    technology 'Web browser'
    link https://wiki.example.com/customer
  }

  crm = system 'CRM System' {
    description 'Customer relationship management'
  }
}
```

### Nesting (Containment)

Children are declared inside their parent's block — this establishes the C4 container/component hierarchy:

```likec4
model {
  cloud = system 'Cloud System' {
    description 'Our SaaS platform'

    api = container 'API Service' {
      description 'REST API backend'
      technology 'Node.js / Express'

      auth = component 'Auth Module' {
        description 'JWT validation and session management'
      }

      orders = component 'Orders Module' {
        description 'Order processing logic'
      }
    }

    db = container 'PostgreSQL' {
      description 'Primary relational data store'
      technology 'PostgreSQL 15'
      style {
        shape storage
      }
    }

    queue = container 'Event Bus' {
      description 'Async message broker'
      technology 'Amazon SQS'
      style {
        shape queue
      }
    }
  }
}
```

### Relationships

```likec4
model {
  // Basic relationship
  customer -> cloud 'uses'

  // With label and properties
  cloud.api -> cloud.db 'reads/writes' {
    technology 'SQL over TLS'
    description 'Queries user and order data'
  }

  // Named relationship kind
  cloud.api -[publishes]-> cloud.queue 'order.created'

  // Relationship with tag
  cloud.api -> externalPayment 'charges card' {
    #external
  }
}
```

### Inline Styles on Elements

```likec4
model {
  legacyApp = system 'Legacy App' {
    style {
      color danger
      opacity 50%
    }
  }
}
```

---

## 3. `views { }` — Visualizations

### Basic View

```likec4
views {
  view index {
    title 'System Landscape'
    description 'All systems and their relationships'
    include *
    autoLayout TopBottom
  }
}
```

### View Scoped to an Element (`view of`)

```likec4
views {
  // Shows the element and its direct children
  view apiContainers of cloud.api {
    title 'API Service — Components'
    include *
    autoLayout LeftRight
  }
}
```

### Element Predicates

Order matters — predicates are applied in sequence:

```likec4
views {
  view example {
    // Include all top-level elements
    include *

    // Include specific element
    include customer

    // Include direct children of cloud
    include cloud.*

    // Include all descendants of cloud (recursive)
    include cloud.**

    // Include an element and all relationships it participates in
    include -> cloud ->

    // Include all incoming relationships to cloud
    include -> cloud

    // Include all outgoing relationships from cloud
    include cloud ->

    // Exclude a specific element (and its edges)
    exclude cloud.legacyModule

    // Exclude all relationships into/out of an element
    exclude -> cloud.legacyModule ->
  }
}
```

### Predicate Filters (Tag and Kind)

```likec4
views {
  view externalSystems {
    include element.tag == #external
    include element.kind == system
  }

  view deprecatedElements {
    include element.tag == #deprecated
    style * {
      color danger
      opacity 50%
    }
  }
}
```

### View-Level Styling

```likec4
views {
  view contextDiagram {
    include *

    // Style a specific element
    style customer {
      color amber
    }

    // Style all elements of a kind
    style element.kind == actor {
      color primary
    }

    // Style all visible elements
    style * {
      opacity 80%
    }
  }
}
```

### `autoLayout` Options

```
autoLayout TopBottom    // TB — default
autoLayout BottomTop    // BT
autoLayout LeftRight    // LR
autoLayout RightLeft    // RL
```

---

## 4. Deployment Model and Views

### `deployment { }` Block

The deployment block lives at the top level (not inside `model`):

```likec4
deployment {
  environment prod {
    zone eu-west-1 {
      // instanceOf references model elements by identifier
      api = instanceOf cloud.api {
        description 'API service running in EU'
      }
      db = instanceOf cloud.db
    }

    zone eu-west-1-failover {
      api = instanceOf cloud.api
    }
  }

  environment staging {
    instanceOf cloud.api
    instanceOf cloud.db
  }
}
```

### Deployment View

```likec4
views {
  deployment view prodDeployment of prod {
    title 'Production Deployment'
    include *
    autoLayout TopBottom
  }

  deployment view stagingDeployment of staging {
    title 'Staging Deployment'
    include *
  }
}
```

---

## 5. `global { }` — Shared Styles

Applied across all views:

```likec4
global {
  style element.kind == actor {
    color amber
    shape person
  }

  style element.tag == #external {
    color muted
    opacity 70%
  }

  style element.tag == #deprecated {
    color danger
    opacity 40%
  }
}
```

---

## Relationship Predicate in Views

```likec4
views {
  view withRelationships {
    include *

    // Include all relationships between included elements
    include * -> *

    // Include only relationships of a specific kind
    include * -[calls]-> *

    // Exclude relationships of a kind
    exclude * -[deprecated]-> *
  }
}
```
