// Organizations module types

// Organization record representing an organization in the system
public type Organization record {|
    int org_id?;
    string org_name;
    string org_address?;
    string org_logo?;
    string org_email?;
|};

// Organization profile record
public type OrgProfile record {|
    string org_name;
    string? org_logo;
    string? org_address;
    string? org_email?;
|};


public type Register record {|
    string username;
    string org_name;
    string email;
    string password;
|};