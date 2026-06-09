# Network Design — West Midlands Care and Community Group

## Objective

Define the virtual network topology, address allocation, and connectivity model for the Microsoft Azure platform supporting a 180-staff United Kingdom care services organisation across three offices, with a hybrid workforce.

This document is the architectural reference for all networking work in Project 2 (Secure Network and Workforce Access Platform) and the substrate on which Projects 3 (workloads) and 4 (DevSecOps and security operations) will be built.

## Scope

This design covers:

- Overall Internet Protocol address space allocation for the Azure estate
- Virtual network topology (hub-and-spoke)
- Subnet structure within each virtual network
- Virtual network peering relationships
- Placement of shared connectivity components (Virtual Private Network Gateway, Azure Firewall, Azure Bastion)
- Naming conventions for networks and subnets
- Required tags

Out of scope for this document (covered in subsequent lessons):

- Network Security Group rules (Lesson 18)
- Virtual Private Network Gateway and site-to-site connectivity configuration (Lesson 19)
- Azure Firewall rule design (Lesson 20)
- Azure Bastion deployment (Lesson 21)
- Private endpoint configuration (Lesson 22)
- Network monitoring through Network Watcher (later in Project 2)

## Design Principles

- **Hub-and-spoke topology**: a central hub virtual network provides shared services; spoke virtual networks host workloads.
- **Centralised egress**: all outbound traffic to the internet flows through Azure Firewall in the hub for inspection and logging.
- **No direct spoke-to-spoke peering**: all inter-spoke traffic transits the hub, where the firewall can apply policy.
- **Tiered subnet structure**: each spoke separates application, data, and management workloads into distinct subnets.
- **Address space sized for growth**: ranges reserved for at least ten years of expected expansion, including future spokes.
- **Regional alignment**: all resources deployed in UK South (default region per `docs/region-policy.md`); UK West reserved for disaster recovery as defined in the region policy.
- **Required-name subnets**: Azure services that require specifically-named subnets (GatewaySubnet, AzureFirewallSubnet, AzureBastionSubnet) are pre-allocated in the hub.

## Overall Address Space

Reserved Azure allocation: `10.0.0.0/12`

This is a private address range under RFC 1918, sized to provide ample headroom for the organisation's expected ten-year growth and any future acquisition or partnership integration. It deliberately avoids `192.168.0.0/16` and `172.16.0.0/12`, which are the common defaults used by office networks and which the three West Midlands offices are likely to use.

Within the `10.0.0.0/12` reservation:

| Network | Address Range | Purpose |
|---|---|---|
| Hub | 10.0.0.0/16 | Shared platform services and external connectivity |
| Production spoke | 10.1.0.0/16 | Production workloads |
| Non-production spoke | 10.2.0.0/16 | Development and staging workloads |
| Sandbox spoke | 10.3.0.0/16 | Experimentation and lab environments |
| Reserved (future spokes) | 10.4.0.0/16 – 10.15.0.0/16 | Future expansion (12 reserved blocks) |

## Hub Virtual Network — `vnet-hub-uksouth-001`

**Address space:** `10.0.0.0/16` (65,536 addresses available)

**Region:** UK South

**Purpose:** Hosts shared connectivity and platform services consumed by all spoke networks.

**Subnets:**

| Subnet Name | Address Range | Purpose |
|---|---|---|
| GatewaySubnet | 10.0.0.0/26 | Virtual Private Network Gateway (Azure-required name) |
| AzureFirewallSubnet | 10.0.0.64/26 | Azure Firewall (Azure-required name) |
| AzureBastionSubnet | 10.0.0.128/26 | Azure Bastion (Azure-required name) |
| snet-hub-shared-services | 10.0.1.0/24 | Domain Name System, monitoring agents, shared platform infrastructure |
| Reserved | 10.0.2.0/23 onwards | Future hub-tier services |

**Note on required subnet names:** GatewaySubnet, AzureFirewallSubnet, and AzureBastionSubnet are not naming conventions chosen by the engineer — they are mandatory names enforced by Azure. The respective services will not deploy into a subnet with any other name.

## Production Spoke Virtual Network — `vnet-prod-uksouth-001`

**Address space:** `10.1.0.0/16`

**Region:** UK South

**Purpose:** Hosts production workloads, separated by tier into distinct subnets to support segmentation, tiered Network Security Group rules, and clear operational ownership boundaries.

**Subnets:**

| Subnet Name | Address Range | Purpose |
|---|---|---|
| snet-prod-app-tier | 10.1.1.0/24 | Application servers (web tier, application tier) |
| snet-prod-data-tier | 10.1.2.0/24 | Databases, storage endpoints, data services |
| snet-prod-management | 10.1.3.0/26 | Administrative resources for production |
| Reserved | 10.1.4.0/22 onwards | Future production tiers |

## Non-Production Spoke Virtual Network — `vnet-nonprod-uksouth-001`

**Address space:** `10.2.0.0/16`

**Region:** UK South

**Purpose:** Hosts development and staging workloads, mirroring the production spoke's structure to ensure parity between environments while maintaining strict isolation.

**Subnets:**

| Subnet Name | Address Range | Purpose |
|---|---|---|
| snet-nonprod-app-tier | 10.2.1.0/24 | Application servers (development and staging) |
| snet-nonprod-data-tier | 10.2.2.0/24 | Databases and data services (development and staging) |
| snet-nonprod-management | 10.2.3.0/26 | Administrative resources for non-production |
| Reserved | 10.2.4.0/22 onwards | Future non-production tiers |

## Sandbox Spoke (Reserved — Not Yet Deployed)

**Reserved address space:** `10.3.0.0/16`

The sandbox spoke is reserved in the address plan for future experimentation workloads. Detailed subnet design will be produced when the sandbox is first deployed.

## Peering

Peering relationships are deliberate decisions, not defaults. The matrix below defines every peering connection in the network.

| Peering | Direction | Allow Forwarded Traffic | Use Remote Gateway |
|---|---|---|---|
| Hub ↔ Production spoke | Bidirectional | Yes | Spoke uses hub gateway |
| Hub ↔ Non-production spoke | Bidirectional | Yes | Spoke uses hub gateway |
| Hub ↔ Sandbox spoke (future) | Bidirectional | Yes | Spoke uses hub gateway |
| Production spoke ↔ Non-production spoke | Not peered | N/A | N/A |
| Production spoke ↔ Sandbox spoke | Not peered | N/A | N/A |
| Non-production spoke ↔ Sandbox spoke | Not peered | N/A | N/A |

**Rationale:** Direct spoke-to-spoke peering is deliberately not established. If a workload in the production spoke needs to communicate with a workload in the non-production spoke, the traffic routes through the hub, where Azure Firewall can inspect, log, and apply policy. This pattern is the foundation of the segmentation that makes the network defensible.

## Connectivity Components (built in subsequent lessons)

- **Virtual Private Network Gateway** in the hub's `GatewaySubnet`, providing Site-to-Site VPN connectivity to the three West Midlands offices. Detailed configuration in Lesson 19.
- **Azure Firewall** in the hub's `AzureFirewallSubnet`, inspecting all egress to the internet and all inter-spoke traffic. Detailed configuration in Lesson 20.
- **Azure Bastion** in the hub's `AzureBastionSubnet`, providing browser-based Remote Desktop Protocol and Secure Shell access to virtual machines in spoke subnets without requiring public Internet Protocol addresses on those machines. Detailed configuration in Lesson 21.
- **Private Endpoints** for sensitive Platform-as-a-Service resources (Key Vault, Storage, SQL) deployed into spoke subnets, removing public network exposure. Detailed configuration in Lesson 22.

## Workforce Access Model

- **Office-based and hybrid workers**: connect through their office network, which reaches Azure via the Site-to-Site VPN configured on the Virtual Private Network Gateway. From the office user's perspective, Azure resources appear as part of the corporate network.
- **Fully remote workers**: continue to use Microsoft 365 via identity-based access (already in place). For direct access to Azure resources (rare for most staff), options include Point-to-Site VPN, Microsoft Entra Application Proxy, or Azure Virtual Desktop. Detailed design deferred to a later lesson.
- **Engineers and administrators**: connect to Azure-resident virtual machines via Azure Bastion in the hub. No virtual machine receives a public Internet Protocol address.

