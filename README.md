# Business-Driven Cloud Security Controls

## Project Overview

Cloud security controls are most useful when they begin with a clear business and security requirement rather than with a specific cloud service.

This project explores a simple requirement:

> **Cloud storage should not become publicly accessible through an unintended configuration change.**

The project uses Amazon S3 as the implementation example and demonstrates how that requirement can be translated into multiple layers of security control.

The architecture separates controls into:

- **Preventive** – reduce the likelihood of public exposure
- **Detective** – identify risky configuration changes
- **Corrective** – restore an approved configuration when an appropriate condition is detected
- **Administrative** – define control intent, ownership, evidence, exceptions, and operating expectations

The broader objective is not simply to secure one S3 bucket. It is to demonstrate how a Security Architect can translate business risk into a layered cloud-control strategy.

---

## Business Problem

Cloud platforms allow teams to deploy and modify resources quickly.

That flexibility also creates the possibility that a resource can be changed in a way that violates the organization's security requirements.

For cloud storage, unintended public access can expose sensitive or business-critical information.

A security architecture therefore needs to answer more than:

> "Can we detect public access?"

It should also consider:

- Can the risky configuration be prevented?
- Can changes outside the approved deployment process still be detected?
- Can a safe condition be corrected automatically?
- How do we know the corrective control actually worked?
- What happens if the control fails?
- When should remediation require human approval instead?
- Who owns an exception or accepts the remaining risk?

---

## Architecture Approach

The project uses layered controls rather than relying on a single security mechanism.

### Prevent

Terraform defines S3 account-level Public Access Block settings intended to reduce the ability to introduce public access.

The control includes settings for blocking or ignoring public ACLs and restricting public bucket policies.

### Detect

An EventBridge rule is defined to observe CloudTrail events associated with:

- `PutBucketAcl`
- `PutBucketPolicy`

This demonstrates monitoring for changes that could affect the storage security posture.

### Correct

A Python Lambda function implements automated remediation for risky **S3 ACL grants**.

The function:

1. Identifies the affected bucket from the event.
2. Retrieves the bucket ACL.
3. Identifies grants associated with `AllUsers` or `AuthenticatedUsers`.
4. Removes those grants.
5. Writes the corrected ACL back to the bucket.
6. Returns information about the remediation performed.

The current function does **not** implement bucket-policy remediation.

### Govern

The technical controls represent only part of the architecture.

A production control would also require decisions about:

- Control ownership
- Logging and evidence
- Alerting
- Exception management
- Remediation authority
- Failure handling
- Testing
- Change management
- Residual-risk acceptance

---

## Control Flow

The architecture demonstrates the following security pattern:

**Business Requirement**

↓

**Preventive Guardrail**

↓

**Configuration Change**

↓

**Detection**

↓

**Corrective Action**

↓

**Validation**

↓

**Evidence / Governance**

This creates defense in depth.

Prevention reduces the likelihood of an unsafe configuration.

Detection provides visibility when a relevant change occurs.

Corrective automation can reduce the time that a known and sufficiently safe condition remains unresolved.

Governance determines when those controls are appropriate and who owns the remaining risk.

---

## Why Multiple Controls?

A preventive control can fail, be bypassed, be disabled, or apply only to a particular deployment path.

A detective control can identify a problem without fixing it.

A corrective control can fail or potentially create unintended consequences if its authority is too broad.

For that reason, the architecture does not treat any single control as sufficient.

The security objective is achieved through the relationship among the controls.

---

## Implementation

This repository includes working examples for portions of the architecture.

### Terraform

The AWS Terraform configuration defines:

- S3 account-level Public Access Block
- EventBridge rule for relevant S3 API changes
- EventBridge target
- Lambda invocation permission
- Lambda execution role and policy
- Lambda deployment package and function

Resource creation is controlled by the `enable_apply` variable so the environment can remain disabled by default.

### Python Remediation

`functions/s3_public_acl_remediator.py`

