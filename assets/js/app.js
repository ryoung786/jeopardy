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

    self.ctx.strokeStyle = "#fff";
    self.ctx.lineJoint = "round";
    self.ctx.lineCap = "round";
    self.ctx.lineWidth = 3;

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
    this.canvas.width = parseInt(getComputedStyle(this.canvas).width);
    this.canvas.height = parseInt(getComputedStyle(this.canvas).height);

    this.offsetX;
    this.offsetY;

    this.points = [];
    this.lastLength = 0;

    // set canvas styling

    this.reOffset(self);
    window.onscroll = function (e) {
      self.reOffset(self);
    };
    window.onresize = function (e) {
      self.canvas.width = parseInt(getComputedStyle(self.canvas).width);
      self.canvas.height = parseInt(getComputedStyle(self.canvas).height);
      self.reOffset(self);
    };

    // start the  animation loop
    requestAnimationFrame(() => {
      self.draw(self);
    });

    canvas.onmousedown = (e) => {
      self.painting = true;
      self.reOffset(self);
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
      return false;
    };
    canvas.onmouseleave = (e) => {
      self.painting = false;
      return false;
    };

    canvas.onmousemove = function (e) {
      self.handleMouseMove(e, self);
      return false;
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
        e.preventDefault();
        return false;
      },
      { passive: false }
    );
    canvas.addEventListener(
      "touchend",
      function (e) {
        var mouseEvent = new MouseEvent("mouseup", {});
        self.canvas.dispatchEvent(mouseEvent);
        e.preventDefault();
        return false;
      },
      { passive: false }
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
        e.preventDefault();
        return false;
      },
      { passive: false }
    );

    // Prevent scrolling when touching the canvas
    document.body.addEventListener("touchstart", (e) => {}, { passive: false });
    document.body.addEventListener("touchend", (e) => {}, { passive: false });
    document.body.addEventListener("touchmove", (e) => {}, { passive: false });

    document.getElementById("screenshot").addEventListener("click", (e) => {
      // find the bounding box and create an image from just that
      // otherwise the signature looks too small in the smaller podium area in game
      let xs = self.points.map((p) => p.x);
      let ys = self.points.map((p) => p.y);
      let min_x = Math.max(0, Math.min(...xs) - 2);
      let max_x = Math.min(self.canvas.width, Math.max(...xs) + 2);
      let min_y = Math.max(0, Math.min(...ys) - 2);
      let max_y = Math.min(self.canvas.width, Math.max(...ys) + 2);

      let imgdata = self.ctx.getImageData(
        min_x,
        min_y,
        max_x - min_x,
        max_y - min_y
      );
      let canvas_copy = document.createElement("canvas");
      canvas_copy.width = imgdata.width;
      canvas_copy.height = imgdata.height;
      canvas_copy.getContext("2d").putImageData(imgdata, 0, 0);
      let data_url = canvas_copy.toDataURL();

      console.log(data_url);

      this.pushEventTo(".awaiting_start", "signed-podium", {
        url: data_url,
      });
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
