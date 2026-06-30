# What I Learned Designing Layered Cloud Security Controls

## 1. Automated Remediation Should Complement Prevention

One of the main lessons from this project was that automated remediation should not replace preventive controls.

The project used infrastructure scanning to identify insecure Terraform configurations before deployment. It also included an event-driven remediation pattern intended to respond if a risky S3 configuration was introduced into the environment.

These controls address different parts of the risk.

Preventive controls reduce the likelihood that an insecure configuration will be deployed. Corrective controls reduce the amount of time the environment remains in an insecure state when prevention is bypassed or fails.

The architecture lesson is that automated remediation is strongest when it acts as a second layer of protection rather than the first and only control.

## 2. Controls Must Account for Changes Outside the Approved Pipeline

Infrastructure scanning is effective only when changes pass through the pipeline in which the scanning control operates.

Cloud resources can also be changed manually, through another automation process, or through an administrative path that does not use the approved deployment workflow.

A design that relies exclusively on pipeline scanning therefore leaves a potential control gap.

The event-driven portion of this project illustrated the need to detect and respond to risky resource changes regardless of how those changes were introduced.

The architecture lesson is that security controls should protect the environment itself, not only the preferred deployment path.

## 3. Detection Without a Defined Response Leaves Risk Unresolved

Detecting a risky configuration is important, but detection alone does not restore the resource to an approved state.

An alert that requires manual investigation may leave the exposure in place while someone reviews and responds to it. Response times may also vary depending on staffing, alert volume, and operational priorities.

The Lambda remediation pattern in this project demonstrated how a clearly defined and sufficiently low-risk condition can be connected to an automated corrective action.

The architecture lesson is that detective controls should be paired with an appropriate response process. That response may be automated, manual, or approval-based depending on the potential impact of the action.

## 4. Corrective Automation Must Be Observable and Verifiable

Automatically correcting a configuration is valuable, but the remediation process should not operate as a black box.

The control design should make it possible to determine:

* What risky change occurred
* Whether the event was detected
* Whether the remediation function executed
* Whether the resource returned to its intended state

Logs, execution results, alerts, and validation checks can support this verification.

This project demonstrated the importance of including observability in the architecture. A production implementation would still require defined requirements for log retention, evidence ownership, reporting, access control, and audit review.

The architecture lesson is that a corrective control should produce enough information for its operation and outcome to be independently validated.

## 5. Local Validation Reduces Cost but Does Not Replace AWS Validation

LocalStack provided a cost-conscious way to develop and validate the project’s AWS-oriented architecture without maintaining chargeable cloud resources.

It was useful for working through the relationships among Terraform, S3, EventBridge, Lambda, and the remediation logic in a local environment.

However, a local emulator does not prove that every service integration, IAM permission, event format, or runtime behavior will operate identically in AWS.

Before using this pattern in a production environment, the architecture would require controlled testing in an AWS account, including IAM validation, failure testing, logging verification, rollback considerations, and confirmation that the event source reliably invokes the remediation workflow.

The architecture lesson is to use local emulation for efficient development and early validation while clearly identifying the remaining cloud-specific testing requirements.

## 6. Security Automation Should Be Classified by Control Purpose

Another lesson from this project was that security automation should not be treated as one undifferentiated control.

The components served distinct purposes:

* **Preventive controls** identified insecure infrastructure definitions before deployment.
* **Detective controls** identified risky changes or events within the environment.
* **Corrective controls** returned the affected resource to its intended configuration.
* **Administrative controls** documented the control intent, business rationale, expected ownership, operating requirements, and relationships among the technical controls.

Separating these purposes made the architecture easier to explain and evaluate. It also made it clearer where the design depended on technology and where it depended on governance, ownership, and operating procedures.

The broader architecture lesson is that security effectiveness comes from how the controls work together—not simply from the number of tools or automated functions included in the design.
