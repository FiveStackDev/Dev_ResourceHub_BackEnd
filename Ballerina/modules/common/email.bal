import ballerina/email;

configurable string SMTP_HOST = ?;
configurable string SMTP_USER = ?;
configurable string SMTP_PASSWORD = ?;

public final email:SmtpClient emailClient = check new (
    host = SMTP_HOST,
    username = SMTP_USER,
    password = SMTP_PASSWORD,
    port = 465,
    security = email:SSL
);
