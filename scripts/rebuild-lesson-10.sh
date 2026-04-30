#!/usr/bin/env bash
set -e

LOCATION="ukwest"

echo "Recreating Lesson 10 governance resource groups..."

az group create --name rg-dev-payroll-app --location "$LOCATION" --tags Environment=Development Owner=CloudTeam Department=Finance Project=PayrollPlatform

az group create --name rg-prod-monitoring --location "$LOCATION" --tags Environment=Production Owner=CloudTeam Department=IT Project=PlatformMonitoring

echo "Rebuild complete."