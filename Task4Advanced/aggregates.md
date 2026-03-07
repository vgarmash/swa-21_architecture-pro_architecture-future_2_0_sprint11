# Описание агрегатов (Aggregates)

## Введение

Агрегаты — это кластеры связанных объектов, которые рассматриваются как единое целое для целей изменения данных. Каждый агрегат имеет корневой объект (Aggregate Root) и границу, определяющую, какие объекты принадлежат агрегату.

---

## Медицинский домен (Medical Domain)

### 1. Patient (Пациент)

**Bounded Context:** Patient Management  
**Aggregate Root:** Patient

**Границы агрегата:**
- Patient (корневой объект)
- ContactInfo (контактная информация)
- InsuranceInfo (страховая информация)
- EmergencyContact (контакты для экстренной связи)

**Ключ агрегата:** `patientId` (UUID)

**Инварианты:**
- Пациент должен иметь уникальный идентификатор
- Пациент должен иметь хотя бы один способ связи
- Дата рождения не может быть в будущем
- ИНН (если предоставлен) должен быть уникальным

**Ответственность:**
- Управление регистрацией и обновлением данных пациента
- Ведение истории изменений персональных данных

**События, публикуемые:**
- `PatientRegistered` — при создании
- `PatientUpdated` — при изменении
- `PatientVerified` — при верификации

---

### 2. Visit (Визит)

**Bounded Context:** Patient Management  
**Aggregate Root:** Visit

**Границы агрегата:**
- Visit (корневой объект)
- Appointment (запись на приём)
- VisitNotes (заметки визита)
- VisitDocuments (документы визита)

**Ключ агрегата:** `visitId` (UUID)

**Инварианты:**
- Визит должен быть связан с существующим пациентом
- Дата визита не может быть в прошлом (для новых визитов)
- Статус визита должен быть валидным (Scheduled, InProgress, Completed, Cancelled)
- Врач должен быть назначен для визита

**Ответственность:**
- Планирование и управление визитами пациентов
- Отслеживание статуса визита

**События, публикуемые:**
- `VisitScheduled` — при создании записи
- `VisitStarted` — при начале визита
- `VisitCompleted` — при завершении визита
- `VisitCancelled` — при отмене

---

### 3. Study (Медицинское исследование)

**Bounded Context:** Diagnostic  
**Aggregate Root:** Study

**Границы агрегата:**
- Study (корневой объект)
- StudyType (тип исследования)
- StudyResult (результаты исследования)
- StudyImages (изображения)
- StudyFiles (файлы)

**Ключ агрегата:** `studyId` (UUID)

**Инварианты:**
- Исследование должно быть связано с визитом или пациентом
- Тип исследования должен быть из справочника
- Дата проведения не может быть в будущем
- Результат должен быть привязан к исследованию

**Ответственность:**
- Управление жизненным циклом медицинских исследований
- Хранение и предоставление результатов

**События, публикуемые:**
- `StudyOrdered` — при назначении
- `StudyInProgress` — при начале
- `StudyCompleted` — при завершении
- `StudyResultsAvailable` — при доступности результатов

---

### 4. TreatmentPlan (План лечения)

**Bounded Context:** Treatment  
**Aggregate Root:** TreatmentPlan

**Границы агрегата:**
- TreatmentPlan (корневой объект)
- Prescription (назначения)
- Procedure (процедуры)
- Medication (лекарства)
- TreatmentProgress (прогресс лечения)

**Ключ агрегата:** `treatmentPlanId` (UUID)

**Инварианты:**
- План лечения должен быть связан с диагнозом
- Дата начала не может быть в прошлом для новых планов
- План должен иметь хотя бы одно назначение

**Ответственность:**
- Управление планами лечения
- Отслеживание выполнения назначений

**События, публикуемые:**
- `TreatmentPrescribed` — при назначении
- `TreatmentStarted` — при начале
- `TreatmentUpdated` — при обновлении
- `TreatmentCompleted` — при завершении

---

## Финансовый домен (Finance Domain)

### 5. Account (Банковский счёт)

**Bounded Context:** Banking  
**Aggregate Root:** Account

**Границы агрегата:**
- Account (корневой объект)
- AccountType (тип счёта)
- AccountBalance (баланс)
- AccountStatus (статус)
- AccountHistory (история операций)

**Ключ агрегата:** `accountId` (UUID)

**Инварианты:**
- Счёт должен быть связан с клиентом
- Номер счёта должен быть уникальным
- Баланс не может быть отрицательным (для депозитных счетов)
- Счёт должен иметь валидный статус

**Ответственность:**
- Управление банковскими счетами
- Отслеживание баланса и операций

**События, публикуемые:**
- `AccountCreated` — при создании
- `AccountActivated` — при активации
- `AccountClosed` — при закрытии
- `AccountBalanceChanged` — при изменении баланса

---

### 6. Credit (Кредит)

**Bounded Context:** Banking  
**Aggregate Root:** Credit

**Границы агрегата:**
- Credit (корневой объект)
- CreditType (тип кредита)
- CreditTerms (условия)
- CreditPaymentSchedule (график платежей)
- CreditStatus (статус)

**Ключ агрегата:** `creditId` (UUID)

**Инварианты:**
- Кредит должен быть связан с существующим счётом
- Сумма кредита должна быть положительной
- Процентная ставка должна быть в допустимых пределах
- Срок кредита должен быть положительным

