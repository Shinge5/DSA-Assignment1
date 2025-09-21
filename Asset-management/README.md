# NUST Asset Management System

A comprehensive RESTful API built in Ballerina for managing university assets including equipment, vehicles, and servers with full support for components, maintenance schedules, work orders, and tasks.

## Files

- `server.bal` - The main RESTful API server
- `client.bal` - Comprehensive client for testing all API endpoints

## Features

### Asset Management
- ✅ Create, Read, Update, Delete assets
- ✅ Filter assets by faculty
- ✅ Check for overdue maintenance
- ✅ Get reference data (faculties, departments, asset types, statuses)

### Component Management
- ✅ Add, view, delete components for assets
- ✅ Track component status (ACTIVE, FAULTY, REPLACED)

### Maintenance Schedule Management
- ✅ Add, view, delete maintenance schedules
- ✅ Support for YEARLY, QUARTERLY, MONTHLY schedules
- ✅ Track schedule status (ACTIVE, COMPLETED, CANCELLED)

### Work Order Management
- ✅ Create, view, update, delete work orders
- ✅ Track work order status (OPEN, IN_PROGRESS, COMPLETED, CANCELLED)
- ✅ Automatic ID generation and date tracking

### Task Management
- ✅ Add, view, update, delete tasks within work orders
- ✅ Track task status (PENDING, IN_PROGRESS, COMPLETED, CANCELLED)
- ✅ Assign tasks to specific personnel

### Data Model
Each asset contains:
- `assetTag` - Unique identifier (e.g., "EQ-001")
- `name` - Asset name
- `faculty` - Faculty name
- `department` - Department name
- `dateAcquired` - Acquisition date
- `status` - Current status (ACTIVE, UNDER_REPAIR, DISPOSED)
- `components[]` - Array of components
- `schedules[]` - Array of maintenance schedules
- `workOrders[]` - Array of work orders

## How to Run

### 1. Start the Server
```bash
cd /Users/erassy/Projects/Assignments/asset-api
bal run server.bal
```

The server will start on `http://localhost:8080`

### 2. Run the Client
```bash
cd /Users/erassy/Projects/Assignments/asset-api
bal run client.bal
```

## API Endpoints

### Asset Management
- `POST /api/v1/assets` - Create new asset
- `GET /api/v1/assets` - Get all assets
- `GET /api/v1/assets/{assetTag}` - Get specific asset
- `PUT /api/v1/assets/{assetTag}` - Update asset
- `DELETE /api/v1/assets/{assetTag}` - Delete asset
- `GET /api/v1/assets/faculty/{faculty}` - Get assets by faculty
- `GET /api/v1/assets/overdue` - Get assets with overdue maintenance

### Component Management
- `POST /api/v1/assets/{assetTag}/components` - Add component to asset
- `GET /api/v1/assets/{assetTag}/components` - Get all components for asset
- `DELETE /api/v1/assets/{assetTag}/components/{componentName}` - Delete component

### Maintenance Schedule Management
- `POST /api/v1/assets/{assetTag}/schedules` - Add maintenance schedule
- `GET /api/v1/assets/{assetTag}/schedules` - Get all schedules for asset
- `DELETE /api/v1/assets/{assetTag}/schedules/{scheduleType}` - Delete schedule

### Work Order Management
- `POST /api/v1/assets/{assetTag}/work-orders` - Create work order
- `GET /api/v1/assets/{assetTag}/work-orders` - Get all work orders for asset
- `PUT /api/v1/assets/{assetTag}/work-orders/{workOrderId}` - Update work order
- `DELETE /api/v1/assets/{assetTag}/work-orders/{workOrderId}` - Delete work order

### Task Management
- `POST /api/v1/assets/{assetTag}/work-orders/{workOrderId}/tasks` - Add task to work order
- `GET /api/v1/assets/{assetTag}/work-orders/{workOrderId}/tasks` - Get all tasks for work order
- `PUT /api/v1/assets/{assetTag}/work-orders/{workOrderId}/tasks/{taskId}` - Update task
- `DELETE /api/v1/assets/{assetTag}/work-orders/{workOrderId}/tasks/{taskId}` - Delete task

### Reference Data
- `GET /api/v1/faculties` - Get all faculties
- `GET /api/v1/departments` - Get all departments
- `GET /api/v1/asset_types` - Get all asset types
- `GET /api/v1/statuses` - Get all statuses

## Example Usage

The client demonstrates:
1. Creating multiple assets (Equipment, Vehicle)
2. Viewing all assets
3. Filtering assets by faculty
4. Managing components (add, view)
5. Managing maintenance schedules (add, view)
6. Managing work orders (create, add tasks)
7. Checking for overdue assets
8. Updating asset information
9. Deleting assets
10. Retrieving reference data

## Requirements

- Ballerina 2201.12.9 or later
- Java 21 or later

## Status

✅ **FULLY FUNCTIONAL** - All basic asset management operations are working correctly.
