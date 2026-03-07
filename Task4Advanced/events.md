# Каталог доменных событий

## Введение

Данный документ содержит полный каталог доменных событий для системы «Будущее 2.0». Для каждого события указаны: название, контекст-источник, семантика, минимальный контракт (поля).

---

## Медицинский домен (Medical Domain)

### Patient Context

#### PatientRegistered
- **Описание:** Зарегистрирован новый пациент в системе
- **Источник:** Patient Context (Patient Aggregate)
- **Подписчики:** Banking Context, Portal, Notification Service
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "PatientRegistered",
    "timestamp": "ISO-8601",
    "patientId": "uuid",
    "firstName": "string",
    "lastName": "string",
    "dateOfBirth": "date",
    "gender": "string",
    "contactInfo": {
      "email": "string",
      "phone": "string"
    },
    "insuranceInfo": {
      "provider": "string",
      "policyNumber": "string"
    }
  }
  ```

#### PatientUpdated
- **Описание:** Обновлены данные пациента
- **Источник:** Patient Context (Patient Aggregate)
- **Подписчики:** Banking Context, Portal
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "PatientUpdated",
    "timestamp": "ISO-8601",
    "patientId": "uuid",
    "previousVersion": "int",
    "updatedFields": ["string"],
    "changes": "object"
  }
  ```

#### PatientVerified
- **Описание:** Пациент прошёл верификацию личности
- **Источник:** Patient Context (Patient Aggregate)
- **Подписчики:** Banking Context, Portal
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "PatientVerified",
    "timestamp": "ISO-8601",
    "patientId": "uuid",
    "verificationMethod": "string",
    "verifiedAt": "ISO-8601"
  }
  ```

---

### Visit Context

#### VisitScheduled
- **Описание:** Запланирован визит пациента
- **Источник:** Patient Context (Visit Aggregate)
- **Подписчики:** Notification Service, Portal
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "VisitScheduled",
    "timestamp": "ISO-8601",
    "visitId": "uuid",
    "patientId": "uuid",
    "doctorId": "uuid",
    "scheduledAt": "ISO-8601",
    "department": "string"
  }
  ```

#### VisitCompleted
- **Описание:** Визит завершён
- **Источник:** Patient Context (Visit Aggregate)
- **Подписчики:** Portal, Diagnostic Context
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "VisitCompleted",
    "timestamp": "ISO-8601",
    "visitId": "uuid",
    "patientId": "uuid",
    "completedAt": "ISO-8601",
    "summary": "string"
  }
  ```

---

### Diagnostic Context

#### StudyOrdered
- **Описание:** Назначено медицинское исследование
- **Источник:** Diagnostic Context (Study Aggregate)
- **Подписчики:** AI Services, Portal
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "StudyOrdered",
    "timestamp": "ISO-8601",
    "studyId": "uuid",
    "patientId": "uuid",
    "visitId": "uuid",
    "studyType": "string",
    "orderedBy": "uuid",
    "priority": "string"
  }
  ```

#### StudyCompleted
- **Описание:** Медицинское исследование завершено
- **Источник:** Diagnostic Context (Study Aggregate)
- **Подписчики:** AI Services, Treatment Context, Portal
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "StudyCompleted",
    "timestamp": "ISO-8601",
    "studyId": "uuid",
    "patientId": "uuid",
    "completedAt": "ISO-8601",
    "resultsAvailable": "boolean",
    "findings": "string"
  }
  ```

#### StudyResultsAvailable
- **Описание:** Результаты исследования доступны
- **Источник:** Diagnostic Context (Study Aggregate)
- **Подписчики:** AI Services, Portal
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "StudyResultsAvailable",
    "timestamp": "ISO-8601",
    "studyId": "uuid",
    "patientId": "uuid",
    "resultUrl": "string",
    "resultType": "string"
  }
  ```

---

### Treatment Context

#### TreatmentPrescribed
- **Описание:** Назначено лечение
- **Источник:** Treatment Context (TreatmentPlan Aggregate)
- **Подписчики:** Payments Context, Portal, Notification Service
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "TreatmentPrescribed",
    "timestamp": "ISO-8601",
    "treatmentPlanId": "uuid",
    "patientId": "uuid",
    "diagnosis": "string",
    "prescriptions": [
      {
        "medication": "string",
        "dosage": "string",
        "frequency": "string",
        "duration": "string"
      }
    ],
    "procedures": ["string"],
    "estimatedCost": "decimal"
  }
  ```

#### TreatmentCompleted
- **Описание:** Лечение завершено
- **Источник:** Treatment Context (TreatmentPlan Aggregate)
- **Подписчики:** Portal, Reporting
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "TreatmentCompleted",
    "timestamp": "ISO-8601",
    "treatmentPlanId": "uuid",
    "patientId": "uuid",
    "completedAt": "ISO-8601",
    "outcome": "string",
    "finalCost": "decimal"
  }
  ```

