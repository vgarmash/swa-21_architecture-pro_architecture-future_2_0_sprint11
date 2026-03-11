# VM Module для Yandex Cloud

Универсальный Terraform-модуль для создания виртуальных машин в Yandex Cloud с подключаемым диском данных.

## Описание

Модуль создаёт следующие ресурсы:
- Виртуальная машина (Compute Instance) с заданными параметрами CPU и RAM
- Загрузочный диск с выбранной ОС
- Подключаемый диск данных (опционально)
- Сетевой интерфейс с возможностью назначения публичного IP

## Структура модуля

```
modules/vm/
├── main.tf        # Основные ресурсы (ВМ + диск + сеть)
├── variables.tf   # Входные параметры модуля
├── outputs.tf     # Выходные значения
└── README.md      # Эта документация
```

## Параметры модуля

### Обязательные параметры

| Параметр | Описание | Тип |
|----------|----------|-----|
| `vm_name` | Имя виртуальной машины | `string` |
| `folder_id` | ID каталога в Yandex Cloud | `string` |
| `cpu_cores` | Количество ядер CPU | `number` |
| `memory_gb` | Объём RAM в ГБ | `number` |
| `subnet_id` | ID подсети для подключения ВМ | `string` |
| `ssh_public_key` | Публичный SSH-ключ | `string` |

### Необязательные параметры

| Параметр | Описание | Тип | Значение по умолчанию |
|----------|----------|-----|----------------------|
| `zone` | Зона доступности | `string` | `ru-central1-a` |
| `core_fraction` | Гарантированная доля CPU (%) | `number` | `100` |
| `boot_disk_image` | ID образа ОС | `string` | (требуется указать) |
| `boot_disk_size_gb` | Размер загрузочного диска | `number` | `20` |
| `boot_disk_type` | Тип загрузочного диска | `string` | `network-ssd` |
| `data_disk_enabled` | Включить диск данных | `bool` | `true` |
| `data_disk_size_gb` | Размер диска данных | `number` | `50` |
| `data_disk_type` | Тип диска данных | `string` | `network-ssd` |
| `data_disk_name` | Имя диска данных | `string` | автогенерация |
| `assign_public_ip` | Назначить публичный IP | `bool` | `true` |
| `ipv4_address` | Статический внутренний IP | `string` | `null` |
| `security_group_ids` | Группы безопасности | `list(string)` | `[]` |
| `service_account_id` | ID сервисного аккаунта | `string` | `null` |
| `ssh_username` | Имя пользователя SSH | `string` | `ubuntu` |
| `metadata` | Дополнительные метаданные | `map(string)` | `{}` |
| `labels` | Метки ресурсов | `map(string)` | `{}` |

## Выходные параметры

| Параметр | Описание |
|----------|----------|
| `vm_id` | ID виртуальной машины |
| `vm_name` | Имя ВМ |
| `internal_ip_address` | Внутренний IPv4-адрес |
| `external_ip_address` | Публичный IPv4-адрес |
| `boot_disk_id` | ID загрузочного диска |
| `data_disk_id` | ID диска данных |
| `ssh_connection_string` | Строка подключения SSH |
| `ssh_command` | Команда для SSH-подключения |
| `instance_info` | Сводная информация о ВМ (map) |

## Использование

### Базовый пример

```hcl
module "vm" {
  source = "./modules/vm"

  vm_name         = "my-vm"
  folder_id       = "b1gxxxxxxxxxxxxxx"
  cpu_cores       = 2
  memory_gb       = 4
  subnet_id       = "e9bxxxxxxxxxxxxxx"
  ssh_public_key  = "ssh-rsa AAAAB3NzaC1yc2E... user@example.com"
}
```

### Расширенный пример

```hcl
module "vm" {
  source = "./modules/vm"

  vm_name         = "production-app-server"
  folder_id       = var.folder_id
  zone            = "ru-central1-b"
  cpu_cores       = 4
  memory_gb       = 8
  core_fraction   = 100
  
  boot_disk_image = "fd8xxxxxx"  # Ubuntu 22.04 LTS
  boot_disk_size_gb = 30
  boot_disk_type  = "network-ssd"
  
  data_disk_enabled   = true
  data_disk_size_gb   = 100
  data_disk_type      = "network-ssd"
  data_disk_name      = "app-data-disk"
  
  subnet_id          = var.subnet_id
  security_group_ids = [var.sg_id]
  assign_public_ip   = true
  
  ssh_public_key = var.ssh_public_key
  ssh_username   = "ubuntu"
  
  labels = {
    environment = "production"
    project     = "my-project"
  }
}
```

## Запуск для разных окружений

### Структура проекта

```
Task1Advanced/
├── modules/
│   └── vm/
└── envs/
    ├── dev/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── dev.tfvars
    ├── stage/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── stage.tfvars
    └── prod/
        ├── main.tf
        ├── variables.tf
        └── prod.tfvars
```

### Инициализация и применение

```bash
# Перейти в директорию окружения
cd envs/dev

# Инициализировать Terraform
terraform init

# Проверить план развёртывания
terraform plan -var-file=dev.tfvars

# Применить конфигурацию
terraform apply -var-file=dev.tfvars

# Просмотреть выходы
terraform output
```

### Пример команды для всех окружений

```bash
# Dev окружение
terraform -chdir=envs/dev init
terraform -chdir=envs/dev apply -var-file=dev.tfvars -auto-approve

# Stage окружение
terraform -chdir=envs/stage init
terraform -chdir=envs/stage apply -var-file=stage.tfvars -auto-approve

# Prod окружение
terraform -chdir=envs/prod init
terraform -chdir=envs/prod apply -var-file=prod.tfvars -auto-approve
```

## Требования

- Terraform >= 1.0.0
- Yandex Cloud Provider >= 0.100.0

## Аутентификация в Yandex Cloud

Перед запуском настройте аутентификацию одним из способов:

### Способ 1: Через переменные окружения

```bash
export YC_TOKEN=<your-oauth-token>
export YC_CLOUD_ID=<your-cloud-id>
export YC_FOLDER_ID=<your-folder-id>
```

### Способ 2: Через файл конфигурации

```bash
yc config create
```

### Способ 3: Через provider в main.tf

```hcl
provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = "ru-central1-a"
}
```

## Уничтожение ресурсов

```bash
terraform destroy -var-file=<env>.tfvars
```
