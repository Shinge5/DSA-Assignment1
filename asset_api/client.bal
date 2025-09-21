import ballerina/http;
import ballerina/io;

public function main() returns error? {
    http:Client assetClient = check new ("http://localhost:8080/api/v1");
    
    io:println("=== NUST Asset Management System Client Demo ===\n");
    
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
    
    if response1.statusCode == 200 {
        io:println("✓ Asset EQ-001 created successfully");
    } else {
        io:println("✗ Failed to create asset EQ-001");
    }
    
    // Create second asset
    http:Response response2 = check assetClient->post("/assets", {
        assetTag: "VEH-001",
        name: "University Van",
        faculty: "Business",
        department: "Finance",
        dateAcquired: "2024-02-01",
    status: "ACTIVE",
    components: [],
    schedules: [],
    workOrders: []
    });
    
    if response2.statusCode == 200 {
        io:println("✓ Asset VEH-001 created successfully");
    } else {
        io:println("✗ Failed to create asset VEH-001");
    }
    
    // 2. View All Assets
    io:println("\n2. Viewing All Assets...");
    http:Response response3 = check assetClient->get("/assets");
    if response3.statusCode == 200 {
        json payload = check response3.getJsonPayload();
        io:println("✓ Retrieved all assets:");
        io:println(payload.toString());
    } else {
        io:println("✗ Failed to retrieve assets");
    }
    
    // 3. View Assets by Faculty
    io:println("\n3. Viewing Assets by Faculty (Engineering)...");
    http:Response response4 = check assetClient->get("/assets/faculty/Engineering");
    if response4.statusCode == 200 {
        json payload = check response4.getJsonPayload();
        io:println("✓ Retrieved Engineering assets:");
        io:println(payload.toString());
    } else {
        io:println("✗ Failed to retrieve Engineering assets");
    }
    
    // 4. Get Reference Data
    io:println("\n4. Getting Reference Data...");
    
    // Get faculties
    http:Response response5 = check assetClient->get("/faculties");
    if response5.statusCode == 200 {
        json payload = check response5.getJsonPayload();
        io:println("✓ Faculties:");
        io:println(payload.toString());
    }
    
    // Get departments
    http:Response response6 = check assetClient->get("/departments");
    if response6.statusCode == 200 {
        json payload = check response6.getJsonPayload();
        io:println("✓ Departments:");
        io:println(payload.toString());
    }
    
    // Get asset types
    http:Response response7 = check assetClient->get("/asset_types");
    if response7.statusCode == 200 {
        json payload = check response7.getJsonPayload();
        io:println("✓ Asset Types:");
        io:println(payload.toString());
    }
    
    // Get statuses
    http:Response response8 = check assetClient->get("/statuses");
    if response8.statusCode == 200 {
        json payload = check response8.getJsonPayload();
        io:println("✓ Statuses:");
        io:println(payload.toString());
    }
    
    // 5. Manage Components
    io:println("\n5. Managing Components...");
    
    // Add components to EQ-001
    http:Response comp1 = check assetClient->post("/assets/EQ-001/components", {
        name: "Hard Drive",
        description: "1TB SSD Storage",
        serialNumber: "HD-001",
        status: "ACTIVE"
    });
    
    if comp1.statusCode == 200 {
        io:println("✓ Added Hard Drive component");
    }
    
    http:Response comp2 = check assetClient->post("/assets/EQ-001/components", {
        name: "RAM",
        description: "16GB DDR4 Memory",
        serialNumber: "RAM-001",
        status: "ACTIVE"
    });
    
    if comp2.statusCode == 200 {
        io:println("✓ Added RAM component");
    }
    
    // View components
    http:Response compList = check assetClient->get("/assets/EQ-001/components");
    if compList.statusCode == 200 {
        json payload = check compList.getJsonPayload();
        io:println("✓ Components for EQ-001:");
        io:println(payload.toString());
    }
    
    // 6. Manage Maintenance Schedules
    io:println("\n6. Managing Maintenance Schedules...");
    
    // Add maintenance schedule
    http:Response sched1 = check assetClient->post("/assets/EQ-001/schedules", {
        type: "YEARLY",
        nextDue: "2024-12-15",
        description: "Annual maintenance and cleaning",
        status: "ACTIVE"
    });
    
    if sched1.statusCode == 200 {
        io:println("✓ Added yearly maintenance schedule");
    }
    
    http:Response sched2 = check assetClient->post("/assets/EQ-001/schedules", {
        type: "QUARTERLY",
        nextDue: "2024-03-15",
        description: "Quarterly inspection",
        status: "ACTIVE"
    });
    
    if sched2.statusCode == 200 {
        io:println("✓ Added quarterly maintenance schedule");
    }
    
    // View schedules
    http:Response schedList = check assetClient->get("/assets/EQ-001/schedules");
    if schedList.statusCode == 200 {
        json payload = check schedList.getJsonPayload();
        io:println("✓ Schedules for EQ-001:");
        io:println(payload.toString());
    }
    
    // 7. Manage Work Orders
    io:println("\n7. Managing Work Orders...");
    
    // Create work order
    http:Response wo1 = check assetClient->post("/assets/EQ-001/work-orders", {
        description: "Laptop screen flickering - needs repair",
        status: "OPEN"
    });
    
    if wo1.statusCode == 200 {
        json woPayload = check wo1.getJsonPayload();
        io:println("✓ Created work order: " + woPayload.id.toString());
        
        // Add tasks to work order
        string workOrderId = woPayload.id.toString();
        
        http:Response task1 = check assetClient->post("/assets/EQ-001/work-orders/" + workOrderId + "/tasks", {
            description: "Diagnose screen flickering issue",
            status: "PENDING",
            assignedTo: "John Smith",
            dueDate: "2024-01-20"
        });
        
        if task1.statusCode == 200 {
            io:println("✓ Added diagnostic task");
        }
        
        http:Response task2 = check assetClient->post("/assets/EQ-001/work-orders/" + workOrderId + "/tasks", {
            description: "Replace screen if needed",
            status: "PENDING",
            assignedTo: "Jane Doe",
            dueDate: "2024-01-25"
        });
        
        if task2.statusCode == 200 {
            io:println("✓ Added repair task");
        }
        
        // View tasks
        http:Response taskList = check assetClient->get("/assets/EQ-001/work-orders/" + workOrderId + "/tasks");
        if taskList.statusCode == 200 {
            json payload = check taskList.getJsonPayload();
            io:println("✓ Tasks for work order:");
            io:println(payload.toString());
        }
    }
    
    // 8. Check for Overdue Assets
    io:println("\n8. Checking for Overdue Assets...");
    http:Response overdue = check assetClient->get("/assets/overdue");
    if overdue.statusCode == 200 {
        json payload = check overdue.getJsonPayload();
        io:println("✓ Overdue assets:");
        io:println(payload.toString());
    }
    
    // 9. Update Asset
    io:println("\n9. Updating Asset...");
    http:Response response9 = check assetClient->put("/assets/EQ-001", {
        assetTag: "EQ-001",
        name: "Laptop Computer (Updated)",
        faculty: "Engineering",
        department: "Computer Science",
        dateAcquired: "2024-01-15",
        status: "UNDER_REPAIR",
        components: [],
        schedules: [],
        workOrders: []
    });
    
    if response9.statusCode == 200 {
        io:println("✓ Asset EQ-001 updated successfully");
    } else {
        io:println("✗ Failed to update asset EQ-001");
    }
    
    // 10. Get Specific Asset
    io:println("\n10. Getting Specific Asset (EQ-001)...");
    http:Response response10 = check assetClient->get("/assets/EQ-001");
    if response10.statusCode == 200 {
        json payload = check response10.getJsonPayload();
        io:println("✓ Retrieved asset EQ-001:");
        io:println(payload.toString());
    } else {
        io:println("✗ Failed to retrieve asset EQ-001");
    }
    
    // 11. Delete Asset
    io:println("\n11. Deleting Asset (VEH-001)...");
    http:Response response11 = check assetClient->delete("/assets/VEH-001");
    if response11.statusCode == 200 {
        io:println("✓ Asset VEH-001 deleted successfully");
    } else {
        io:println("✗ Failed to delete asset VEH-001");
    }
    
    // 12. Final Asset List
    io:println("\n12. Final Asset List...");
    http:Response response12 = check assetClient->get("/assets");
    if response12.statusCode == 200 {
        json payload = check response12.getJsonPayload();
        io:println("✓ Final assets:");
        io:println(payload.toString());
    } else {
        io:println("✗ Failed to retrieve final assets");
    }
    
    io:println("\n=== Demo Complete ===");
}
