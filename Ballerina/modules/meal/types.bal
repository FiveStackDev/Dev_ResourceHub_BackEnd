// Meal module types

// Meal type record representing different meal types
public type MealType record {|
    int mealtype_id?;
    string mealtype_name;
    string mealtype_image_url;
    int org_id?;
    int[] mealtime_ids?;
|};

// Meal time record representing different meal times
public type MealTime record {|
    int mealtime_id?;
    string mealtime_name;
    string mealtime_image_url;
    int org_id?;
    int[] mealtype_ids?;
|};

// Meal event record representing meal calendar events
public type MealEvent record {|
    int requestedmeal_id?;
    int mealtime_id;
    int mealtype_id;
    string mealtype_name?;
    string mealtime_name?;
    string username?;
    int user_id;
    string submitted_date;
    string meal_request_date;
    int org_id?;
|};
