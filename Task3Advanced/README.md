# Решение задания №3: Архитектура Data Mesh для «Будущего 2.0»

Данное решение представляет собой синтез стратегического подхода **Data Mesh** и детального управления рисками, адаптированное под долгосрочные цели компании.

## 1. Стратегическое видение
Мы отказываемся от централизованного DWH в пользу распределенной архитектуры, где каждый домен (Финтех, Медицина, ИИ) владеет своими данными и предоставляет их как **продукты**. Интеграция происходит через **Global Event Mesh (Kafka)**, обеспечивая гибкость и масштабируемость.

## 2. Матрица прослеживаемости (Traceability)

| Бизнес-цель | Архитектурное решение | Техническая реализация | Риск и меры по снижению |
| :--- | :--- | :--- | :--- |
| **Масштабируемость** (новые направления) | Децентрализация ответственности | Domain-owned Data Products | **Риск:** Силосы. **Меры по снижению:** Federated Governance. |
| **Time-to-Market** (быстрая отчетность) | Самообслуживание (Self-Service) | Data Portal + Trino/Presto | **Риск:** Низкий UX. **Меры по снижению:** Blueprints & Templates. |
| **Near-real-time** аналитика | Событийная платформа | Kafka + Apache Flink | **Риск:** Консистентность. **Меры по снижению:** Idempotency keys. |
| **Безопасность** (PII/Fin data) | Политики как код (Policy-as-Code) | Open Policy Agent (OPA) | **Риск:** Утечки. **Меры по снижению:** Dynamic Masking. |

## 3. Этапы трансформации (Дорожная карта)

### Этап 1: Фундамент (0-6 мес)
*   **Файлы:** [c4_context_stage1.puml](c4_context_stage1.puml), [c4_container_stage1.puml](c4_container_stage1.puml)
*   **Результат:** Пилот в Финтех-домене. Развернута Kafka, базовый портал каталога. CDC из легаси DWH.

### Этап 2: Масштабирование (6-18 мес)
*   **Файлы:** [c4_context_stage2.puml](c4_context_stage2.puml), [c4_container_stage2.puml](c4_container_stage2.puml)
*   **Результат:** Подключение Медицины и ИИ. Внедрение федеративного управления (Federated Governance). Кросс-доменные SQL-запросы через Trino.

### Этап 3: Целевой Data Mesh (18-36 мес)
*   **Файлы:** [c4_context_stage3.puml](c4_context_stage3.puml), [c4_container_stage3.puml](c4_container_stage3.puml)
*   **Результат:** Полная автономность доменов. Подключение новых вертикалей (Фарма, IoT). Легаси DWH выведен из эксплуатации.

## 4. Управление рисками
Подробный анализ рисков, оформленный в виде технического рассказа со сценариями и мерами митигации, находится в файле:
📄 **[risk_mitigation_plan.md](risk_mitigation_plan.md)**

## 5. Технологический стек
*   **Messaging:** Apache Kafka (Event Mesh)
*   **CDC:** Debezium / Kafka Connect
*   **Analytics:** Trino (Federated Queries), Apache Flink (Streaming)
*   **Governance:** DataHub (Catalog), OPA (Security Policies)
*   **Infrastructure:** Kubernetes, Terraform (Self-service blueprints)
