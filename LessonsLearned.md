# Lessons Learned

## 1. Automated Remediation Should Complement Prevention

Automated remediation is valuable because it reduces the time a risky configuration remains active. However, remediation should not replace preventive controls.

In this project, infrastructure scanning was used to identify insecure configurations before deployment, while event-driven remediation addressed changes that still reached the environment. This layered approach is stronger than relying on either control independently.

The architecture lesson is that prevention should reduce the likelihood of exposure, while remediation should reduce the duration and impact of exposure when prevention fails.

## 2. Controls Must Account for Changes Outside the Approved Pipeline

Preventive scanning is most effective when infrastructure changes follow the approved deployment process. However, cloud environments may also be modified manually, through alternate automation, or through administrative access.

A control design that relies only on pipeline scanning assumes every change will follow the intended path. The project therefore included detective and corrective capabilities that could respond to risky changes regardless of how they were introduced.

The architecture should protect the environment, not only the deployment pipeline.

## 3. Detection Without Correction Leaves Risk Unresolved

Detective controls provide visibility, but an alert alone does not remove the insecure condition.

If a public S3 configuration is detected but no corrective action occurs, the exposure remains until someone investigates and responds. Manual response can also introduce delays, inconsistent handling, and operational dependency.

Automated correction helps shorten the exposure window and creates a more predictable response. Detection should therefore be connected to a defined remediation process rather than treated as the final control outcome.

## 4. Correction Without Evidence Creates a Governance Gap

A control may successfully correct a configuration but still fail to provide sufficient evidence that the event occurred, the remediation executed, and the environment returned to an approved state.

Architecture must include observability and evidence requirements alongside technical remediation. Logs, alerts, execution records, and validation results support auditability and allow stakeholders to verify that the control operated as intended.

A control is not fully operationalized until its effectiveness can be demonstrated.

## 5. LocalStack Supports Cost-Efficient Validation but Does Not Replace AWS Testing

LocalStack provided a useful environment for validating the project architecture without creating unnecessary cloud resources or ongoing costs.

It supported development of the event flow, remediation logic, infrastructure definitions, and control relationships. This made it possible to test the overall design locally before considering deployment into AWS.

However, local emulation does not guarantee identical behavior across every AWS service, permission model, event format, or integration. A production implementation would still require controlled validation in an AWS environment before release.

The lesson is to use local testing for fast and cost-efficient architecture validation while clearly documenting where cloud-specific verification remains necessary.

## 6. Security Automation Should Be Classified by Control Purpose

Security automation is often described as a single capability, but the components of this project served different control objectives.

* Preventive controls attempted to stop insecure configurations before deployment.
* Detective controls identified risky changes that occurred in the environment.
* Corrective controls restored the resource to an approved state.
* Administrative controls documented expectations, ownership, evidence, and governance requirements.

Separating the architecture into these control categories made the design easier to explain, evaluate, and map to security frameworks.

The broader lesson is that effective security architecture is not defined by the number of tools deployed. It is defined by how the controls work together to prevent risk, identify failure, restore the environment, and prove the outcome.