The function removes ACL grants associated with the AWS global `AllUsers` and `AuthenticatedUsers` groups.

### Unit Test

`tests/test_remediator.py`

The test uses mocked AWS services to:

1. Create an S3 bucket.
2. Apply a public-read ACL.
3. Invoke the remediation handler.
4. Retrieve the resulting ACL.
5. Verify that risky public grants have been removed.

This validates the remediation logic without claiming that the complete production AWS event path has been proven.

---

## Security Boundaries

### What Is Being Protected?

S3 storage from unintended public exposure through ACL configuration.

### What Is the Risk?

An authorized or automated change could introduce public access that violates the organization's security requirement.

### Where Can Prevention Fail?

Changes may occur outside an approved deployment pipeline, preventive controls may be altered, or future configurations may introduce paths not covered by the original control.

### What Happens When Prevention Fails?

The architecture introduces detection and corrective layers rather than assuming prevention will always succeed.

### What Happens if Remediation Fails?

The exposure may remain unresolved.

A production design therefore requires monitoring of the remediation process itself, alerting on failure, defined escalation, and ownership of unresolved conditions.

---

## Automated Remediation Is a Risk Decision

Not every security finding should be automatically corrected.

Automated remediation is most appropriate when:

- The unsafe state is clearly defined.
- The corrective action is deterministic.
- The probability of disrupting legitimate business activity is understood.
- The remediation can be logged and verified.
- Failure can be detected.
- Ownership and escalation are defined.

Higher-impact or ambiguous conditions may require approval or manual investigation instead.

The decision to automate remediation is therefore an architecture and risk decision, not simply a technical capability.

---

## Identity and Least Privilege

The remediation function requires permission to inspect and modify S3 ACLs.

The current Terraform policy uses:

`arn:aws:s3:::*`

for the S3 permissions used by the remediation role.

This is acceptable for exploring the control pattern but would require tighter scoping in a production implementation.

Production authorization could be constrained through mechanisms such as:

- Approved account boundaries
- Resource naming or tagging
- Organizational structure
- Separate remediation roles
- Explicit resource scope
- Additional policy conditions

Corrective automation should receive only the authority required to perform its defined function.

---

## Control Failure and Assurance

A security control should not only exist. Its effectiveness should be verifiable.

For this architecture, useful validation questions include:

- Is the preventive control enabled?
- Are relevant configuration changes being recorded?
- Is the detection mechanism receiving the expected events?
- Did the remediation function execute?
- Did the resource return to its intended state?
- Was the outcome recorded?
- Did anyone receive notification if remediation failed?

This creates a second-order security requirement:

> **Monitor the security controls themselves.**

---

## Exception Governance

There may be legitimate business cases where public access or another deviation from the standard is required.

A production architecture should not force those cases into undocumented workarounds.

A governed exception should identify:

- The security requirement being waived
- Business justification
- Scope
- Compensating controls
- Risk owner
- Security review
- Approval
- Expiration or reassessment date

This allows security requirements to remain consistent while legitimate business exceptions are explicitly governed.

---

## Local Validation vs. Production Validation

Local testing and mocked AWS services are useful for validating logic and developing the control pattern without maintaining unnecessary cloud resources.

They do not prove that every AWS service integration will behave identically in a production environment.

Before production adoption, the architecture would require controlled AWS validation of areas such as:

- Event delivery
- IAM permissions
- Lambda invocation
- Failure behavior
- Logging
- Alerting
- Rollback
- Scale
- Operational ownership

The project intentionally distinguishes architectural validation from production readiness.

---

## Architecture Takeaway

The primary lesson from this project is not that Lambda can modify an S3 ACL.

It is that a business security requirement can be translated into a layered control architecture:

**Requirement → Prevent → Detect → Correct → Verify → Govern**

Each layer addresses a different failure condition.

A Security Architect must determine how those controls work together, where they can fail, what should happen when they do, and who owns the remaining risk.
