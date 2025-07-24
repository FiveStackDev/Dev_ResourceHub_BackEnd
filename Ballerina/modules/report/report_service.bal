import ResourceHub.common;
import ResourceHub.database;

import ballerina/email;
import ballerina/http;
import ballerina/io;
import ballerina/mime;
import ballerina/sql;

configurable string PDFSHIFT_API_KEY = ?;

service /report on database:reportListener {
    // Meal Reports
    resource function get generateWeeklyMeal() returns error? {
        check generateAndSendReport("/weeklymealdetails", "Weekly Meal Events Report", "Weekly_Meal_Events_Report.pdf", "meal", "weekly");
        io:println("Weekly Meal Report generated and sent successfully");
    }

    resource function get generateBiweeklyMeal() returns error? {
        check generateAndSendReport("/biweeklymealdetails", "Biweekly Meal Events Report", "Biweekly_Meal_Events_Report.pdf", "meal", "Bi-weekly");
        io:println("Biweekly Meal Report generated and sent successfully");
    }

    resource function get generateMonthlyMeal() returns error? {
        check generateAndSendReport("/monthlymealdetails", "Monthly Meal Events Report", "Monthly_Meal_Events_Report.pdf", "meal", "monthly");
        io:println("Monthly Meal Report generated and sent successfully");
    }

    // Asset Reports
    resource function get generateWeeklyAsset() returns error? {
        check generateAndSendReport("/weeklyassetrequestdetails", "Weekly Assets Report", "Weekly_Assets_Report.pdf", "asset", "weekly");
        io:println("Weekly Asset Report generated and sent successfully");
    }

    resource function get generateBiweeklyAsset() returns error? {
        check generateAndSendReport("/biweeklyassetrequestdetails", "Biweekly Assets Report", "Biweekly_Assets_Report.pdf", "asset", "Bi-weekly");
        io:println("Biweekly Asset Report generated and sent successfully");
    }

    resource function get generateMonthlyAsset() returns error? {
        check generateAndSendReport("/monthlyassetrequestdetails", "Monthly Assets Report", "Monthly_Assets_Report.pdf", "asset", "monthly");
        io:println("Monthly Asset Report generated and sent successfully");
    }

    // Maintenance Reports
    resource function get generateWeeklyMaintenance() returns error? {
        check generateAndSendReport("/weeklymaintenancedetails", "Weekly Maintenances Report", "Weekly_Maintenances_Report.pdf", "maintenance", "weekly");
        io:println("✅ Weekly Maintenance Report generated and sent successfully");
    }

    resource function get generateBiweeklyMaintenance() returns error? {
        check generateAndSendReport("/biweeklymaintenancedetails", "Biweekly Maintenances Report", "Biweekly_Maintenances_Report.pdf", "maintenance", "Bi-weekly");
        io:println("✅ Biweekly Maintenance Report generated and sent successfully");
    }

    resource function get generateMonthlyMaintenance() returns error? {
        check generateAndSendReport("/monthlymaintenancedetails", "Monthly Maintenances Report", "Monthly_Maintenances_Report.pdf", "maintenance", "monthly");
        io:println("✅ Monthly Maintenance Report generated and sent successfully");
    }
}

function generateAndSendReport(string endpoint, string reportTitle, string fileName, string reportName, string frequency) returns error? {

    // First, get all organizations that have scheduled reports for this type and frequency
    sql:ParameterizedQuery orgQuery = `SELECT DISTINCT s.org_id FROM schedulereports s WHERE s.report_name = ${reportName} AND s.frequency = ${frequency}`;
    stream<record {|int org_id;|}, error?> orgStream = database:dbClient->query(orgQuery);
    int[] orgIds = [];
    error? orgError = orgStream.forEach(function(record {|int org_id;|} row) {
        orgIds.push(row.org_id);
    });
    check orgError;
    check orgStream.close();

    // Generate reports for each organization
    foreach int orgId in orgIds {
        check generateAndSendReportForOrg(endpoint, reportTitle, fileName, reportName, frequency, orgId);
    }

    return;
}

