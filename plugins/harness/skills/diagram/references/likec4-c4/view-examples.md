# LikeC4 View Examples

Each example is self-contained and can be pasted directly into a `.likec4` file. They are intentionally illustrative — adapt element identifiers and names to the actual system being modeled.

---

## Context View (C4 Level 1)

Shows the target system in relation to users and external systems. No internal structure is visible.

```likec4
specification {
  element actor {
    notation "Person"
    style {
      shape person
      color amber
    }
  }

  element system {
    notation "Software System"
    style {
      opacity 10%
    }
  }

  element externalSystem {
    notation "External System"
    style {
      color muted
      opacity 20%
    }
  }
}

model {
  customer    = actor 'Customer'         { description 'End user placing orders' }
  supportStaff = actor 'Support Staff'  { description 'Internal support agents' }

  orderPlatform = system 'Order Platform' {
    description 'Manages orders, inventory, and fulfilment'
  }

  paymentGateway = externalSystem 'Payment Gateway' {
    description 'Third-party card processing (Stripe)'
  }

  emailProvider = externalSystem 'Email Provider' {
    description 'Transactional email delivery (SendGrid)'
  }

  // Relationships
  customer      -> orderPlatform    'places and tracks orders'
  supportStaff  -> orderPlatform    'manages orders on behalf of customers'
  orderPlatform -> paymentGateway   'charges cards'
  orderPlatform -> emailProvider    'sends order confirmations'
}

views {
  view context {
    title 'System Context — Order Platform'
    description 'Who uses the Order Platform and what external systems does it rely on'

    include
      *,
      customer,
      supportStaff,
      -> orderPlatform ->

    style paymentGateway, emailProvider {
      color muted
    }

    autoLayout TopBottom
  }
}
```

---

## Container View (C4 Level 2)

Zooms into one system to show its containers (applications, services, data stores, queues).

```likec4
specification {
  element actor {
    notation "Person"
    style { shape person; color amber }
  }

  element system {
    notation "Software System"
    style { opacity 10% }
  }

  element webApp {
    notation "Web Application"
    style { shape browser; color primary }
  }

  element apiService {
    notation "API Service"
    style { color primary }
  }

  element database {
    notation "Database"
    style { shape storage; color secondary }
  }

  element queue {
    notation "Message Queue"
    style { shape queue; color secondary }
  }

  element worker {
    notation "Background Worker"
    style { color secondary }
  }
}

model {
  customer = actor 'Customer'

  orderPlatform = system 'Order Platform' {
    spa = webApp 'Single-Page Application' {
      description 'React frontend served via CDN'
      technology 'React 18 / TypeScript'
    }

    api = apiService 'API Gateway' {
      description 'REST and GraphQL entry point'
      technology 'Node.js / Express'
    }

    orderSvc = apiService 'Order Service' {
      description 'Order lifecycle management'
      technology 'Go'
    }

    db = database 'Order DB' {
      description 'Primary relational data store'
      technology 'PostgreSQL 15'
    }

    eventBus = queue 'Event Bus' {
      description 'Domain event streaming'
      technology 'Amazon SQS'
    }

    fulfilmentWorker = worker 'Fulfilment Worker' {
      description 'Processes order.created events'
      technology 'Go'
    }
  }

  paymentGateway = system 'Payment Gateway' {
    style { color muted; opacity 20% }
  }

  // Relationships
  customer             -> spa               'uses via HTTPS'
  spa                  -> api               'calls'
  api                  -> orderSvc          'routes to'
  orderSvc             -> db                'reads/writes'
  orderSvc             -> eventBus          'publishes order.created'
  fulfilmentWorker     -> eventBus          'consumes order.created'
  orderSvc             -> paymentGateway    'charges card'
}

views {
  view orderPlatformContainers of orderPlatform {
    title 'Order Platform — Containers'
    description 'Internal containers and their interactions'

    include
      *,
      customer,
      paymentGateway,
      -> orderPlatform ->

    style customer {
      color amber
    }

    style paymentGateway {
      color muted
      opacity 30%
    }

    autoLayout TopBottom
  }
}
```

---

## Component View (C4 Level 3)

Zooms into one container to show its components (modules, layers, classes of responsibility).

