# Key Vault and Secrets Management

## Objective

Establish a managed secrets store as the foundation for all secure application
patterns in the platform.

## Scope

Initial Key Vault for the development environment, supporting the Payroll
Application and other early development workloads.

## Vault Configuration

| Attribute | Value |
|---|---|
| Name pattern | kv-wmcc-<environment>-<suffix> |
| First instance | kv-wmcc-dev-elbafag |
| Region | UK South |
| Pricing tier | Standard |
| Permission model | Azure Role-Based Access Control |
| Soft-delete retention | 7 days (lab) |
| Purge protection | Disabled (lab; production would be enabled) |
| Network access | Public (lab; production would use private endpoint) |

## Naming Convention for Secrets

Pattern: `<application>-<resource>-<credential-type>-<environment>`

Examples:
- `payroll-db-password-dev`
- `payroll-db-password-prod`
- `hr-api-key-dev`

## Required Tags on Vaults

- Environment
- Owner
- Department
- Project

## Access Model

Role-Based Access Control is the chosen permission model for all new vaults.
Access policies (the legacy model) are not used.

Standard role assignments:
- Cloud Team: Key Vault Secrets Officer (full secrets management)
- Application service principals or managed identities: Key Vault Secrets User (read only)
- Auditors: Key Vault Reader (vault metadata only, no secret access)

## Soft-Delete and Purge-Protection

Production vaults must have purge-protection enabled. The lab environment
disables purge-protection deliberately to support repeated tear-down and
rebuild during the learning programme.

## Rotation

Secrets must have an expiration date set on creation. Six months is the default
for lab work. Production rotation cadence is to be defined per credential type
in a future iteration of this document.

## Logging

Diagnostic settings sending vault audit logs to Log Analytics will be
configured in Project 4 (DevSecOps, Monitoring, and Security Operations).
The current lab is missing this control deliberately and will catch up.

## Target State

In the mature platform:
- One vault per environment for shared secrets
- Per-application vaults for application-specific secrets
- Private endpoints with no public network access
- Diagnostic logging to a central Log Analytics workspace
- Vault definitions in Bicep or Terraform, deployed via pipeline
- Managed identity used by applications to authenticate to vaults
- Automated rotation for credentials where the source system supports it

## Lesson Execution Notes

The Lesson 13 hands-on revealed several real Azure friction points worth
recording:

1. **Purge-protection is a one-way switch.** Setting `--enable-purge-protection false`
   explicitly during vault creation can produce a BadRequest error. The correct
   approach is to omit the flag entirely; Azure defaults to "not enabled,"
   which matches the intent.

2. **RBAC propagation is not instantaneous.** Role assignments to Key Vault
   typically take 30 to 60 seconds to propagate. Premature secret operations
   after assignment fail with `Forbidden` errors.

3. **Control plane and data plane are separate.** Creating a vault does not
   grant the creator permission to read its secrets. The data-plane role
   (Key Vault Secrets Officer or Key Vault Secrets User) must be assigned
   explicitly.

4. **The Azure CLI cache can drift.** After region changes or resource
   recreations, `az keyvault show --name X` may fail with confusing errors.
   The reliable form is `az keyvault show --name X --resource-group Y`.

5. **Resource group region is independent of resource region.** A resource
   group in one region can contain resources in different regions.

6. **CLI environment state can corrupt.** Long debugging sessions can leave
   the local Azure CLI in a state where commands fail with `MissingSubscription`
   even when subscription context appears valid. Resolution is `az logout`,
   delete the local `.azure` folder, then `az login` from a fresh terminal
   session. The Portal authenticates through a separate path and remains
   available as a fallback.

These notes are kept here as a record of real engineering friction
encountered, not failures.