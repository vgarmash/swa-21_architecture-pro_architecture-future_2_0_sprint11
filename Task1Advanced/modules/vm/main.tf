# =============================================================================
# VM Module - Main Configuration
# =============================================================================
# Модуль создаёт виртуальную машину в Yandex Cloud с подключаемым диском
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

# -----------------------------------------------------------------------------
# Локальные значения
# -----------------------------------------------------------------------------

locals {
  # Имя диска данных: используем заданное имя или генерируем на основе имени ВМ
  data_disk_name = var.data_disk_enabled ? (
    var.data_disk_name != null ? var.data_disk_name : "${var.vm_name}-data-disk"
  ) : null

  # Метаданные с SSH-ключом
  ssh_metadata = {
    ssh-keys = "${var.ssh_username}:${var.ssh_public_key}"
  }

  # Объединённые метаданные
  all_metadata = merge(local.ssh_metadata, var.metadata)
}

# -----------------------------------------------------------------------------
# Диск данных (подключаемый)
# -----------------------------------------------------------------------------

resource "yandex_compute_disk" "data_disk" {
  count = var.data_disk_enabled ? 1 : 0

  name      = local.data_disk_name
  type      = var.data_disk_type
  size      = var.data_disk_size_gb
  zone      = var.zone
  folder_id = var.folder_id
  labels    = var.labels

  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Виртуальная машина
# -----------------------------------------------------------------------------

resource "yandex_compute_instance" "vm" {
  name        = var.vm_name
  description = "VM created by Terraform VM Module"
  zone        = var.zone
  folder_id   = var.folder_id
  labels      = var.labels

  # Ресурсы вычислительной машины
  resources {
    cores         = var.cpu_cores
    memory        = var.memory_gb
    core_fraction = var.core_fraction
  }

  # Загрузочный диск
  boot_disk {
    initialize_params {
      image_id = var.boot_disk_image
      name     = "${var.vm_name}-boot-disk"
      type     = var.boot_disk_type
      size     = var.boot_disk_size_gb
    }
  }

  # Подключаемый диск данных
  dynamic "secondary_disk" {
    for_each = var.data_disk_enabled ? [1] : []
    content {
      disk_id  = yandex_compute_disk.data_disk[0].id
      auto_delete = false
    }
  }

  # Сетевой интерфейс
  network_interface {
    subnet_id          = var.subnet_id
    ip_address         = var.ipv4_address
    nat                = var.assign_public_ip
    security_group_ids = length(var.security_group_ids) > 0 ? var.security_group_ids : null
  }

  # Сервисный аккаунт
  service_account_id = var.service_account_id

  # Метаданные (SSH-ключи и др.)
  metadata = local.all_metadata

  # Настройки жизненного цикла
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      metadata,
    ]
  }
}
