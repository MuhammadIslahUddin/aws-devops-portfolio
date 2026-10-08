const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, ScanCommand, PutCommand } = require("@aws-sdk/lib-dynamodb");

const TABLE = process.env.DYNAMODB_TABLE;
const REGION = process.env.REGION;

const db = new DynamoDBClient({ region: REGION });
const doc = DynamoDBDocumentClient.from(db);

exports.handler = async (event) => {
  console.log("🔷 Full Event:", JSON.stringify(event, null, 2));
  
  const method = event.requestContext?.http?.method;
  const path = event.rawPath || event.path;

  console.log(`📥 ${method} ${path}`);

  try {
    // GET all tasks
    if (method === "GET" && path === "/api/tasks") {
      const result = await doc.send(new ScanCommand({ TableName: TABLE }));
      return {
        statusCode: 200,
        headers: { 
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*"
        },
        body: JSON.stringify({ tasks: result.Items || [] })
      };
    }

    // POST new task
    if (method === "POST" && path === "/api/tasks") {
      const body = JSON.parse(event.body);
      const task = {
        id: Date.now().toString(),
        title: body.title,
        createdAt: new Date().toISOString()
      };
      await doc.send(new PutCommand({ TableName: TABLE, Item: task }));
      return {
        statusCode: 201,
        headers: { 
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*"
        },
        body: JSON.stringify(task)
      };
    }

    console.log("❌ Route not matched");
    return {
      statusCode: 404,
      body: JSON.stringify({ message: "Not Found", method, path })
    };

  } catch (err) {
    console.error("💥 Error:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: err.message })
    };
  }
};
