// Report module types

// Schedule report record for automated report generation
public type ScheduleReport record {|
    int user_id;
    string report_name;
    string frequency;
    int org_id?;
|};
