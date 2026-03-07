# Рабочий процесс DevOps-инженера

В этом документе описан пошаговый процесс внесения изменений в инфраструктуру через CI/CD pipeline.

---

## Сценарий: Добавление второй виртуальной машины

**Задача:** Добавить вторую ВМ (`dev-future20-vm-2`) в dev окружение.

### Шаг 1: Создать рабочую ветку

```bash
# Перейдите в репозиторий
cd path/to/repo

# Создайте новую ветку от main
git checkout -b feature/add-second-vm-dev
```

### Шаг 2: Изменить файлы окружения

**Файл:** `Task2Advanced/envs/dev/main.tf`

Добавьте второй экземпляр модуля VM:

```hcl
# =============================================================================
# Первая виртуальная машина (существующая)
# =============================================================================
module "vm_dev_1" {
  source = "../../modules/vm"

  vm_name   = "dev-future20-vm-1"
  folder_id = var.yc_folder_id
  zone      = var.yc_zone

  cpu_cores     = var.vm_cpu_cores
  memory_gb     = var.vm_memory_gb
  core_fraction = var.vm_core_fraction

  boot_disk_image   = var.boot_disk_image
  boot_disk_size_gb = var.boot_disk_size_gb
  boot_disk_type    = var.boot_disk_type

  data_disk_enabled   = true
  data_disk_size_gb   = var.data_disk_size_gb
  data_disk_type      = var.data_disk_type
  data_disk_name      = "${var.vm_name}-data-disk-1"

  subnet_id          = yandex_vpc_subnet.this.id
  security_group_ids = []
  assign_public_ip   = true

  ssh_public_key = var.ssh_public_key
  ssh_username   = var.ssh_username

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
# Вторая виртуальная машина (НОВАЯ)
# =============================================================================
module "vm_dev_2" {
  source = "../../modules/vm"

  vm_name   = "dev-future20-vm-2"  # ← Уникальное имя
  folder_id = var.yc_folder_id
  zone      = var.yc_zone

  cpu_cores     = var.vm_cpu_cores
  memory_gb     = var.vm_memory_gb
  core_fraction = var.vm_core_fraction

  boot_disk_image   = var.boot_disk_image
  boot_disk_size_gb = var.boot_disk_size_gb
  boot_disk_type    = var.boot_disk_type

  data_disk_enabled   = true
  data_disk_size_gb   = var.data_disk_size_gb
  data_disk_type      = var.data_disk_type
  data_disk_name      = "dev-future20-vm-2-data-disk"  # ← Уникальное имя

  subnet_id          = yandex_vpc_subnet.this.id  # ← Та же подсеть
  security_group_ids = []
  assign_public_ip   = true

  ssh_public_key = var.ssh_public_key
  ssh_username   = var.ssh_username

  labels = merge(
    {
      environment = var.environment
      project     = var.project_name
      managed_by  = "terraform"
    },
    var.additional_labels
  )
}
```

### Шаг 3: Добавить outputs для новой ВМ

**Файл:** `Task2Advanced/envs/dev/main.tf` (в конец файла)

```hcl
# =============================================================================
# Outputs для второй ВМ
# =============================================================================

output "vm_dev_2_id" {
  description = "ID второй виртуальной машины"
  value       = module.vm_dev_2.vm_id
}

output "vm_dev_2_external_ip" {
  description = "Публичный IP второй ВМ"
  value       = module.vm_dev_2.external_ip_address
}

output "vm_dev_2_ssh_command" {
  description = "Команда SSH для второй ВМ"
  value       = module.vm_dev_2.ssh_command
}
```

### Шаг 4: Проверить локально

```bash
# Перейдите в директорию окружения
cd Task2Advanced/envs/dev

# Инициализируйте backend (если нужно)
terraform init

# Проверьте синтаксис
terraform validate

# Запустите plan для проверки изменений
terraform plan -var-file=dev.tfvars
```

**Ожидаемый вывод plan:**
```
Terraform will perform the following actions:

  # module.vm_dev_2.yandex_compute_disk.data_disk[0] will be created
  + resource "yandex_compute_disk" "data_disk" {
      + name = "dev-future20-vm-2-data-disk"
      + size = 20
      ...
    }

  # module.vm_dev_2.yandex_compute_instance.vm will be created
  + resource "yandex_compute_instance" "vm" {
      + name = "dev-future20-vm-2"
      + cores = 2
      + memory = 2
      ...
    }

Plan: 3 to add, 0 to change, 0 to destroy.
```

### Шаг 5: Закоммитить изменения

```bash
# Добавьте изменённые файлы
git add Task2Advanced/envs/dev/main.tf

# Создайте коммит
git commit -m "feat: add second VM to dev environment

- Added vm_dev_2 module instance
- Added outputs for new VM (ID, external IP, SSH command)
- Uses same subnet as vm_dev_1
- Resources: 2 CPU, 2GB RAM, 20GB boot + 20GB data disk"

# Отправьте в удалённый репозиторий
git push origin feature/add-second-vm-dev
```

