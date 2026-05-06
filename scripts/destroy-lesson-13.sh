#!/usr/bin/env bash
set -e

# ---------------------------------------------------------------------------
# Lesson 13 — Key Vault destroy script
#
# Tears down the Lesson 13 Key Vault and its containing resource group.
# Includes the soft-delete purge step so the vault name can be reused
# without waiting for the retention period to expire.
#
# Status: written but only partially validated end-to-end. The CLI environment
# during Lesson 13's first attempt suffered persistent MissingSubscription
# errors that were not fully diagnosed. Run with attention; the Portal is
# always available as a fallback.
# ---------------------------------------------------------------------------

VAULT_NAME="kv-wmcc-dev-elbafag"
RESOURCE_GROUP="rg-dev-payroll-app"
LOCATION="uksouth"

echo "==========================================="
echo "Lesson 13 destroy"
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
echo "This will:"
echo "  1. Delete the Key Vault (soft-delete)"
echo "  2. Purge the soft-deleted vault (frees the name immediately)"
echo "  3. Delete the resource group"
echo ""
read -p "Type YES to continue: " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
  echo "Deletion cancelled."
  exit 0
fi

echo ""
echo "Step 2: deleting Key Vault (soft-delete)..."
az keyvault delete \
  --name "$VAULT_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  || echo "Vault delete failed or vault did not exist; continuing."

echo ""
echo "Step 3: purging soft-deleted Key Vault..."
az keyvault purge \
  --name "$VAULT_NAME" \
  --location "$LOCATION" \
  || echo "Vault purge failed or no soft-deleted vault present; continuing."

echo ""
echo "Step 4: deleting resource group..."
az group delete \
  --name "$RESOURCE_GROUP" \
  --yes \
  --no-wait \
  || echo "Resource group delete failed or group did not exist; continuing."

echo ""
echo "==========================================="
echo "Destroy commands submitted."
echo ""
echo "Verify in the Azure Portal:"
echo "  - Key Vaults > Manage deleted vaults (should not list $VAULT_NAME)"
echo "  - Resource groups (should not list $RESOURCE_GROUP)"
echo "==========================================="