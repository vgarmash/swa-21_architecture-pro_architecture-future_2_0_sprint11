# Task2Advanced — Terraform CI/CD с удалённым состоянием

## Техническое описание решения

Данный проект реализует полный цикл управления инфраструктурой компании «Будущее 2.0» через Terraform с автоматизацией развёртывания в GitHub Actions и централизованным хранением состояния в Yandex Object Storage.

---

## 1. Архитектура решения

### 1.1. Компоненты системы

Система состоит из четырёх основных компонентов:

**1. Репозиторий GitHub** — хранит код Terraform, конфигурацию pipeline и документацию.

**2. GitHub Actions** — исполняет pipeline, запуская Terraform-команды на изолированных runner'ах.

**3. Yandex Object Storage** — хранит файлы состояния (`.tfstate`) для всех окружений.

**4. Yandex Cloud** — целевая инфраструктура (виртуальные машины, сети, диски).

### 1.2. Диаграмма архитектуры

Диаграмма доступна в формате PlantUML: [`docs/architecture.puml`](docs/architecture.puml)

Для просмотра:
- Откройте в [PlantText](https://www.planttext.com/)
- Используйте расширение PlantUML в VS Code
- Сгенерируйте PNG: `plantuml docs/architecture.puml`

> **Workflow Steps:**
> 1. checkout@v4
> 2. setup-terraform@v3
> 3. Configure Credentials
>    - Save SA key to file
>    - yc iam create-token
>    - Set YC_TOKEN env
>    - Delete temp key file
> 4. terraform init
> 5. terraform validate
> 6. terraform plan/apply

---

## 2. Где находится инфраструктура

### 2.1. Terraform-файлы для создания инфраструктуры

Файлы, описывающие инфраструктуру, расположены в директориях окружений:

```
Task2Advanced/
└── envs/
    ├── dev/
    │   ├── main.tf           # ← Создаёт VPC, подсеть и вызывает модуль VM
    │   ├── variables.tf      # ← Переменные окружения
    │   ├── backend.tf        # ← Конфигурация S3 backend
    │   └── dev.tfvars        # ← Значения переменных для dev
    ├── stage/
    │   ├── main.tf           # ← Создаёт VPC, подсеть и вызывает модуль VM
    │   ├── variables.tf
    │   ├── backend.tf
    │   └── stage.tfvars
    └── prod/
        ├── main.tf           # ← Создаёт VPC, подсеть и вызывает модуль VM
        ├── variables.tf
        ├── backend.tf
        └── prod.tfvars
```

---

## 3. Рабочий процесс DevOps-инженера

📄 **Подробная инструкция:** См. [`docs/devops-workflow.md`](docs/devops-workflow.md)

**Краткое содержание:**

- **Пошаговый сценарий** — добавление второй ВМ в dev окружение
- **Чек-лист** — 10 пунктов для проверки перед изменениями
- **Типовые изменения** — таблица с файлами для редактирования
- **Запреты** — 4 вещи, которые нельзя делать

---

## 4. Как работает CI/CD pipeline

### 4.1. Terraform Plan (автоматически при PR)

**Файл:** `.github/workflows/terraform-plan.yml`

**Триггеры:**
- Push в Pull Request (ветка `main`)
- Ручной запуск через UI

**Concurrency:**
- group: terraform-plan-${{ github.head_ref }}
- cancel-in-progress: true

**Диаграмма workflow:**

![Terraform Plan Workflow](docs/workflow-plan.png)

> **Аутентификация:**
> - GitHub Secrets: YC_SA_KEY_ID, YC_SA_PRIVATE_KEY
> - IAM токен получается автоматически при запуске
> - Срок действия токена: 1 час
> - Service Account Key: не истекает

Исходный файл PlantUML: [`docs/workflow-plan.puml`](docs/workflow-plan.puml)

**Результат:** Комментарий в PR с планом изменений для каждого окружения.

---

### 4.2. Terraform Apply (вручную с подтверждением)

**Файл:** `.github/workflows/terraform-apply.yml`

**Триггеры:**
- Только ручной запуск через GitHub Actions UI

**Environment Protection:**
- dev: без ограничений
- stage: без ограничений
- prod: Required reviewers

**Диаграмма workflow:**

![Terraform Apply Workflow](docs/workflow-apply.png)

> **Аутентификация:**
> - GitHub Secrets: YC_SA_KEY_ID, YC_SA_PRIVATE_KEY
> - IAM токен получается автоматически при запуске
> - Срок действия токена: 1 час
> - Service Account Key: не истекает
>
> **Concurrency:**
> - group: terraform-apply-${{ github.event.inputs.environment }}
> - cancel-in-progress: false

Исходный файл PlantUML: [`docs/workflow-apply.puml`](docs/workflow-apply.puml)

---

## 5. Управление состоянием (State Management)

### 5.1. Где хранится состояние

**Yandex Object Storage:**
```
Bucket: yc-bucket-terraform-state
├── dev/terraform.tfstate      # Состояние dev окружения
├── stage/terraform.tfstate    # Состояние stage окружения
└── prod/terraform.tfstate     # Состояние prod окружения
```

### 5.2. Как работает блокировка (State Locking)

**Важное замечание:** Yandex Object Storage **не поддерживает** state locking на уровне backend.

В отличие от AWS S3, где можно указать `dynamodb_table` для блокировок, в Yandex Cloud нет аналога DynamoDB для этой цели.

**Что это означает на практике:**

> **Ограничение Yandex Object Storage:**
> - State file хранится в бакете
> - Блокировка (locking) НЕ работает
> - Защита от одновременного изменения ОТСУТСТВУЕТ

**Потенциальная проблема:**

```
Время T0: Workflow 1 начинает apply (dev)
├─ terraform init → загрузка state из S3
├─ terraform apply → создание ресурсов
└─ (в процессе выполнения...)

Время T1: Workflow 2 начинает apply (dev) ← ПРОБЛЕМА!
├─ terraform init → загрузка state из S3
├─ terraform apply → создание ресурсов
└─ (конфликт! оба workflow меняют одни ресурсы)

Время T2: Workflow 1 завершается
└─ Загружает state в S3

Время T3: Workflow 2 завершается
└─ Перезаписывает state в S3 ← Последний выиграл!
   (изменения Workflow 1 могут быть потеряны)
```

**Как мы защищаемся в этом проекте:**

1. **GitHub Concurrency Groups** (в workflow файлах):

```yaml
# terraform-plan.yml
concurrency:
  group: terraform-plan-${{ github.head_ref || github.run_id }}
  cancel-in-progress: true  # ← Отменяет дублирующиеся запуски

# terraform-apply.yml
concurrency:
  group: terraform-apply-${{ github.event.inputs.environment }}
  cancel-in-progress: false  # ← Не отменяет текущий apply
```

2. **Environment Protection Rules** (для prod):
   - Только один workflow может выполняться для prod окружения
   - Остальные становятся в очередь

3. **Ручная координация**:
   - Команда должна следить за запущенными workflow
   - Не запускать apply для одного окружения одновременно

**Рекомендации для production:**

Если нужна гарантированная защита от конфликтов:

1. **Используйте Terraform Cloud/Enterprise** — имеют встроенный locking
2. **Используйте AWS S3 + DynamoDB** — если возможна миграция
3. **Добавьте pre-check скрипт** — проверяет, не запущен ли уже workflow

### 5.3. Шифрование состояния

State файл шифруется на стороне S3:

```hcl
# backend.tf
terraform {
  backend "s3" {
    encrypt = true  # ← Включает шифрование AES-256
    ...
  }
}
```

---

## 6. Где находится целевая инфраструктура

### 6.1. Yandex Cloud Resources

После применения Terraform создаются следующие ресурсы:

**Для каждого окружения (dev, stage, prod):**

```
Yandex Cloud Folder: b1gqrsec7dnon46srdpo
├── VPC Network
│   └── dev-future20-network (enpXXXXXXXXXXXXX)
│       └── Subnet
│           └── dev-future20-subnet (e2lXXXXXXXXXXXXX)
│               └── CIDR: 10.0.1.0/24
│
├── Compute Instance
│   └── dev-future20-vm (epdXXXXXXXXXXXXX)
│       ├── Platform: standard-v1
│       ├── CPU: 2 ядра (20% guarantee)
│       ├── RAM: 2 GB
│       ├── Zone: ru-central1-b
│       ├── Internal IP: 10.0.1.14
│       └── External IP: 89.169.162.126
│
├── Boot Disk
│   └── dev-future20-vm-boot-disk (epdXXXXXXXXXXXXX)
│       ├── Size: 20 GB
│       └── Type: network-hdd
│
└── Data Disk
    └── dev-future20-vm-data-disk (epdXXXXXXXXXXXXX)
        ├── Size: 20 GB
        └── Type: network-hdd
```

### 6.2. Как посмотреть инфраструктуру

**Через Yandex Cloud Console:**
```
1. Откройте https://console.cloud.yandex.ru/
2. Выберите каталог (folder)
3. Перейдите в раздел "Compute Cloud"
4. Увидите список ВМ с префиксом <env>-future20-vm
```

**Через Yandex CLI:**
```bash
# Список ВМ
yc compute instance list --folder-id <folder-id>

# Список сетей
yc vpc network list --folder-id <folder-id>

# Список подсетей
yc vpc subnet list --folder-id <folder-id>
```

**Через Terraform:**
```bash
# После apply получите outputs:
terraform output

# Пример вывода:
vm_id = "epd1hrulbeqqfkrp0ive"
external_ip = "89.169.162.126"
ssh_command = "ssh ubuntu@89.169.162.126"
```

---

## 7. Инструкция по использованию

### 7.1. Предварительная настройка

**Шаг 1: Создайте Yandex Object Storage bucket**

```bash
# Создайте бакет
yc storage bucket create --name yc-bucket-terraform-state

# Проверьте
yc storage bucket list
```

**Шаг 2: Создайте сервисный аккаунт для GitHub Actions**

```bash
# Создайте сервисный аккаунт
yc iam service-account create --name github-actions --description "SA for GitHub Actions CI/CD"

# Получите ID
SA_ID=$(yc iam service-account get github-actions --format json | jq -r '.id')

# Назначьте права storage.editor
yc resource-manager folder add-access-binding <folder-id> \
  --role storage.editor \
  --service-account-id $SA_ID

# Назначьте права compute.editor
yc resource-manager folder add-access-binding <folder-id> \
  --role compute.editor \
  --service-account-id $SA_ID

# Назначьте права vpc.admin
yc resource-manager folder add-access-binding <folder-id> \
  --role vpc.admin \
  --service-account-id $SA_ID
```

**Шаг 3: Создайте авторизованный ключ**

```bash
yc iam key create --service-account-id $SA_ID \
  --output github-actions-sa-key.json \
  --key-type access-key

# Просмотрите ключ (для копирования в GitHub Secrets)
cat github-actions-sa-key.json
```

**Сохраните файл `github-actions-sa-key.json`** — он понадобится для добавления в GitHub Secrets.

---

### 7.2. Настройка GitHub Secrets

📄 **Подробная инструкция по настройке SA:** См. [`docs/service-account-setup.md`](docs/service-account-setup.md)

**Необходимые секреты:**

| Secret | Описание |
|--------|----------|
| `YC_SA_KEY_ID` | Access Key ID из файла ключа |
| `YC_SA_PRIVATE_KEY` | Полное содержимое файла `github-actions-sa-key.json` (включая `{ }`) |
| `YC_FOLDER_ID` | ID каталога |
| `YC_CLOUD_ID` | ID облака |

**⚠️ Важно:** Для `YC_SA_PRIVATE_KEY` скопируйте **весь JSON файл** целиком, включая фигурные скобки.

**Environments:**

1. Settings → Environments → New environment
2. Создайте `dev`, `stage`, `prod`
3. Для `prod` включите **Required reviewers**

### 7.3. Запуск pipeline

**Plan (автоматически):**
```
1. Создайте Pull Request в ветку main
2. Workflow запустится автоматически
3. Проверьте комментарий в PR с планом
```

**Apply (вручную):**
```
1. Actions → Terraform Apply → Run workflow
2. Выберите окружение (dev/stage/prod)
3. Введите название окружения для подтверждения
4. Для prod дождитесь одобрения reviewer
5. Нажмите Run workflow
```

### 7.4. Локальная разработка

**Инициализация (включает backend):**

```bash
# Установите переменные
export YC_TOKEN="t1.9euelZq..."
export AWS_ACCESS_KEY_ID="YCAXXXXXXXXXXXXXXXXX"
export AWS_SECRET_ACCESS_KEY="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

# Перейдите в директорию окружения
cd Task2Advanced/envs/dev

# Инициализируйте backend (загружает state из S3)
terraform init

# Что происходит:
# 1. Читает backend.tf
# 2. Подключается к storage.yandexcloud.net
# 3. Загружает dev/terraform.tfstate из бакета
# 4. Скачивает провайдер yandex-cloud/yandex
```

**План и применение:**

```bash
# План изменений
terraform plan -var-file=dev.tfvars

# Применение
terraform apply -var-file=dev.tfvars

# Уничтожение
terraform destroy -var-file=dev.tfvars
```

---

## 8. Безопасность

### 8.1. Хранение секретов

| Метод | Безопасно? | Примечание |
|-------|------------|------------|
| GitHub Secrets | ✅ Да | Рекомендуемый способ |
| Переменные окружения | ✅ Да | Для локальной разработки |
| Хардкод в коде | ❌ Нет | Никогда не делайте так |
| Файлы .tfvars | ❌ Нет | Игнорируйте в .gitignore |

### 8.2. Защита state file

**Что игнорировать в Git:**

```gitignore
# Никогда не коммитьте:
*.tfstate           # Содержит реальные IDs ресурсов
*.tfstate.backup    # Резервные копии state
.terraform/         # Провайдеры и кэш
*.tfplan            # Бинарные планы
authorized_key.json # Приватные ключи
```

### 8.3. Environment Protection

**Для production:**

1. Settings → Environments → prod
2. Включите **Required reviewers**
3. Добавьте ответственных (2+ человека)
4. Включите **Wait timer** (опционально)

**Результат:**
- Workflow останавливается перед apply
- Требуется одобрение reviewer
- Уведомления отправляются на почту

---

## 9. Troubleshooting

### 9.1. Ошибка инициализации backend

**Симптом:**
```
Error: InvalidAccessKeyId: The Access Key Id you provided does not exist.
```

**Решение:**
1. Проверьте `YC_ACCESS_KEY` в GitHub Secrets
2. Убедитесь, что ключ активен
3. Пересоздайте ключ при необходимости

### 9.2. Конфликт при одновременном apply

**Симптом:**
```
Warning: Applied changes may be lost
Another process modified the state while you were working.
```

**Причина:**
Yandex Object Storage не поддерживает state locking. Два workflow запустились одновременно для одного окружения.

**Решение:**
1. Проверьте GitHub Actions — не запущены ли несколько workflow
2. Отмените дублирующиеся запуски
3. Перезапустите apply
4. Проверьте, что `concurrency` настроен в workflow файлах

**Профилактика:**
```yaml
# В workflow файлах уже настроено:
concurrency:
  group: terraform-apply-${{ github.event.inputs.environment }}
  cancel-in-progress: false
```

### 9.3. Workflow не запускается

**Проверьте:**
1. Secrets настроены правильно
2. Ветка называется `main` (или обновите trigger в workflow)
3. У runner'а есть доступ к интернету

---

## 10. Дополнительные ресурсы

- [Terraform S3 Backend Documentation](https://www.terraform.io/language/settings/backends/s3)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Yandex Object Storage](https://cloud.yandex.ru/docs/storage/)
- [State Locking](https://www.terraform.io/language/state/locking)

---

## 11. Поддержка

По вопросам создайте Issue в репозитории или обратитесь к владельцу проекта.
