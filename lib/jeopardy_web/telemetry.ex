defmodule JeopardyWeb.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
      # Add reporters as children of your supervision tree.
      # {Telemetry.Metrics.ConsoleReporter, metrics: metrics()}
    ]

    setup_influx()
    Supervisor.init(children, strategy: :one_for_one)
  end

  defp setup_influx() do
    TelemetryInfluxDB.start_link(
      events: [
        %{name: [:metrics_demo, :foo]},
        %{name: [:j, :buzz], metadata_tag_keys: [:game_code, :player_name]},
        %{name: [:j, :games, :created]},
        %{name: [:j, :answers, :correct]},
        %{name: [:j, :answers, :incorrect]}
      ],
      version: :v2,
      port: 443,
      protocol: :http,
      org: "ryoung786@gmail.com",
      host: "https://us-central1-1.gcp.cloud2.influxdata.com",
      bucket: "jeopardy",
      token:
        "JR16emjVVZipHB7uhOFhWiJFUKueDt9wXurn4TBHwVyVy8dLqA1EGWWMomdp_rA3mrrS1twvRYBIFVgT5nYZfQ=="
    )

    nil
  end

  def metrics do
    [
      # Phoenix Metrics
      summary("phoenix.endpoint.stop.duration",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),

      # App Metrics
      counter("metrics_demo.render.controller"),

      # Database Metrics
      summary("jeopardy.repo.query.total_time", unit: {:native, :millisecond}),
      summary("jeopardy.repo.query.decode_time", unit: {:native, :millisecond}),
      summary("jeopardy.repo.query.query_time", unit: {:native, :millisecond}),
      summary("jeopardy.repo.query.queue_time", unit: {:native, :millisecond}),
      summary("jeopardy.repo.query.idle_time", unit: {:native, :millisecond}),

      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io")
    ]
  end

  defp periodic_measurements do
    [
      # A module, function and arguments to be invoked periodically.
      # This function must call :telemetry.execute/3 and a metric must be added above.
      # {JeopardyWeb, :count_users, []}
    ]
  end
end
