// Organizations module types

// Organization record representing an organization in the system
public type Organization record {|
    int org_id?;
    string org_name;
    string org_address?;
    string org_logo?;
    string org_email?;
    string org_about?;
    string org_website?;
    string org_phone?;
    string org_founded?;
    string created_at?;
    string updated_at?;
|};

// Organization profile record
public type OrgProfile record {|
    string org_name;
    string? org_logo;
    string? org_address;
    string org_email?;
    string? org_about;
    string? org_website;
    string? org_phone;
    string? org_founded;
|};

public type Register record {|
    string username;
    string org_name;
    string email;
    string password;
    string? org_about;
    string? org_website;
    string? org_phone;
    string? org_founded;
|};
