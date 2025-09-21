// src/types.bal
public type Status "ACTIVE" | "UNDER_REPAIR" | "DISPOSED";

public type Component record {|
    string componentId;
    string name;
    string description;
|};

public type Schedule record {|
    string scheduleId;
    string scheduleType;  //e.g, " quarterly", "yearly"
    string nextDueDate;
|};

public type Task record {|
    string taskId;
    string description;
|};

public type WorkOrder record {|
    string orderId;
    string description;
    string status;
    Task[] tasks = [];
|};

public type Asset record {|
    string assetTag;
    string name;
    string faculty;
    string department;
    Status status;
    string acquiredDate;
    Component[] components = [];
    Schedule[] schedules = [];
    WorkOrder[] workOrders = [];
|};
