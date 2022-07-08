##############################################################
##############################################################
# Define outputs
##############################################################
##############################################################



##############################################################
# Output resources_prefix
##############################################################

output "resources_prefix" {
  value = local.resources_prefix
}


##############################################################
#  Output resource group id
##############################################################

output "resource_group_id" {
    value = data.ibm_resource_group.resource_group_vmw.id
}
   

##############################################################
#  Output zone VPC subnets
##############################################################

output "zone_subnets" {
  value = local.subnets
}


##############################################################
#  Output DNS root domain
##############################################################

output "dns_root_domain" {
  value = var.dns_root_domain
}


##############################################################
#  Output cluster hosts
##############################################################

output "cluster_host_map_out" {
  value = local.cluster_host_map
}


/*

locals {
    cluster_host_map_out_json = jsonencode(local.cluster_host_map)
}


output "cluster_host_map_out_json" {
  value = local.cluster_host_map_out_json
}

*/

##############################################################
#  Output vcenter
##############################################################

output "vcenter" {
  value = local.vcenter
}


##############################################################
#  Output NSX-T
##############################################################


output "zone_nsx_t_mgr" {
  value = local.nsx_t_mgr
}



##############################################################
#  Output NSX-T edge and T0
##############################################################

output "zone_nsx_t_edge" {
  value = local.nsx_t_edge
}

output "zone_subnets_edge" {
  value = local.nsxt_edge_subnets
}

output "nsx_t_t0" {
  value = local.nsx_t_t0
}

output "t0_public_ips" {
  value = ibm_is_floating_ip.floating_ip[*].address
}


##############################################################
# Output VCF 
##############################################################



output "vcf" {
  value = var.enable_vcf_mode ? local.vcf : {}
}

output "vcf_pools" {
  value = var.enable_vcf_mode ? local.vcf_pools : {}
}

output "vcf_vlan_nics" {
  value = var.enable_vcf_mode ? local.vcf_vlan_nics : {}
}



##############################################################
# Output Windows server
##############################################################


output "vpc_bastion" {
  value = var.deploy_bastion ? local.bastion : {}
  sensitive = true
}



##############################################################
# Output VPC routes
##############################################################

/*
output "created_vpc_routes_default_egress" {
    value = local.vpc_routes_default_egress
}

output "created_vpc_routes_tgw_dl_ingress" {
    value = local.vpc_routes_tgw_dl_ingress
}
*/

output "routes_default_egress_per_zone" {
    value = local.vpc_egress_routes_per_zone
}


output "routes_tgw_dl_ingress_egress_per_zone" {
    value = local.vpc_tgw_dl_ingress_routes_per_zone
}
