export default {
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
