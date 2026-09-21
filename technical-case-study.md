# Technical Case Study – Business-Driven Cloud Security Controls

## Architecture Problem

The security requirement for this project is straightforward:

> Cloud storage should not become publicly accessible through an unintended configuration change.

The architectural challenge is that no single control completely satisfies that requirement.

A preventive control can be disabled, bypassed, or changed. Detection can identify an unsafe state without correcting it. Automated remediation can reduce exposure time, but it introduces privileged access and the possibility of unintended changes.

The architecture therefore treats security as a control system rather than as a single configuration.

---

## Security Objective

The objective is to reduce the likelihood and duration of unintended public exposure while maintaining visibility, accountability, and control over corrective actions.

The architecture follows:

**Requirement → Prevent → Detect → Correct → Verify → Govern**

Each stage addresses a different security question:

- Can the unsafe state be prevented?
- Can relevant changes still be detected?
- Can a clearly defined unsafe state be corrected?
- Can the correction be verified?
- What happens if any control fails?
- Who owns exceptions and residual risk?

---

## Threat and Failure Scenarios

The design considers more than a malicious external actor.

Relevant scenarios include:

- An administrator unintentionally changes an access configuration.
- Automation applies an incorrect configuration.
- A change occurs outside the expected deployment process.
- A preventive guardrail is modified or disabled.
- A relevant configuration change occurs but detection fails.
- The remediation function is invoked but cannot correct the resource.
- The remediation identity receives more authority than necessary.
- A legitimate business requirement conflicts with the standard control.

This changes the architecture discussion from simply preventing an attack to managing security-relevant failure conditions.

---

## Preventive Control

S3 account-level Public Access Block is used as the preventive layer.

Its purpose is to reduce the ability to introduce public access through ACLs or bucket policies.

Prevention is preferred because stopping an unsafe state before it exists generally creates less exposure than detecting and correcting it afterward.

However, the architecture does not assume that the preventive control will always remain effective.

That assumption drives the need for independent detection and response.

---

## Detective Control

EventBridge is configured to observe CloudTrail events associated with changes to S3 ACLs and bucket policies.

The detective layer provides visibility into security-relevant changes even when the organization expects preventive controls to block unsafe configurations.

This distinction is important:

> A preventive control defines what should be allowed. A detective control provides evidence about what actually occurred.

The current implementation detects both ACL and bucket-policy changes, while automated remediation is limited to ACL grants.

Detection scope and remediation scope therefore remain intentionally distinct.

---

## Corrective Control

The Python remediation function removes ACL grants associated with the AWS global `AllUsers` and `AuthenticatedUsers` groups.

The corrective action is deliberately narrow:

1. Identify the affected bucket.
2. Retrieve its ACL.
3. Identify risky public grants.
4. Remove those grants.
5. Write the corrected ACL.
6. Report the remediation result.

The function does not implement bucket-policy remediation.

Keeping the corrective action narrowly defined makes its behavior easier to understand, test, and govern.

---

## Automated Remediation Decision

Automated remediation is not automatically appropriate simply because automation is technically possible.

Before allowing a security control to modify production resources, an architecture review should consider:

- Is the unsafe condition unambiguous?
- Is the corrective action deterministic?
- Could remediation disrupt legitimate business activity?
- Can execution and results be recorded?
- Can failure be detected?
- Can the resulting state be independently verified?
- Is escalation defined?
- Is rollback required?

For ambiguous or high-impact conditions, detection followed by human approval may be safer than immediate remediation.

Automation therefore represents a risk decision as well as a technical design decision.

---

## Privileged Remediation Boundary

The remediation function represents an important trust boundary because it has authority to modify cloud resources.

That makes the security control itself a potential source of risk.

The implementation grants the function only the S3 actions required for its current ACL remediation behavior:

- `s3:GetBucketAcl`
- `s3:PutBucketAcl`

The demonstration currently permits those actions across S3 buckets in scope through:

`arn:aws:s3:::*`

A production implementation would require a decision about how that authority should be constrained.

Possible approaches include:

- Explicit resource scope
- Account boundaries
- Resource tags
- Naming conventions
- Separate remediation roles
- Additional IAM conditions

The design principle is:

> Corrective controls should have enough authority to restore an approved state, but no more authority than their defined function requires.

---

## Control Failure

The architecture assumes that security controls can fail.

Examples include:

- Public Access Block is disabled.
- Expected events are not delivered.
- EventBridge configuration changes.
- Lambda invocation fails.
- IAM permissions prevent remediation.
- The function executes but does not restore the intended state.
- Logging or alerting fails.

A production architecture therefore needs assurance mechanisms for the controls themselves.

It is not sufficient to ask:

> Is the security control deployed?

The stronger question is:

> Can we demonstrate that the security control is operating effectively?

---

## Verification and Assurance

The repository includes a mocked unit test that verifies the ACL-remediation logic.

The test demonstrates that a public ACL grant can be identified and removed by the function.

It does not validate the complete AWS service path.

Production assurance would additionally require validation of:

- CloudTrail event generation
- EventBridge delivery
- Lambda invocation
- IAM authorization
- Remediation outcome
- Logging
- Alerting
- Failure escalation
- Control-health monitoring

This separates code-level validation from operational security assurance.

---

## Exception Governance

A standard prohibiting public storage access may still have legitimate exceptions.

An exception should not be implemented by silently disabling the security control.

A governed exception should define:

- Business justification
- Scope
- Risk being accepted
- Compensating controls
- Risk owner
- Security review
- Approval
- Expiration or reassessment date

This allows the security requirement to remain consistent while accommodating legitimate business needs through an explicit risk decision.

---

## Residual Risk

Even with preventive, detective, and corrective controls, residual risk remains.

Examples include:

- A failure affecting multiple control layers
- Configuration paths not covered by the current design
- Excessive remediation permissions
- Delayed or failed detection
- Incorrect exception handling
- Operational failure of monitoring or escalation

The architecture does not claim to eliminate these risks.

Instead, it makes them visible so ownership, monitoring, compensating controls, and risk acceptance can be determined.

---

## Production Architecture Considerations

Before production adoption, an Architecture Review Board should evaluate:

- Scope of the security requirement
- Resource and account boundaries
- IAM scope for remediation
- Event reliability
- Failure handling
- Alerting and escalation
- Evidence retention
- Exception governance
- Rollback requirements
- Testing strategy
- Operational ownership
- Residual-risk ownership

These decisions determine whether the control pattern is appropriate for the organization's environment and risk tolerance.

---

## Architecture Outcome

The project demonstrates that securing a cloud resource is not simply a matter of enabling a cloud security feature.

The architecture connects a business requirement to multiple security mechanisms and then considers how those mechanisms can fail.

The resulting pattern is:

**Requirement → Prevent → Detect → Correct → Verify → Govern**

The key architectural decision is not which AWS service to use.

It is how preventive, detective, corrective, and governance controls work together to reduce risk while preserving accountability for exceptions, failures, and residual risk.
