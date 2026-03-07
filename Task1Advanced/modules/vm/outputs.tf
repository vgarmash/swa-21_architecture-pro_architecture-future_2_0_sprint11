# =============================================================================
# VM Module - Outputs
# =============================================================================

output "vm_id" {
  description = "ID of the created virtual machine"
  value       = yandex_compute_instance.vm.id
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = yandex_compute_instance.vm.name
}

output "vm_folder_id" {
  description = "Folder ID where the VM was created"
  value       = yandex_compute_instance.vm.folder_id
}

output "vm_zone" {
  description = "Availability zone of the VM"
  value       = yandex_compute_instance.vm.zone
}

output "internal_ip_address" {
  description = "Internal IPv4 address of the VM"
  value       = yandex_compute_instance.vm.network_interface.0.ip_address
}

output "external_ip_address" {
  description = "Public IPv4 address of the VM (if assigned)"
  value       = yandex_compute_instance.vm.network_interface.0.nat_ip_address
}

output "mac_address" {
  description = "MAC address of the VM network interface"
  value       = yandex_compute_instance.vm.network_interface.0.mac_address
}

output "subnet_id" {
  description = "ID of the subnet the VM is connected to"
  value       = yandex_compute_instance.vm.network_interface.0.subnet_id
}

output "boot_disk_id" {
  description = "ID of the VM boot disk"
  value       = yandex_compute_instance.vm.boot_disk.0.disk_id
}

output "data_disk_id" {
  description = "ID of the attached data disk (if created)"
  value       = var.data_disk_enabled ? yandex_compute_disk.data_disk.0.id : null
}

output "data_disk_name" {
  description = "Name of the attached data disk (if created)"
  value       = var.data_disk_enabled ? yandex_compute_disk.data_disk.0.name : null
}

output "ssh_connection_string" {
  description = "SSH connection string"
  value       = "${var.ssh_username}@${yandex_compute_instance.vm.network_interface.0.nat_ip_address}"
}

output "ssh_command" {
  description = "SSH connection command"
  value       = "ssh ${var.ssh_username}@${yandex_compute_instance.vm.network_interface.0.nat_ip_address}"
}

output "instance_info" {
  description = "Summary information about the VM"
  value = {
    id                  = yandex_compute_instance.vm.id
    name                = yandex_compute_instance.vm.name
    zone                = yandex_compute_instance.vm.zone
    cores               = tostring(yandex_compute_instance.vm.resources.0.cores)
    memory_gb           = tostring(yandex_compute_instance.vm.resources.0.memory)
    internal_ip         = yandex_compute_instance.vm.network_interface.0.ip_address
    external_ip         = yandex_compute_instance.vm.network_interface.0.nat_ip_address
    boot_disk_id        = yandex_compute_instance.vm.boot_disk.0.disk_id
    data_disk_id        = var.data_disk_enabled ? yandex_compute_disk.data_disk.0.id : "N/A"
    ssh_connection      = "${var.ssh_username}@${yandex_compute_instance.vm.network_interface.0.nat_ip_address}"
  }
}
