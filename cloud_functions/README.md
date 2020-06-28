# Cloud Functions
Google Cloud Functions that run as part of the app.

## load_and_dedupe
This is triggered when a new file is uploaded to the GCS bucket.  It then does a few things:
1. Checks to see if it's a csv that we care about (db records ready for replication)
2. If yes, it loads the csv into the corresponding BigQuery dataset table
3. BigQuery doesn't have any unique key constraints, so the records are most likely duplicates.  So we must run a query to delete old copies of each record.

Once the function is complete, our BigQuery dataset contains the full history of jeopardy games, players, and clues.  It frees us up to delete everything in the Google Cloud Storage (GCS) bucket, as well as truncate the production database.  This is extremely helpful, because gigalixir only allows for 10,000 records in their free tier postgres instance.  By replicating frequently and truncating, we can safely stay under the threshold.  BigQuery allows for 10GB of data in its free tier, which jeopardy won't fill up for a while, if ever.

This scheme has the added benefit of decoupling any BI querying we'd like to do from the production DB.  I currently have [Metabase](https://www.metabase.com/), hosted on heroku (again, free), pointed at the BigQuery dataset, providing some great dashboards and charts.  Previously I had to point it at the gigalixir prod DB, which was a problem because in the free tier it only allows for 2 concurrent connections, which meant that oftentimes Metabase would be unable to sync or query data.

### Replication and BI
The rough idea is for the elixir app to check [every so often](https://github.com/ryoung786/jeopardy/blob/master/config/prod.exs#L44) for any records that have been updated since the last time they were replicated (relevant code [here](https://github.com/ryoung786/jeopardy/blob/master/lib/jeopardy/bi_replication.ex#L60)).  To do that, we set a `replicated_at` column on each database table, defaulting to the earliest possible date.  When the job wakes up, it runs the queries to see which records need replicating, then writes it to a temporary CSV.  It then updates those records in the database, setting the `replicated_at` timestamp to now so we know not to process it again.  We upload the CSV to GCS bucket and delete the temp CSV from disk to clean up after ourselves.  The cloud function triggers off that and takes it from there.

### Why not use Fivetran or Stitch?
I would have loved to, but a few things meant they weren't an option.  Both can shuttle data from postgres to BigQuery, but Fivetran charges after a trial period.  Stitch was unable to connect, I suspect due to gigalixir's 2 concurrent connection limit on the free tier database.  By moving the replication inside the app itself, we can bypass the connection limit and stay within our budget.
