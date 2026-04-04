# Access Control Design

## Objective
Introduce controlled Azure access using Role-Based Access Control.

## Key Concepts
### Access control
Determines who can perform which actions on which Azure resources.

### Role-Based Access Control
Azure authorization system that uses role assignments to control access.

### Scope
The level where access applies, such as management group, subscription, resource group, or resource.

## First Practical Assignment
A Reader role assignment was created for the Information Technology Support Team group at the resource group scope.

## Resource Group
- rg-lesson7-access-lab

## Assigned Group
- Information Technology Support Team

## Assigned Role
- Reader

## Design Reason
This design follows least privilege and group-based assignment principles. It gives support staff visibility into the resource group without allowing modification.

## Security Reason
Reader was chosen instead of Contributor or Owner to avoid unnecessary elevated permissions.
