# =============================================================================
# Инструкция: Настройка Service Account для GitHub Actions
# =============================================================================
# Этот файл описывает процесс создания сервисного аккаунта для автоматического
# получения IAM-токенов в GitHub Actions без ручного обновления.
# =============================================================================

## Шаг 1: Создайте сервисный аккаунт

```bash
# Создайте сервисный аккаунт
yc iam service-account create --name github-actions --description "SA for GitHub Actions CI/CD"

# Получите ID сервисного аккаунта
SA_ID=$(yc iam service-account get github-actions --format json | jq -r '.id')
echo "Service Account ID: $SA_ID"
```

## Шаг 2: Назначьте права

```bash
# Права для Object Storage (backend)
yc resource-manager folder add-access-binding <folder-id> \
  --role storage.editor \
  --service-account-id $SA_ID

# Права для Compute (создание ВМ)
yc resource-manager folder add-access-binding <folder-id> \
  --role compute.editor \
  --service-account-id $SA_ID

# Права для VPC (сети)
yc resource-manager folder add-access-binding <folder-id> \
  --role vpc.admin \
  --service-account-id $SA_ID
```

## Шаг 3: Создайте авторизованный ключ

```bash
# Создайте ключ
yc iam key create --service-account-id $SA_ID \
  --output github-actions-sa-key.json \
  --key-type access-key

# Извлеките ключи (для проверки)
jq -r '.access_key_id' github-actions-sa-key.json
jq -r '.secret_key' github-actions-sa-key.json
```

## Шаг 4: Добавьте ключи в GitHub Secrets

Перейдите в **Settings → Secrets and variables → Actions → New repository secret**:

| Secret Name | Value |
|-------------|-------|
| `YC_SA_KEY_ID` | Значение из `jq '.access_key_id' github-actions-sa-key.json` |
| `YC_SA_PRIVATE_KEY` | Полное содержимое файла `github-actions-sa-key.json` (включая { }) |

**Важно:** Для `YC_SA_PRIVATE_KEY` скопируйте **весь JSON файл**, включая фигурные скобки.

Пример содержимого `YC_SA_PRIVATE_KEY`:
```json
{
  "id": "...",
  "service_account_id": "...",
  "created_at": "...",
  "key_algorithm": "RSA_2048",
  "public_key": "-----BEGIN PUBLIC KEY-----\n...\n-----END PUBLIC KEY-----\n",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
}
```

## Шаг 5: Обновите workflow

Workflow автоматически использует новые переменные для получения IAM-токена.

**Что изменилось:**
- ❌ Удалён секрет `YC_TOKEN` (больше не нужен)
- ✅ Добавлены секреты `YC_SA_KEY_ID` и `YC_SA_PRIVATE_KEY`
- ✅ Workflow сам получает IAM-токен через `yc iam create-token`

## Шаг 6: Проверка

Запустите workflow вручную:
1. Actions → Terraform Apply → Run workflow
2. Проверьте логи — токен должен получиться автоматически

---

## Почему это лучше?

| Подход | Обновление токена | Безопасность | Удобство |
|--------|-------------------|--------------|----------|
| **Ручной (YC_TOKEN)** | Каждые 1 час вручную | ❌ Токен в secrets | ❌ Неудобно |
| **Автоматический (SA Key)** | Автоматически при запуске | ✅ Key не истекает | ✅ Удобно |

**Срок действия:**
- IAM-токен: ~1 час (получается автоматически при каждом запуске)
- Service Account Key: **не истекает** (хранится в secrets)
