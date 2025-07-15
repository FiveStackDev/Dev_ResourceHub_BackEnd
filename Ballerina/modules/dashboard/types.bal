// Dashboard module types

// Meal time record for dashboard
public type MealTime record {|
    int mealtime_id;
    string mealtime_name;
    string? mealtime_image_url?;
|};

// Monthly user data for charts
public type MonthlyUserData record {|
    int month;
    int count;
|};

// Monthly meal data for charts
public type MonthlyMealData record {|
    int month;
    int count;
|};

// Monthly asset request data for charts
public type MonthlyAssetRequestData record {|
    int month;
    int count;
|};

// Monthly maintenance data for charts
public type MonthlyMaintenanceData record {|
    int month;
    int count;
|};

// Meal distribution data for charts
public type MealDistributionData record {|
    int day_of_week;
    string mealtime_name;
    int count;
|};

// Resource allocation data for charts
public type ResourceAllocationData record {|
    string category;
    decimal allocated;
    decimal total;
|};
