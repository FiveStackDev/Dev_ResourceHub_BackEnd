import ballerina/http;
import ballerina/io;
import ballerina/task;

class WeeklyJob {
    *task:Job;

    public function execute() {
        do {
            http:Client reportClient = check new ("http://localhost:9091");
            http:Response mealResp = check reportClient->get("/report/generateWeeklyMeal");
            io:println("Weekly Meal report response: ", check mealResp.getTextPayload());

            http:Response assetResp = check reportClient->get("/report/generateWeeklyAsset");
            io:println("Weekly Asset report response: ", check assetResp.getTextPayload());

            http:Response maintResp = check reportClient->get("/report/generateWeeklyMaintenance");
            io:println("Weekly Maintenance report response: ", check maintResp.getTextPayload());
        } on fail error e {
            io:println("Error occurred while calling weekly report endpoints: ", e.toString());
        }
    }
}

// Biweekly job: calls biweekly endpoints
class BiweeklyJob {
    *task:Job;

    public function execute() {
        do {
            http:Client reportClient = check new ("http://localhost:9091");
            http:Response mealResp = check reportClient->get("/report/generateBiweeklyMeal");
            io:println("Biweekly Meal report response: ", check mealResp.getTextPayload());

            http:Response assetResp = check reportClient->get("/report/generateBiweeklyAsset");
            io:println("Biweekly Asset report response: ", check assetResp.getTextPayload());

            http:Response maintResp = check reportClient->get("/report/generateBiweeklyMaintenance");
            io:println("Biweekly Maintenance report response: ", check maintResp.getTextPayload());
        } on fail error e {
            io:println("Error occurred while calling biweekly report endpoints: ", e.toString());
        }
    }
}

// Monthly job: calls monthly endpoints
class MonthlyJob {
    *task:Job;

    public function execute() {
        do {
            http:Client reportClient = check new ("http://localhost:9091");
            http:Response mealResp = check reportClient->get("/report/generateMonthlyMeal");
            io:println("Monthly Meal report response: ", check mealResp.getTextPayload());

            http:Response assetResp = check reportClient->get("/report/generateMonthlyAsset");
            io:println("Monthly Asset report response: ", check assetResp.getTextPayload());

            http:Response maintResp = check reportClient->get("/report/generateMonthlyMaintenance");
            io:println("Monthly Maintenance report response: ", check maintResp.getTextPayload());
        } on fail error e {
            io:println("Error occurred while calling monthly report endpoints: ", e.toString());
        }
    }
}

public function scheduled() returns error? {
    // Schedule weekly job: every 7 days (604800 seconds)
    task:JobId _ = check task:scheduleJobRecurByFrequency(new WeeklyJob(), 604800);
    io:println("Scheduled weekly report job (every 7 days).");

    // Schedule biweekly job: every 14 days (1209600 seconds)
    task:JobId _ = check task:scheduleJobRecurByFrequency(new BiweeklyJob(), 1209600);
    io:println("Scheduled biweekly report job (every 14 days).");

    // Schedule monthly job: every 30 days (2592000 seconds)
    task:JobId _ = check task:scheduleJobRecurByFrequency(new MonthlyJob(), 2592000);
    io:println("Scheduled monthly report job (every 30 days).");
}