## Naming Convention

- **Virtual networks**: `vnet-<purpose>-<region>-<sequence>`
  - Examples: `vnet-hub-uksouth-001`, `vnet-prod-uksouth-001`
- **Subnets within virtual networks**: `snet-<scope>-<purpose>`
  - Examples: `snet-prod-app-tier`, `snet-hub-shared-services`
- **Azure-required subnets**: keep their mandated names exactly
  - GatewaySubnet, AzureFirewallSubnet, AzureBastionSubnet

## Required Tags

All virtual networks and subnets inherit the platform tagging standard defined in `docs/platform-standards.md`:

- Environment (Production, Non-production, Sandbox, Shared)
- Owner (CloudTeam for hub; respective workload teams for spokes)
- Department (Platform for hub; per-workload for spokes)
- Project (PlatformNetworking for hub; per-workload for spokes)

## Office Address Spaces (To Be Confirmed)

To prevent overlap with the Azure allocation, the three West Midlands offices' on-premises networks must use address ranges outside the `10.0.0.0/12` Azure reservation.

Verified compatible ranges include:

- `192.168.0.0/16` (and subdivisions)
- `172.16.0.0/12` (and subdivisions)

The exact ranges in use at each West Midlands office are to be confirmed before Virtual Private Network Gateway deployment in Lesson 19. Any overlap with the Azure allocation must be resolved through office-side re-addressing before Site-to-Site VPN connectivity is configured.

## Open Items

| Item | Owner | Resolution Plan |
|---|---|---|
| Confirm on-premises Internet Protocol ranges at each of the three West Midlands offices | Cloud platform engineer | Before Lesson 19 (Virtual Private Network Gateway) |
| Decide detailed subnet sizing for sandbox spoke | Cloud platform engineer | When sandbox is first deployed |
| Decide approach for fully remote worker direct-to-Azure access | Cloud platform engineer | Later in Project 2 |
| Decide whether to upgrade to ExpressRoute in future | Cloud platform engineer | Reviewed annually as scale grows |

## Lab vs Production Deltas

| Item | Lab State | Production State at Scale |
|---|---|---|
| Number of hubs | One (single region) | Multi-region hubs connected via Azure Virtual WAN |
| Number of spokes | Three (production, non-production, sandbox) | Typically 10 to 50, structured by business unit or workload |
| External connectivity | Single Virtual Private Network Gateway, Site-to-Site VPN | ExpressRoute with VPN as failover for higher-bandwidth deployments |
| Firewall | Azure Firewall Standard | Azure Firewall Premium or third-party network virtual appliance at larger scale |
| Address planning horizon | 10 years | 20+ years, with explicit headroom for acquisitions |
| Multi-region resilience | Not configured | Active-active or active-passive failover with global load balancing |

## Target State

In the mature platform:

- Multi-region hub-and-spoke (UK South primary, UK West secondary)
- ExpressRoute connectivity to office sites
- Azure Firewall Premium with TLS inspection and intrusion detection
- Private endpoints for every Platform-as-a-Service resource
- Network design defined as Infrastructure as Code (Bicep, then Terraform)
- Network monitoring through Network Watcher and Microsoft Sentinel integration
- Automated subnet allocation registry to prevent address conflicts as new spokes are added

## Reference Diagram

A reference diagram of the hub-and-spoke topology will be added at `diagrams/network-topology.png` (or `.svg`) once initial deployment begins in Lesson 17. The diagram will show:

- The hub at the centre with its three Azure-required subnets and the shared services subnet
- The production and non-production spokes connected via peering
- The three West Midlands offices connected via Site-to-Site VPN
- The Azure Firewall as the inspection point for inter-spoke and egress traffic
- The Azure Bastion as the administrative access point

## Document Maintenance

This document is the architectural source of truth for the network design. It is updated when:

- A new spoke is added or removed
- Address allocations change
- Peering relationships are added, removed, or modified
- Office connectivity changes (additional sites, ExpressRoute migration)
- Open items are resolved