function generateAndSendReportForOrg(string endpoint, string reportTitle, string fileName, string reportName, string frequency, int orgId) returns error? {

    // 1. Fetch data for the report for this specific organization

    // Use the actual report generation endpoint
    http:Client dataClient = check new ("https://e7f2b9c3-7f86-4a6b-91f9-2ae1c2e1c631-dev.e1-us-east-azure.choreoapis.dev/default/ballerina/schedulereports-4d0/v1.0");

    // Alternatively, if running locally, you can use:
    // http:Client dataClient = check new ("http://localhost:9091/schedulereports");

    http:Response dataResp = check dataClient->get(endpoint + "/" + orgId.toString());
    json data = check dataResp.getJsonPayload();

    // 2. Generate HTML content
    string htmlContent = "<!DOCTYPE html>\n<html>\n<head>\n" +
                        "<title>" + reportTitle + "</title>\n" +
                        "<style>table { border-collapse: collapse; width: 100%; }" +
                        "th, td { border: 1px solid black; padding: 8px; text-align: left; }" +
                        "th { background-color: #f2f2f2; }</style>\n" +
                        "</head>\n<body>\n<h1>" + reportTitle + "</h1>\n<table>\n";

    json[] events = <json[]>data;
    if events.length() == 0 {
        htmlContent += "<tr><td>No data found</td></tr>";
    } else {
        map<json> firstEvent = <map<json>>events[0];
        string[] headers = firstEvent.keys();

        htmlContent += "<tr>";
        foreach string header in headers {
            htmlContent += "<th>" + header + "</th>";
        }
        htmlContent += "</tr>";

        foreach json event in events {
            htmlContent += "<tr>";
            map<json> eventMap = <map<json>>event;
            foreach string key in headers {
                json|error value = eventMap.get(key);
                string cellValue = value is json ? value.toString() : "N/A";
                htmlContent += "<td>" + cellValue + "</td>";
            }
            htmlContent += "</tr>";
        }
    }

    htmlContent += "</table></body></html>";

    // 3. Convert HTML to PDF using PDFShift API
    http:Client pdfShiftClient = check new ("https://api.pdfshift.io");
    json pdfRequest = {
        "source": htmlContent,
        "landscape": false,
        "use_print": false
    };

    http:Response pdfResponse = check pdfShiftClient->post(
        "/v3/convert/pdf",
        pdfRequest,
        headers = <map<string>>{
        "Authorization": "Basic " + ("api:" + PDFSHIFT_API_KEY).toBytes().toBase64(),
        "Content-Type": "application/json"
    }
    );

    byte[] pdfBytes = check pdfResponse.getBinaryPayload();

    // 4. Fetch user emails from DB for this report type, frequency, and organization
    sql:ParameterizedQuery pq = `SELECT u.email FROM schedulereports s JOIN users u ON s.user_id = u.user_id WHERE s.report_name = ${reportName} AND s.frequency = ${frequency} AND s.org_id = ${orgId}`;
    stream<record {|string email;|}, error?> emailStream = database:dbClient->query(pq);
    string[] emailList = [];
    error? e = emailStream.forEach(function(record {|string email;|} row) {
        emailList.push(row.email);
    });
    check e;
    check emailStream.close();

    if emailList.length() == 0 {
        io:println("ℹ️ No users found for " + reportName + " " + frequency + " report in org: " + orgId.toString());
        return;
    }

    // 5. Send email with PDF attachment to all users in this organization
    mime:Entity pdfAttachment = new;
    pdfAttachment.setByteArray(pdfBytes, "application/pdf");
    pdfAttachment.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

    email:Message emailMessage = {
        to: emailList,
        subject: reportTitle,
        body: "Please find the attached " + reportTitle + ".",
        attachments: [pdfAttachment]
    };

    check common:emailClient->sendMessage(emailMessage);
    io:println("📧 Email sent successfully to " + emailList.length().toString() + " users for " + reportName + " " + frequency + " report in org: " + orgId.toString());

    return;
}

public function startReportService() returns error? {
    io:println("Report service started on port 9091");
}
