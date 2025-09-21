import ballerina/http;
import ballerina/uuid;
import ballerina/time;

// Data structures
public type Component record {|
    string name;
    string? description;
    string? serialNumber;
    string status = "ACTIVE"; // ACTIVE, FAULTY, REPLACED
|};

public type MaintenanceSchedule record {|
    string type; // YEARLY, QUARTERLY, MONTHLY
    string nextDue;
    string? description;
    string status = "ACTIVE"; // ACTIVE, COMPLETED, CANCELLED
|};

public type Task record {|
    string id;
    string description;
    string status = "PENDING"; // PENDING, IN_PROGRESS, COMPLETED, CANCELLED
    string? assignedTo;
    string? dueDate;
|};

public type WorkOrder record {|
    string id;
    string description;
    string status = "OPEN"; // OPEN, IN_PROGRESS, COMPLETED, CANCELLED
    string createdDate;
    string? completedDate;
    Task[] tasks = [];
|};

public type Asset record {|
    string assetTag;
    string name;
    string faculty;
    string department;
    string dateAcquired;
    string status;
    Component[] components = [];
    MaintenanceSchedule[] schedules = [];
    WorkOrder[] workOrders = [];
|};

// In-memory storage
map<Asset> assets = {};

listener http:Listener assetListener = new(8080);

