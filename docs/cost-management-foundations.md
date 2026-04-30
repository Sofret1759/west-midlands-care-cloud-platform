# Cost Management Foundations

## Objective

Establish the first financial discipline layer of the Azure platform through
budgets, alerts, and anomaly detection.

## Scope

This document covers the initial cost management configuration applied at the
subscription level during the early lab stage of the platform build. It
establishes the patterns to be extended in later stages across multiple
subscriptions and management groups.

## Current State

- One Pay-As-You-Go subscription in use for the lab environment
- No resources persistently deployed; build-destroy-rebuild discipline enforced
- Personal tolerance for unintended cost: under fifteen pounds per month

## Budget Configuration

### Primary Subscription Budget

| Attribute | Value |
|---|---|
| Name | budget-subscription-monthly-10gbp |
| Scope | Subscription |
| Amount | £10 |
| Period | Monthly |
| Reset | Monthly |

### Alert Thresholds

| Type | Threshold | Meaning | Action |
|---|---|---|---|
| Actual | 20% (£2) | Unexpected activity | Investigate what is running |
| Actual | 50% (£5) | Significant consumption | Act now or risk overrun |
| Actual | 80% (£8) | Approaching ceiling | Tear down non-essential resources |
| Forecasted | 100% (£10) | Month-end projection over budget | Review spend velocity immediately |

All alerts route to the platform engineer's personal email address during the
lab phase.

## Anomaly Detection

A subscription-level cost anomaly alert rule is enabled to detect unusual
spending patterns independent of the budget thresholds. This serves as both a
financial control and a behavioural security control, as unusual spend is
frequently the earliest visible symptom of subscription compromise.

## Cost Allocation via Tags

Tag-based cost analysis is used to break down spend by:

- Environment
- Owner
- Department
- Project

These tags are defined in the platform standards document and are required on
all governed resource groups.

## Target State

In the mature platform:

- Budgets defined at management group, subscription, and resource group scopes
- Budgets deployed as Infrastructure as Code (Bicep or Terraform)
- Alerts routed via Action Groups to shared mailboxes and incident channels
- Runbooks defined for each alert threshold
- Quarterly reservations and savings plans review
- Cost allocation rules redistributing platform costs across consuming units

## Security Dimension

Cost management is treated as a behavioural security detection layer. Anomalous
spend often precedes other indicators of subscription compromise, making cost
alerts a first-line early-warning control.

## Operating Discipline

All lab resources are destroyed at the end of each lesson to hold monthly spend
within personal tolerance. Budgets remain configured as a standing safety net.

## Review Cadence

Budget thresholds and alert recipients will be reviewed at the start of each
new project phase.