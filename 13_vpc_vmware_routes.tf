
##############################################################
# Create VPC ingress routing table to NSX-T overlay networks
##############################################################


resource "ibm_is_vpc_routing_table" "nsxt_overlay_route_table_ingress" {
    name                          = "${local.resources_prefix}-nsx-t-ingress-routing-table"
    vpc                           = module.vpc-subnets[var.vpc_name].vmware_vpc.id
    route_direct_link_ingress     = true
    route_transit_gateway_ingress = true
    route_vpc_zone_ingress        = true

    depends_on  = [
      module.vpc-subnets,
      module.zone_nxt_t_edge
    ] 
}


##############################################################
# Create VPC egress routes to NSX-T overlay networks
##############################################################


resource "ibm_is_vpc_routing_table_route" "zone_1_nsxt_overlay_routes" {
    for_each      = var.nsx_t_overlay_networks

    name          = "nsx-t-${each.value.name}-${var.ibmcloud_vpc_region}-1"

    vpc           = module.vpc-subnets[var.vpc_name].vmware_vpc.id
    routing_table = module.vpc-subnets[var.vpc_name].vmware_vpc.default_routing_table
    zone          = "${var.ibmcloud_vpc_region}-1"

    destination   = each.value.destination
    action        = "deliver"
    next_hop      = local.nsx_t_t0.ha-vip.private_uplink.ip_address

    depends_on  = [
      module.vpc-subnets,
      module.zone_nxt_t_edge,
    ] 
}

resource "ibm_is_vpc_routing_table_route" "zone_2_nsxt_overlay_routes" {
    for_each      = var.nsx_t_overlay_networks

    name          = "nsx-t-${each.value.name}-${var.ibmcloud_vpc_region}-2"

    vpc           = module.vpc-subnets[var.vpc_name].vmware_vpc.id
    routing_table = module.vpc-subnets[var.vpc_name].vmware_vpc.default_routing_table
    zone          = "${var.ibmcloud_vpc_region}-2"

    destination   = each.value.destination
    action        = "deliver"
    next_hop      = local.nsx_t_t0.ha-vip.private_uplink.ip_address

    depends_on  = [
      module.vpc-subnets,
      module.zone_nxt_t_edge,
    ] 
}

resource "ibm_is_vpc_routing_table_route" "zone_3_nsxt_overlay_routes" {
    for_each      = var.nsx_t_overlay_networks

    name          = "nsx-t-${each.value.name}-${var.ibmcloud_vpc_region}-3"

    vpc           = module.vpc-subnets[var.vpc_name].vmware_vpc.id
    routing_table = module.vpc-subnets[var.vpc_name].vmware_vpc.default_routing_table
    zone          = "${var.ibmcloud_vpc_region}-3"

    destination   = each.value.destination
    action        = "deliver"
    next_hop      = local.nsx_t_t0.ha-vip.private_uplink.ip_address

    depends_on  = [
      module.vpc-subnets,
      module.zone_nxt_t_edge,
    ] 
}



##############################################################
# Create VPC ingress routes to NSX-T overlay networks
##############################################################

# Note...VPC routes outside VPC prefix are not advertised to TGW or Direct Link  
# this is a workaround before the capability is available.

resource "ibm_is_vpc_address_prefix" "nsx_t_overlay_prefix" {
    for_each    = var.nsx_t_overlay_networks
    name = "prefix-nsx-t-${each.value.name}-${var.vpc_zone}"

    vpc  = module.vpc-subnets[var.vpc_name].vmware_vpc.id
    zone = var.vpc_zone # prefix is created only on the zone where VMware is deployed

    cidr = each.value.destination

    depends_on  = [
      module.vpc-subnets,
      module.zone_nxt_t_edge
    ] 
}


resource "ibm_is_vpc_routing_table_route" "zone_1_nsxt_overlay_routes_ingress" {
    for_each      = var.nsx_t_overlay_networks

    name          = "nsx-t-${each.value.name}-${var.ibmcloud_vpc_region}-1"

    vpc           = module.vpc-subnets[var.vpc_name].vmware_vpc.id
    routing_table = ibm_is_vpc_routing_table.nsxt_overlay_route_table_ingress.routing_table
    zone          = "${var.ibmcloud_vpc_region}-1"

    destination   = each.value.destination
    action        = "deliver"
    next_hop      = local.nsx_t_t0.ha-vip.private_uplink.ip_address

    depends_on  = [
      module.vpc-subnets,
      module.zone_nxt_t_edge,
      ibm_is_vpc_address_prefix.nsx_t_overlay_prefix,
      ibm_is_vpc_routing_table.nsxt_overlay_route_table_ingress
    ] 
}

