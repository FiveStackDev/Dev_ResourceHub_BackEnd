import ballerina/http;
import ballerina/email;
import ballerina/mime;

configurable string SMTP_HOST = ?;
configurable string SMTP_USER = ?;
configurable string SMTP_PASSWORD = ?;
configurable string PDFSHIFT_API_KEY = ?;

service /report on report {
    // Meal Reports
    resource function get generateWeeklyMeal() returns error? {
        check generateAndSendReport("/schedulereports/weeklymealevents", "Weekly Meal Events Report", "Weekly_Meal_Events_Report.pdf");
    }
    resource function get generateBiweeklyMeal() returns error? {
        check generateAndSendReport("/schedulereports/biweeklymealevents", "Biweekly Meal Events Report", "Biweekly_Meal_Events_Report.pdf");
    }
    resource function get generateMonthlyMeal() returns error? {
        check generateAndSendReport("/schedulereports/monthlymealevents", "Monthly Meal Events Report", "Monthly_Meal_Events_Report.pdf");
    }

    // Asset Reports
    resource function get generateWeeklyAsset() returns error? {
        check generateAndSendReport("/schedulereports/weeklyassetrequestdetails", "Weekly Assets Report", "Weekly_Assets_Report.pdf");
    }
    resource function get generateBiweeklyAsset() returns error? {
        check generateAndSendReport("/schedulereports/biweeklyassetrequestdetails", "Biweekly Assets Report", "Biweekly_Assets_Report.pdf");
    }
    resource function get generateMonthlyAsset() returns error? {
        check generateAndSendReport("/schedulereports/monthlyassetrequestdetails", "Monthly Assets Report", "Monthly_Assets_Report.pdf");
    }

    // Maintenance Reports
    resource function get generateWeeklyMaintenance() returns error? {
        check generateAndSendReport("/schedulereports/weeklymaintenancedetails", "Weekly Maintenances Report", "Weekly_Maintenances_Report.pdf");
    }
    resource function get generateBiweeklyMaintenance() returns error? {
        check generateAndSendReport("/schedulereports/biweeklymaintenancedetails", "Biweekly Maintenances Report", "Biweekly_Maintenances_Report.pdf");
    }
    resource function get generateMonthlyMaintenance() returns error? {
        check generateAndSendReport("/schedulereports/monthlymaintenancedetails", "Monthly Maintenances Report", "Monthly_Maintenances_Report.pdf");
    }
}

function generateAndSendReport(string endpoint, string reportTitle, string fileName) returns error? {

    http:Client dataClient = check new ("http://localhost:9091");
    http:Response dataResp = check dataClient->get(endpoint);
    json data = check dataResp.getJsonPayload();

    // Generate HTML content
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

    // Convert HTML to PDF using PDFShift API
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

    // Send email with PDF attachment
    mime:Entity pdfAttachment = new;
    pdfAttachment.setByteArray(pdfBytes, "application/pdf");
    pdfAttachment.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

    email:Message emailMessage = {
        to: ["kahandamc.22@uom.lk"],
        subject: reportTitle,
        body: "Please find the attached " + reportTitle + ".",
        attachments: [pdfAttachment]
    };

    check emailClient->sendMessage(emailMessage);

    http:Response response = new;
    response.setPayload("Report has been sent successfully");
}
