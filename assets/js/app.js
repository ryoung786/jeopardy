// We need to import the CSS so that webpack will load it.
// The  MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html";
import { Socket } from "phoenix";
import NProgress from "nprogress";
import { LiveSocket } from "phoenix_live_view";

let Hooks = {};
Hooks.vibratePhone = {
  mounted() {
    if ("vibrate" in navigator) {
      window.navigator.vibrate([200, 30, 200]);
    }
  },
};
Hooks.FinalJeopardyReveal = {
  updateScoreboard(player_id) {
    let podium = document.querySelector(
      '.scoreboard .podium[data-player_id="' + player_id + '"]'
    );
    podium.querySelector(".score").classList.add("revealed");
  },
  fun(current, next) {
    if (next) {
      current.classList.remove("active");
      next.classList.add("active");
    } else {
      // we're done, time to tell the backend to advance to game over
      this.pushEventTo(".tv.revealing_final_scores", "game_over", {});
    }
  },
  mounted() {
    document.addEventListener("animationend", (e) => {
      if (e.target.closest(".tv.final-jeopardy .details .wager")) {
        let player_id = e.target.closest(".details.active").dataset[
          "player_id"
        ];
        let current = e.target.closest(".details.active");
        let next = current.nextElementSibling;
        let self = this;
        // One second after we reveal the player's wager, update their podium score
        window.setTimeout(function () {
          self.updateScoreboard(player_id);
        }, 1000);
        // Five seconds after we reveal the player's wager,
        // start animating the next player
        window.setTimeout(function () {
          self.fun(current, next);
        }, 5000);
      }
    });
  },
};
Hooks.stats = {
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
Hooks.DrawName = {
  // handle windows scrolling & resizing
  reOffset(self) {
    var BB = canvas.getBoundingClientRect();
    self.offsetX = BB.left;
    self.offsetY = BB.top;
  },
  // Get the position of a touch relative to the canvas
  getTouchPos(canvasDom, touchEvent) {
    var rect = canvasDom.getBoundingClientRect();
    return {
      x: touchEvent.touches[0].clientX - rect.left,
      y: touchEvent.touches[0].clientY - rect.top,
    };
  },
  handleMouseMove(e, self) {
    // tell the browser we're handling this event
    e.preventDefault();
    e.stopPropagation();

    // get the mouse position
    let mouseX = parseInt(e.clientX - self.offsetX);
    let mouseY = parseInt(e.clientY - self.offsetY);

    // save the mouse position in the points[] array
    // but don't draw anything
    if (self.painting) {
      self.points.push({ x: mouseX, y: mouseY, drag: true });
    }
  },

  draw(self) {
    // No additional points? Request another frame an return
    var length = self.points.length;
    if (length == self.lastLength) {
      requestAnimationFrame(() => {
        self.draw(self);
      });
      return;
    }

    // draw the additional points
    var point = self.points[self.lastLength];
    self.ctx.beginPath();
    self.ctx.moveTo(point.x, point.y);
    for (var i = self.lastLength; i < length; i++) {
      point = self.points[i];
      if (point.drag) {
        self.ctx.lineTo(point.x, point.y);
      } else {
        self.ctx.moveTo(point.x, point.y);
      }
    }
    self.ctx.stroke();

    // request another animation loop
    requestAnimationFrame(() => {
      self.draw(self);
    });
  },

  mounted() {
    // canvas variables
    let self = this;
    this.painting = false;
    this.canvas = document.getElementById("canvas");
    this.ctx = canvas.getContext("2d");
    this.cw = canvas.width;
    this.ch = canvas.height;

    this.offsetX;
    this.offsetY;

    this.points = [];
    this.lastLength = 0;

    // set canvas styling
    this.ctx.strokeStyle = "skyblue";
    this.ctx.lineJoint = "round";
    this.ctx.lineCap = "round";
    this.ctx.lineWidth = 6;

    this.reOffset(self);
    window.onscroll = function (e) {
      self.reOffset(self);
    };
    window.onresize = function (e) {
      self.reOffset(self);
    };

    // start the  animation loop
    requestAnimationFrame(() => {
      this.draw(self);
    });

    canvas.onmousedown = (e) => {
      self.painting = true;
      // get the mouse position
      let mouseX = parseInt(e.clientX - self.offsetX);
      let mouseY = parseInt(e.clientY - self.offsetY);

      // save the mouse position in the points[] array
      // but don't draw anything
      if (self.painting) {
        self.points.push({ x: mouseX, y: mouseY, drag: false });
      }
    };
    canvas.onmouseup = (e) => {
      self.painting = false;
    };
    canvas.onmouseleave = (e) => {
      self.painting = false;
    };

    canvas.onmousemove = function (e) {
      self.handleMouseMove(e, self);
    };

    // Set up touch events for mobile, etc
    canvas.addEventListener(
      "touchstart",
      function (e) {
        let mousePos = self.getTouchPos(self.canvas, e);
        var touch = e.touches[0];
        var mouseEvent = new MouseEvent("mousedown", {
          clientX: touch.clientX,
          clientY: touch.clientY,
        });
        self.canvas.dispatchEvent(mouseEvent);
      },
      false
    );
    canvas.addEventListener(
      "touchend",
      function (e) {
        var mouseEvent = new MouseEvent("mouseup", {});
        self.canvas.dispatchEvent(mouseEvent);
      },
      false
    );
    canvas.addEventListener(
      "touchmove",
      function (e) {
        var touch = e.touches[0];
        var mouseEvent = new MouseEvent("mousemove", {
          clientX: touch.clientX,
          clientY: touch.clientY,
        });
        self.canvas.dispatchEvent(mouseEvent);
      },
      false
    );

    // Prevent scrolling when touching the canvas
    document.body.addEventListener(
      "touchstart",
      function (e) {
        if (e.target == self.canvas) {
          e.preventDefault();
        }
      },
      false
    );
    document.body.addEventListener(
      "touchend",
      function (e) {
        if (e.target == self.canvas) {
          e.preventDefault();
        }
      },
      false
    );
    document.body.addEventListener("touchmove", (e) => {}, { passive: false });

    document.getElementById("screenshot").addEventListener("click", (e) => {
      console.log(self.canvas.toDataURL());
    });
    document.getElementById("clear").addEventListener("click", (e) => {
      self.ctx.clearRect(0, 0, self.ctx.canvas.width, self.ctx.canvas.height);
      self.points = [];
    });
  },
};
let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
});

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", (info) => NProgress.start());
window.addEventListener("phx:page-loading-stop", (info) => NProgress.done());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket;
