# LikeC4 Dynamic View — Flow Examples

Each example below is a complete, pasteable `.likec4` file including the required `specification` and `model` blocks.

---

## Example 1 — Simple Request/Response Flow

A user submits a web form; the backend validates and persists the data, then returns a confirmation.

```likec4
specification {
  element actor
  element webApp
  element service
  element database

  relationship calls
}

model {
  customer = actor 'Customer'
  frontend = webApp 'Web Frontend'
  api = service 'API Service'
  db = database 'PostgreSQL'

  customer -> frontend 'uses'
  frontend -> api 'calls'
  api -> db 'reads/writes'
}

views {
  dynamic view submitContactForm {
    title 'Submit Contact Form'

    customer -> frontend 'fills in and submits form'
    frontend -> api 'POST /contacts'
    api -> db 'INSERT INTO contacts'
    db <- api 'row inserted'
    api -> frontend '201 Created + contact ID'
    customer <- frontend 'shows success message'
  }
}
```

---

## Example 2 — Parallel Fan-Out

An API gateway fans out concurrently to multiple downstream services and aggregates the responses.

```likec4
specification {
  element actor
  element gateway
  element service
  element cache
  element database
}

model {
  user = actor 'User'
  gw = gateway 'API Gateway'
  productSvc = service 'Product Service'
  inventorySvc = service 'Inventory Service'
  pricingSvc = service 'Pricing Service'
  productCache = cache 'Product Cache'
  inventoryDb = database 'Inventory DB'
  pricingDb = database 'Pricing DB'

  user -> gw 'requests product page'
  gw -> productSvc 'calls'
  gw -> inventorySvc 'calls'
  gw -> pricingSvc 'calls'
  productSvc -> productCache 'reads'
  inventorySvc -> inventoryDb 'reads'
  pricingSvc -> pricingDb 'reads'
}

views {
  dynamic view productPageLoad {
    title 'Product Page — Parallel Data Fetch'

    user -> gw 'GET /products/:id'
    parallel {
      gw -> productSvc 'fetch product details'
      gw -> inventorySvc 'check stock levels'
      gw -> pricingSvc 'get current price'
    }
    gw -> user '200 OK — aggregated product response'
  }

  dynamic view productSvcDetail {
    title 'Product Service Internals'

    productSvc -> productCache 'GET product:{id}' {
      notes 'Cache TTL is 5 minutes'
    }
    productCache <- productSvc 'cached product JSON or cache miss'
  }
}
```

---

## Example 3 — Error Handling Flow

A payment attempt showing the happy path, a declined card path, and a network-error fallback.

```likec4
specification {
  element actor
  element webApp
  element service
  element externalSystem

  tag #error
  tag #happy
}

model {
  shopper = actor 'Shopper'
  checkout = webApp 'Checkout UI'
  orderSvc = service 'Order Service'
  paymentGw = externalSystem 'Payment Gateway'
  notifySvc = service 'Notification Service'
  dlq = service 'Dead Letter Queue'

  shopper -> checkout 'uses'
  checkout -> orderSvc 'calls'
  orderSvc -> paymentGw 'charges card'
  orderSvc -> notifySvc 'sends receipt'
  orderSvc -> dlq 'enqueues failed events'
}

views {
  dynamic view paymentHappyPath {
    title 'Payment — Happy Path'

    shopper -> checkout 'clicks Pay Now'
    checkout -> orderSvc 'POST /orders/checkout'
    orderSvc -> paymentGw 'charge $42.00'
    paymentGw -> orderSvc '200 OK — transaction ID'
    orderSvc -> notifySvc 'send order confirmation email'
    checkout <- orderSvc '201 Order Created'
    shopper <- checkout 'order confirmation screen'
  }

  dynamic view paymentDeclined {
    title 'Payment — Card Declined'

    shopper -> checkout 'clicks Pay Now'
    checkout -> orderSvc 'POST /orders/checkout'
    orderSvc -> paymentGw 'charge $42.00'
    paymentGw -> orderSvc '402 Payment Required — card declined' {
      notes 'Order remains in PENDING state — no inventory reserved'
    }
    checkout <- orderSvc '422 Unprocessable — payment declined'
    shopper <- checkout 'shows decline reason + retry prompt'
  }

  dynamic view paymentNetworkError {
    title 'Payment — Gateway Timeout / Network Error'

    shopper -> checkout 'clicks Pay Now'
    checkout -> orderSvc 'POST /orders/checkout'
    orderSvc -> paymentGw 'charge $42.00'
    paymentGw -> orderSvc 'timeout after 30s' {
      notes 'Gateway unreachable — treat as indeterminate outcome'
    }
    orderSvc -> dlq 'enqueue payment-retry event'
    checkout <- orderSvc '503 Service Unavailable — try again later'
    shopper <- checkout 'shows retry screen'
  }
}
```

