const { BigQuery } = require("@google-cloud/bigquery");
const { Storage } = require("@google-cloud/storage");

const bigquery = new BigQuery();

async function insert(user) {
  const dataset = "prod";
  const query = `INSERT ${dataset}.deploys (created_at, user)
    VALUES (current_timestamp(), '${user}')`;

  // For all options, see https://cloud.google.com/bigquery/docs/reference/rest/v2/jobs/query
  const options = {
    query: query,
    location: "US",
  };

  // Run the query as a job
  const [job] = await bigquery.createQueryJob(options);
  console.log("inserted " + user);

  // Wait for the query to finish
  const [rows] = await job.getQueryResults();
}

/**
 * Triggered from a message on a Cloud Pub/Sub topic.
 *
 * @param {!Object} event Event payload.
 * @param {!Object} context Metadata for the event.
 */
exports.helloPubSub = (event, context) => {
  const message = event.data
    ? Buffer.from(event.data, "base64").toString()
    : "Hello, World";
  console.log(message);

  insert(message);
};
