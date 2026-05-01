# Governance Controls

## Objective
Strengthen Azure governance by adding enforceable controls beyond naming and tagging.

## Governance Controls Introduced

### Resource lock
A delete lock was added to the `rg-prod-monitoring` resource group to reduce the risk of accidental deletion.

### Azure Policy
A built-in Azure Policy was assigned to check for required tagging on resource groups.

## Resource Lock Details
- Resource group: `rg-prod-monitoring`
- Lock name: `protect-prod-monitoring`
- Lock type: Delete

## Policy Goal
Require governance-relevant tags so resources remain easier to manage, review, and track.

## Why This Matters
Guidance alone is not enough in real cloud environments. Governance becomes stronger when Azure can help prevent mistakes and evaluate compliance.

## Cost Awareness
Good governance supports cost awareness by improving tagging, ownership visibility, and environment control.

I will be invoving Shedrack to work with me on planning the cost of the first quarter of the cloud formation.