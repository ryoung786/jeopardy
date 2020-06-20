"use strict";
export default {
  chartColors: {
    green: "rgb(75, 192, 192)",
    orange: "rgb(255, 159, 64)",
    blue: "rgb(54, 162, 235)",
    red: "rgb(255, 99, 132)",
    yellow: "rgb(255, 205, 86)",
    grey: "rgb(201, 203, 207)",
    purple: "rgb(153, 102, 255)",
  },
  getColor(i) {
    return this.chartColors[
      Object.keys(this.chartColors)[i % Object.keys(this.chartColors).length]
    ];
  },
  getDataForChart() {
    const el = document.getElementById("js-stats-data");
    const stats = JSON.parse(el.dataset.stats);
    const datasets =
      stats === null
        ? []
        : Object.keys(stats).map((player_id, i) => {
            return {
              label: stats[player_id].name,
              data: stats[player_id].scores,
              borderColor: this.getColor(i),
              fill: false,
              // lineTension: 0
            };
          });
    return {
      labels: [...Array(62).keys()],
      datasets: datasets,
    };
  },
  mounted() {
    var ctx = document.getElementById("stats").getContext("2d");
    const stats = JSON.parse(
      document.getElementById("js-stats-data").dataset.stats
    );
    const allscores =
      stats == null
        ? []
        : Object.keys(stats).reduce(
            (acc, id) => acc.concat(stats[id].scores),
            []
          );

    window.lineChart = new Chart(ctx, {
      type: "line",
      data: this.getDataForChart(),
      options: {
        tooltips: { mode: "x", position: "nearest" },
        elements: { point: { radius: 0 } },
        scales: {
          xAxes: [
            {
              gridLines: { display: false },
              ticks: { display: false },
            },
          ],
          yAxes: [
            {
              gridLines: { drawTicks: false },
              ticks: {
                padding: 15,
                precision: 0,
                suggestedMin: Math.min(...allscores) - 500,
                suggestedMax: Math.max(...allscores) + 500,
                callback: (value, index, values) => {
                  return (value < 0 ? "-" : "") + "$" + Math.abs(value);
                },
              },
            },
          ],
        },
      },
    });
  },
  updated() {
    window.lineChart.data = this.getDataForChart();
    window.lineChart.update(0);
  },
};