---

## Example 4 — Multi-Step Saga (Order Fulfillment)

An order fulfillment saga showing the sequence of payment, inventory reservation, and notification steps — with a compensating transaction on failure.

```likec4
specification {
  element actor
  element webApp
  element service
  element database
  element queue
  element externalSystem
}

model {
  customer = actor 'Customer'
  storefront = webApp 'Storefront'
  orderSvc = service 'Order Service'
  paymentSvc = service 'Payment Service'
  inventorySvc = service 'Inventory Service'
  notifySvc = service 'Notification Service'
  orderDb = database 'Order DB'
  inventoryDb = database 'Inventory DB'
  eventBus = queue 'Event Bus'
  emailProvider = externalSystem 'Email Provider (SES)'

  customer -> storefront 'uses'
  storefront -> orderSvc 'submits order'
  orderSvc -> paymentSvc 'requests payment'
  orderSvc -> inventorySvc 'reserves items'
  orderSvc -> notifySvc 'triggers notification'
  orderSvc -> orderDb 'persists order'
  inventorySvc -> inventoryDb 'updates stock'
  orderSvc -> eventBus 'publishes events'
  notifySvc -> emailProvider 'sends email'
}

views {
  dynamic view orderFulfillment {
    title 'Order Fulfillment Saga — Happy Path'

    customer -> storefront 'places order'
    storefront -> orderSvc 'POST /orders'
    orderSvc -> orderDb 'INSERT order (status=PENDING)'
    parallel {
      orderSvc -> paymentSvc 'charge card' {
        navigateTo paymentDetail
      }
      orderSvc -> inventorySvc 'reserve items'
    }
    inventorySvc -> inventoryDb 'UPDATE stock (reserved)'
    paymentSvc -> orderSvc 'payment confirmed'
    orderSvc -> orderDb 'UPDATE order (status=CONFIRMED)'
    orderSvc -> eventBus 'publish OrderConfirmed'
    orderSvc -> notifySvc 'send order receipt'
    notifySvc -> emailProvider 'deliver email'
    storefront <- orderSvc '201 Order Confirmed'
    customer <- storefront 'order confirmation page'
  }

  dynamic view orderFulfillmentCompensation {
    title 'Order Fulfillment Saga — Payment Failure Compensation'

    orderSvc -> paymentSvc 'charge card'
    paymentSvc -> orderSvc 'payment failed'
    orderSvc -> inventorySvc 'release reserved items' {
      notes 'Compensating transaction — reverses the inventory reservation'
    }
    inventorySvc -> inventoryDb 'UPDATE stock (released)'
    orderSvc -> orderDb 'UPDATE order (status=FAILED)'
    orderSvc -> eventBus 'publish OrderFailed'
    orderSvc -> notifySvc 'send failure notification'
    storefront <- orderSvc '422 Order Failed'
    customer <- storefront 'payment declined screen'
  }

  dynamic view paymentDetail {
    title 'Payment Service — Internal Flow'

    orderSvc -> paymentSvc 'charge card'
    paymentSvc -> emailProvider 'tokenize card via Vault'
    emailProvider -> paymentSvc 'payment token'
    paymentSvc -> orderSvc 'charge result'
  }
}
```
