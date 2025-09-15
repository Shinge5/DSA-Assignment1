// src/types.bal
import ballerina/time;

public type Status "ACTIVE" | "UNDER_REPAIR" | "DISPOSED";

public type Component record {|
    string componentId;
    string name;
    string description;
|};

public type Schedule record {|
    string scheduleId;
    string type;  // e.g., "quarterly", "yearly"
    string nextDueDate;  // Format: "yyyy-MM-dd"
|};

public type Task record {|
    string taskId;
    string description;
|};

public type WorkOrder record {|
    string orderId;
    string description;
    string status;  // e.g., "OPEN", "CLOSED"
    Task[] tasks = [];
|};

public type Asset record {|
    string assetTag;  // Unique key
    string name;
    string faculty;
    string department;
    Status status;
    string acquiredDate;  // Format: "yyyy-MM-dd"
    Component[] components = [];
    Schedule[] schedules = [];
    WorkOrder[] workOrders = [];
|};