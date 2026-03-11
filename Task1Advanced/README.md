# Task1Advanced — Модульная инфраструктура Terraform для компании «Будущее 2.0»

## Обзор

Этот проект содержит универсальный модуль Terraform для создания виртуальных машин в Yandex Cloud, который может использоваться для разных окружений (dev, stage, prod) в рамках трансформации IT-ландшафта компании «Будущее 2.0».

## Структура проекта

```
Task1Advanced/
├── .gitignore                  # Игнорируемые файлы Terraform
├── README.md                   # Эта документация
├── task1.md                    # Описание задания
├── HANDOVER.md                 # Сводка для возобновления работы
├── terraform.rc                # Конфигурация провайдера Yandex Cloud (общая)
├── deploy.ps1                  # Универсальный скрипт развёртывания
├── destroy.ps1                 # Универсальный скрипт уничтожения
├── .terraform/                 # Провайдеры (общие для всех окружений)
├── .terraform.lock.hcl         # Блокировка версий провайдеров
├── modules/
│   └── vm/                     # Универсальный модуль ВМ
│       ├── main.tf             # Ресурсы: ВМ + диск + сеть
│       ├── variables.tf        # Входные параметры модуля
│       ├── outputs.tf          # Выходные значения
│       └── README.md           # Документация модуля
└── envs/
    ├── dev/                    # Dev окружение
    │   ├── main.tf             # Конфигурация окружения
    │   ├── variables.tf        # Переменные окружения
    │   ├── dev.tfvars          # Значения переменных для dev
    │   └── terraform.tfstate   # State-файл (не коммитить!)
    ├── stage/                  # Stage окружение
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── stage.tfvars
    │   └── terraform.tfstate
    └── prod/                   # Prod окружение
        ├── main.tf
        ├── variables.tf
        ├── prod.tfvars
        └── terraform.tfstate
```

## Быстрый старт

### 1. Настройка аутентификации в Yandex Cloud

#### Windows PowerShell

```powershell
# Установите переменные окружения
$Env:YC_TOKEN = yc iam create-token --impersonate-service-account-id <service-account-id>
$Env:YC_CLOUD_ID = yc config get cloud-id
$Env:YC_FOLDER_ID = yc config get folder-id

# Проверка
yc config list
```

#### Linux/macOS

```bash
export YC_TOKEN=$(yc iam create-token --impersonate-service-account-id <service-account-id>)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```

### 2. Настройка SSH-ключа

```bash
# Создайте SSH-ключ (если нет)
ssh-keygen -t ed25519 -f ~/.ssh/yandex_cloud -N "" -C "your-email@example.com"

# Получите публичный ключ для вставки в .tfvars
cat ~/.ssh/yandex_cloud.pub
```

### 3. Конфигурация окружений

Отредактируйте файлы `.tfvars` для каждого окружения в папке `envs/<env>/`:
- `yc_token` — ваш OAuth-токен (или оставьте пустым для использования переменной окружения)
- `yc_cloud_id` — ID облака
- `yc_folder_id` — ID каталога
- `ssh_public_key` — ваш публичный SSH-ключ

### 4. Запуск Terraform

#### Универсальные скрипты (рекомендуется)

```powershell
cd Task1Advanced

# Dev окружение
.\deploy.ps1 -Environment dev

# Stage окружение
.\deploy.ps1 -Environment stage

# Prod окружение
.\deploy.ps1 -Environment prod

# Уничтожение ресурсов
.\destroy.ps1 -Environment dev
.\destroy.ps1 -Environment stage
.\destroy.ps1 -Environment prod  # Требует подтверждения 'DESTROY PRODUCTION'
```

#### Ручной запуск (кроссплатформенный)

```powershell
# Установка переменных окружения
$Env:YC_TOKEN = yc iam create-token --impersonate-service-account-id ajeu39krvvpe031mt22c
$Env:YC_CLOUD_ID = yc config get cloud-id
$Env:YC_FOLDER_ID = yc config get folder-id
$Env:TF_CLI_CONFIG_FILE = "terraform.rc"

# Переход в директорию окружения
cd envs/dev

# Инициализация (использует общий .terraform/ из корня)
terraform init -backend-config="path=$PWD/terraform.tfstate"

# План и применение
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

### 5. Подключение к ВМ

```powershell
# После применения получите SSH-команду
cd envs/dev
terraform output ssh_command

# Или подключитесь вручную
ssh ubuntu@<external-ip>
```

## Сравнение окружений

| Параметр | Dev | Stage | Prod |
|----------|-----|-------|------|
| CPU (ядра) | 2 | 4 | 4 |
| RAM (ГБ) | 2 | 4 | 4 |
| Core Fraction (%) | 20 | 20 | 20 |
| Boot Disk (ГБ) | 20 (HDD) | 30 (SSD) | 30 (SSD) |
| Data Disk (ГБ) | 20 (HDD) | 50 (SSD) | 50 (SSD) |
| Зона | ru-central1-b | ru-central1-b | ru-central1-a |
| CIDR | 10.0.1.0/24 | 10.0.2.0/24 | 10.0.3.0/24 |

**Примечание:** Prod окружение настроено с теми же ресурсами, что и stage (для тестирования). Для production нагрузки увеличьте параметры в `prod.tfvars`.

## Уничтожение ресурсов

```bash
# Для каждого окружения
terraform destroy -var-file=<env>.tfvars
```

## Требования

- Terraform >= 1.0.0
- Yandex Cloud Provider >= 0.100.0
- Yandex Cloud CLI (`yc`)

## Примечания для компании «Будущее 2.0»

Этот модуль может использоваться для развёртывания инфраструктуры в рамках миграции в облако:
- **Dev** — для тестирования новых функций и интеграций
- **Stage** — для предпродакшн тестирования перед развёртыванием
- **Prod** — для рабочей нагрузки медицинских и финтех-сервисов

