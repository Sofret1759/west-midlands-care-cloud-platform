# Subscription and Management Structure

## Objective
Define the Azure subscription and management group design for the cloud platform.

## Current State
The current learning environment uses a limited Azure subscription model suitable for lab work and controlled learning. This is acceptable for early-stage delivery practice, but it is not the preferred long-term platform design for a growing organization.

## Target State
The target Azure structure for West Midlands Care and Community Group includes:

- Platform subscription
- Production subscription
- Non-production subscription
- Sandbox subscription

## Management Group Design
A simple future management group hierarchy could be:

- Root management group
  - Platform
  - Production
  - Non-production
  - Sandbox

## Why This Design Matters
This design improves:
- governance
- policy inheritance
- access control separation
- operational clarity
- cost visibility
- safer environment separation

## Current Constraint
If only one subscription is available in the lab, the target design is still documented and used as the architectural direction.

## Architect Thinking
Good cloud design does not confuse the current lab limitation with the final production design. Current state and target state must be separated clearly.