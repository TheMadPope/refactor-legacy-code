# Naming Conventions
Your preferences matter, please feel free to update for your org - just have and follow a convention!
This is helpful for humans AND robots!

## Object and Field Names

- **Remove spaces** — name things like Salesforce does!

**Field Example:**

| Label            | API Name          |
|------------------|-------------------|
| My Custom Field  | MyCustomField__c  |

**Object Example:**

| Label              | API Name            |
|--------------------|---------------------|
| My Custom Object   | MyCustomObject__c   |

---

## Variable Naming Guidelines

- **Do not include the variable type** in the name (that’s redundant).
- **Use camelCase** (start with lowercase, capitalize new words, no underscores).
- **Keep names brief** where possible, but use longer names if needed for clarity.
- **Avoid uncommon abbreviations.**

**Bad Examples:**

```
intLoopCounter
mapAccounts
boolShouldProcess
acctNew
dncRecords
```

**Better Examples:**

```
loopCounter
accountsById
shouldProcess
accountsWithContactsInSpecialStatus
doNotContact
```

### Maps

- Use the pattern: `valueByKey`

**Examples:**

```
accountById
contactByAccountId
internalStatusByExternalStatus
```

---

## Flows

- Use: `ObjectName_Action` (like Service Methods, but with object name at the front)

**Examples:**

```
Case_AssignOwner
Invoice_SubmitForApproval
ObjectName_ThingYouAreDoing
```
- Use: `FlowLib_` prefix for reusable subflows

---

## Classes

Class types generally include:

- `TriggerHandler` (e.g., `CaseTriggerHandler`, `InvoiceTriggerHandler`)
- `Service` (e.g., `CaseService`, `InvoiceService`)
- `Selector` (e.g., `CaseSelector`, `InvoiceSelector`)

- **Class names:** Use PascalCase
- **Method names:** Use camelCase
- **Return object type should NOT appear in the method name** (the signature defines this)