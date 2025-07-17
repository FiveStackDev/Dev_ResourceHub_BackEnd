// Maintenance module types

// Maintenance record representing a maintenance request
public type Maintenance record {|
    int maintenance_id?;
    int user_id;
    string? name;
    string description;
    string priorityLevel;
    string status?;
    string submitted_date?;
    string profilePicture?;
    string username?;
    int org_id?;
|};
