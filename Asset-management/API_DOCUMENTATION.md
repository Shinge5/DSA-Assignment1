# NUST Asset Management API Documentation

## Overview
This API provides comprehensive asset management capabilities for the National University of Science and Technology (NUST). It supports managing equipment, vehicles, servers, and other university assets with full lifecycle tracking including components, maintenance schedules, work orders, and tasks.

## Base URL
```
http://localhost:8080/api/v1
```

## Authentication
Currently, no authentication is required. In production, implement appropriate authentication mechanisms.

## Data Models

### Asset
```json
{
  "assetTag": "string (required, unique)",
  "name": "string (required)",
  "faculty": "string (required)",
  "department": "string (required)",
  "dateAcquired": "string (required, YYYY-MM-DD)",
  "status": "string (required, ACTIVE|UNDER_REPAIR|DISPOSED)",
  "components": "Component[] (optional)",
  "schedules": "MaintenanceSchedule[] (optional)",
  "workOrders": "WorkOrder[] (optional)"
}
```

### Component
```json
{
  "name": "string (required)",
  "description": "string (optional)",
  "serialNumber": "string (optional)",
  "status": "string (required, ACTIVE|FAULTY|REPLACED)"
}
```

### MaintenanceSchedule
```json
{
  "type": "string (required, YEARLY|QUARTERLY|MONTHLY)",
  "nextDue": "string (required, YYYY-MM-DD)",
  "description": "string (optional)",
  "status": "string (required, ACTIVE|COMPLETED|CANCELLED)"
}
```

### WorkOrder
```json
{
  "id": "string (auto-generated)",
  "description": "string (required)",
  "status": "string (required, OPEN|IN_PROGRESS|COMPLETED|CANCELLED)",
  "createdDate": "string (auto-generated, ISO 8601)",
  "completedDate": "string (optional, ISO 8601)",
  "tasks": "Task[] (optional)"
}
```

### Task
```json
{
  "id": "string (auto-generated)",
  "description": "string (required)",
  "status": "string (required, PENDING|IN_PROGRESS|COMPLETED|CANCELLED)",
  "assignedTo": "string (optional)",
  "dueDate": "string (optional, YYYY-MM-DD)"
}
```

## API Endpoints

### Asset Management

#### Create Asset
```http
POST /assets
Content-Type: application/json

{
  "assetTag": "EQ-001",
  "name": "Laptop Computer",
  "faculty": "Engineering",
  "department": "Computer Science",
  "dateAcquired": "2024-01-15",
  "status": "ACTIVE"
}
```

**Response:** `201 Created` with the created asset

#### Get All Assets
```http
GET /assets
```

**Response:** `200 OK` with array of all assets

#### Get Asset by Tag
```http
GET /assets/{assetTag}
```

**Response:** `200 OK` with the specific asset or `404 Not Found`

#### Update Asset
```http
PUT /assets/{assetTag}
Content-Type: application/json

{
  "assetTag": "EQ-001",
  "name": "Updated Laptop Computer",
  "faculty": "Engineering",
  "department": "Computer Science",
  "dateAcquired": "2024-01-15",
  "status": "UNDER_REPAIR"
}
```

**Response:** `200 OK` with the updated asset or `404 Not Found`

#### Delete Asset
```http
DELETE /assets/{assetTag}
```

**Response:** `200 OK` with success message or `404 Not Found`

#### Get Assets by Faculty
```http
GET /assets/faculty/{faculty}
```

**Response:** `200 OK` with array of assets for the specified faculty

#### Get Overdue Assets
```http
GET /assets/overdue
```

**Response:** `200 OK` with array of assets that have overdue maintenance

### Component Management

#### Add Component to Asset
```http
POST /assets/{assetTag}/components
Content-Type: application/json

{
  "name": "Hard Drive",
  "description": "1TB SSD Storage",
  "serialNumber": "HD-001",
  "status": "ACTIVE"
}
```

**Response:** `201 Created` with the created component

#### Get Components for Asset
```http
GET /assets/{assetTag}/components
```

**Response:** `200 OK` with array of components or `404 Not Found`

#### Delete Component
```http
DELETE /assets/{assetTag}/components/{componentName}
```

**Response:** `200 OK` with success message or `404 Not Found`

### Maintenance Schedule Management

#### Add Maintenance Schedule
```http
POST /assets/{assetTag}/schedules
Content-Type: application/json

{
  "type": "YEARLY",
  "nextDue": "2024-12-15",
  "description": "Annual maintenance and cleaning",
  "status": "ACTIVE"
}
```

**Response:** `201 Created` with the created schedule

#### Get Schedules for Asset
```http
GET /assets/{assetTag}/schedules
```

**Response:** `200 OK` with array of schedules or `404 Not Found`

