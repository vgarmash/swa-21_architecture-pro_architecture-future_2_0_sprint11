# =============================================================================
# VM Module Variables
# =============================================================================
# Универсальный модуль для создания виртуальных машин в Yandex Cloud
# =============================================================================

# -----------------------------------------------------------------------------
# Основные параметры виртуальной машины
# -----------------------------------------------------------------------------

variable "vm_name" {
  description = "Имя виртуальной машины"
  type        = string
}

variable "folder_id" {
  description = "ID каталога в Yandex Cloud, где будет создана ВМ"
  type        = string
}

variable "zone" {
  description = "Зона доступности Yandex Cloud (например, ru-central1-a)"
  type        = string
  default     = "ru-central1-a"
}

# -----------------------------------------------------------------------------
# Параметры вычислительных ресурсов (CPU и RAM)
# -----------------------------------------------------------------------------

variable "cpu_cores" {
  description = "Количество ядер CPU для виртуальной машины"
  type        = number
}

variable "memory_gb" {
  description = "Объём оперативной памяти в ГБ"
  type        = number
}

variable "core_fraction" {
  description = "Гарантированная доля CPU (например, 20, 50, 100)"
  type        = number
  default     = 100
}

# -----------------------------------------------------------------------------
# Параметры образа и загрузочного диска
# -----------------------------------------------------------------------------

variable "boot_disk_image" {
  description = "ID образа ОС для загрузочного диска (например, Ubuntu 22.04)"
  type        = string
  default     = "fd8k7q5f8p0vqjqvqjqv"
}

variable "boot_disk_size_gb" {
  description = "Размер загрузочного диска в ГБ"
  type        = number
  default     = 20
}

variable "boot_disk_type" {
  description = "Тип загрузочного диска (network-ssd, network-hdd, network-ssd-nonreplicated)"
  type        = string
  default     = "network-ssd"
}

# -----------------------------------------------------------------------------
# Параметры подключаемого диска данных
# -----------------------------------------------------------------------------

variable "data_disk_enabled" {
  description = "Флаг включения дополнительного диска данных"
  type        = bool
  default     = true
}

variable "data_disk_size_gb" {
  description = "Размер подключаемого диска данных в ГБ"
  type        = number
  default     = 50
}

variable "data_disk_type" {
  description = "Тип подключаемого диска (network-ssd, network-hdd, network-ssd-nonreplicated)"
  type        = string
  default     = "network-ssd"
}

variable "data_disk_name" {
  description = "Имя подключаемого диска данных"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Параметры сети
# -----------------------------------------------------------------------------

variable "subnet_id" {
  description = "ID подсети, к которой будет подключена ВМ"
  type        = string
}

variable "security_group_ids" {
  description = "Список ID групп безопасности"
  type        = list(string)
  default     = []
}

variable "assign_public_ip" {
  description = "Назначить ли публичный IP-адрес"
  type        = bool
  default     = true
}

variable "ipv4_address" {
  description = "Статический внутренний IPv4-адрес (опционально)"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Параметры аутентификации
# -----------------------------------------------------------------------------

variable "ssh_public_key" {
  description = "Публичный SSH-ключ для доступа к ВМ"
  type        = string
}

variable "ssh_username" {
  description = "Имя пользователя для SSH-доступа"
  type        = string
  default     = "ubuntu"
}

# -----------------------------------------------------------------------------
# Метаданные и сервисные аккаунты
# -----------------------------------------------------------------------------

variable "service_account_id" {
  description = "ID сервисного аккаунта для ВМ"
  type        = string
  default     = null
}

variable "metadata" {
  description = "Дополнительные метаданные ВМ (map of strings)"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Метки для ресурсов ВМ"
  type        = map(string)
  default     = {}
}