```likec4
specification {
  element component {
    notation "Component"
    style { color primary }
  }

  element store {
    notation "Data Store"
    style { shape storage; color secondary }
  }

  element externalService {
    notation "External Service"
    style { color muted; opacity 30% }
  }
}

model {
  orderPlatform = system 'Order Platform' {
    orderSvc = container 'Order Service' {

      router = component 'HTTP Router' {
        description 'Routes incoming HTTP requests'
        technology 'Go net/http'
      }

      orderHandler = component 'Order Handler' {
        description 'Validates request and delegates to use cases'
        technology 'Go'
      }

      createOrderUseCase = component 'Create Order Use Case' {
        description 'Orchestrates order creation workflow'
        technology 'Go'
      }

      orderRepo = component 'Order Repository' {
        description 'Persistence adapter — translates between domain and DB'
        technology 'Go / pgx'
      }

      eventPublisher = component 'Event Publisher' {
        description 'Publishes domain events to SQS'
        technology 'Go / AWS SDK'
      }
    }

    db = store 'Order DB' { technology 'PostgreSQL 15' }
  }

  sqsQueue = externalService 'SQS Queue'
  paymentSvc = externalService 'Payment Service'

  // Internal component relationships
  orderSvc.router            -> orderSvc.orderHandler       'dispatches'
  orderSvc.orderHandler      -> orderSvc.createOrderUseCase 'invokes'
  orderSvc.createOrderUseCase -> orderSvc.orderRepo         'persists via'
  orderSvc.createOrderUseCase -> orderSvc.eventPublisher    'emits event via'
  orderSvc.createOrderUseCase -> paymentSvc                 'charges card'
  orderSvc.orderRepo         -> db                          'SQL'
  orderSvc.eventPublisher    -> sqsQueue                    'publishes'
}

views {
  view orderServiceComponents of orderPlatform.orderSvc {
    title 'Order Service — Components'
    description 'Internal components of the Order Service container'

    include
      *,
      db,
      sqsQueue,
      paymentSvc,
      -> * ->

    style db, sqsQueue, paymentSvc {
      color muted
      opacity 40%
    }

    autoLayout LeftRight
  }
}
```

---

## Deployment View (C4 Level 4 — Deployment)

Shows how containers are deployed onto infrastructure.

```likec4
specification {
  element actor {
    style { shape person; color amber }
  }

  element system {
    style { opacity 10% }
  }

  element webApp {
    style { shape browser; color primary }
  }

  element apiService {
    style { color primary }
  }

  element database {
    style { shape storage; color secondary }
  }

  element queue {
    style { shape queue; color secondary }
  }
}

model {
  orderPlatform = system 'Order Platform' {
    spa     = webApp    'SPA'         { technology 'React' }
    api     = apiService 'API Gateway' { technology 'Node.js' }
    orderSvc = apiService 'Order Service' { technology 'Go' }
    db      = database  'Order DB'    { technology 'PostgreSQL 15' }
    eventBus = queue    'Event Bus'   { technology 'Amazon SQS' }
  }

  spa      -> api
  api      -> orderSvc
  orderSvc -> db
  orderSvc -> eventBus
}

deployment {
  environment prod {
    zone cdn 'CDN Edge' {
      spaInstance = instanceOf orderPlatform.spa {
        description 'React SPA served from CloudFront'
      }
    }

    zone appTier 'App Tier (eu-west-1)' {
      apiInstance     = instanceOf orderPlatform.api     { description 'ECS Fargate task' }
      orderSvcInstance = instanceOf orderPlatform.orderSvc { description 'ECS Fargate task' }
    }

    zone dataTier 'Data Tier (eu-west-1)' {
      dbInstance      = instanceOf orderPlatform.db     { description 'RDS Multi-AZ' }
      queueInstance   = instanceOf orderPlatform.eventBus { description 'SQS FIFO queue' }
    }
  }

  environment staging {
    zone appTier {
      instanceOf orderPlatform.api
      instanceOf orderPlatform.orderSvc
    }
    zone dataTier {
      instanceOf orderPlatform.db
      instanceOf orderPlatform.eventBus
    }
  }
}

views {
  deployment view prodDeployment of prod {
    title 'Production Deployment'
    description 'Order Platform running in AWS eu-west-1'
    include *
    autoLayout TopBottom
  }

  deployment view stagingDeployment of staging {
    title 'Staging Deployment'
    include *
    autoLayout TopBottom
  }
}
```
