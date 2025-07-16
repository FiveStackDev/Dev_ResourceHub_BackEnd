// Authentication module types

// Credentials record for login
public type Credentials record {|
    string email;
    string password;
|};

// User authentication data record
public type UserAuthData record {|
    string username;
    int user_id;
    string email;
    string password;
    string usertype;
    string profile_picture_url;
    int org_id;
    string? org_logo;
|};

// Forgot password request record
public type ForgotPassword record {|
    string email;
|};