**Ответственность:**
- Управление кредитными продуктами
- Расчёт платежей и процентов

**События, публикуемые:**
- `CreditApplicationSubmitted` — при подаче заявки
- `CreditApproved` — при одобрении
- `CreditRejected` — при отказе
- `CreditDisbursed` — при выдаче
- `CreditPaidOff` — при полном погашении

---

### 7. Payment (Платёж)

**Bounded Context:** Payments  
**Aggregate Root:** Payment

**Границы агрегата:**
- Payment (корневой объект)
- PaymentMethod (способ оплаты)
- PaymentDetails (детали платежа)
- PaymentStatus (статус)

**Ключ агрегата:** `paymentId` (UUID)

**Инварианты:**
- Платёж должен быть связан со счётом или счётом-фактурой
- Сумма платежа должна быть положительной
- Статус должен изменяться только в валидной последовательности

**Ответственность:**
- Обработка платежей
- Отслеживание статуса платежа

**События, публикуемые:**
- `PaymentInitiated` — при инициации
- `PaymentAuthorized` — при авторизации
- `PaymentCaptured` — при подтверждении
- `PaymentCompleted` — при завершении
- `PaymentFailed` — при ошибке
- `PaymentRefunded` — при возврате

---

### 8. Invoice (Счёт/Счёт-фактура)

**Bounded Context:** Payments  
**Aggregate Root:** Invoice

**Границы агрегата:**
- Invoice (корневой объект)
- InvoiceLine (позиции счёта)
- InvoiceStatus (статус)
- TaxInfo (налоговая информация)

**Ключ агрегата:** `invoiceId` (UUID)

**Инварианты:**
- Счёт должен быть связан с пациентом или договором
- Сумма должна соответствовать сумме позиций
- Дата оплаты не может быть раньше даты создания

**Ответственность:**
- Генерация и управление счетами
- Отслеживание оплаты

**События, публикуемые:**
- `InvoiceGenerated` — при создании
- `InvoiceSent` — при отправке
- `InvoicePaid` — при оплате
- `InvoiceOverdue` — при просрочке
- `InvoiceCancelled` — при отмене

---

## ИИ-домен (AI Services Domain)

### 9. AnalysisJob (Задача анализа)

**Bounded Context:** ML Pipeline  
**Aggregate Root:** AnalysisJob

**Границы агрегата:**
- AnalysisJob (корневой объект)
- InputData (входные данные)
- ModelInfo (информация о модели)
- JobStatus (статус)
- JobMetrics (метрики)

**Ключ агрегата:** `jobId` (UUID)

**Инварианты:**
- Задача должна иметь валидную ссылку на источник данных
- Модель должна быть доступна для инференса
- Статус должен изменяться в правильной последовательности

**Ответственность:**
- Управление задачами машинного обучения
- Отслеживание выполнения

**События, публикуемые:**
- `AnalysisRequested` — при запросе
- `AnalysisQueued` — при постановке в очередь
- `AnalysisStarted` — при начале
- `AnalysisCompleted` — при завершении
- `AnalysisFailed` — при ошибке

---

### 10. Prediction (Прогноз)

**Bounded Context:** Analysis  
**Aggregate Root:** Prediction

**Границы агрегата:**
- Prediction (корневой объект)
- PredictionResult (результат)
- ConfidenceScore (достоверность)
- Recommendation (рекомендация)

**Ключ агрегата:** `predictionId` (UUID)

**Инварианты:**
- Прогноз должен быть связан с задачей анализа
- Достоверность должна быть в диапазоне 0-1
- Дата прогноза не может быть в будущем

**Ответственность:**
- Хранение и предоставление прогнозов
- Генерация рекомендаций

**События, публикуемые:**
- `PredictionGenerated` — при генерации
- `PredictionViewed` — при просмотре
- `PredictionConfirmed` — при подтверждении

---

## Общие домены (Shared Kernel)

### 11. Customer (Клиент)

**Bounded Context:** Shared Kernel  
**Aggregate Root:** Customer

**Границы агрегата:**
- Customer (корневой объект)
- CustomerProfile (профиль)
- CustomerVerification (верификация)
- CustomerConsent (согласия)

**Ключ агрегата:** `customerId` (UUID)

**Инварианты:**
- Клиент может быть привязан к пациенту или к счёту (или к обоим)
- Email должен быть уникальным
- Телефон должен быть верифицирован

**События, публикуемые:**
- `CustomerCreated` — при создании
- `CustomerVerified` — при верификации
- `CustomerUpdated` — при обновлении

---

## Сводная таблица агрегатов

| Агрегат | Bounded Context | Ключ | Домен |
|---------|-----------------|------|-------|
| Patient | Patient Management | patientId | Medical |
| Visit | Patient Management | visitId | Medical |
| Study | Diagnostic | studyId | Medical |
| TreatmentPlan | Treatment | treatmentPlanId | Medical |
| Account | Banking | accountId | Finance |
| Credit | Banking | creditId | Finance |
| Payment | Payments | paymentId | Finance |
| Invoice | Payments | invoiceId | Finance |
| AnalysisJob | ML Pipeline | jobId | AI |
| Prediction | Analysis | predictionId | AI |
| Customer | Shared Kernel | customerId | Shared |
