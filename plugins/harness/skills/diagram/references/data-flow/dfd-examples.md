# DFD Examples

## Example 1: Context-Level DFD (Level 0)

The system is a single process node. Show all external entities and the major data flows crossing the system boundary. No internal detail.

```mermaid
flowchart LR
    customer[Customer]:::entity
    bank[Payment Gateway]:::entity
    warehouse[Warehouse System]:::entity

    subgraph boundary["Order Management System"]
        oms(Order Management\nSystem):::process
    end

    customer -->|place order| oms
    oms -->|order confirmation| customer
    oms -->|payment request| bank
    bank -->|payment result| oms
    oms -->|fulfillment request| warehouse
    warehouse -->|shipment status| oms

    classDef entity fill:#dae8fc,stroke:#6c8ebf,color:#000
    classDef process fill:#d5e8d4,stroke:#82b366,color:#000
```

**When to stop at Level 0:** When the audience needs only the system boundary and external actors — useful for scope discussions, threat modeling (STRIDE trust boundary identification), or executive communication.

---

## Example 2: Detailed DFD (Level 1)

Decompose the single context process into sub-processes. Every data flow from Level 0 must enter or leave the boundary. Data stores appear here.

```mermaid
flowchart LR
    customer[Customer]:::entity
    bank[Payment Gateway]:::entity
    warehouse[Warehouse System]:::entity

    subgraph boundary["Order Management System"]
        validate(1. Validate\nOrder):::process
        charge(2. Process\nPayment):::process
        fulfill(3. Create\nFulfillment):::process

        orders[(Orders DB)]:::store
        payments[(Payments DB)]:::store
    end

    customer -->|order request| validate
    validate -->|valid order| charge
    validate -->|reject notice| customer
    charge -->|payment request| bank
    bank -->|payment result| charge
    charge -->|confirmed order| fulfill
    charge -->|payment record| payments
    fulfill -->|fulfillment request| warehouse
    fulfill -->|order record| orders
    warehouse -->|shipment status| fulfill
    fulfill -->|order confirmation| customer

    classDef entity fill:#dae8fc,stroke:#6c8ebf,color:#000
    classDef process fill:#d5e8d4,stroke:#82b366,color:#000
    classDef store fill:#fff2cc,stroke:#d6b656,color:#000
```

---

## Example 3: Styled DFD with classDef

Full styling to distinguish element types at a glance. This example models a user authentication flow.

```mermaid
flowchart TD
    user[User]:::entity
    ldap[LDAP Directory]:::entity
    audit[Audit System]:::entity

    subgraph boundary["Auth Service"]
        login(1. Receive\nCredentials):::process
        verify(2. Verify\nIdentity):::process
        issue(3. Issue Token):::process

        sessions[(Session Store)]:::store
        tokens[(Token Store)]:::store
    end

    user -->|username + password| login
    login -->|credentials| verify
    verify -->|lookup request| ldap
    ldap -->|user record| verify
    verify -->|verified identity| issue
    verify -->|auth failure| user
    issue -->|write session| sessions
    issue -->|write token| tokens
    issue -->|JWT token| user
    verify -->|auth event| audit

    classDef entity fill:#dae8fc,stroke:#6c8ebf,stroke-width:2px,color:#000
    classDef process fill:#d5e8d4,stroke:#82b366,stroke-width:2px,color:#000
    classDef store fill:#fff2cc,stroke:#d6b656,stroke-width:2px,color:#000
```

---

## Example 4: Multi-Boundary DFD

When a system integrates with a partner system that also has internal structure worth showing, use nested or adjacent subgraphs.

```mermaid
flowchart LR
    customer[Customer]:::entity

    subgraph ours["Our System"]
        api(API Gateway):::process
        svc(Order Service):::process
        db[(Order DB)]:::store
    end

    subgraph partner["Partner Fulfillment"]
        recv(Receive Order):::process
        pick(Pick & Pack):::process
    end

    customer -->|HTTP request| api
    api -->|parsed request| svc
    svc -->|write| db
    svc -->|fulfillment event| recv
    recv -->|work order| pick
    pick -->|shipment notification| svc
    svc -->|response| api
    api -->|HTTP response| customer

    classDef entity fill:#dae8fc,stroke:#6c8ebf,color:#000
    classDef process fill:#d5e8d4,stroke:#82b366,color:#000
    classDef store fill:#fff2cc,stroke:#d6b656,color:#000
```
