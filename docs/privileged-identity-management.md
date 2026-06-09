# Privileged Identity Management

## Objective

Implement just-in-time administrative access for Microsoft Entra ID
directory roles, replacing standing administrator assignments with
time-bounded, audited, approval-gated activations.

## Scope

Initial Privileged Identity Management configuration on the User
Administrator role, establishing the patterns to be extended to all
PIM-eligible directory roles in subsequent project phases.

## Activation Policy — User Administrator

| Setting | Value |
|---|---|
| Activation maximum duration | 4 hours |
| Multi-factor authentication on activation | Required |
| Justification on activation | Required |
| Ticket information on activation | Not required (lab; production would integrate with ticketing) |
| Approval required | Yes |
| Approver | Self (lab; production would be a different administrator) |

## Eligible Assignment

The cloud platform engineer (current account) holds a permanent eligible
assignment for User Administrator. The role is not actively held;
activation must be requested and approved per the policy above.

## Activation Flow

1. Eligible user opens Privileged Identity Management in the Portal.
2. Selects the role under "My roles" and clicks Activate.
3. Provides duration, justification, and multi-factor authentication.
4. Request enters the approval queue.
5. Approver reviews justification and approves or denies.
6. On approval, role becomes active for the chosen duration.
7. On duration expiry, role automatically deactivates.
8. Every step is logged in the PIM audit history.

## Audit History

Every activation, approval, and deactivation is logged in the PIM audit
history for the role. The audit history is the primary evidence source
for compliance reviews requiring proof of controlled privileged access
(United Kingdom General Data Protection Regulation, National Health
Service Data Security and Protection Toolkit).

## Lab vs Production Deltas

| Item | Lab State | Production State |
|---|---|---|
| Approver | Self | Different administrator |
| Roles under PIM management | One (User Administrator) | All directory roles granting meaningful capability |
| Break-glass accounts | Not built | Two permanently active Global Administrator accounts, excluded from all Conditional Access policies, monitored continuously |
| Access reviews | Not configured | Quarterly access reviews on every eligible role |
| Activation justifications | Free-text | Structured, referencing ticket numbers from change or incident management systems |
| Integration with security information and event management | Not configured | Activation events forwarded to Microsoft Sentinel or equivalent, with alerts on unusual patterns (e.g. activation outside normal hours) |

## Target State

In the mature platform:

- Every directory role granting meaningful capability is PIM-managed
  (Global Administrator, Privileged Role Administrator, User
  Administrator, Application Administrator, Security Administrator,
  and others)
- Activation durations tuned per role tier (shorter for higher
  privilege)
- Approval workflows route to appropriate approvers per role
- Break-glass accounts in place with continuous monitoring
- Quarterly access reviews automated
- Activation events forwarded to centralised security monitoring

## Security Dimension

Privileged Identity Management defends against three primary failure
modes:

1. Credential theft on administrator accounts — the role is dormant
   at the moment of compromise, and activation triggers alerts and
   approval requirements.
2. Insider misuse — every privileged action is bracketed by a request,
   justification, approval, and audit record, making after-the-fact
   investigation feasible.
3. Compliance evidence gap — the audit history is the direct evidence
   required by UK regulators, ready to download.

## Break-Glass Accounts (Not Built — Documented for Future)

Production tenants require two break-glass accounts. The pattern:

- Permanently assigned Global Administrator (not PIM-managed)
- Excluded from every Conditional Access policy
- Credentials stored offline in a secure physical location
- Long, complex passwords (30+ character random strings)
- Used only in genuine emergencies
- Every sign-in attempt monitored as a high-severity alert

These will be built during the security operations hardening in
Project 4.

## Lesson Notes

Configured on User Administrator as the demonstration role rather than
Global Administrator, because misconfiguration of Global Administrator
during a lab session could produce a tenant-level lockout. The
mechanics are identical regardless of which role is PIM-managed; the
choice of User Administrator is purely a risk-management decision for
the lab.

Self-approval is artificial. In a single-user lab, the four-eyes
principle cannot be exercised. The lab demonstrates the *mechanic*; a
real implementation requires distinct approvers per role.