---

## Финансовый домен (Finance Domain)

### Banking Context

#### AccountCreated
- **Описание:** Создан банковский счёт
- **Источник:** Banking Context (Account Aggregate)
- **Подписчики:** Medical Context, Portal, Reporting
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "AccountCreated",
    "timestamp": "ISO-8601",
    "accountId": "uuid",
    "customerId": "uuid",
    "accountType": "string",
    "accountNumber": "string",
    "currency": "string",
    "initialBalance": "decimal"
  }
  ```

#### CreditApplicationSubmitted
- **Описание:** Подана заявка на кредит
- **Источник:** Banking Context (Credit Aggregate)
- **Подписчики:** Medical Context, Portal
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "CreditApplicationSubmitted",
    "timestamp": "ISO-8601",
    "applicationId": "uuid",
    "customerId": "uuid",
    "requestedAmount": "decimal",
    "requestedTerm": "int",
    "purpose": "string"
  }
  ```

#### CreditApproved
- **Описание:** Кредит одобрен
- **Источник:** Banking Context (Credit Aggregate)
- **Подписчики:** Medical Context, Portal, Payments Context
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "CreditApproved",
    "timestamp": "ISO-8601",
    "creditId": "uuid",
    "customerId": "uuid",
    "approvedAmount": "decimal",
    "interestRate": "decimal",
    "term": "int",
    "monthlyPayment": "decimal"
  }
  ```

#### CreditDisbursed
- **Описание:** Кредит выдан (средства зачислены)
- **Источник:** Banking Context (Credit Aggregate)
- **Подписчики:** Payments Context, Portal
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "CreditDisbursed",
    "timestamp": "ISO-8601",
    "creditId": "uuid",
    "accountId": "uuid",
    "amount": "decimal",
    "disbursedAt": "ISO-8601"
  }
  ```

---

### Payments Context

#### InvoiceGenerated
- **Описание:** Сформирован счёт на оплату
- **Источник:** Payments Context (Invoice Aggregate)
- **Подписчики:** Medical Context, Banking Context, Portal
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "InvoiceGenerated",
    "timestamp": "ISO-8601",
    "invoiceId": "uuid",
    "customerId": "uuid",
    "treatmentPlanId": "uuid",
    "amount": "decimal",
    "dueDate": "date",
    "lineItems": [
      {
        "description": "string",
        "quantity": "int",
        "unitPrice": "decimal",
        "total": "decimal"
      }
    ]
  }
  ```

#### PaymentInitiated
- **Описание:** Инициирован платёж
- **Источник:** Payments Context (Payment Aggregate)
- **Подписчики:** Banking Context, Portal
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "PaymentInitiated",
    "timestamp": "ISO-8601",
    "paymentId": "uuid",
    "invoiceId": "uuid",
    "customerId": "uuid",
    "amount": "decimal",
    "paymentMethod": "string"
  }
  ```

#### PaymentCompleted
- **Описание:** Платёж успешно завершён
- **Источник:** Payments Context (Payment Aggregate)
- **Подписчики:** Medical Context, Banking Context, Portal, Reporting
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "PaymentCompleted",
    "timestamp": "ISO-8601",
    "paymentId": "uuid",
    "invoiceId": "uuid",
    "customerId": "uuid",
    "amount": "decimal",
    "completedAt": "ISO-8601",
    "transactionId": "string"
  }
  ```

#### PaymentRefunded
- **Описание:** Платёж возвращён
- **Источник:** Payments Context (Payment Aggregate)
- **Подписчики:** Banking Context, Portal, Reporting
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "PaymentRefunded",
    "timestamp": "ISO-8601",
    "paymentId": "uuid",
    "originalPaymentId": "uuid",
    "amount": "decimal",
    "reason": "string",
    "refundedAt": "ISO-8601"
  }
  ```

---

## ИИ-домен (AI Services Domain)

### ML Pipeline Context

