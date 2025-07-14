import ballerina/email;

final email:SmtpClient emailClient = check new (
    host = SMTP_HOST,
    username = SMTP_USER,
    password = SMTP_PASSWORD,
    security = email:SSL
);
