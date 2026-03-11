# =============================================================================
# Variables для окружений
# =============================================================================
# Переменные уровня окружения (dev, stage, prod)
# =============================================================================

# -----------------------------------------------------------------------------
# Yandex Cloud параметры
# -----------------------------------------------------------------------------

variable "yc_token" {
  description = "OAuth-токен для аутентификации в Yandex Cloud"
  type        = string
  sensitive   = true
}

variable "yc_cloud_id" {
  description = "ID облака Yandex Cloud"
  type        = string
}

variable "yc_folder_id" {
  description = "ID каталога Yandex Cloud"
  type        = string
}

variable "yc_zone" {
  description = "Зона доступности"
  type        = string
  default     = "ru-central1-a"
}

# -----------------------------------------------------------------------------
# Сетевые параметры
# -----------------------------------------------------------------------------

variable "vpc_name" {
  description = "Имя VPC сети"
  type        = string
}

variable "subnet_name" {
  description = "Имя подсети"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR блок подсети"
  type        = string
}

variable "subnet_zone" {
  description = "Зона доступности подсети"
  type        = string
}

# -----------------------------------------------------------------------------
# Параметры виртуальной машины
# -----------------------------------------------------------------------------

variable "vm_name" {
  description = "Имя виртуальной машины"
  type        = string
}

variable "vm_cpu_cores" {
  description = "Количество ядер CPU"
  type        = number
}

variable "vm_memory_gb" {
  description = "Объём оперативной памяти в ГБ"
  type        = number
}

variable "vm_core_fraction" {
  description = "Гарантированная доля CPU (%)"
  type        = number
  default     = 100
}

# -----------------------------------------------------------------------------
# Параметры дисков
# -----------------------------------------------------------------------------

variable "boot_disk_image" {
  description = "ID образа ОС для загрузочного диска"
  type        = string
}

variable "boot_disk_size_gb" {
  description = "Размер загрузочного диска в ГБ"
  type        = number
  default     = 20
}

variable "boot_disk_type" {
  description = "Тип загрузочного диска"
  type        = string
  default     = "network-ssd"
}

variable "data_disk_size_gb" {
  description = "Размер диска данных в ГБ"
  type        = number
  default     = 50
}

variable "data_disk_type" {
  description = "Тип диска данных"
  type        = string
  default     = "network-ssd"
}

# -----------------------------------------------------------------------------
# SSH доступ
# -----------------------------------------------------------------------------

variable "ssh_public_key" {
  description = "Публичный SSH-ключ"
  type        = string
  sensitive   = true
}

variable "ssh_username" {
  description = "Имя пользователя для SSH"
  type        = string
  default     = "ubuntu"
}

# -----------------------------------------------------------------------------
# Метки и теги
# -----------------------------------------------------------------------------

variable "environment" {
  description = "Имя окружения (dev, stage, prod)"
  type        = string
}

variable "project_name" {
  description = "Имя проекта"
  type        = string
  default     = "future-2-0"
}

variable "additional_labels" {
  description = "Дополнительные метки"
  type        = map(string)
  default     = {}
}
