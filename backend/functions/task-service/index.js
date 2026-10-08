const https = require('https');

const TABLE = process.env.DYNAMODB_TABLE;
const REGION = process.env.REGION;

const send = (code, body) => ({
  statusCode: code,
  headers: {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*"
  },
  body: JSON.stringify(body)
});

const callDynamo = (action, body) => {
  const post = JSON.stringify(body);
  const opts = {
    hostname: `dynamodb.${REGION}.amazonaws.com`,
    port: 443,
    path: '/',
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-amz-json-1.0',
      'X-Amz-Target': `DynamoDB_20120810.${action}`,
      'Content-Length': Buffer.byteLength(post)
    }
  };
  return new Promise((res, rej) => {
    const req = https.request(opts, (resp) => {
      let d = '';
      resp.on('data', c => d += c);
      resp.on('end', () => res(JSON.parse(d)));
    });
    req.on('error', rej);
    req.write(post);
    req.end();
  });
};

exports.handler = async (event) => {
  console.log("EVENT:", JSON.stringify(event, null, 2));
  
  const method = event.requestContext?.http?.method;
  const path = event.rawPath;
  
  console.log("REQ:", method, path);

  try {
    if (method === "GET" && path === "/api/tasks") {
      const data = await callDynamo("Scan", { TableName: TABLE });
      const tasks = (data.Items || []).map(i => ({
        id: i.id.S,
        title: i.title.S,
        createdAt: i.createdAt.S
      }));
      return send(200, { tasks });
    }

    if (method === "POST" && path === "/api/tasks") {
      const body = JSON.parse(event.body || "{}");
      if (!body.title) return send(400, { error: "Title required" });
      
      const id = Date.now().toString();
      const item = {
        id: { S: id },
        title: { S: body.title },
        createdAt: { S: new Date().toISOString() }
      };
      
      await callDynamo("PutItem", { TableName: TABLE, Item: item });
      return send(201, { id, title: body.title });
    }

    return send(404, { error: "Not Found", method, path });
  } catch (e) {
    console.error("ERROR:", e);
    return send(500, { error: e.message });
  }
};
