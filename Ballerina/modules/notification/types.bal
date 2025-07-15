// Notification module types

// Notification record representing a notification
public type Notification record {|
    int maintenance_id;
    int user_id;
    string name?;
    string description?;
    string priorityLevel?;
    string status?;
    string submitted_date?;
    string profilePicture?;
    string username?;
|};
