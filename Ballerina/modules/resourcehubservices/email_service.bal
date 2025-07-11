import ballerina/http;
import ballerina/io;
import ballerina/email;
import ballerina/mime;



configurable string SMTP_HOST = ?;
configurable string SMTP_USER = ?;
configurable string SMTP_PASSWORD = ?;
configurable string PDFSHIFT_API_KEY = ?;

service /report on ln {
    resource function get generate(http:Caller caller) returns error? {
        // Fetch data
        http:Client bookClient = check new ("http://localhost:9090");
        json bookData = check bookClient->get("/calendar/mealevents");

        // Generate HTML content
        string htmlContent = "<!DOCTYPE html>\n<html>\n<head>\n" +
                           "<title>Meal Events Report</title>\n" +
                           "<style>table { border-collapse: collapse; width: 100%; }" +
                           "th, td { border: 1px solid black; padding: 8px; text-align: left; }" +
                           "th { background-color: #f2f2f2; }</style>\n" +
                           "</head>\n<body>\n<h1>Report</h1>\n<table>\n";

        json[] events = <json[]>bookData;
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

        // Step 1: Convert HTML to PDF using PDFShift API
        http:Client pdfShiftClient = check new ("https://api.pdfshift.io");
        json pdfRequest = {
            "source": htmlContent,
            "landscape": false,
            "use_print": false
        };

        http:Response pdfResponse = check pdfShiftClient->post(
            "/v3/convert/pdf",
            pdfRequest,
            headers = {
                "Authorization": "Basic " + ("api:" + PDFSHIFT_API_KEY).toBytes().toBase64(), 
                "Content-Type": "application/json"
            }
        );

        byte[] pdfBytes = check pdfResponse.getBinaryPayload();

        // Step 2: Send email with PDF attachment

        mime:Entity pdfAttachment = new;
        pdfAttachment.setByteArray(pdfBytes, "application/pdf");
        pdfAttachment.setHeader("Content-Disposition", "attachment; filename=\"Meal_Events_Report.pdf\"");

        email:Message emailMessage = {
            to: ["kahandamc.22@uom.lk"],
            subject: "Meal Events Report",
            body: "Please find the attached Meal Events Report.",
            attachments: [pdfAttachment]
        };

        check emailClient->sendMessage(emailMessage);

        http:Response response = new;
        response.setPayload("Report has been sented sucessfully" );
        check caller->respond(response);
    }
}

public function emailservice() {
    io:println("Report service started at http://localhost:9090/report/generate");
}