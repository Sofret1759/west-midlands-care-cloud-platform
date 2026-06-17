#!/usr/bin/env bash
set -e

# ---------------------------------------------------------------------------
# Lesson 17 — Hub-and-spoke network destroy
#
# Deletes both network resource groups, which removes all virtual
# networks, subnets, and peering objects in a single operation.
#
# Cost impact: zero. Today's deployment has no hourly cost.
# ---------------------------------------------------------------------------

HUB_RG="rg-hub-network-uksouth"
SPOKES_RG="rg-spokes-network-uksouth"

echo "==========================================="
echo "Lesson 17 destroy"
echo "Hub RG:    $HUB_RG"
echo "Spokes RG: $SPOKES_RG"
echo "==========================================="
echo ""
echo "This will delete both resource groups and all networks and peerings within them."
echo ""
read -p "Type YES to continue: " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
  echo "Deletion cancelled."
  exit 0
fi

echo ""
echo "Step 1: resolving subscription context..."
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
if [ -z "$SUBSCRIPTION_ID" ]; then
  echo "ERROR: could not resolve subscription. Run 'az login' and try again."
  exit 1
fi
az account set --subscription "$SUBSCRIPTION_ID"

echo ""
echo "Step 2: deleting hub resource group..."
az group delete --name "$HUB_RG" --yes --no-wait || echo "Hub RG delete failed or did not exist; continuing."

echo ""
echo "Step 3: deleting spokes resource group..."
az group delete --name "$SPOKES_RG" --yes --no-wait || echo "Spokes RG delete failed or did not exist; continuing."

echo ""
echo "==========================================="
echo "Destroy commands submitted."
echo "Verify in the Azure Portal that both resource groups are removed."
echo "==========================================="