### Шаг 6: Создать Pull Request

1. Откройте GitHub → ваш репозиторий
2. Нажмите **Pull requests** → **New pull request**
3. Выберите:
   - **base:** `main`
   - **compare:** `feature/add-second-vm-dev`
4. Добавьте описание:
   ```
   ## Изменения
   - Добавлена вторая ВМ в dev окружение
   
   ## Ресурсы
   - dev-future20-vm-2 (2 CPU, 2GB RAM)
   - dev-future20-vm-2-data-disk (20GB HDD)
   
   ## Тестирование
   - [x] terraform validate прошёл
   - [x] terraform plan показал 3 ресурса к созданию
   ```
5. Нажмите **Create pull request**

### Шаг 7: Дождаться GitHub Actions

Автоматически запустится workflow **Terraform Plan**:

```
✅ Workflow: Terraform Plan
   ├── Job: terraform-plan (dev)
   │   ├── ✅ Checkout
   │   ├── ✅ Setup Terraform
   │   ├── ✅ Terraform Init
   │   ├── ✅ Terraform Validate
   │   └── ✅ Terraform Plan
   └── Comment added to PR
```

Проверьте комментарий в PR — план должен показать создание 3 ресурсов.

### Шаг 8: Получить approval и замержить

1. Дождитесь review от коллег
2. После approval нажмите **Merge pull request**
3. Удалите ветку (опционально)

### Шаг 9: Применить изменения (Apply)

**Вариант A: Автоматически (если настроен CI/CD)**

Если у вас настроен auto-apply после merge:
- Workflow запустится автоматически
- Дождитесь завершения

**Вариант B: Вручную (рекомендуется)**

1. Откройте **Actions** → **Terraform Apply**
2. Нажмите **Run workflow**
3. Выберите окружение: `dev`
4. Введите подтверждение: `dev`
5. Нажмите **Run workflow**

### Шаг 10: Проверить результат

**В GitHub Actions:**
```
✅ Workflow: Terraform Apply
   └── Job: terraform-apply (dev)
       ├── ✅ Terraform Init
       ├── ✅ Terraform Plan
       ├── ✅ Terraform Apply
       └── ✅ Upload Outputs
```

**В Yandex Cloud Console:**
```
Compute Cloud → Instances
├── dev-future20-vm-1 (RUNNING)
└── dev-future20-vm-2 (RUNNING) ← Новая ВМ
```

**Через Terraform outputs:**
```bash
# После apply в логах workflow увидите:
vm_dev_2_id = "epdXXXXXXXXXXXXX"
vm_dev_2_external_ip = "89.169.XXX.XXX"
vm_dev_2_ssh_command = "ssh ubuntu@89.169.XXX.XXX"
```

**Подключение по SSH:**
```bash
ssh ubuntu@89.169.XXX.XXX
```

---

## Чек-лист DevOps-инженера

Перед каждым изменением инфраструктуры:

```
□ Создана отдельная ветка от main
□ Изменения только в одном окружении (dev/stage/prod)
□ terraform validate прошёл локально
□ terraform plan показал ожидаемые изменения
□ Коммит с понятным сообщением
□ PR с описанием изменений
□ GitHub Actions plan прошёл успешно
□ Получено approval от коллег
□ Apply запущен вручную (для prod обязательно)
□ Ресурсы проверены в Yandex Cloud Console
```

---

## Типовые изменения

| Изменение | Какие файлы править |
|-----------|---------------------|
| Добавить ВМ | `envs/<env>/main.tf` (добавить module block) |
| Изменить CPU/RAM | `envs/<env>/*.tfvars` (изменить `vm_cpu_cores`, `vm_memory_gb`) |
| Изменить размер диска | `envs/<env>/*.tfvars` (изменить `data_disk_size_gb`) |
| Добавить окружение | Создать папку `envs/<new-env>/` с файлами |
| Изменить модуль | `modules/vm/*.tf` (влияет на все окружения!) |

---

## Что НЕЛЬЗЯ делать

❌ **Никогда не редактируйте state файл вручную**
```bash
# ПЛОХО:
nano dev/terraform.tfstate  # ← Никогда так не делайте!
```

❌ **Не коммитьте state файлы в Git**
```bash
# ПЛОХО:
git add envs/dev/terraform.tfstate
git commit -m "Update state"  # ← State должен быть только в S3!
```

❌ **Не запускайте apply локально в обход CI/CD**
```bash
# ПЛОХО:
terraform apply -var-file=dev.tfvars  # ← Используйте GitHub Actions!
```

❌ **Не меняйте prod напрямую**
```bash
# ПЛОХО:
git checkout main
# правки в main.tf
git commit -am "Quick fix for prod"
git push  # ← Всегда через PR + approval!
```

---

## Дополнительные ресурсы

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Git Workflow Best Practices](https://www.atlassian.com/git/tutorials/comparing-workflows)
