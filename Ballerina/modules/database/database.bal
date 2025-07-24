import ballerina/http;
import ballerina/io;
import ballerinax/mysql;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

public final mysql:Client dbClient = check new (
    host = HOST,
    user = USER,
    password = PASSWORD,
    port = PORT,
    database = DATABASE
);

public listener http:Listener mainListener = new (9090);
public listener http:Listener reportListener = new (9091);
public listener http:Listener dashboardListener = new (9092);
public listener http:Listener notificationListener = new (9093);
public listener http:Listener authListener = new (9094);

public function connectDatabase() returns error? {
    io:println("Database connected successfully...");
}
