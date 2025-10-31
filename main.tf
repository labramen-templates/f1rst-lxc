resource "proxmox_lxc" "container" {
  target_node  = var.proxmox_node
  hostname     = var.hostname
  ostemplate   = var.template
  unprivileged = true
  onboot       = true
  start        = true
  
  # Root password for initial SSH access
  password = var.root_password
  
  # SSH keys (optional)
  ssh_public_keys = var.ssh_public_keys != "" ? var.ssh_public_keys : null
  
  # Resources
  cores  = var.cores
  memory = var.memory
  
  # Root filesystem
  rootfs {
    storage = var.storage
    size    = var.disk_size
  }
  
  # Network
  network {
    name   = "eth0"
    bridge = var.network_bridge
    ip     = "dhcp"
    ip6    = "auto"
  }
  
  # Features
  features {
    nesting = true  # Allow Docker/nested containers if needed
  }
  
  # Wait for network to be ready
  lifecycle {
    ignore_changes = [
      # Ignore manual changes to these
      description,
    ]
  }
}

# Output the container ID and IP
output "container_id" {
  description = "The VMID of the created container"
  value       = proxmox_lxc.container.vmid
}

output "container_hostname" {
  description = "The hostname of the container"
  value       = proxmox_lxc.container.hostname
}

output "container_ip" {
  description = "The IP address of the container (may take a moment to populate)"
  value       = try(proxmox_lxc.container.network[0].ip, "Pending DHCP...")
}