#### Delete Schedule
```http
DELETE /assets/{assetTag}/schedules/{scheduleType}
```

**Response:** `200 OK` with success message or `404 Not Found`

### Work Order Management

#### Create Work Order
```http
POST /assets/{assetTag}/work-orders
Content-Type: application/json

{
  "description": "Laptop screen flickering - needs repair",
  "status": "OPEN"
}
```

**Response:** `201 Created` with the created work order (includes auto-generated ID and createdDate)

#### Get Work Orders for Asset
```http
GET /assets/{assetTag}/work-orders
```

**Response:** `200 OK` with array of work orders or `404 Not Found`

#### Update Work Order
```http
PUT /assets/{assetTag}/work-orders/{workOrderId}
Content-Type: application/json

{
  "description": "Updated work order description",
  "status": "IN_PROGRESS",
  "completedDate": "2024-01-20T10:30:00Z"
}
```

**Response:** `200 OK` with the updated work order or `404 Not Found`

#### Delete Work Order
```http
DELETE /assets/{assetTag}/work-orders/{workOrderId}
```

**Response:** `200 OK` with success message or `404 Not Found`

### Task Management

#### Add Task to Work Order
```http
POST /assets/{assetTag}/work-orders/{workOrderId}/tasks
Content-Type: application/json

{
  "description": "Diagnose screen flickering issue",
  "status": "PENDING",
  "assignedTo": "John Smith",
  "dueDate": "2024-01-20"
}
```

**Response:** `201 Created` with the created task (includes auto-generated ID)

#### Get Tasks for Work Order
```http
GET /assets/{assetTag}/work-orders/{workOrderId}/tasks
```

**Response:** `200 OK` with array of tasks or `404 Not Found`

#### Update Task
```http
PUT /assets/{assetTag}/work-orders/{workOrderId}/tasks/{taskId}
Content-Type: application/json

{
  "description": "Updated task description",
  "status": "IN_PROGRESS",
  "assignedTo": "Jane Doe",
  "dueDate": "2024-01-25"
}
```

**Response:** `200 OK` with the updated task or `404 Not Found`

#### Delete Task
```http
DELETE /assets/{assetTag}/work-orders/{workOrderId}/tasks/{taskId}
```

**Response:** `200 OK` with success message or `404 Not Found`

### Reference Data

#### Get Faculties
```http
GET /faculties
```

**Response:** `200 OK` with array of available faculties

#### Get Departments
```http
GET /departments
```

**Response:** `200 OK` with array of available departments

#### Get Asset Types
```http
GET /asset_types
```

**Response:** `200 OK` with array of available asset types

#### Get Statuses
```http
GET /statuses
```

**Response:** `200 OK` with array of available statuses

## Error Responses

All error responses follow this format:
```json
{
  "error": "Error message description"
}
```

Common HTTP status codes:
- `200 OK` - Request successful
- `201 Created` - Resource created successfully
- `400 Bad Request` - Invalid request data
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

## Example Usage

### Complete Asset Lifecycle Example

1. **Create an asset:**
```bash
curl -X POST http://localhost:8080/api/v1/assets \
  -H "Content-Type: application/json" \
  -d '{
    "assetTag": "EQ-001",
    "name": "Dell Laptop",
    "faculty": "Engineering",
    "department": "Computer Science",
    "dateAcquired": "2024-01-15",
    "status": "ACTIVE"
  }'
```

2. **Add components:**
```bash
curl -X POST http://localhost:8080/api/v1/assets/EQ-001/components \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Hard Drive",
    "description": "1TB SSD",
    "serialNumber": "HD-001",
    "status": "ACTIVE"
  }'
```

3. **Add maintenance schedule:**
```bash
curl -X POST http://localhost:8080/api/v1/assets/EQ-001/schedules \
  -H "Content-Type: application/json" \
  -d '{
    "type": "YEARLY",
    "nextDue": "2024-12-15",
    "description": "Annual maintenance",
    "status": "ACTIVE"
  }'
```

4. **Create work order:**
```bash
curl -X POST http://localhost:8080/api/v1/assets/EQ-001/work-orders \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Screen flickering issue",
    "status": "OPEN"
  }'
```

5. **Add task to work order:**
```bash
curl -X POST http://localhost:8080/api/v1/assets/EQ-001/work-orders/{workOrderId}/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Diagnose screen issue",
    "status": "PENDING",
    "assignedTo": "John Smith",
    "dueDate": "2024-01-20"
  }'
```

## Rate Limiting
Currently no rate limiting is implemented. Consider implementing rate limiting for production use.

## CORS
CORS is not configured. Add appropriate CORS headers for web client access.

## Monitoring and Logging
The API includes basic logging. Consider adding structured logging and monitoring for production use.
