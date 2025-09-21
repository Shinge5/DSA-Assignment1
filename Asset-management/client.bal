import ballerina/http;
import ballerina/io;

public function main() returns error? {
    // Create HTTP client
    http:Client assetClient = check new ("http://localhost:8080");
    
    io:println("=== NUST Asset Management System - Client Demo ===\n");
    
    // 1. Create Assets
    io:println("1. Creating Assets...");
    
    // Create first asset
    http:Response response1 = check assetClient->post("/assets", {
        assetTag: "EQ-001",
        name: "Laptop Computer",
        faculty: "Engineering",
        department: "Computer Science",
        dateAcquired: "2024-01-15",
        status: "ACTIVE",
        components: [],
        schedules: [],
        workOrders: []
    });
    
    if response1.statusCode == 201 {
        io:println("✓ Created asset EQ-001");
    } else {
        io:println("✗ Failed to create asset EQ-001");
    }
    
    // Create second asset
    http:Response response2 = check assetClient->post("/assets", {
        assetTag: "EQ-002",
        name: "Projector",
        faculty: "Business",
        department: "Management",
        dateAcquired: "2024-02-20",
        status: "ACTIVE",
        components: [],
        schedules: [],
        workOrders: []
    });
    
    if response2.statusCode == 201 {
        io:println("✓ Created asset EQ-002");
    } else {
        io:println("✗ Failed to create asset EQ-002");
    }
    
    // 2. View All Assets
    io:println("\n2. Viewing All Assets...");
    http:Response allAssets = check assetClient->get("/assets");
    if allAssets.statusCode == 200 {
        io:println("✓ Retrieved all assets");
    } else {
        io:println("✗ Failed to retrieve assets");
    }
    
    // 3. View Assets by Faculty
    io:println("\n3. Viewing Assets by Faculty (Engineering)...");
    http:Response engAssets = check assetClient->get("/assets?faculty=Engineering");
    if engAssets.statusCode == 200 {
        io:println("✓ Retrieved Engineering assets");
    } else {
        io:println("✗ Failed to retrieve Engineering assets");
    }
    
    // 4. Add Component to EQ-001
    io:println("\n4. Adding Component to EQ-001...");
    http:Response compResponse = check assetClient->post("/assets/EQ-001/components", {
        name: "Hard Drive",
        description: "1TB SSD Storage",
        serialNumber: "HD-001",
        status: "ACTIVE"
    });
    
    if compResponse.statusCode == 200 {
        io:println("✓ Added Hard Drive component");
    } else {
        io:println("✗ Failed to add component");
    }
    
    // 5. Add Maintenance Schedule to EQ-001
    io:println("\n5. Adding Maintenance Schedule to EQ-001...");
    http:Response scheduleResponse = check assetClient->post("/assets/EQ-001/schedules", {
        'type: "YEARLY",
        nextDue: "2025-01-15",
        description: "Annual maintenance check",
        status: "ACTIVE"
    });
    
    if scheduleResponse.statusCode == 200 {
        io:println("✓ Added yearly maintenance schedule");
    } else {
        io:println("✗ Failed to add schedule");
    }
    
    // 6. Create Work Order
    io:println("\n6. Creating Work Order for EQ-001...");
    http:Response woResponse = check assetClient->post("/assets/EQ-001/work-orders", {
        description: "Screen replacement needed",
        status: "OPEN"
    });
    
    if woResponse.statusCode == 200 {
        io:println("✓ Created work order");
    } else {
        io:println("✗ Failed to create work order");
    }
    
    // 7. Check Overdue Assets
    io:println("\n7. Checking for Overdue Assets...");
    http:Response overdueResponse = check assetClient->get("/assets/overdue");
    if overdueResponse.statusCode == 200 {
        io:println("✓ Retrieved overdue assets");
    } else {
        io:println("✗ Failed to retrieve overdue assets");
    }
    
    io:println("\n=== Demo Complete ===");
}
