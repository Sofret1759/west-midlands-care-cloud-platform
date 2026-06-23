# West Midlands Care and Community Group — Azure Cloud Platform

## Overview

This repository documents the design and delivery of a secure, governed, and
automated Azure cloud platform for West Midlands Care and Community Group, a
United Kingdom care and community services organisation with 180 staff across
three West Midlands offices.

The work is delivered as a structured engineering programme, built around four
connected projects.

## The Company

- **Name:** West Midlands Care and Community Group
- **Sector:** United Kingdom care and community services (healthcare-adjacent)
- **Size:** 180 staff
- **Locations:** 3 offices across the West Midlands
- **Workforce model:** hybrid, remote, and office-based
- **Current state:** Microsoft 365 in use; no Azure environment at start
- **Regulatory context:** United Kingdom General Data Protection Regulation;
  National Health Service Data Security and Protection Toolkit awareness

## The Four Projects

1. **Cloud Foundation, Identity, Governance, and Administrative Control**
   Secure, governed, scalable Azure foundation.
2. **Secure Network and Workforce Access Platform**
   Zero-Trust-aligned network design for people, admins, and workloads.
3. **Business Workload Hosting Platform**
   Secure, resilient hosting for business workloads.
4. **DevSecOps, Automation, Monitoring, and Security Operations**
   Delivery engineering, detection, and operational maturity.

## Progress

### Project 1 — Cloud Foundation, Identity, Governance, and Administrative Control

- [x] Identity design
- [x] Sample users and groups
- [x] First group-based access assignment (Role-Based Access Control)
- [x] Governance structure with tagged resource groups
- [x] Governance controls (resource locks and Azure Policy)
- [x] Subscription and management structure (current state vs target state)
- [x] Platform naming and tagging standards
- [x] Cost management foundations
- [x] Key Vault and secrets management
- [x] Conditional Access and Privileged Identity Management
- [x] Project 1 closeout and architecture document

**Status: Complete.** See `docs/project-1-architecture.md` for the
consolidated design document.


### Project 2 — Secure Network and Workforce Access Platform   


- [x] Project 2 introduction and virtual network design
- [x] Hub and production spoke deployment
- [x] Network Security Groups and traffic rules
- [ ] Virtual Private Network Gateway and site-to-site connectivity
- [ ] Azure Firewall and egress control
- [ ] Azure Bastion for administrative access
- [ ] Private endpoints for Platform-as-a-Service resources
- [ ] Network monitoring with Network Watcher

**Status: In progress.** See `docs/network-design.md` for the topology design and address allocation.

### Project 3 — Business Workload Hosting Platform

Not yet started.

### Project 4 — DevSecOps, Automation, Monitoring, and Security Operations

Not yet started.

## Repository Structure

- `azure-cli/` — Azure Command-Line Interface scripts used in lessons
- `bicep/` — Bicep templates (to be introduced later in the programme)
- `diagrams/` — architecture and design diagrams
- `docs/` — design documents and written standards
- `runbooks/` — operational procedures
- `scripts/` — helper scripts, including per-lesson rebuild and destroy scripts
- `security/` — security design artefacts, threat models, and controls
- `terraform/` — Terraform configurations (to be introduced later in the programme)

## Operating Discipline

This platform is delivered under a strict build-learn-validate-document-commit-
destroy-rebuild discipline. No chargeable resources are left running between
lessons. Nothing important depends on manual portal clicks or memory.
Everything important is reproducible from code.

## Cost Discipline

Personal monthly spend tolerance: under £15. A subscription-level budget is
configured with tiered alerts (20%, 50%, 80%) and a forecasted 100% alert, plus
cost anomaly detection. See `docs/cost-management-foundations.md` for detail.

## Author
West Midlands Care and Community Group (scenario).
Programme delivered under cloud security architect Fola Agbaje.