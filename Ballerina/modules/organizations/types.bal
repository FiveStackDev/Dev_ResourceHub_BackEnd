// Organizations module types

// Organization profile record
public type OrgProfile record {|
    string org_name;
    string org_logo;
    string? org_address = ();
    string? org_email = ();
|};

// User profile record

public type Register record {|
    string username;
    string org_name;
    string email;
    string password;
|};