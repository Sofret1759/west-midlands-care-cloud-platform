# Project 1 — Cloud Foundation, Identity, Governance, and Administrative Control
## Architecture and Design Document

**Organisation:** West Midlands Care and Community Group
**Project owner:** Cloud platform engineer (programme delivery)
**Document version:** 1.0
**Last updated:** [insert today's date]
**Repository:** github.com/Sofret1759

---

## 1. Executive Summary

West Midlands Care and Community Group is a 180-staff United Kingdom care
and community services organisation operating across three offices in the
West Midlands, with a hybrid and remote workforce. Microsoft 365 is
already in use across the organisation. This project established the
foundational Microsoft Azure platform from a zero baseline, with focus
on secure identity, governance, financial discipline, and managed
secrets — preparing the organisation for the secure hosting of business
workloads in subsequent projects.

The platform is designed in line with UK General Data Protection
Regulation and National Health Service Data Security and Protection
Toolkit awareness, recognising the sensitive nature of the service-user
data the organisation handles.

---

## 2. Scope

This document covers the foundation layer established in Lessons 1
through 14. It does not cover network design (Project 2), workload
hosting (Project 3), or DevSecOps and security operations (Project 4),
which are addressed in their own architecture documents.

In-scope capabilities:

- Microsoft Entra ID identity foundation, including user, group, and
  administrative identity separation
- Role-Based Access Control assignment patterns and the principle of
  least privilege
- Resource organisation through tagged resource groups and a documented
  subscription and management group target model
- Governance controls including resource locks and Azure Policy
  enforcement
- Platform standards for naming and tagging
- Cost management with tiered alerts and anomaly detection
- Managed secrets through Azure Key Vault under Role-Based Access
  Control mode
- Conditional Access policies for sign-in protection
- Privileged Identity Management for time-bound administrative access

Out of scope for this project:

- Virtual network design
- Workload hosting (virtual machines, App Service, containers)
- Backup, disaster recovery, and resilience
- Centralised monitoring, security information and event management,
  and threat detection
- Infrastructure as Code deployment (Bicep, Terraform)
- AI workload security and governance

---

## 3. Identity Foundation

[Pull and consolidate from docs/identity-design.md]

The identity model distinguishes between three categories of user:

- Standard employee users — daily collaboration and business application
  access
- Information Technology support users — elevated operational needs
  without permanent privileged administrator access for daily work
- Privileged administrator users — separate identities for administrative
  tasks, deliberately distinct from daily-use accounts

Access design principles applied throughout:

- Group-based access assignment is preferred over direct user assignment
- Least privilege is the default; elevated permissions are exceptional
  and time-bound through Privileged Identity Management
- Normal user identities and privileged administrator identities are
  separated

Department groups currently defined include the Finance Team, Human
Resources Team, and Information Technology Support Team. Access groups
such as Payroll Application Users exist alongside department groups,
providing flexibility for application-specific access patterns.

---

## 4. Access Control

[Pull and consolidate from docs/access-control-design.md]

The platform uses Role-Based Access Control as its sole access mechanism
for Azure resources. The first applied pattern was the assignment of
the Reader role to the Information Technology Support Team group at
resource group scope, demonstrating both least privilege and group-based
assignment.

Scope hierarchy is applied deliberately: management group, subscription,
resource group, individual resource. The default scope of any
assignment is the narrowest that satisfies the requirement.

---

## 5. Subscription and Management Group Structure

[Pull and consolidate from docs/subscription-and-management-structure.md]

### Current State

The lab uses a single Pay-As-You-Go subscription, suitable for
controlled learning. This is not the preferred long-term platform
design for a growing organisation.

### Target State

The target Azure structure includes:

- Platform subscription — shared platform services
- Production subscription — live business workloads
- Non-production subscription — development and staging environments
- Sandbox subscription — experimentation and learning

A management group hierarchy unifies these subscriptions under common
governance:

- Root management group
  - Platform
  - Production
  - Non-production
  - Sandbox

This design improves governance, policy inheritance, access control
separation, operational clarity, cost visibility, and environment
separation.

---

## 6. Governance

[Pull and consolidate from docs/governance-controls.md and
docs/platform-standards.md]

### Resource Organisation

Resource groups are the primary organising container, used to scope
governance, access, and cost ownership.

### Naming Standard

Pattern for resource groups: `rg-<environment>-<purpose>`

Examples in current use:
- `rg-dev-payroll-app`
- `rg-prod-monitoring`
- `rg-sbx-lab-network` (target)

Names hold stable, essential information unlikely to change. Variable
business metadata lives in tags.

### Tagging Standard

Required tags on important resource groups:

- Environment (Development, Production, Non-production, Sandbox)
- Owner (responsible team)
- Department (business unit)
- Project (initiative or workload name)

Tags support cost allocation, governance filtering, ownership
visibility, and operational automation.

### Governance Controls

- Resource locks (delete-protection) applied to critical resource
  groups such as `rg-prod-monitoring`
- Azure Policy assignments enforce or audit tag presence
- Policy assignment scopes reflect the management hierarchy where
  available

---

## 7. Cost Management

[Pull and consolidate from docs/cost-management-foundations.md]

### Budget Configuration

A primary subscription-level budget is configured:

- Name: `budget-subscription-monthly-10gbp`
- Amount: £10 (lab tolerance)
- Period: Monthly

### Alert Thresholds

| Type | Threshold | Action |
|---|---|---|
| Actual | 20% (£2) | Investigate unexpected activity |
| Actual | 50% (£5) | Act now to prevent overrun |
| Actual | 80% (£8) | Tear down non-essential resources |
| Forecasted | 100% (£10) | Review spend velocity |

### Cost Anomaly Detection

A subscription-level anomaly detection rule complements the budget
thresholds. Unusual spend is treated as both a financial signal and
a behavioural security signal, recognising that subscription
compromise often produces spend anomalies before other indicators
fire.

### Cost Allocation

Tag-based cost analysis enables breakdown by Environment, Owner,
Department, and Project. This is the operational payoff of the
tagging discipline established in Section 6.

---

## 8. Managed Secrets

[Pull and consolidate from docs/key-vault-and-secrets-management.md]

### Vault Configuration

Initial vault: `kv-wmcc-dev-elbafag`
- Region: UK South
- Pricing tier: Standard
- Permission model: Azure Role-Based Access Control
- Soft-delete retention: 7 days (lab)
- Purge protection: Disabled (lab); production would be enabled
- Network access: Public (lab); production would use private endpoint

### Secret Naming Convention

Pattern: `<application>-<resource>-<credential-type>-<environment>`

Examples:
- `payroll-db-password-dev`
- `hr-api-key-dev`

### Access Model

Role-Based Access Control is used exclusively. Access policies (the
legacy model) are not configured.

Standard role assignments:

- Cloud Team: Key Vault Secrets Officer (full secrets management)
- Application identities: Key Vault Secrets User (read only)
- Auditors: Key Vault Reader (metadata only, no secret access)

### Lessons Learned

The lesson execution notes captured several real-world Azure friction
points, retained here for institutional memory:

1. `--enable-purge-protection false` should never be set explicitly;
   omit the flag and Azure defaults correctly.
2. Role-Based Access Control propagation takes 30 to 60 seconds; secret
   operations after assignment require a brief delay.
3. Control plane and data plane permissions on Key Vault are separate.
4. Resource group region is independent of resource region.
5. The Azure Command-Line Interface can drift after region changes;
   always specify `--resource-group` explicitly.

---

## 9. Sign-in Protection — Conditional Access

[Pull and consolidate from docs/conditional-access.md]

Three Conditional Access policies are deployed in report-only mode:

1. `wmcc-require-mfa-all-users-reportonly` — requires multi-factor
   authentication on all sign-ins
2. `wmcc-block-legacy-authentication-reportonly` — blocks legacy
   authentication protocols
3. `wmcc-require-mfa-azure-management-reportonly` — requires
   multi-factor authentication for Azure Portal and management plane
   access

All policies remain in report-only mode in the lab. Production
deployment would follow a deploy-monitor-enforce pattern: report-only
for 1-2 weeks, review sign-in logs for unintended impact, then flip
to enforced.

---

## 10. Privileged Access — Privileged Identity Management

[Pull and consolidate from docs/privileged-identity-management.md]

Privileged Identity Management converts standing administrative role
assignments into eligible assignments. An eligible administrator does
not hold the role most of the time; they activate it on demand, for a
limited time window, with multi-factor authentication and approval.

Current configuration:

- Role: User Administrator (PIM-managed)
- Activation maximum duration: 4 hours
- Multi-factor authentication required on activation
- Justification required on activation
- Approval required (single approver in lab; production would require
  separation of duties)

The User Administrator role is held as eligible by the cloud platform
engineer. Activation produces a permanent audit record viewable in
PIM's audit history.

### Break-Glass Accounts

Production tenants require two break-glass accounts: permanently
active Global Administrators, excluded from all Conditional Access
policies, with credentials stored offline. These are documented as a
deliberate next step for the security operations layer.

---

## 11. Region Policy

[Pull and consolidate from docs/region-policy.md]

Default region: UK South. Disaster recovery region: UK West.

### Current Drift

The following resources do not currently match the UK South default
and are scheduled for migration once Infrastructure as Code is
introduced:

- `rg-lesson7-access-lab` — UK West
- `rg-prod-monitoring` — UK West
- `rg-dev-payroll-app` — UK West (the Key Vault inside is UK South)
- `rg-wmccg-management-ukw-001` — East US (contains the global cost
  Action Group)

---

## 12. Operating Discipline

The platform is delivered under a strict discipline:

**Build → Learn → Validate → Document → Commit → Destroy → Rebuild**

Chargeable resources are not left running between lessons. Important
state is reproducible from code, not dependent on memory or Portal
clicks. Scripts to rebuild and destroy each lesson's resources are
maintained in `scripts/` and are tested where possible.

Cost discipline holds the monthly subscription spend under £15
during the lab phase.

---

## 13. Pending Items (Honest Backlog)

Items deferred to later projects or requiring catch-up:

| Item | Status | Resolution Plan |
|---|---|---|
| Region drift (4 resource groups) | Open | Migrate to UK South in dedicated lesson after Bicep introduction |
| Diagnostic logging on Key Vault | Open | Configure in Project 4 (DevSecOps and Monitoring) |
| Conditional Access policies in report-only | Open | Enforce after Project 4 monitoring is in place |
| Break-glass accounts | Open | Build during PIM hardening in Project 4 |
| Infrastructure as Code | Open | Bicep introduced in late Project 1 / early Project 2 |
| Multi-subscription structure | Open | Out of scope for lab; documented as target |
| Sample user lifecycle management | Open | Test users remain; not subject to access review |

---

## 14. Capabilities Now Available

With Project 1 complete, the platform supports:

- Identity provisioning under a documented user and group model
- Role-Based Access Control assignment at appropriate scopes
- Tag-based cost allocation and ownership tracking
- Governance through naming, tagging, and policy
- Cost monitoring with tiered alerts and anomaly detection
- Managed secret storage with Role-Based Access Control protection
- Sign-in evaluation through Conditional Access (currently in
  report-only mode)
- Time-bound administrative access through Privileged Identity
  Management

The foundation is ready to support the deployment of network and
workload resources, which is the work of Projects 2 and 3.

---

## 15. Prerequisites for Project 2

Before Project 2 (Secure Network and Workforce Access Platform)
begins, the following should be in place:

- All Project 1 documentation files committed to the repository
- Region drift addressed or formally accepted as deferred
- This architecture document reviewed end-to-end
- Confidence in the identity foundation, as networking decisions
  depend on it

If any of the above is unresolved, address it before starting
Lesson 16.

---

## 16. Reference Documents

This document consolidates the following design records:

- `docs/identity-design.md`
- `docs/access-control-design.md`
- `docs/governance-controls.md`
- `docs/subscription-and-management-structure.md`
- `docs/platform-standards.md`
- `docs/cost-management-foundations.md`
- `docs/key-vault-and-secrets-management.md`
- `docs/conditional-access.md`
- `docs/privileged-identity-management.md`
- `docs/region-policy.md`

Scripts and reproducible artefacts are in `scripts/`. The full Git
history of this project is the ultimate reference for any decision
not captured in the documents above.