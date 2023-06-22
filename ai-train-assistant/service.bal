import ballerina/http;
import ballerinax/openai.text;
import ballerinax/googleapis.gmail;

configurable string gmailToken = ?;
configurable string openaiToken = ?;

string TRAIN_API_URL = "http://34.125.67.16:8080/train-operations/v1";

type TrainInfoRequest record {|
    # The email address of the recipient.
    string recipientEmail;
    # The question to answer regarding the train schedules. e.g. "What are the traings leaving from London in the morning?"
    string query;
    # The departure station.
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

final http:Client trainApi = check new (TRAIN_API_URL);
final gmail:Client gmailApi = check new ({auth: {token: gmailToken}});
final text:Client openaiTextApi = check new ({auth: {token: openaiToken}});

# A service representing a network-accessible API
# bound to port `9090`.
isolated service / on new http:Listener(9090) {

    resource function post sendTrainSchedule(@http:Payload TrainInfoRequest payload) returns string|error {
        string 'from = payload.'from is () ? "" : payload.'from.toString();
        string to = payload.to is () ? "" : payload.to.toString();

        TrainInfoResponse[] trainInfo = check trainApi->/schedules(params = {"from": 'from, "to": to});

        // ------- Generative AI to generate the email with requested information -------
        text:CreateCompletionResponse generatedMail = check openaiTextApi->/completions.post({
            model: "text-davinci-003",
            prompt: generatePrompt(payload.query, trainInfo),
            max_tokens: 256
        });

        string? email = generatedMail.choices[0].text;
        if email is () {
            return "Failed to generate the email";
        }

        // --------------------------------------------------------------------------------

        record {|string subject; string messageBody;|} emailRecord = check email.fromJsonStringWithType();

        _ = check gmailApi->sendMessage({
            recipient: payload.recipientEmail,
            subject: emailRecord.subject,
            messageBody: emailRecord.messageBody,
            contentType: gmail:TEXT_PLAIN
        });

        return string `Successfully sent the train schedules to the ${payload.recipientEmail} with the email:${"\n"}${emailRecord.toString()}"`;
    }
}

isolated function generatePrompt(string question, TrainInfoResponse[] trainInfo) returns string {
    return string `Generate an email with the following format to answer the given question. Use the following train schedules to answer the question.

${trainInfo.toString()}

Always reply with an JSON object with the following format:
{
    "subject": "Subject of the email",
    "messageBody": "Body of the email with the requested information. Start with Hi {name}, and ends with "If you have any further questions or need additional assistance, please feel free to let us know"."
}

Question: ${question}
JSON email object:`;
}
