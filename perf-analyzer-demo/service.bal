// import ballerina/http;
// import ballerina/log;
// import ballerinax/googleapis.gmail;
// import ballerinax/googleapis.sheets;
// import ballerinax/twilio;

// configurable string gmailToken = ?;

// // string TRAIN_API_URL = "http://34.125.67.16:8080/train-operations/v1";
// string TRAIN_API_URL = "http://api.worldbank.org/v2";

// type TrainInfoRequest record {|
//     string recipientEmail;
//     string 'from?;
//     string to?;
// |};

// type TrainInfoResponse record {|
//     string entryId;
//     string startTime;
//     string endTime;
//     string 'from;
//     string to;
//     string trainType;
// |};

// final http:Client trainApi = check new ("http://api.worldbank.org/v2");
// final gmail:Client gmailApi = check new ({auth: {token: gmailToken}});
// // final twilio:Client smsApi = check new ({twilioAuth: {accountSId: "", authToken: ""}, senderNumber: "+94771234567"});

// # A service representing a network-accessible API
// # bound to port `9090`.
// isolated service / on new http:Listener(9090) {

//     resource function post sendTrainSchedule(@http:Payload TrainInfoRequest payload) returns string|error {

//         string 'from = payload.'from is () ? "" : payload.'from.toString();
//         string to = payload.to is () ? "" : payload.to.toString();

//         TrainInfoResponse[] trainInfo = check trainApi->get("/schedules");

//     //    twilio:SmsResponse smsResponse = check smsApi->sendSms(fromNo = "+94771234567", toNo = "+94771234567", message = "Hello World");

//         // TrainInfoResponse[] trainInfo = check trainApi->/schedules(params = {"from": 'from, "to": to});

//         // string subject = string `Train Schedules${payload.'from is () ? "" :" from " + payload.'from.toString()}${payload.to is () ? "" : " to " + payload.to.toString()}`;

//         // string messageBody = "Hi,\n\nPlease find the train schedules below.\n\n";
//         // foreach var trainSchedule in trainInfo {
//         //     messageBody = messageBody + string `- Train ${trainSchedule.trainType} from ${trainSchedule.'from} to ${trainSchedule.to} will start at ${trainSchedule.startTime} and will end at ${trainSchedule.endTime}.${"\n"}`;
//         // }
//         gmail:MessageRequest messageRequest = {
//             recipient: payload.recipientEmail,
//             subject: "",
//             messageBody: "",
//             contentType: gmail:TEXT_PLAIN
//         };

//         // _ = check gmailApi->sendMessage(messageRequest);

//         log:printInfo(string `Successfully sent the train schedules to the ${payload.recipientEmail} with the subject "${subject}" and the message:${"\n"}"${messageBody}"`);
//         // return string`Successfully sent the train schedules to the ${payload.recipientEmail} with the subject "${subject}"" and the message:${"\n"}"${messageBody}"`;
//     }
// }
