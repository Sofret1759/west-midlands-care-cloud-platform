#!/usr/bin/env bash
set -e

# ---------------------------------------------------------------------------
# Lesson 17 — Hub-and-spoke network rebuild
#
# Recreates the hub virtual network, the production spoke, the
# non-production spoke, and the four peering relationships between
# them.
#
# Cost: zero hourly cost for the resources this script creates.
# Virtual networks and peerings do not charge per hour at lab scale.
#
# Note for Windows + Git Bash users: MSYS_NO_PATHCONV=1 is prefixed on the
# peering commands. Without it, Git Bash converts the Azure resource ID
# (which starts with /subscriptions/...) into a Windows-style path and the
# Azure CLI receives an invalid value. This is a Git Bash behaviour, not
# an Azure CLI bug. The prefix is harmless on Linux, macOS, and Azure
# Cloud Shell environments.
# ---------------------------------------------------------------------------

LOCATION="uksouth"
HUB_RG="rg-hub-network-uksouth"
SPOKES_RG="rg-spokes-network-uksouth"

echo "==========================================="
echo "Lesson 17 rebuild"
echo "Region:     $LOCATION"
echo "Hub RG:     $HUB_RG"
echo "Spokes RG:  $SPOKES_RG"
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
echo "Step 2: creating hub resource group..."
az group create \
  --name "$HUB_RG" \
  --location "$LOCATION" \
  --tags Environment=Shared Owner=CloudTeam Department=Platform Project=PlatformNetworking

echo ""
echo "Step 3: creating spokes resource group..."
az group create \
  --name "$SPOKES_RG" \
  --location "$LOCATION" \
  --tags Environment=Shared Owner=CloudTeam Department=Platform Project=PlatformNetworking

echo ""
echo "Step 4: creating hub virtual network with all four subnets..."
az network vnet create \
  --resource-group "$HUB_RG" \
  --name vnet-hub-uksouth-001 \
  --address-prefix 10.0.0.0/16 \
  --subnet-name GatewaySubnet \
  --subnet-prefix 10.0.0.0/26 \
  --location "$LOCATION" \
  --tags Environment=Shared Owner=CloudTeam Department=Platform Project=PlatformNetworking

az network vnet subnet create \
  --resource-group "$HUB_RG" \
  --vnet-name vnet-hub-uksouth-001 \
  --name AzureFirewallSubnet \
  --address-prefixes 10.0.0.64/26

az network vnet subnet create \
  --resource-group "$HUB_RG" \
  --vnet-name vnet-hub-uksouth-001 \
  --name AzureBastionSubnet \
  --address-prefixes 10.0.0.128/26

az network vnet subnet create \
  --resource-group "$HUB_RG" \
  --vnet-name vnet-hub-uksouth-001 \
  --name snet-hub-shared-services \
  --address-prefixes 10.0.1.0/24

echo ""
echo "Step 5: creating production spoke with all three subnets..."
az network vnet create \
  --resource-group "$SPOKES_RG" \
  --name vnet-prod-uksouth-001 \
  --address-prefix 10.1.0.0/16 \
  --subnet-name snet-prod-app-tier \
  --subnet-prefix 10.1.1.0/24 \
  --location "$LOCATION" \
  --tags Environment=Production Owner=CloudTeam Department=Platform Project=PlatformNetworking

az network vnet subnet create \
  --resource-group "$SPOKES_RG" \
  --vnet-name vnet-prod-uksouth-001 \
  --name snet-prod-data-tier \
  --address-prefixes 10.1.2.0/24

az network vnet subnet create \
  --resource-group "$SPOKES_RG" \
  --vnet-name vnet-prod-uksouth-001 \
  --name snet-prod-management \
  --address-prefixes 10.1.3.0/26

echo ""
echo "Step 6: creating non-production spoke with all three subnets..."
az network vnet create \
  --resource-group "$SPOKES_RG" \
  --name vnet-nonprod-uksouth-001 \
  --address-prefix 10.2.0.0/16 \
  --subnet-name snet-nonprod-app-tier \
  --subnet-prefix 10.2.1.0/24 \
  --location "$LOCATION" \
  --tags Environment=Non-production Owner=CloudTeam Department=Platform Project=PlatformNetworking

az network vnet subnet create \
  --resource-group "$SPOKES_RG" \
  --vnet-name vnet-nonprod-uksouth-001 \
  --name snet-nonprod-data-tier \
  --address-prefixes 10.2.2.0/24

az network vnet subnet create \
  --resource-group "$SPOKES_RG" \
  --vnet-name vnet-nonprod-uksouth-001 \
  --name snet-nonprod-management \
  --address-prefixes 10.2.3.0/26

echo ""
echo "Step 7: capturing virtual network identifiers for peering..."
HUB_VNET_ID=$(az network vnet show --resource-group "$HUB_RG" --name vnet-hub-uksouth-001 --query id --output tsv)
PROD_VNET_ID=$(az network vnet show --resource-group "$SPOKES_RG" --name vnet-prod-uksouth-001 --query id --output tsv)
NONPROD_VNET_ID=$(az network vnet show --resource-group "$SPOKES_RG" --name vnet-nonprod-uksouth-001 --query id --output tsv)

if [ -z "$HUB_VNET_ID" ] || [ -z "$PROD_VNET_ID" ] || [ -z "$NONPROD_VNET_ID" ]; then
  echo "ERROR: one or more vnet identifiers came back empty. Aborting."
  exit 1
fi

echo ""
echo "Step 8: creating all four peering objects..."
echo "Note: MSYS_NO_PATHCONV=1 prefix added for Git Bash on Windows compatibility."

MSYS_NO_PATHCONV=1 az network vnet peering create \
  --name peer-hub-to-prod \
  --resource-group "$HUB_RG" \
  --vnet-name vnet-hub-uksouth-001 \
  --remote-vnet "$PROD_VNET_ID" \
  --allow-vnet-access \
  --allow-forwarded-traffic

MSYS_NO_PATHCONV=1 az network vnet peering create \
  --name peer-prod-to-hub \
  --resource-group "$SPOKES_RG" \
  --vnet-name vnet-prod-uksouth-001 \
  --remote-vnet "$HUB_VNET_ID" \
  --allow-vnet-access \
  --allow-forwarded-traffic

MSYS_NO_PATHCONV=1 az network vnet peering create \
  --name peer-hub-to-nonprod \
  --resource-group "$HUB_RG" \
  --vnet-name vnet-hub-uksouth-001 \
  --remote-vnet "$NONPROD_VNET_ID" \
  --allow-vnet-access \
  --allow-forwarded-traffic

MSYS_NO_PATHCONV=1 az network vnet peering create \
  --name peer-nonprod-to-hub \
  --resource-group "$SPOKES_RG" \
  --vnet-name vnet-nonprod-uksouth-001 \
  --remote-vnet "$HUB_VNET_ID" \
  --allow-vnet-access \
  --allow-forwarded-traffic

echo ""
echo "Step 9: verifying peering state..."
az network vnet peering list \
  --resource-group "$HUB_RG" \
  --vnet-name vnet-hub-uksouth-001 \
  --query "[].{Name:name, State:peeringState}" \
  --output table

echo ""
echo "==========================================="
echo "Lesson 17 rebuild complete."
echo "Verify all peerings show State: Connected"
echo "==========================================="