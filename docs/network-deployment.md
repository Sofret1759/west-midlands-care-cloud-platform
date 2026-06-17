# Network Deployment — Hub and Two Spokes

## Objective

Document the initial deployment of the hub-and-spoke topology designed in `docs/network-design.md`. This document records what was actually deployed, when, and how it can be verified.

## Deployed Networks

### Hub

| Property | Value |
|---|---|
| Name | vnet-hub-uksouth-001 |
| Resource group | rg-hub-network-uksouth |
| Address space | 10.0.0.0/16 |
| Region | UK South |
| Subnets | GatewaySubnet (10.0.0.0/26), AzureFirewallSubnet (10.0.0.64/26), AzureBastionSubnet (10.0.0.128/26), snet-hub-shared-services (10.0.1.0/24) |

### Production Spoke

| Property | Value |
|---|---|
| Name | vnet-prod-uksouth-001 |
| Resource group | rg-spokes-network-uksouth |
| Address space | 10.1.0.0/16 |
| Region | UK South |
| Subnets | snet-prod-app-tier (10.1.1.0/24), snet-prod-data-tier (10.1.2.0/24), snet-prod-management (10.1.3.0/26) |

### Non-Production Spoke

| Property | Value |
|---|---|
| Name | vnet-nonprod-uksouth-001 |
| Resource group | rg-spokes-network-uksouth |
| Address space | 10.2.0.0/16 |
| Region | UK South |
| Subnets | snet-nonprod-app-tier (10.2.1.0/24), snet-nonprod-data-tier (10.2.2.0/24), snet-nonprod-management (10.2.3.0/26) |

## Peering Relationships

| Peering Object | In Network | Points To | Direction |
|---|---|---|---|
| peer-hub-to-prod | vnet-hub-uksouth-001 | vnet-prod-uksouth-001 | Hub → Production |
| peer-prod-to-hub | vnet-prod-uksouth-001 | vnet-hub-uksouth-001 | Production → Hub |
| peer-hub-to-nonprod | vnet-hub-uksouth-001 | vnet-nonprod-uksouth-001 | Hub → Non-production |
| peer-nonprod-to-hub | vnet-nonprod-uksouth-001 | vnet-hub-uksouth-001 | Non-production → Hub |

All peerings configured with:
- `--allow-vnet-access`: permits traffic between networks
- `--allow-forwarded-traffic`: permits traffic forwarded by the hub (important for hub-and-spoke routing)

No direct production-to-non-production peering. Traffic between the two spokes must transit the hub, where Azure Firewall will inspect it (deployed in Lesson 20).

## Verification

To verify the deployment matches what is documented:

```bash
az network vnet list \
  --query "[].{Name:name, AddressSpace:addressSpace.addressPrefixes[0], Location:location}" \
  --output table
```

To verify peering state is Connected (not Initiated):

```bash
az network vnet peering list \
  --resource-group rg-hub-network-uksouth \
  --vnet-name vnet-hub-uksouth-001 \
  --query "[].{Name:name, State:peeringState}" \
  --output table
```

All peerings should show `State: Connected`.

## Tags Applied

All networks carry the platform standard tags:

| Tag | Hub | Production | Non-production |
|---|---|---|---|
| Environment | Shared | Production | Non-production |
| Owner | CloudTeam | CloudTeam | CloudTeam |
| Department | Platform | Platform | Platform |
| Project | PlatformNetworking | PlatformNetworking | PlatformNetworking |

## What Has Not Been Deployed Yet (Honest Backlog)

- No Network Security Groups (Lesson 18)
- No Virtual Private Network Gateway (Lesson 19)
- No Azure Firewall (Lesson 20)
- No Azure Bastion (Lesson 21)
- No private endpoints (Lesson 22)
- No diagnostic logging (Project 4)
- No Infrastructure as Code definition yet (Bicep planned later in Project 2)

## Lesson Execution Notes

### Git Bash on Windows mangles Azure resource identifiers in peering commands

When running `az network vnet peering create` from Git Bash (MINGW64) on Windows, the command fails with errors that look like the remote VNet identifier is invalid, even though `echo "$PROD_VNET_ID"` clearly shows the correct value.

**Root cause:** Git Bash automatically tries to convert paths beginning with a forward slash to Windows-style paths. Azure resource identifiers start with `/subscriptions/...`, which Git Bash interprets as a Linux file path and rewrites before passing the command to the Azure CLI. The Azure CLI then receives a mangled identifier and rejects the request.

The Azure infrastructure is correct. The error happens on the client side, before Azure processes the request.

**Solution:** Prefix every peering command (and any other Azure CLI command passing a resource identifier as an argument) with `MSYS_NO_PATHCONV=1`. This disables Git Bash path conversion for that specific command without affecting other commands.

Example:

```bash
MSYS_NO_PATHCONV=1 az network vnet peering create \
  --name peer-hub-to-prod \
  --resource-group rg-hub-network-uksouth \
  --vnet-name vnet-hub-uksouth-001 \
  --remote-vnet "$PROD_VNET_ID" \
  --allow-vnet-access \
  --allow-forwarded-traffic
```

This is documented behaviour of Git Bash / MINGW64, not an Azure CLI issue. The same problem affects any command line tool on Windows Git Bash that accepts identifiers starting with a forward slash.

### Affected commands in this lesson

All four peering creation commands required the `MSYS_NO_PATHCONV=1` prefix:

- `peer-hub-to-prod`
- `peer-prod-to-hub`
- `peer-hub-to-nonprod`
- `peer-nonprod-to-hub`

Verification commands (`az network vnet peering list`) did not require the prefix because they do not pass resource identifiers as arguments.

### Alternative environments that avoid the issue

- Azure Cloud Shell (browser-based shell from the Azure Portal) runs in a Linux environment with no path mangling
- Windows Subsystem for Linux (WSL) provides a Linux environment without Git Bash's path conversion behaviour
- A native Linux or macOS terminal has no equivalent issue

For this blueprint, the Git Bash + `MSYS_NO_PATHCONV=1` pattern is sufficient. The friction does not appear in Infrastructure as Code workflows (Bicep, Terraform) because those tools do not pass resource identifiers via command line in the same way.

## Cost Footprint

Zero hourly cost. Virtual networks and peering connections do not charge per hour at this scale. Data transferred across peering connections costs a small per-gigabyte amount, negligible at lab volumes.

When the chargeable services arrive (Gateway, Firewall, Bastion in Lessons 19-21), each carries an ongoing hourly cost. These will be destroyed at the end of their respective lessons under the build-learn-validate-document-commit-destroy-rebuild discipline.