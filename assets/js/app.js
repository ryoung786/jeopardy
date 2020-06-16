// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"

let Hooks = {}
Hooks.vibratePhone = {
    mounted() {
        if ("vibrate" in navigator) {
            window.navigator.vibrate([200, 30, 200]);
        }
    }
}
Hooks.FinalJeopardyReveal = {
    updateScoreboard(player_id) {
        let podium = document.querySelector('.scoreboard .podium[data-player_id="'+player_id+'"]');
        podium.querySelector('.score').classList.add('revealed');
    },
    fun (current, next) {
        if (next) {
            current.classList.remove('active');
            next.classList.add('active');
        } else {
            // we're done, time to tell the backend to advance to game over
            this.pushEvent("next", {})
        }
    },
    mounted() {
        document.addEventListener('animationend', e => {
            if (e.target.closest('.tv.final-jeopardy .details .wager')) {
                let player_id = e.target.closest('.details.active').dataset['player_id'];
                let current = e.target.closest('.details.active');
                let next = current.nextElementSibling;
                let self = this;
                // One second after we reveal the player's wager, update their podium score
                window.setTimeout(
                    function() { self.updateScoreboard(player_id); },
                    1000
                );
                // Five seconds after we reveal the player's wager,
                // start animating the next player
                window.setTimeout(
                    function() { self.fun(current, next); },
                    5000
                );
            }
        })
    }
}
Hooks.stats = {
    chartColors: {
        green: 'rgb(75, 192, 192)',
        orange: 'rgb(255, 159, 64)',
        blue: 'rgb(54, 162, 235)',
        red: 'rgb(255, 99, 132)',
        yellow: 'rgb(255, 205, 86)',
        grey: 'rgb(201, 203, 207)',
        purple: 'rgb(153, 102, 255)',
    },
    getColor(i) {
        return this.chartColors[
            Object.keys(this.chartColors)[i % Object.keys(this.chartColors).length]
        ]
    },
    getDataForChart() {
        const el = document.getElementById("js-stats-data")
        const stats = JSON.parse(el.dataset.stats)
        const datasets = (stats === null)
              ? []
              : Object.keys(stats).map((player_id, i) => {
                  return {
                      label: stats[player_id].name,
                      data: stats[player_id].scores,
                      borderColor: this.getColor(i),
                      fill: false,
                      // lineTension: 0
                  }
              })
        return {
            labels: [...Array(62).keys()],
            datasets: datasets
        }
    },
    mounted() {
        var ctx = document.getElementById("stats").getContext("2d")
        const stats = JSON.parse(document.getElementById("js-stats-data").dataset.stats)
        const allscores = (stats == null)
              ? []
              : Object.keys(stats).reduce(((acc, id) => acc.concat(stats[id].scores)), [])

        window.lineChart = new Chart(ctx, {
            type: 'line',
            data: this.getDataForChart(),
            options: {
                tooltips: { mode: 'x', position: 'nearest' },
                elements: { point: { radius: 0 }},
                scales: {
                    xAxes: [{
                        gridLines: { display: false },
                        ticks: { display: false }
                    }],
                    yAxes: [{
                        gridLines: { drawTicks: false },
                        ticks: {
                            padding: 15,
                            precision: 0,
                            suggestedMin: Math.min(...allscores) - 500,
                            suggestedMax: Math.max(...allscores) + 500,
                            callback: (value, index, values) => {
                                return (value < 0 ? '-' : '') + '$' + Math.abs(value);
                            }
                        }
                    }],
                }
            }
        });
    },
    updated() {
        window.lineChart.data = this.getDataForChart();
        window.lineChart.update(0);
    }
}
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket
