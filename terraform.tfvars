# Services deployment options

deploy_dns = false
deploy_fileshare = false
deploy_iam = false
enable_vcf_mode = true
deploy_bastion = true


# Resource group name to use
# leave empty if you want to provision a new resource group

resource_group_name = "Default"


# Resource prefix for naming assets

resource_prefix = "vcf"


# DNS root domain

dns_root_domain = "vcf-test-1.ibmcloud.local"


# IBM CLoud Region and VPC Zone

ibmcloud_vpc_region = "us-south"
vpc_zone = "us-south-1"


# Hosts and clusters

zone_clusters = {
      cluster_0 = { 
         name = "type1"
         #vmw_host_profile = "bx2d-metaldev8-192x768"
         vmw_host_profile = "bx2d-metaldev8-160x768"
         host_count = 4 
         vpc_file_shares = [ ] 
         },
      cluster_1 = { 
         name = "type2"
         vmw_host_profile = "bx2d-metaldev8-160x768"
         host_count = 0 
         vpc_file_shares = [ ] 
         },
   }


# Networking

vpc_zone_prefix = "10.100.0.0/22" # infrastucture subnets
vpc_zone_prefix_t0_uplinks = "192.168.10.0/24" # edge and tier 0 gateway subnets

vcf_avn_local_network_prefix = "172.27.16.0/24" # avn overlay local subnet
vcf_avn_x_region_network_prefix = "172.27.16.0/24" # avn overlay x-region subnet

vcf_avn_dns_records = {
     lcm = {
       name = "xint-vrslcm01"
       ip_address = "172.27.17.20"
     },
   }




mgmt_vlan_id = 1611
vmot_vlan_id = 1612
vsan_vlan_id = 1613
tep_vlan_id	= 1614

edge_uplink_public_vlan_id	= 2711
edge_uplink_private_vlan_id = 2712
edge_tep_vlan_id = 2713

vcf_host_pool_size = 10
vcf_edge_pool_size = 2   # Note two TEPs per edge nodes in VCF >> double reservation done in resource 

vpc_t0_public_ips = 1


# Network security

security_group_rules = {
      "mgmt" = [
         {
            name      = "allow-all-mgmt"
            direction = "inbound"
            remote_id = "mgmt"
         },
         {
            name      = "allow-inbound-10-8"
            direction = "inbound"
            remote    = "10.0.0.0/8"
         },
         {
            name      = "allow-outbound-any"
            direction = "outbound"
            remote    = "0.0.0.0/0"
         }
      ]
      "vmot" = [
         {
            name      = "allow-icmp-mgmt"
            direction = "inbound"
            remote_id = "mgmt"
            icmp = {
            type = 8
            }
         },
         {
            name      = "allow-inbound-vmot"
            direction = "inbound"
            remote_id = "vmot"
         },
         {
            name      = "allow-outbound-vmot"
            direction = "outbound"
            remote_id = "vmot"
         }
      ]
      "vsan" = [
         {
            name      = "allow-icmp-mgmt"
            direction = "inbound"
            remote_id = "mgmt"
            icmp = {
            type = 8
            }
         },
         {
            name      = "allow-inbound-vsan"
            direction = "inbound"
            remote_id = "vsan"
         },
         {
            name      = "allow-outbound-vsan"
            direction = "outbound"
            remote_id = "vsan"
         }
      ]
      "tep" = [
         {
            name      = "allow-icmp-mgmt"
            direction = "inbound"
            remote_id = "mgmt"
            icmp = {
            type = 8
            }
         },
         {
            name      = "allow-inbound-tep"
            direction = "inbound"
            remote_id = "tep"
         },
         {
            name      = "allow-outbound-tep"
            direction = "outbound"
            remote_id = "tep"
         }
      ]
        "uplink-pub" = [
          {
            name      = "allow-inbound-any"
            direction = "inbound"
            remote    = "0.0.0.0/0"
            icmp = {
              type = 8
            }
          },
          {
            name      = "allow-outbound-any"
            direction = "outbound"
            remote    = "0.0.0.0/0"
          }
        ],
        "uplink-priv" = [
          {
            name      = "allow-inbound-any"
            direction = "inbound"
            remote    = "0.0.0.0/0"
          },
          {
            name      = "allow-outbound-any"
            direction = "outbound"
            remote    = "0.0.0.0/0"
          }
        ],
        "bastion" = [
          {
            name      = "allow-inbound-rdp"
            direction = "inbound"
            remote    = "0.0.0.0/0"
            tcp = {
              port_max = 3389
              port_min = 3389             
            }
          },
          {
            name      = "allow-outbound-any"
            direction = "outbound"
            remote    = "0.0.0.0/0"
          }
        ]
  }

