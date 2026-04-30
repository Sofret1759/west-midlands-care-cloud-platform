#!/usr/bin/env bash
set -e

echo "This will delete the Lesson 11 lab resource groups."
read -p "Type YES to continue: " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
  echo "Deletion cancelled."
  exit 0
fi

echo "Deleting rg-dev-payroll-app..."
az group delete --name rg-dev-payroll-app --yes --no-wait || true

echo "Deleting rg-prod-monitoring..."
az group delete --name rg-prod-monitoring --yes --no-wait || true

echo "Deletion commands submitted. Verify in the Azure Portal."