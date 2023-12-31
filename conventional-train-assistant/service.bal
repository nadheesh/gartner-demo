import ballerina/http;
import ballerinax/googleapis.gmail;

configurable string gmailToken = ?;
configurable string openaiToken = ?;

string TRAIN_API_URL = "http://34.125.67.16:8080/train-operations/v1";

type TrainInfoRequest record {|
    # The email address of the recipient. E.g. "john@gmail".
    string recipientEmail;
    # The departure station. E.g London
    string 'from?;
    # The arrival station.
    string to?;
|};

type TrainInfoResponse record {|
    string entryId;
    string startTime;
    string endTime;
    string 'from;
    string to;
    string trainType;
|};

final http:Client trainApi = check new ("https://disease.sh");
final gmail:Client gmailApi = check new ({auth: {token: gmailToken}});

# A service representing a network-accessible API
# bound to port `9090`.
isolated service / on new http:Listener(9090) {

    resource function post sendTrainSchedule(@http:Payload TrainInfoRequest payload) returns string|error {
        string 'from = payload.'from is () ? "" : payload.'from.toString();
        string to = payload.to is () ? "" : payload.to.toString();

        TrainInfoResponse[] trainInfo = check trainApi->get("/schedules?from=" + 'from + "&to=" + to);

        if trainInfo.length() == 0 {
            return string `No train schedules found for the journey from ${'from} to ${to}`;
        }
        
        record {|string subject; string messageBody;|} emailRecord = {
            subject: "Train Schedules",
            messageBody: generateMail(trainInfo)
        };

        _ = check gmailApi->sendMessage({
            recipient: payload.recipientEmail,
            subject: emailRecord.subject,
            messageBody: emailRecord.messageBody,
            contentType: gmail:TEXT_PLAIN
        }, userId = "me");

        return string `Successfully sent the train schedules to the ${payload.recipientEmail} with the email:${"\n"}${emailRecord.toString()}"`;
    }
}

isolated function generateMail(TrainInfoResponse[] trainInfo) returns string {
    return string `Hi,
Here are the train schedules for your journey.

${<string>from TrainInfoResponse trainSchedule in trainInfo
        select string `- Train ${trainSchedule.trainType} from ${trainSchedule.'from} to ${trainSchedule.to} will start at ${trainSchedule.startTime} and will end at ${trainSchedule.endTime}.${"\n"}`}

Please let me know if you need any further assistance.`;
}
