
### Provider

variable "ibmcloud_api_key" {
  description = "Enter your IBM Cloud API Key"
}

### Resource prefix for each item

variable "resource_prefix" {
  description = "Resource Group Prefix to create in the IBM Cloud account"
  default = "vmw"
}


### Deployment option variables

variable "deploy_iam" {
  description = "Boolean to enable IAM deployment."
  default = true
}

variable "deploy_fileshare" {
  description = "Boolean to enable fileshare deployment. Alternatively customize the cluster map."
  default = true
}

variable "deploy_dns" {
  description = "Boolean to enable DNS service deployment."
  default = true
}

variable "enable_vcf_mode" {
  description = "Boolean to enable VCF options for BMS deployment (dual PCI uplinks and vmk1 in instance management subnet)."
  default = false
}


### DNS root domain

variable "dns_root_domain" {
  description = "Root Domain of Private DNS used with the Virtual Server"
  default = "vmw-terraform.ibmcloud.local"
}

### IBM Cloud Region variables

variable "ibmcloud_vpc_region" {
  description = "Enter the target Region of IBM Cloud"
  default = "eu-de"
}

variable "vpc_zone" {
  description = "VPC Zone"
  default     = "eu-de-1"
}

variable "vpc_zone_prefix" {
  description = "This is the address prefix for VMware components for each zone. /22 is recommended for appx. 120 hosts, /23 for appx. 60 hosts etc."
  default  = "10.100.0.0/22"
}


variable "vpc_name" {
  description = "Name of the VPC to create."
  default     = "vpc"
}


variable "vpc_zone_subnet_size" {
  description = "This is the number of additional bits with which to extend the prefix for each VMware infrastructure subnet."
  default     = 3 
}

variable "vpc_zone_prefix_t0_uplinks" {
  description = "This is the NSX-T uplink address prefix for each zone."
  default  = "192.168.10.0/24"
}

variable "vpc_zone_t0_uplinks_subnet_size" {
  description = "This is the number of additional bits with which to extend the prefix for each uplink subnet."
  default     = 4 
}

variable "vpc_t0_public_ips" {
  description = "Number of public / floating IPs for T0."
  default     = 0 
}

# Use 'ibmcloud is images | grep esx' to get the images for esx.
/*
variable "vmw_esx_image_name" {
  description = "ESX image - default IBM license"
#  default = "r010-85e78310-b809-4e03-9257-52c7959435ea"
#  default = "ibm-esxi-7-amd64-1"
   default = "ibm-esxi-7-amd64-3-tes"
}
*/
  
variable "esxi_image" {
  description = "Base ESXI image name, terraform will find the latest available image id"
  default = "esxi-7-byol"
}

# vCenter will be deployed in the first cluster "cluster_0". Please do not change the key if adding new clusters. See examples for alternate configs. 

# Use 'ibmcloud is bare-metal-server-profiles' to get the profiles.

variable "zone_clusters" {
  description = "Clusters in VPC"
  type        = map
  default     = {
    cluster_0 = {
      name = "mgmt"
      vmw_host_profile = "bx2d-metal-96x384"
      host_count = 1
      vpc_file_shares = [
        {
          name = "cluster0_share1" 
          size = 500 
          profile = "tier-3iops" 
          target = "cluster0_share1_target"
        }
      ]
    }
  }
}

# Security Groups Rules

variable "security_group_rules" {

    description = "Security group Rules to create"
    #type        = map
    default = {
        "mgmt" = [
          {
            name      = "allow-icmp-mgmt"
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
        "uplink" = [
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
        ]
    }
}

### VPC Subnets

variable "vpc" {
    description = "VPC Data Structure"
    type        = map
    default = {
      vpc = {
        zones = {
            vpc_zone = {
              infrastructure = {
                  vpc_zone_prefix = "10.100.0.0/22"
                  vpc_zone_subnet_size = 3
                  public_gateways = ["subnet-public-gateway"]
                  subnets = {
                    host-mgmt = {
                        cidr_offset = 0
                        ip_version = "ipv4"
                    },
                    inst-mgmt = {
                        cidr_offset = 1
                        ip_version = "ipv4"
                        public_gateway = "subnet-public-gateway"
                    },
                    vmot = {
                        cidr_offset = 2
                        ip_version = "ipv4"
                    },
                    vsan = {
                        cidr_offset = 3
                        ip_version = "ipv4"
                    },
                    tep = {
                        cidr_offset = 4
                        ip_version = "ipv4"
                    }
                }
              },
              t0-uplink = {
                  vpc_zone_prefix = "192.168.10.0/24"
                  vpc_zone_subnet_size = 4
                  subnets = {
                    t0-priv = {
                        cidr_offset = 0
                        ip_version = "ipv4"
                    },
                    t0-pub = {
                        cidr_offset = 1
                        ip_version = "ipv4"
                    }
                  }
              }
            }
        }
      }
    }
}