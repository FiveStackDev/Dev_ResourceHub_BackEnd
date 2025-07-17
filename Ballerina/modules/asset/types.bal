// Asset record type representing an asset in the system
public type Asset record {|
    int asset_id?;
    string asset_name;
    string category;
    int quantity;
    string condition_type;
    string location;
    boolean is_available?;
    int org_id?;
|};

// AssetRequest record type representing an asset request
public type AssetRequest record {|
    int requestedasset_id?;
    int user_id;
    int asset_id;
    string category?;
    string submitted_date;
    string handover_date;
    int remaining_days?;
    int quantity;
    string profile_picture_url?;
    string username?;
    string status?;
    boolean is_returning?;
    string asset_name?;
    int org_id?;
|};