service /api/v1 on assetListener {

    // Create Asset
    resource function post assets(@http:Payload Asset newAsset) returns Asset|error {
        if assets.hasKey(newAsset.assetTag) {
            return error("Asset with tag " + newAsset.assetTag + " already exists");
        }
        
        assets[newAsset.assetTag] = newAsset;
        return newAsset;
    }

    // Get All Assets
    resource function get assets() returns Asset[]|error {
        Asset[] result = [];
        foreach var [_, asset] in assets.entries() {
            result.push(asset);
        }
        return result;
    }

    // Get Asset by Tag
    resource function get assets/[string assetTag]() returns Asset|error {
        if !assets.hasKey(assetTag) {
            return error("Asset not found");
        }
        Asset? asset = assets[assetTag];
        if asset is () {
            return error("Asset not found");
        }
        return asset;
    }

    // Update Asset
    resource function put assets/[string assetTag](@http:Payload Asset updatedAsset) returns Asset|error {
        if !assets.hasKey(assetTag) {
            return error("Asset not found");
        }
        
        assets[assetTag] = updatedAsset;
        return updatedAsset;
    }

    // Delete Asset
    resource function delete assets/[string assetTag]() returns string|error {
        if !assets.hasKey(assetTag) {
            return error("Asset not found");
        }
        
        _ = assets.remove(assetTag);
        return "Asset deleted successfully";
    }

    // Get Assets by Faculty
    resource function get assets/faculty/[string faculty]() returns Asset[]|error {
        Asset[] result = [];
        foreach var [_, asset] in assets.entries() {
            if asset.faculty == faculty {
                result.push(asset);
            }
        }
        return result;
    }

    // ==================== COMPONENT MANAGEMENT ====================
    resource function post assets/[string assetTag]/components(@http:Payload Component newComponent) returns Component|error {
        if !assets.hasKey(assetTag) {
            return error("Asset not found");
        }
        
        Asset? asset = assets[assetTag];
        if asset is () {
            return error("Asset not found");
        }
        
        asset.components.push(newComponent);
        assets[assetTag] = asset;
        return newComponent;
    }

    resource function get assets/[string assetTag]/components() returns Component[]|error {
        if !assets.hasKey(assetTag) {
            return error("Asset not found");
        }
        
        Asset? asset = assets[assetTag];
        if asset is () {
            return error("Asset not found");
        }
        
        return asset.components;
    }

    resource function delete assets/[string assetTag]/components/[string componentName]() returns string|error {
        if !assets.hasKey(assetTag) {
            return error("Asset not found");
        }
        
        Asset? asset = assets[assetTag];
        if asset is () {
            return error("Asset not found");
        }
        
        Component[] newComponents = [];
        boolean found = false;
        foreach var component in asset.components {
            if component.name != componentName {
                newComponents.push(component);
            } else {
                found = true;
            }
        }
        
        if !found {
            return error("Component not found");
        }
        
        asset.components = newComponents;
        assets[assetTag] = asset;
        return "Component deleted successfully";
    }

    // ==================== MAINTENANCE SCHEDULE MANAGEMENT ====================
    resource function post assets/[string assetTag]/schedules(@http:Payload MaintenanceSchedule newSchedule) returns MaintenanceSchedule|error {
        if !assets.hasKey(assetTag) {
            return error("Asset not found");
        }
        
        Asset? asset = assets[assetTag];
        if asset is () {
            return error("Asset not found");
        }
        
        asset.schedules.push(newSchedule);
        assets[assetTag] = asset;
        return newSchedule;
    }

    resource function get assets/[string assetTag]/schedules() returns MaintenanceSchedule[]|error {
        if !assets.hasKey(assetTag) {
            return error("Asset not found");
        }
        
        Asset? asset = assets[assetTag];
        if asset is () {
            return error("Asset not found");
        }
        
        return asset.schedules;
    }

    resource function delete assets/[string assetTag]/schedules/[string scheduleType]() returns string|error {
        if !assets.hasKey(assetTag) {
            return error("Asset not found");
        }
        
        Asset? asset = assets[assetTag];
        if asset is () {
            return error("Asset not found");
        }
        
        MaintenanceSchedule[] newSchedules = [];
        boolean found = false;
        foreach var schedule in asset.schedules {
            if schedule.type != scheduleType {
                newSchedules.push(schedule);
            } else {
                found = true;
            }
        }
        
        if !found {
            return error("Schedule not found");
        }
        
        asset.schedules = newSchedules;
        assets[assetTag] = asset;
        return "Schedule deleted successfully";
    }

    // ==================== WORK ORDER MANAGEMENT ====================
    resource function post assets/[string assetTag]/work-orders(@http:Payload WorkOrder newWorkOrder) returns WorkOrder|error {
        if !assets.hasKey(assetTag) {
            return error("Asset not found");
        }
        
        Asset? asset = assets[assetTag];
        if asset is () {
            return error("Asset not found");
        }
        
        // Generate ID and set created date
        newWorkOrder.id = check uuid:create();
        time:Utc current = time:utcNow();
        newWorkOrder.createdDate = time:utcToString(current);
        
        asset.workOrders.push(newWorkOrder);
        assets[assetTag] = asset;
        return newWorkOrder;
    }

    resource function get assets/[string assetTag]/work-orders() returns WorkOrder[]|error {
        if !assets.hasKey(assetTag) {
            return error("Asset not found");
        }
        
        Asset? asset = assets[assetTag];
        if asset is () {
            return error("Asset not found");
        }
        
        return asset.workOrders;
    }

    resource function put assets/[string assetTag]/work-orders/[string workOrderId](@http:Payload WorkOrder updatedWorkOrder) returns WorkOrder|error {
        if !assets.hasKey(assetTag) {
            return error("Asset not found");
        }
        
        Asset? asset = assets[assetTag];
        if asset is () {
            return error("Asset not found");
        }
        
        WorkOrder[] newWorkOrders = [];
        boolean found = false;
        foreach var workOrder in asset.workOrders {
            if workOrder.id == workOrderId {
                updatedWorkOrder.id = workOrderId;
                updatedWorkOrder.createdDate = workOrder.createdDate;
                newWorkOrders.push(updatedWorkOrder);
                found = true;
            } else {
                newWorkOrders.push(workOrder);
            }
        }
        
        if !found {
            return error("Work order not found");
        }
        
        asset.workOrders = newWorkOrders;
        assets[assetTag] = asset;
        return updatedWorkOrder;
    }

    resource function delete assets/[string assetTag]/work-orders/[string workOrderId]() returns string|error {
        if !assets.hasKey(assetTag) {
            return error("Asset not found");
        }
        
        Asset? asset = assets[assetTag];
        if asset is () {
            return error("Asset not found");
        }
        
        WorkOrder[] newWorkOrders = [];
        boolean found = false;
        foreach var workOrder in asset.workOrders {
            if workOrder.id != workOrderId {
                newWorkOrders.push(workOrder);
            } else {
                found = true;
            }
        }
        
        if !found {
            return error("Work order not found");
        }
        
        asset.workOrders = newWorkOrders;
        assets[assetTag] = asset;
        return "Work order deleted successfully";
    }

    // ==================== TASK MANAGEMENT ====================
    resource function post assets/[string assetTag]/work-orders/[string workOrderId]/tasks(@http:Payload Task newTask) returns Task|error {
        if !assets.hasKey(assetTag) {
            return error("Asset not found");
        }
        
        Asset? asset = assets[assetTag];
        if asset is () {
            return error("Asset not found");
        }
        
        // Find the work order
        WorkOrder? targetWorkOrder = ();
        foreach var workOrder in asset.workOrders {
            if workOrder.id == workOrderId {
                targetWorkOrder = workOrder;
                break;
            }
        }
        
        if targetWorkOrder is () {
            return error("Work order not found");
        }
        
        // Generate task ID
        newTask.id = check uuid:create();
        targetWorkOrder.tasks.push(newTask);
        
        // Update the work order in the asset
        WorkOrder[] newWorkOrders = [];
        foreach var workOrder in asset.workOrders {
            if workOrder.id == workOrderId {
                newWorkOrders.push(targetWorkOrder);
            } else {
                newWorkOrders.push(workOrder);
            }
        }
        
        asset.workOrders = newWorkOrders;
        assets[assetTag] = asset;
        return newTask;
    }

    resource function get assets/[string assetTag]/work-orders/[string workOrderId]/tasks() returns Task[]|error {
        if !assets.hasKey(assetTag) {
            return error("Asset not found");
        }
        
        Asset? asset = assets[assetTag];
        if asset is () {
            return error("Asset not found");
        }
        
        foreach var workOrder in asset.workOrders {
            if workOrder.id == workOrderId {
                return workOrder.tasks;
            }
        }
        
        return error("Work order not found");
    }

    resource function put assets/[string assetTag]/work-orders/[string workOrderId]/tasks/[string taskId](@http:Payload Task updatedTask) returns Task|error {
        if !assets.hasKey(assetTag) {
            return error("Asset not found");
        }
        
        Asset? asset = assets[assetTag];
        if asset is () {
            return error("Asset not found");
        }
        
        WorkOrder[] newWorkOrders = [];
        foreach var workOrder in asset.workOrders {
            if workOrder.id == workOrderId {
                Task[] newTasks = [];
                boolean found = false;
                foreach var task in workOrder.tasks {
                    if task.id == taskId {
                        updatedTask.id = taskId;
                        newTasks.push(updatedTask);
                        found = true;
                    } else {
                        newTasks.push(task);
                    }
                }
                
                if !found {
                    return error("Task not found");
                }
                
                workOrder.tasks = newTasks;
                newWorkOrders.push(workOrder);
            } else {
                newWorkOrders.push(workOrder);
            }
        }
        
        asset.workOrders = newWorkOrders;
        assets[assetTag] = asset;
        return updatedTask;
    }

    resource function delete assets/[string assetTag]/work-orders/[string workOrderId]/tasks/[string taskId]() returns string|error {
        if !assets.hasKey(assetTag) {
            return error("Asset not found");
        }
        
        Asset? asset = assets[assetTag];
        if asset is () {
            return error("Asset not found");
        }
        
        WorkOrder[] newWorkOrders = [];
        foreach var workOrder in asset.workOrders {
            if workOrder.id == workOrderId {
                Task[] newTasks = [];
                boolean found = false;
                foreach var task in workOrder.tasks {
                    if task.id != taskId {
                        newTasks.push(task);
                    } else {
                        found = true;
                    }
                }
                
                if !found {
                    return error("Task not found");
                }
                
                workOrder.tasks = newTasks;
                newWorkOrders.push(workOrder);
            } else {
                newWorkOrders.push(workOrder);
            }
        }
        
        asset.workOrders = newWorkOrders;
        assets[assetTag] = asset;
        return "Task deleted successfully";
    }

    // ==================== OVERDUE MAINTENANCE ====================
    resource function get assets/overdue() returns Asset[]|error {
        Asset[] overdueAssets = [];
        time:Utc current = time:utcNow();
        string today = time:utcToString(current);
        
        foreach var [_, asset] in assets.entries() {
            boolean hasOverdue = false;
            foreach var schedule in asset.schedules {
                if schedule.status == "ACTIVE" && schedule.nextDue < today {
                    hasOverdue = true;
                    break;
                }
            }
            
            if hasOverdue {
                overdueAssets.push(asset);
            }
        }
        
        return overdueAssets;
    }

    // ==================== REFERENCE DATA ====================
    resource function get faculties() returns string[]|error {
        string[] faculties = ["Engineering", "Business", "Science", "Medicine", "Arts"];
        return faculties;
    }

    resource function get departments() returns string[]|error {
        string[] departments = ["Mechanical", "Electrical", "Computer Science", "Civil", "Finance", "Marketing", "Physics", "Chemistry", "Cardiology", "Surgery"];
        return departments;
    }

    resource function get asset_types() returns string[]|error {
        string[] assetTypes = ["Equipment", "Vehicle", "Server", "Furniture"];
        return assetTypes;
    }

    resource function get statuses() returns string[]|error {
        string[] statuses = ["ACTIVE", "UNDER_REPAIR", "DISPOSED"];
        return statuses;
    }
}
