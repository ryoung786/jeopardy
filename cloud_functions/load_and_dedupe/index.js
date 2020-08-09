const { BigQuery } = require("@google-cloud/bigquery");
const { Storage } = require("@google-cloud/storage");
const path = require("path");
const os = require("os");
const fs = require("fs");

const bigquery = new BigQuery();
const storage = new Storage();

async function did_num_records_change(event) {
  const old_num_records = await count_records();
  const new_num_records = await get_records_from_gcs_file(event);

  console.log("num_records from BQ", old_num_records);
  console.log("num_records from file", new_num_records);

  return old_num_records != new_num_records;
}

async function count_records() {
  const dataset = "prod";
  const table = "db_records";

  const query = `SELECT num_records
    FROM ${dataset}.${table}
    ORDER BY replicated_at DESC
    LIMIT 1`;

  // For all options, see https://cloud.google.com/bigquery/docs/reference/rest/v2/jobs/query
  const options = { query: query, location: "US" };
  const [job] = await bigquery.createQueryJob(options);
  const [rows] = await job.getQueryResults();
  return rows[0].num_records;
}

async function get_records_from_gcs_file(event) {
  const tempFilePath = path.join(os.tmpdir(), "abc");
  console.log("tempFilePath", tempFilePath);
  await storage
    .bucket(event.bucket)
    .file(event.name)
    .download({ destination: tempFilePath });
  const line = fs.readFileSync(tempFilePath).toString().split("\n")[1];
  fs.unlinkSync(tempFilePath);
  return parseInt(line.split(",")[0]);
}

async function loadCSVFromGCS(event, table) {
  const datasetId = "prod";

  // if we're dealing with db_records and there wasn't a change,
  // then there's no need to insert another record into BigQuery
  if (table == "db_records") {
    const did_change = await did_num_records_change(event);
    if (!did_change) {
      console.log("it did not change, so skipping loading csv into bq");
      return;
    }
  }

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
  console.log(`CSV Loading Job ${job.id} completed.  table: ${table}`);

  // Check the job's status for errors
  const errors = job.status.errors;
  if (errors && errors.length > 0) {
    throw errors;
  }
}

async function latest_db_records_count() {
  const query = `SELECT num_records
    FROM prod.db_records
    ORDER BY replicated_at DESC
    LIMIT 1`;

  // For all options, see https://cloud.google.com/bigquery/docs/reference/rest/v2/jobs/query
  const options = {
    query: query,
    location: "US",
  };

  // Run the query as a job
  const [job] = await bigquery.createQueryJob(options);
  // Wait for the query to finish
  const [rows] = await job.getQueryResults();
  return rows[0].num_records;
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
