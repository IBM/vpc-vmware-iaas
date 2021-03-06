

##############################################################
# Create private SSH key for Bare Metal Server
# Name of SSH Public Key stored in IBM Cloud must be unique within the Account
##############################################################

resource "tls_private_key" "host_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "write_private_key" {
  content         = tls_private_key.host_ssh.private_key_pem
  filename        = "SSH_KEYS/${local.resources_prefix}-esx_host_rsa"
  file_permission = 0600
}


# Public SSH key used to connect to the servers
resource "ibm_is_ssh_key" "host_ssh_key" {

  name       = "${local.resources_prefix}-host-ssh-key"
  public_key = trimspace(tls_private_key.host_ssh.public_key_openssh)
  resource_group = data.ibm_resource_group.resource_group_vmw.id

  tags = local.resource_tags.ssh_key
}

