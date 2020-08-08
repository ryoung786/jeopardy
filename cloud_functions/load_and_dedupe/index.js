const { BigQuery } = require("@google-cloud/bigquery");
const { Storage } = require("@google-cloud/storage");

const bigquery = new BigQuery();
const storage = new Storage();

async function loadCSVFromGCS(event, table) {
  const datasetId = "prod";

  // https://cloud.google.com/bigquery/docs/reference/rest/v2/Job#JobConfigurationLoad
  const metadata = {
    sourceFormat: "CSV",
    skipLeadingRows: 1,
    allowQuotedNewlines: true,
    location: "US", // maybe don't need this
  };

  // Load data from a Google Cloud Storage file into the table
  const [job] = await bigquery
    .dataset(datasetId)
    .table(table)
    .load(storage.bucket(event.bucket).file(event.name), metadata);

  // load() waits for the job to finish
  console.log(`Job ${job.id} completed.  table: ${table}`);

  // Check the job's status for errors
  const errors = job.status.errors;
  if (errors && errors.length > 0) {
    throw errors;
  }
}

async function dedupe(table) {
  const dataset = "prod";

  const query = `DELETE ${dataset}.${table} a
    WHERE a.replicated_at < (
      SELECT MAX(replicated_at)
      FROM ${dataset}.${table} b
      WHERE a.id = b.id
    )`;

  // For all options, see https://cloud.google.com/bigquery/docs/reference/rest/v2/jobs/query
  const options = {
    query: query,
    location: "US",
  };

  // Run the query as a job
  const [job] = await bigquery.createQueryJob(options);
  console.log(`Dedupe query Job ${job.id} started.`);

  // Wait for the query to finish
  const [rows] = await job.getQueryResults();
}

/**
 * Triggered from a change to a Cloud Storage bucket.
 *
 * @param {!Object} event Event payload.
 * @param {!Object} context Metadata for the event.
 */
exports.helloGCS = (event, context) => {
  if (
    !(
      event.name.startsWith("incremental_games_") ||
      event.name.startsWith("incremental_players_") ||
      event.name.startsWith("incremental_clues_") ||
      event.name.startsWith("db_records_")
    )
  ) {
    console.log("don't care");
    return;
  }

  const table = event.name.startsWith("incremental_games_")
    ? "games"
    : event.name.startsWith("incremental_players_")
    ? "players"
    : event.name.startsWith("incremental_clues_")
    ? "clues"
    : "db_records";

  const skip_dedupe = ["db_records"];

  console.log(`Processing file: ${event.name} ;; bucket: ${event.bucket}`);

  loadCSVFromGCS(event, table)
    .then(() => {
      console.log(`Table uploaded: ${table}`);
      if (skip_dedupe.includes(table)) return;

      dedupe(table);
    })
    .then(() => {
      // delete our original gcs file
      storage.bucket(event.bucket).file(event.name).delete();

      if (!skip_dedupe.includes(table)) {
        console.log(`Table deduped: ${table}`);
      }
    })
    .then(() => {
      console.log(`deleted gcs file ${event.name}`);
    });
};
