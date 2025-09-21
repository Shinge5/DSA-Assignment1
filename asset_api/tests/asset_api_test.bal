import ballerina/test;
import ballerina/http;
import ballerina/uuid;
import ballerina/time;

// Test data
public type TestAsset record {|
    string assetTag;
    string name;
    string faculty;
    string department;
    string dateAcquired;
    string status;
    Component[] components;
    MaintenanceSchedule[] schedules;
    WorkOrder[] workOrders;
|};

public type Component record {|
    string name;
    string? description;
    string? serialNumber;
    string status;
|};

public type MaintenanceSchedule record {|
    string type;
    string nextDue;
    string? description;
    string status;
|};

public type WorkOrder record {|
    string id;
    string description;
    string status;
    string createdDate;
    string? completedDate;
    Task[] tasks;
|};

public type Task record {|
    string id;
    string description;
    string status;
    string? assignedTo;
    string? dueDate;
|};

@test:Config {}
function testCreateAsset() returns error? {
    http:Client assetClient = check new ("http://localhost:8080/api/v1");
    
    TestAsset newAsset = {
        assetTag: "TEST-001",
        name: "Test Equipment",
        faculty: "Engineering",
        department: "Computer Science",
        dateAcquired: "2024-01-01",
        status: "ACTIVE",
        components: [],
        schedules: [],
        workOrders: []
    };
    
    http:Response response = check assetClient->post("/assets", newAsset);
    test:assertEquals(response.statusCode, 200);
}

@test:Config {}
function testGetAllAssets() returns error? {
    http:Client assetClient = check new ("http://localhost:8080/api/v1");
    
    http:Response response = check assetClient->get("/assets");
    test:assertEquals(response.statusCode, 200);
}

@test:Config {}
function testGetAssetByTag() returns error? {
    http:Client assetClient = check new ("http://localhost:8080/api/v1");
    
    http:Response response = check assetClient->get("/assets/TEST-001");
    test:assertEquals(response.statusCode, 200);
}

@test:Config {}
function testGetFaculties() returns error? {
    http:Client assetClient = check new ("http://localhost:8080/api/v1");
    
    http:Response response = check assetClient->get("/faculties");
    test:assertEquals(response.statusCode, 200);
}

@test:Config {}
function testGetDepartments() returns error? {
    http:Client assetClient = check new ("http://localhost:8080/api/v1");
    
    http:Response response = check assetClient->get("/departments");
    test:assertEquals(response.statusCode, 200);
}

@test:Config {}
function testGetAssetTypes() returns error? {
    http:Client assetClient = check new ("http://localhost:8080/api/v1");
    
    http:Response response = check assetClient->get("/asset_types");
    test:assertEquals(response.statusCode, 200);
}

@test:Config {}
function testGetStatuses() returns error? {
    http:Client assetClient = check new ("http://localhost:8080/api/v1");
    
    http:Response response = check assetClient->get("/statuses");
    test:assertEquals(response.statusCode, 200);
}

@test:Config {}
function testAddComponent() returns error? {
    http:Client assetClient = check new ("http://localhost:8080/api/v1");
    
    Component newComponent = {
        name: "Test Component",
        description: "Test Description",
        serialNumber: "TC-001",
        status: "ACTIVE"
    };
    
    http:Response response = check assetClient->post("/assets/TEST-001/components", newComponent);
    test:assertEquals(response.statusCode, 200);
}

@test:Config {}
function testAddMaintenanceSchedule() returns error? {
    http:Client assetClient = check new ("http://localhost:8080/api/v1");
    
    MaintenanceSchedule newSchedule = {
        type: "YEARLY",
        nextDue: "2024-12-31",
        description: "Annual maintenance",
        status: "ACTIVE"
    };
    
    http:Response response = check assetClient->post("/assets/TEST-001/schedules", newSchedule);
    test:assertEquals(response.statusCode, 200);
}

@test:Config {}
function testCreateWorkOrder() returns error? {
    http:Client assetClient = check new ("http://localhost:8080/api/v1");
    
    WorkOrder newWorkOrder = {
        description: "Test work order",
        status: "OPEN"
    };
    
    http:Response response = check assetClient->post("/assets/TEST-001/work-orders", newWorkOrder);
    test:assertEquals(response.statusCode, 200);
}

@test:Config {}
function testCleanupTestAsset() returns error? {
    http:Client assetClient = check new ("http://localhost:8080/api/v1");
    
    http:Response response = check assetClient->delete("/assets/TEST-001");
    test:assertEquals(response.statusCode, 200);
}
