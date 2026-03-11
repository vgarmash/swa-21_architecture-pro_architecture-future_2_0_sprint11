# =============================================================================
# Terraform Provider Configuration
# =============================================================================

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.100.0"
    }
  }
}

# Provider configuration will be set via environment variables:
# YC_TOKEN, YC_CLOUD_ID, YC_FOLDER_ID

# =============================================================================
# VPC Network and Subnet
# =============================================================================

resource "yandex_vpc_network" "this" {
  name      = var.vpc_name
  folder_id = var.yc_folder_id

  labels = {
    environment = var.environment
    project     = var.project_name
  }
}

resource "yandex_vpc_subnet" "this" {
  name           = var.subnet_name
  folder_id      = var.yc_folder_id
  zone           = var.subnet_zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [var.subnet_cidr]

  labels = {
    environment = var.environment
    project     = var.project_name
  }
}

# =============================================================================
# VM Module Invocation
# =============================================================================

module "vm" {
  source = "../../modules/vm"

  # Основные параметры
  vm_name   = var.vm_name
  folder_id = var.yc_folder_id
  zone      = var.yc_zone

  # Ресурсы вычислительной машины
  cpu_cores     = var.vm_cpu_cores
  memory_gb     = var.vm_memory_gb
  core_fraction = var.vm_core_fraction

  # Загрузочный диск
  boot_disk_image   = var.boot_disk_image
  boot_disk_size_gb = var.boot_disk_size_gb
  boot_disk_type    = var.boot_disk_type

  # Диск данных
  data_disk_enabled   = true
  data_disk_size_gb   = var.data_disk_size_gb
  data_disk_type      = var.data_disk_type
  data_disk_name      = "${var.vm_name}-data-disk"

  # Сеть
  subnet_id          = yandex_vpc_subnet.this.id
  security_group_ids = []
  assign_public_ip   = true

  # SSH доступ
  ssh_public_key = var.ssh_public_key
  ssh_username   = var.ssh_username

  # Метки
  labels = merge(
    {
      environment = var.environment
      project     = var.project_name
      managed_by  = "terraform"
    },
    var.additional_labels
  )
}

# =============================================================================
# Outputs
# =============================================================================

output "vm_id" {
  description = "ID виртуальной машины"
  value       = module.vm.vm_id
}

output "vm_name" {
  description = "Имя виртуальной машины"
  value       = module.vm.vm_name
}

output "internal_ip" {
  description = "Внутренний IP-адрес ВМ"
  value       = module.vm.internal_ip_address
}

output "external_ip" {
  description = "Публичный IP-адрес ВМ"
  value       = module.vm.external_ip_address
}

output "ssh_command" {
  description = "Команда для SSH-подключения"
  value       = module.vm.ssh_command
}

output "data_disk_id" {
  description = "ID диска данных"
  value       = module.vm.data_disk_id
}

output "network_id" {
  description = "ID VPC сети"
  value       = yandex_vpc_network.this.id
}

output "subnet_id" {
  description = "ID подсети"
  value       = yandex_vpc_subnet.this.id
}

output "instance_summary" {
  description = "Сводная информация о ВМ"
  value       = module.vm.instance_info
}
