// User module types

// User record representing a user in the system
public type User record {|
    int user_id?;
    string username;
    string profile_picture_url?;
    string usertype;
    string email;
    string phone_number?;
    string password?;
    string bio;
    string created_at?;
    int org_id?;
|};

// Profile data structure for user settings
public type Profile record {|
    string username;
    string profile_picture_url;
    string? bio = ();
    string? usertype = ();
    string? email = ();
    string? phone_number = ();
|};

// Structure to carry email and verification code
public type Email record {|
    string email;
    int? code = ();
|};

// Structure for phone number update
public type Phone record {|
    string phone_number;
|};

// Structure for password update request
public type Password record {|
    string current_password;
    string new_password;
|};
