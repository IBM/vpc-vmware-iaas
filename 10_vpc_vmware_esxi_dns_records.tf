

##############################################################
# Create DNS records for host management IPs
##############################################################

# Note to disable deployment for VPC DNS, 
# set var.deploy_dns to false

# Note the local cluster_host_map must be flattened 
# and converted to a new map create DNS records. 

locals {
  dns_entry_list = flatten ([
    for cluster in local.cluster_host_map.clusters.*: [ 
      for hosts in cluster.hosts.* : {
        "hostname" = hosts.host
        "mgmt_ip_address" = hosts.mgmt.ip_address
        }
      ]
    ])
  dns_entry_map = {
    for host in local.dns_entry_list :
      "${host.hostname}" => {
        "mgmt_ip_address" = host.mgmt_ip_address 
      }
    }
}




module "zone_dns_records_for_hosts" {
  source = "./modules/vpc-dns-record"
  #for_each = local.dns_entry_map
  for_each = var.deploy_dns ? local.dns_entry_map : {}

  #vmw_dns_instance_guid = ibm_resource_instance.dns_services_instance.guid
  vmw_dns_instance_guid = ibm_resource_instance.dns_services_instance[0].guid

  #vmw_dns_zone_id = ibm_dns_zone.dns_services_zone.zone_id
  vmw_dns_zone_id = ibm_dns_zone.dns_services_zone[0].zone_id

  vmw_dns_root_domain = var.dns_root_domain
  vmw_dns_type = "A"
  vmw_dns_name = each.key
  vmw_ip_address = each.value.mgmt_ip_address
  depends_on = [
    ibm_resource_instance.dns_services_instance,
    ibm_dns_zone.dns_services_zone,
    module.zone_bare_metal_esxi
  ]
}


##############################################################
# Create DNS record for vCenter in Zone 1
##############################################################


module "zone_dns_record_for_vcenter" {
  source = "./modules/vpc-dns-record"
  count =  var.deploy_dns ? 1 : 0

  #vmw_dns_instance_guid = ibm_resource_instance.dns_services_instance.guid
  vmw_dns_instance_guid = ibm_resource_instance.dns_services_instance[0].guid

  #vmw_dns_zone_id = ibm_dns_zone.dns_services_zone.zone_id
  vmw_dns_zone_id = ibm_dns_zone.dns_services_zone[0].zone_id

  vmw_dns_root_domain = var.dns_root_domain
  vmw_dns_name = "vcenter"
  vmw_dns_type = "A"
  vmw_ip_address = module.zone_vcenter.vmw_vcenter_ip
  depends_on = [
    ibm_resource_instance.dns_services_instance,
    ibm_dns_zone.dns_services_zone,
    module.zone_vcenter
  ]
}

module "zone_dns_ptr_for_vcenter" {
  source = "./modules/vpc-dns-record"
  count =  var.deploy_dns ? 1 : 0

  #vmw_dns_instance_guid = ibm_resource_instance.dns_services_instance.guid
  vmw_dns_instance_guid = ibm_resource_instance.dns_services_instance[0].guid

  #vmw_dns_zone_id = ibm_dns_zone.dns_services_zone.zone_id
  vmw_dns_zone_id = ibm_dns_zone.dns_services_zone[0].zone_id

  vmw_dns_root_domain = var.dns_root_domain
  vmw_dns_name = "vcenter"
  vmw_dns_type = "PTR"
  vmw_ip_address = module.zone_vcenter.vmw_vcenter_ip
  depends_on = [
    ibm_resource_instance.dns_services_instance,
    ibm_dns_zone.dns_services_zone,
    module.zone_vcenter,
    module.zone_dns_record_for_vcenter
  ]
}


##############################################################
# Create DNS record for NSX-T in Zone 1
##############################################################



module "zone_dns_record_for_nsxt_mgr" {
  source = "./modules/vpc-dns-record"
  #count = 3
  count =  var.deploy_dns ? 3 : 0

  #vmw_dns_instance_guid = ibm_resource_instance.dns_services_instance.guid
  vmw_dns_instance_guid = ibm_resource_instance.dns_services_instance[0].guid

  #vmw_dns_zone_id = ibm_dns_zone.dns_services_zone.zone_id
  vmw_dns_zone_id = ibm_dns_zone.dns_services_zone[0].zone_id

  vmw_dns_root_domain = var.dns_root_domain
  vmw_dns_type = "A"
  vmw_dns_name = "nsx-t-${count.index}"
  vmw_ip_address = module.zone_nxt_t.vmw_nsx_t_manager_ip[count.index].primary_ip[0].address
  depends_on = [
    ibm_resource_instance.dns_services_instance,
    ibm_dns_zone.dns_services_zone,
    module.zone_nxt_t
  ]
}

module "zone_dns_record_for_nsxt_mgr_vip" {
  source = "./modules/vpc-dns-record"
  count =  var.deploy_dns ? 1 : 0

  #vmw_dns_instance_guid = ibm_resource_instance.dns_services_instance.guid
  vmw_dns_instance_guid = ibm_resource_instance.dns_services_instance[0].guid

  #vmw_dns_zone_id = ibm_dns_zone.dns_services_zone.zone_id
  vmw_dns_zone_id = ibm_dns_zone.dns_services_zone[0].zone_id

  vmw_dns_root_domain = var.dns_root_domain
  vmw_dns_type = "A"
  vmw_dns_name = "nsx-t-vip"
  vmw_ip_address = module.zone_nxt_t.vmw_nsx_t_manager_ip_vip.primary_ip[0].address
  depends_on = [
    ibm_resource_instance.dns_services_instance,
    ibm_dns_zone.dns_services_zone,
    module.zone_nxt_t
  ]
}


module "zone_dns_record_for_nsxt_edge" {
  source = "./modules/vpc-dns-record"
  #count = 2
  count =  var.deploy_dns ? 2 : 0

  #vmw_dns_instance_guid = ibm_resource_instance.dns_services_instance.guid
  vmw_dns_instance_guid = ibm_resource_instance.dns_services_instance[0].guid

  #vmw_dns_zone_id = ibm_dns_zone.dns_services_zone.zone_id
  vmw_dns_zone_id = ibm_dns_zone.dns_services_zone[0].zone_id

  vmw_dns_root_domain = var.dns_root_domain
  vmw_dns_name = "edge-${count.index}"
  vmw_dns_type = "A"
  vmw_ip_address = module.zone_nxt_t_edge.vmw_nsx_t_edge_mgmt_ip[count.index].primary_ip[0].address
  depends_on = [
    ibm_resource_instance.dns_services_instance,
    ibm_dns_zone.dns_services_zone,
    module.zone_nxt_t
  ]
}
