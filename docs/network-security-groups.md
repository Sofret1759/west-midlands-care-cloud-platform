# Network Security Groups

## Objective

Implement the first layer of micro-segmentation on top of the hub-and-spoke topology established in Lesson 17. Network Security Groups (NSGs) sit at the subnet level controlling traffic in and out, enforcing the principle of least privilege at the network layer.

## Scope

Five NSGs deployed:

- `nsg-prod-app-tier` — production application subnet
- `nsg-prod-data-tier` — production data subnet
- `nsg-nonprod-app-tier` — non-production application subnet
- `nsg-nonprod-data-tier` — non-production data subnet
- `nsg-hub-shared-services` — hub shared services subnet (placeholder, no custom rules)

Subnets not yet receiving custom NSGs:

- GatewaySubnet, AzureFirewallSubnet, AzureBastionSubnet — managed by their respective services
- Management subnets (prod and non-prod) — empty placeholder space, no resources to protect yet

## Design Principles

- Explicit allow rules for required traffic
- Explicit `Deny` rule at priority 4000 to override default-allow-VNet
- Service Tags preferred over literal IP ranges
- Priorities gapped (100, 110, 200, etc.) to allow future insertion without renumbering
- Every rule named descriptively and documented with a business reason

## Rule Sets

### nsg-prod-app-tier

**Inbound:**

| Priority | Name | Source | Destination | Port | Protocol | Action |
|---|---|---|---|---|---|---|
| 100 | AllowHttpsInboundFromInternet | Internet | VirtualNetwork | 443 | TCP | Allow |
| 110 | AllowHttpInboundFromInternet | Internet | VirtualNetwork | 80 | TCP | Allow |
| 200 | AllowBastionInbound | 10.0.0.128/26 | VirtualNetwork | 22, 3389 | TCP | Allow |
| 4000 | DenyAllOtherInbound | Any | Any | Any | Any | Deny |

**Outbound:**

| Priority | Name | Source | Destination | Port | Protocol | Action |
|---|---|---|---|---|---|---|
| 100 | AllowOutboundToProdDataTier | VirtualNetwork | 10.1.2.0/24 | 1433, 3306, 5432 | TCP | Allow |
| 200 | AllowAzureMonitorOutbound | VirtualNetwork | AzureMonitor | 443 | TCP | Allow |
| 300 | AllowKeyVaultOutbound | VirtualNetwork | AzureKeyVault | 443 | TCP | Allow |
| 4000 | DenyAllOtherOutbound | Any | Any | Any | Any | Deny |

### nsg-prod-data-tier

**Inbound:**

| Priority | Name | Source | Destination | Port | Protocol | Action |
|---|---|---|---|---|---|---|
| 100 | AllowDatabaseInboundFromAppTier | 10.1.1.0/24 | VirtualNetwork | 1433, 3306, 5432 | TCP | Allow |
| 200 | AllowBastionInbound | 10.0.0.128/26 | VirtualNetwork | 22, 3389 | TCP | Allow |
| 4000 | DenyAllOtherInbound | Any | Any | Any | Any | Deny |

**Outbound:**

| Priority | Name | Source | Destination | Port | Protocol | Action |
|---|---|---|---|---|---|---|
| 100 | AllowAzureMonitorOutbound | VirtualNetwork | AzureMonitor | 443 | TCP | Allow |
| 200 | AllowKeyVaultOutbound | VirtualNetwork | AzureKeyVault | 443 | TCP | Allow |
| 4000 | DenyAllOtherOutbound | Any | Any | Any | Any | Deny |

### nsg-nonprod-app-tier

Identical pattern to nsg-prod-app-tier, with outbound destination range adjusted to `10.2.2.0/24`.

### nsg-nonprod-data-tier

Identical pattern to nsg-prod-data-tier, with inbound source range adjusted to `10.2.1.0/24`.

### nsg-hub-shared-services

Default rules only. Custom rules to be added when shared services are deployed.

## Subnet Associations

| Subnet | NSG |
|---|---|
| vnet-prod-uksouth-001/snet-prod-app-tier | nsg-prod-app-tier |
| vnet-prod-uksouth-001/snet-prod-data-tier | nsg-prod-data-tier |
| vnet-nonprod-uksouth-001/snet-nonprod-app-tier | nsg-nonprod-app-tier |
| vnet-nonprod-uksouth-001/snet-nonprod-data-tier | nsg-nonprod-data-tier |
| vnet-hub-uksouth-001/snet-hub-shared-services | nsg-hub-shared-services |

## Lab vs Production Deltas

| Item | Lab | Production |
|---|---|---|
| Rule references | Literal address prefixes | Application Security Groups |
| HTTP port 80 | Allowed for demonstration | Denied; HTTPS-only enforced |
| Outbound to internet | Default-allowed (no firewall yet) | Forced through Azure Firewall in hub |
| Flow logs | Not configured | NSG flow logs to Log Analytics, analysed by Sentinel |
| Rule sources | Manual creation | Version-controlled in Bicep/Terraform with peer review |
| Database access | Network-layer only | Combined with managed identity, private endpoints, database firewall |

## Verification

```bash
az network nsg list \
  --query "[].{Name:name, ResourceGroup:resourceGroup}" \
  --output table
```

```bash
az network nsg rule list \
  --resource-group rg-spokes-network-uksouth \
  --nsg-name nsg-prod-app-tier \
  --query "[].{Name:name, Priority:priority, Direction:direction, Access:access}" \
  --output table
```

## Target State

In the mature platform:

- All rules reference Application Security Groups, not literal address ranges
- NSG flow logs streaming to Log Analytics
- Microsoft Sentinel rules detecting anomalous traffic patterns
- Outbound traffic forced through Azure Firewall (no direct internet egress)
- Rules version-controlled in Bicep/Terraform, deployed via pipeline
- Quarterly NSG rule reviews to identify dead rules and tighten over-broad ones

## Cost Footprint

Zero. NSGs are free.