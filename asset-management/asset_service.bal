// src/asset_service.bal
import ballerina/http;
import ballerina/time;
import ballerina/io;
import 'types';  // Import your types

table<types:Asset> key(assetTag) assetsDB = table [];

service /assets on new http:Listener(8080) {

    // Create new asset (POST /assets)
    resource function post .(http:Request req) returns http:Response|error {
        json payload = check req.getJsonPayload();
        types:Asset newAsset = check payload.cloneWithType(types:Asset);
        
        // Check if tag exists
        if assetsDB.hasKey(newAsset.assetTag) {
            return prepareErrorResponse("Asset with tag " + newAsset.assetTag + " already exists", 409);
        }
        
        assetsDB.add(newAsset);
        json responsePayload = check newAsset.cloneWithType(json);
        http:Response res = new;
        res.statusCode = 201;
        res.setJsonPayload(responsePayload);
        return res;
    }

    // Get all assets (GET /assets)
    resource function get .() returns json|error {
        types:Asset[] assets = [];
        foreach var asset in assetsDB {
            assets.push(asset);
        }
        return assets.cloneWithType(json);
    }

    // Get asset by tag (GET /assets/{assetTag})
    resource function get [string assetTag]() returns json|error {
        types:Asset? asset = assetsDB.get(assetTag);
        if asset == () {
            return prepareErrorResponse("Asset not found: " + assetTag, 404);
        }
        return asset.cloneWithType(json);
    }

    // Update asset (PUT /assets/{assetTag})
    resource function put [string assetTag](http:Request req) returns http:Response|error {
        json payload = check req.getJsonPayload();
        types:Asset updateData = check payload.cloneWithType(types:Asset);
        
        types:Asset? existing = assetsDB.get(assetTag);
        if existing == () {
            return prepareErrorResponse("Asset not found: " + assetTag, 404);
        }
        
        // Merge updates (simple overwrite for simplicity)
        existing.name = updateData.name ?: existing.name;
        existing.faculty = updateData.faculty ?: existing.faculty;
        existing.department = updateData.department ?: existing.department;
        existing.status = updateData.status ?: existing.status;
        existing.acquiredDate = updateData.acquiredDate ?: existing.acquiredDate;
        existing.components = updateData.components ?: existing.components;
        existing.schedules = updateData.schedules ?: existing.schedules;
        existing.workOrders = updateData.workOrders ?: existing.workOrders;
        
        assetsDB.put(existing);
        json responsePayload = check existing.cloneWithType(json);
        http:Response res = new;
        res.setJsonPayload(responsePayload);
        return res;
    }

    // Delete asset (DELETE /assets/{assetTag})
    resource function delete [string assetTag]() returns http:Response|error {
        if !assetsDB.hasKey(assetTag) {
            return prepareErrorResponse("Asset not found: " + assetTag, 404);
        }
        assetsDB.remove(assetTag);
        http:Response res = new;
        res.statusCode = 204;
        return res;
    }

    // Get assets by faculty (GET /assets/faculty/{faculty})
    resource function get faculty/[string facultyName]() returns json|error {
        types:Asset[] filtered = [];
        foreach var asset in assetsDB {
            if asset.faculty == facultyName {
                filtered.push(asset);
            }
        }
        return filtered.cloneWithType(json);
    }

    // Get overdue assets (GET /assets/overdue)
    resource function get overdue() returns json|error {
        types:Asset[] overdueAssets = [];
        time:Civil current = time:toCivil(time:now());
        string today = string `20%02d-%02d-%02d`(current.year, current.month, current.day);
        
        foreach var asset in assetsDB {
            boolean hasOverdue = false;
            foreach var schedule in asset.schedules {
                time:Civil due = check time:toCivil(check time:parse(schedule.nextDueDate, "yyyy-MM-dd"));
                string dueStr = string `20%02d-%02d-%02d`(due.year, due.month, due.day);
                if dueStr < today {
                    hasOverdue = true;
                    break;
                }
            }
            if hasOverdue {
                overdueAssets.push(asset);
            }
        }
        return overdueAssets.cloneWithType(json);
    }

    // Add component (POST /assets/{assetTag}/components)
    resource function post [string assetTag]/components(http:Request req) returns http:Response|error {
        return addOrRemoveNested("components", assetTag, req, true);
    }

    // Remove component (DELETE /assets/{assetTag}/components/{compId})
    resource function delete [string assetTag]/components/[string compId]() returns http:Response|error {
        return addOrRemoveNested("components", assetTag, (), false, compId);
    }

    // Add schedule (POST /assets/{assetTag}/schedules)
    resource function post [string assetTag]/schedules(http:Request req) returns http:Response|error {
        return addOrRemoveNested("schedules", assetTag, req, true);
    }

    // Remove schedule (DELETE /assets/{assetTag}/schedules/{schedId})
    resource function delete [string assetTag]/schedules/[string schedId]() returns http:Response|error {
        return addOrRemoveNested("schedules", assetTag, (), false, schedId);
    }
}

// Helper to add/remove nested items (components/schedules)
function addOrRemoveNested(string field, string assetTag, http:Request? req, boolean isAdd, string? id = ()) returns http:Response|error {
    types:Asset? asset = assetsDB.get(assetTag);
    if asset == () {
        return prepareErrorResponse("Asset not found: " + assetTag, 404);
    }

    if isAdd {
        json payload = check req.getJsonPayload();
        if field == "components" {
            types:Component comp = check payload.cloneWithType(types:Component);
            asset.components.push(comp);
        } else {
            types:Schedule sched = check payload.cloneWithType(types:Schedule);
            asset.schedules.push(sched);
        }
    } else {
        // Remove by ID
        if field == "components" {
            int index = -1;
            int i = 0;
            foreach var comp in asset.components {
                if comp.componentId == id {
                    index = i;
                    break;
                }
                i += 1;
            }
            if index >= 0 {
                asset.components.splice(index, 1);
            } else {
                return prepareErrorResponse("Component not found: " + <string>id, 404);
            }
        } else {
            // Similar for schedules...
            int index = -1;
            int i = 0;
            foreach var sched in asset.schedules {
                if sched.scheduleId == <string>id {
                    index = i;
                    break;
                }
                i += 1;
            }
            if index >= 0 {
                asset.schedules.splice(index, 1);
            } else {
                return prepareErrorResponse("Schedule not found: " + <string>id, 404);
            }
        }
    }

    assetsDB.put(asset);
    json responsePayload = check asset.cloneWithType(json);
    http:Response res = new;
    res.setJsonPayload(responsePayload);
    return res;
}

// Helper for error responses
function prepareErrorResponse(string message, int statusCode) returns http:Response {
    json errorPayload = { "error": message };
    http:Response res = new;
    res.statusCode = statusCode;
    res.setJsonPayload(errorPayload);
    return res;
}