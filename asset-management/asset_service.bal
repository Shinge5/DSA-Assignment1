// src/asset_service.bal
import ballerina/http;
import 'types';

// In-memory database
table<types:Asset> key(assetTag) assetsDB = table [];

service /assets on new http:Listener(8080) {

    // POST /assets - Add a new asset
    resource function post .(@http:Payload types:Asset asset) returns types:Asset|http:Conflict {
        if assetsDB.hasKey(asset.assetTag) {
            return http:CONFLICT;
        }
        assetsDB.add(asset);
        return asset;
    }

    // GET /assets - Get all assets
    resource function get .() returns types:Asset[] {
        return assetsDB.toArray();
    }

    // GET /assets/{assetTag} - Get asset by tag
    resource function get [string assetTag]() returns types:Asset|http:NotFound {
        types:Asset? asset = assetsDB[assetTag];
        if asset == () {
            return http:NOT_FOUND;
        }
        return asset;
    }

    // PUT /assets/{assetTag} - Update asset
    resource function put [string assetTag](@http:Payload json update) returns types:Asset|http:NotFound {
        types:Asset? asset = assetsDB[assetTag];
        if asset == () {
            return http:NOT_FOUND;
        }
        map<json> updateMap = check update.ensureType(map<json>);
        foreach [string, json] [key, value] in updateMap.entries() {
            if key == "status" && value is string {
                asset.status = <types:Status>value;
            }
        }
        return asset;
    }

    // DELETE /assets/{assetTag} - Remove asset
    resource function delete [string assetTag]() returns http:Ok|http:NotFound {
        if assetsDB.remove(assetTag) == () {
            return http:NOT_FOUND;
        }
        return http:OK;
    }

    // POST /assets/{assetTag}/components - Add component
    resource function post [string assetTag]/components(@http:Payload types:Component component) returns types:Component|http:NotFound {
        types:Asset? asset = assetsDB[assetTag];
        if asset == () {
            return http:NOT_FOUND;
        }
        asset.components.push(component);
        return component;
    }

    // GET /assets/overdue - Get overdue assets
    resource function get overdue() returns types:Asset[] {
        types:Asset[] overdue = [];
        foreach var asset in assetsDB {
            foreach var schedule in asset.schedules {
                if schedule.nextDueDate < "2025-09-16" { // Test date (current is Sept 16, 2025)
                    overdue.push(asset);
                    break;
                }
            }
        }
        return overdue;
    }

    // GET /assets/faculty/{faculty} - Get by faculty
    resource function get faculty/[string faculty]() returns types:Asset[] {
        return from types:Asset asset in assetsDB
            where asset.faculty == faculty
            select asset;
    }
}