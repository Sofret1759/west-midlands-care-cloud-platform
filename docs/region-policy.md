# Region Policy

## Decision

The default Azure region for all platform resources is **UK South (uksouth)**.

## Rationale

UK South is Microsoft's primary United Kingdom region. It offers:

- The full Azure service catalogue, including services that arrive months or
  years before they reach UK West
- Availability Zone support for resilient workload placement
- Higher capacity and broader compatibility with Microsoft documentation,
  reference architectures, and Infrastructure as Code templates
- Geographic proximity to the West Midlands offices of West Midlands Care and
  Community Group

## Disaster Recovery Region

**UK West (ukwest)** is the designated disaster recovery and backup region. UK
South and UK West form Microsoft's official UK regional pair, designed for
geo-redundant replication and failover.

This pairing will be used in later projects when configuring:

- Geo-redundant storage
- Azure Site Recovery
- Geo-replicated databases
- Multi-region disaster recovery patterns

## Current State Drift

Several existing resources from earlier lessons (Lessons 7 through 11) were
created in UK West rather than UK South. A standalone region migration
exercise is planned for a later lesson, after Infrastructure as Code (Bicep)
has been introduced. The migration will be scripted, version-controlled, and
documented as a portfolio artefact rather than performed manually.

The following resources are pending migration to UK South:

- rg-lesson7-access-lab (currently ukwest)
- rg-prod-monitoring (currently ukwest)
- rg-dev-payroll-app (currently ukwest)
- ag-wmccg-costmanagement-001 (currently in rg-wmccg-management-ukw-001 / eastus)
- The Lesson 13 Key Vault, once created

## Exceptions

If a required Azure service is not available in UK South (rare, but possible
for very new services), the lesson or workload may deploy in another region.
Any deviation must be:

1. Justified in the lesson notes or design document
2. Documented in this file under "Known Exceptions"
3. Reviewed when the service becomes available in UK South

## Known Exceptions

None at this time.

## Review

This policy is reviewed at the start of each new project phase, and whenever a
service unavailability forces a deviation.