// Notification module types

// Notification record representing a notification
public type Notification record {|
    int notification_id?;
    int user_id?;
    string 'type;                    // 'maintenance', 'asset_request', 'due_reminder', etc.
    int reference_id?;               // e.g., maintenance_id or requestedasset_id
    string title?;                   // optional title
    string message;                  // full message to display
    boolean is_read?;               // unread tracker
    string created_at?;             // timestamp
    int org_id;
    string username?;
    string profile_picture_url?;
    string priority?;
|};

// Input type for creating notifications
public type NotificationInput record {|
    int user_id?;
    string 'type;
    int reference_id?;
    string title?;
    string message;
    string priority = "General";
|};