#### AnalysisRequested
- **Описание:** Запрошен анализ медицинских данных
- **Источник:** ML Pipeline Context (AnalysisJob Aggregate)
- **Подписчики:** Medical Context, Portal
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "AnalysisRequested",
    "timestamp": "ISO-8601",
    "jobId": "uuid",
    "patientId": "uuid",
    "studyId": "uuid",
    "analysisType": "string",
    "modelVersion": "string"
  }
  ```

#### AnalysisCompleted
- **Описане:** Анализ завершён
- **Источник:** ML Pipeline Context (AnalysisJob Aggregate)
- **Подписчики:** Medical Context, Portal, Treatment Context
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "AnalysisCompleted",
    "timestamp": "ISO-8601",
    "jobId": "uuid",
    "patientId": "uuid",
    "completedAt": "ISO-8601",
    "processingTime": "int",
    "predictionId": "uuid"
  }
  ```

---

### Analysis Context

#### PredictionGenerated
- **Описание:** Сгенерирован прогноз/рекомендация
- **Источник:** Analysis Context (Prediction Aggregate)
- **Подписчики:** Medical Context, Portal, Treatment Context
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "PredictionGenerated",
    "timestamp": "ISO-8601",
    "predictionId": "uuid",
    "patientId": "uuid",
    "analysisType": "string",
    "prediction": {
      "result": "string",
      "confidence": "decimal",
      "recommendations": ["string"]
    },
    "modelInfo": {
      "modelName": "string",
      "modelVersion": "string"
    }
  }
  ```

---

## Общие события (Shared Kernel)

### Customer Context

#### CustomerCreated
- **Описание:** Создана универсальная запись клиента
- **Источник:** Shared Kernel (Customer Aggregate)
- **Подписчики:** All domains
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "CustomerCreated",
    "timestamp": "ISO-8601",
    "customerId": "uuid",
    "patientId": "uuid",
    "accountId": "uuid",
    "email": "string",
    "createdAt": "ISO-8601"
  }
  ```

#### CustomerVerified
- **Описание:** Клиент верифицирован
- **Источник:** Shared Kernel (Customer Aggregate)
- **Подписчики:** All domains
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "CustomerVerified",
    "timestamp": "ISO-8601",
    "customerId": "uuid",
    "verificationLevel": "string",
    "verifiedAt": "ISO-8601"
  }
  ```

---

### Notification Context

#### NotificationSent
- **Описание:** Отправлено уведомление
- **Источник:** Shared Kernel (Notification Aggregate)
- **Подписчики:** Reporting
- **Контракт:**
  ```json
  {
    "eventId": "uuid",
    "eventType": "NotificationSent",
    "timestamp": "ISO-8601",
    "notificationId": "uuid",
    "customerId": "uuid",
    "channel": "string",
    "subject": "string",
    "sentAt": "ISO-8601"
  }
  ```

---

## Сводная таблица событий

| Событие | Bounded Context | Издатель | Подписчики |
|---------|-----------------|----------|------------|
| PatientRegistered | Patient Context | Patient | Banking, Portal |
| PatientUpdated | Patient Context | Patient | Banking, Portal |
| PatientVerified | Patient Context | Patient | Banking, Portal |
| VisitScheduled | Patient Context | Visit | Notifications |
| VisitCompleted | Patient Context | Visit | Portal, Diagnostic |
| StudyOrdered | Diagnostic Context | Study | AI Services |
| StudyCompleted | Diagnostic Context | Study | AI, Treatment |
| StudyResultsAvailable | Diagnostic Context | Study | AI, Portal |
| TreatmentPrescribed | Treatment Context | TreatmentPlan | Payments, Portal |
| TreatmentCompleted | Treatment Context | TreatmentPlan | Portal |
| AccountCreated | Banking Context | Account | Medical, Portal |
| CreditApplicationSubmitted | Banking Context | Credit | Medical |
| CreditApproved | Banking Context | Credit | Medical, Payments |
| CreditDisbursed | Banking Context | Credit | Payments |
| InvoiceGenerated | Payments Context | Invoice | Medical, Banking |
| PaymentInitiated | Payments Context | Payment | Banking |
| PaymentCompleted | Payments Context | Payment | Medical, Banking |
| PaymentRefunded | Payments Context | Payment | Banking |
| AnalysisRequested | ML Pipeline Context | AnalysisJob | Medical |
| AnalysisCompleted | ML Pipeline Context | AnalysisJob | Medical, Treatment |
| PredictionGenerated | Analysis Context | Prediction | Medical, Treatment |
| CustomerCreated | Shared Kernel | Customer | All |
| CustomerVerified | Shared Kernel | Customer | All |
| NotificationSent | Shared Kernel | Notification | Reporting |
