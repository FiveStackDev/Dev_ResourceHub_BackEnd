import ballerina/io;
import ballerina/task;
import ballerina/http;

class WeeklyJob {
    *task:Job;
    public function execute() {
        do {
            http:Client reportClient = check new ("http://localhost:9091");
            
            // Generate meal report
            do {
                http:Response _ = check reportClient->get("/report/generateWeeklyMeal");
                io:println("✅ Weekly meal report job completed successfully");
            } on fail error e {
                io:println("Error generating weekly meal report: ", e.toString());
            }

            // Generate asset report
            do {
                http:Response _ = check reportClient->get("/report/generateWeeklyAsset");
                io:println("✅ Weekly asset report job completed successfully");
            } on fail error e {
                io:println("Error generating weekly asset report: ", e.toString());
            }

            // Generate maintenance report
            do {
                http:Response _ = check reportClient->get("/report/generateWeeklyMaintenance");
                io:println("✅ Weekly maintenance report job completed successfully");
            } on fail error e {
                io:println("Error generating weekly maintenance report: ", e.toString());
            }
            
            io:println("🎉 All weekly reports completed successfully!");
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
            
            // Generate meal report
            do {
                http:Response _ = check reportClient->get("/report/generateBiweeklyMeal");
                io:println("✅ Biweekly meal report job completed successfully");
            } on fail error e {
                io:println("Error generating biweekly meal report: ", e.toString());
            }

            // Generate asset report
            do {
                http:Response _ = check reportClient->get("/report/generateBiweeklyAsset");
                io:println("✅ Biweekly asset report job completed successfully");
            } on fail error e {
                io:println("Error generating biweekly asset report: ", e.toString());
            }

            // Generate maintenance report
            do {
                http:Response _ = check reportClient->get("/report/generateBiweeklyMaintenance");
                io:println("✅ Biweekly maintenance report job completed successfully");
            } on fail error e {
                io:println("Error generating biweekly maintenance report: ", e.toString());
            }
            
            io:println("🎉 All biweekly reports completed successfully!");
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
            
            // Generate meal report
            do {
                http:Response _ = check reportClient->get("/report/generateMonthlyMeal");
                io:println("✅ Monthly meal report job completed successfully");
            } on fail error e {
                io:println("Error generating monthly meal report: ", e.toString());
            }

            // Generate asset report
            do {
                http:Response _ = check reportClient->get("/report/generateMonthlyAsset");
                io:println("✅ Monthly asset report job completed successfully");
            } on fail error e {
                io:println("Error generating monthly asset report: ", e.toString());
            }

            // Generate maintenance report
            do {
                http:Response _ = check reportClient->get("/report/generateMonthlyMaintenance");
                io:println("✅ Monthly maintenance report job completed successfully");
            } on fail error e {
                io:println("Error generating monthly maintenance report: ", e.toString());
            }
            
            io:println("🎉 All monthly reports completed successfully!");
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