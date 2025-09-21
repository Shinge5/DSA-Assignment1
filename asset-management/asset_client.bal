// src/asset_client.bal
import ballerina/http;
import 'types';
import ballerina/io;

public function main() returns error? {
    http:Client assetClient = check new ("http://localhost:8080", { httpVersion: http:HTTP_1_1 });

    // 1. Add asset
    types:Asset newAsset = {
        assetTag: "EQ-001",
        name: "3D Printer",
        faculty: "Computing & Informatics",
        department: "Software Engineering",
        status: "ACTIVE",
        acquiredDate: "2024-03-10",
        components: [],
        schedules: [],
        workOrders: []
    };
    json assetJson = check newAsset.cloneWithType(json);
    var response = check assetClient->post("/assets", assetJson);
    if response is http:Response {
        io:println("Added asset: ", check response.getJsonPayload());
    }

    // 2. Update asset (change status)
    json updateJson = { status: "UNDER_REPAIR" };
    response = check assetClient->put("/assets/EQ-001", updateJson);
    if response is http:Response {
        io:println("Updated: ", check response.getJsonPayload());
    }

    // 3. View all
    response = check assetClient->get("/assets");
    if response is http:Response {
        io:println("All assets: ", check response.getJsonPayload());
    }

    // 4. View by faculty
    response = check assetClient->get("/assets/faculty/Computing%20&%20Informatics");
    if response is http:Response {
        io:println("By faculty: ", check response.getJsonPayload());
    }

    // 5. Overdue check (add a past schedule first)
    json schedJson = { scheduleId: "S1", scheduleType: "quarterly", nextDueDate: "2024-01-01" };  // Past date
    response = check assetClient->post("/assets/EQ-001/schedules", schedJson);
    response = check assetClient->get("/assets/overdue");
    if response is http:Response {
        io:println("Overdue: ", check response.getJsonPayload());
    }

    // 6. Manage component
    json compJson = { componentId: "C1", name: "Motor", description: "Main motor" };
    response = check assetClient->post("/assets/EQ-001/components", compJson);
    if response is http:Response {
        io:println("Added component: ", check response.getJsonPayload());
    }
}