resource "ibm_is_vpc_routing_table_route" "zone_2_nsxt_overlay_routes_ingress" {
    for_each      = var.nsx_t_overlay_networks

    name          = "nsx-t-${each.value.name}-${var.ibmcloud_vpc_region}-2"

    vpc           = module.vpc-subnets[var.vpc_name].vmware_vpc.id
    routing_table = ibm_is_vpc_routing_table.nsxt_overlay_route_table_ingress.routing_table
    zone          = "${var.ibmcloud_vpc_region}-2"

    destination   = each.value.destination
    action        = "deliver"
    next_hop      = local.nsx_t_t0.ha-vip.private_uplink.ip_address

    depends_on  = [
      module.vpc-subnets,
      module.zone_nxt_t_edge,
      ibm_is_vpc_address_prefix.nsx_t_overlay_prefix,
      ibm_is_vpc_routing_table.nsxt_overlay_route_table_ingress
    ] 
}

resource "ibm_is_vpc_routing_table_route" "zone_3_nsxt_overlay_routes_ingress" {
    for_each      = var.nsx_t_overlay_networks

    name          = "nsx-t-${each.value.name}-${var.ibmcloud_vpc_region}-3"

    vpc           = module.vpc-subnets[var.vpc_name].vmware_vpc.id
    routing_table = ibm_is_vpc_routing_table.nsxt_overlay_route_table_ingress.routing_table
    zone          = "${var.ibmcloud_vpc_region}-3"

    destination   = each.value.destination
    action        = "deliver"
    next_hop      = local.nsx_t_t0.ha-vip.private_uplink.ip_address

    depends_on  = [
      module.vpc-subnets,
      module.zone_nxt_t_edge,
      ibm_is_vpc_address_prefix.nsx_t_overlay_prefix,
      ibm_is_vpc_routing_table.nsxt_overlay_route_table_ingress
    ] 
}




##############################################################
# Get all VPC routes to display
##############################################################


data "ibm_is_vpc_routing_table_routes" "routes_default_egress" {
    vpc           = module.vpc-subnets[var.vpc_name].vmware_vpc.id
    routing_table = module.vpc-subnets[var.vpc_name].vmware_vpc.default_routing_table

    depends_on  = [
      module.vpc-subnets,
      module.zone_nxt_t_edge,
      ibm_is_vpc_routing_table_route.zone_1_nsxt_overlay_routes,
      ibm_is_vpc_routing_table_route.zone_2_nsxt_overlay_routes,
      ibm_is_vpc_routing_table_route.zone_3_nsxt_overlay_routes
    ] 
}

# Create a list of all routes

locals {
  vpc_routes_default_egress = [
    for route in data.ibm_is_vpc_routing_table_routes.routes_default_egress.routes : {
      "name" : route.name,
      "destination" : route.destination,
      "nexthop" : route.nexthop,
      "zone" : route.zone,
    }
  ]
}


# Create a view per zone

locals {
  vpc_egress_routes_per_zone = {
    "${var.ibmcloud_vpc_region}-1" = toset([for each in local.vpc_routes_default_egress : each if each.zone == "${var.ibmcloud_vpc_region}-1"])
    "${var.ibmcloud_vpc_region}-2" = toset([for each in local.vpc_routes_default_egress : each if each.zone == "${var.ibmcloud_vpc_region}-2"])
    "${var.ibmcloud_vpc_region}-3" = toset([for each in local.vpc_routes_default_egress : each if each.zone == "${var.ibmcloud_vpc_region}-3"])
  }
}



data "ibm_is_vpc_routing_table_routes" "routes_tgw_dl_ingress" {
    vpc           = module.vpc-subnets[var.vpc_name].vmware_vpc.id
    routing_table = ibm_is_vpc_routing_table.nsxt_overlay_route_table_ingress.routing_table

    depends_on  = [
      module.vpc-subnets,
      module.zone_nxt_t_edge,
      ibm_is_vpc_routing_table_route.zone_1_nsxt_overlay_routes_ingress,
      ibm_is_vpc_routing_table_route.zone_2_nsxt_overlay_routes_ingress,
      ibm_is_vpc_routing_table_route.zone_3_nsxt_overlay_routes_ingress
    ] 
}

# Create a list of all routes

locals {
  vpc_routes_tgw_dl_ingress = [
    for route in data.ibm_is_vpc_routing_table_routes.routes_default_egress.routes : {
      "name" : route.name,
      "destination" : route.destination,
      "nexthop" : route.nexthop,
      "zone" : route.zone,
    }
  ]
}

# Create a view per zone


locals {
  vpc_tgw_dl_ingress_routes_per_zone = {
    "${var.ibmcloud_vpc_region}-1" = toset([for each in local.vpc_routes_tgw_dl_ingress : each if each.zone == "${var.ibmcloud_vpc_region}-1"])
    "${var.ibmcloud_vpc_region}-2" = toset([for each in local.vpc_routes_tgw_dl_ingress : each if each.zone == "${var.ibmcloud_vpc_region}-2"])
    "${var.ibmcloud_vpc_region}-3" = toset([for each in local.vpc_routes_tgw_dl_ingress : each if each.zone == "${var.ibmcloud_vpc_region}-3"])
  }
}

