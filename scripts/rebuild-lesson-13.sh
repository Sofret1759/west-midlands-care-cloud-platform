#!/usr/bin/env bash
set -e

# ---------------------------------------------------------------------------
# Lesson 13 — Key Vault rebuild script
#
# Recreates the resource group, the Key Vault, the role assignment, and the
# two demonstration secrets from a clean slate.
#
# Status: written but not yet validated end-to-end via the Azure CLI.
# Lesson 13's first attempt encountered persistent MissingSubscription errors
# during the role assignment step. The role assignment was completed via the
# Azure Portal as a workaround. This script is to be re-validated with a
# fresh CLI session in the next session.
#
# Known fragility points:
#   - Step 7 (role assignment) is the step that failed during Lesson 13.
#     If it fails again with MissingSubscription, fall back to assigning
#     the role manually in the Portal.
#   - Step 8 sleeps for 60 seconds to allow RBAC propagation. Premature
#     secret operations after assignment fail with Forbidden errors.
# ---------------------------------------------------------------------------

VAULT_NAME="kv-wmcc-dev-elbafag"
RESOURCE_GROUP="rg-dev-payroll-app"
LOCATION="uksouth"

echo "==========================================="
echo "Lesson 13 rebuild"
echo "Vault:    $VAULT_NAME"
echo "Region:   $LOCATION"
echo "Group:    $RESOURCE_GROUP"
echo "==========================================="
echo ""

echo "Step 1: resolving subscription context..."
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
if [ -z "$SUBSCRIPTION_ID" ]; then
  echo "ERROR: could not resolve subscription. Run 'az login' and try again."
  exit 1
fi
echo "Operating in subscription: $SUBSCRIPTION_ID"
az account set --subscription "$SUBSCRIPTION_ID"

echo ""
echo "Step 2: capturing current user object id..."
USER_OBJECT_ID=$(az ad signed-in-user show --query id --output tsv)
echo "USER_OBJECT_ID is: [$USER_OBJECT_ID]"
if [ -z "$USER_OBJECT_ID" ]; then
  echo "ERROR: USER_OBJECT_ID is empty. Aborting."
  exit 1
fi

echo ""
echo "Step 3: purging any soft-deleted vault with the same name..."
az keyvault purge \
  --name "$VAULT_NAME" \
  --location "$LOCATION" \
  || echo "No soft-deleted vault present; continuing."

echo ""
echo "Step 4: creating resource group in $LOCATION..."
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --tags Environment=Development Owner=CloudTeam Department=Finance Project=PayrollPlatform

echo ""
echo "Step 5: creating Key Vault..."
az keyvault create \
  --name "$VAULT_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku standard \
  --enable-rbac-authorization true \
  --retention-days 7 \
  --tags Environment=Development Owner=CloudTeam Department=Finance Project=PayrollPlatform

echo ""
echo "Step 6: capturing vault scope..."
VAULT_ID=$(az keyvault show \
  --name "$VAULT_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query id \
  --output tsv)
echo "VAULT_ID is: [$VAULT_ID]"
if [ -z "$VAULT_ID" ]; then
  echo "ERROR: VAULT_ID is empty. Aborting."
  exit 1
fi

echo ""
echo "Step 7: assigning Key Vault Secrets Officer role to current user..."
echo "If this step fails with MissingSubscription, assign the role manually in"
echo "the Portal: Key Vault > Access control (IAM) > Add role assignment."
az role assignment create \
  --role "Key Vault Secrets Officer" \
  --assignee-object-id "$USER_OBJECT_ID" \
  --assignee-principal-type User \
  --scope "$VAULT_ID" \
  || {
    echo ""
    echo "WARNING: role assignment via CLI failed."
    echo "Continue manually in the Portal, then re-run from Step 9."
    exit 1
  }

echo ""
echo "Step 8: waiting 60 seconds for RBAC propagation..."
sleep 60

echo ""
echo "Step 9: creating placeholder secret..."
az keyvault secret set \
  --vault-name "$VAULT_NAME" \
  --name "placeholder-test-secret" \
  --value "dev-test-secret-12345"

echo ""
echo "Step 10: creating realistic application secret..."
az keyvault secret set \
  --vault-name "$VAULT_NAME" \
  --name "payroll-db-password-dev" \
  --value "LessonThirteen-FakePassword-DoNotReuse-1234"

echo ""
echo "Step 11: verifying secrets..."
az keyvault secret list \
  --vault-name "$VAULT_NAME" \
  --output table

echo ""
echo "==========================================="
echo "Lesson 13 rebuild complete."
echo "Vault:    $VAULT_NAME"
echo "Region:   $LOCATION"
echo "Group:    $RESOURCE_GROUP"
echo "==========================================="