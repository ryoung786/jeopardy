export default {
  updated() {
    this.card = this.el.querySelector(".card");
    this.handle(this.card);
  },

  handle(card) {
    console.log("handle");
    card.style.transform =
      "translateX(0) translateY(0) rotate(0deg) rotateY(0deg) scale(1)";

    // destroy previous Hammer instance, if present
    if (this.hammer) this.hammer.destroy();

    // listen for tap and pan gestures on top card
    this.hammer = new Hammer(card);

    // pass events data to custom callbacks
    if (card.dataset.tap) {
      this.hammer.on("tap", (e) => {
        this.onTap(e);
      });
    }
    if (card.dataset.left && card.dataset.right) {
      this.hammer.on("pan", (e) => {
        this.onPan(e);
      });
    }
  },

  onPan(e) {
    let card = e.target;
    console.log("pan");
    console.log(e);

    if (!this.isPanning) {
      this.isPanning = true;

      // remove transition properties
      card.style.transition = null;

      // get top card coordinates in pixels
      let style = window.getComputedStyle(card);
      let mx = style.transform.match(/^matrix\((.+)\)$/);
      this.startPosX = mx ? parseFloat(mx[1].split(", ")[4]) : 0;
      this.startPosY = mx ? parseFloat(mx[1].split(", ")[5]) : 0;

      // get top card bounds
      let bounds = card.getBoundingClientRect();

      // get finger position on top card, top (1) or bottom (-1)
      this.isDraggingFrom =
        e.center.y - bounds.top > card.clientHeight / 2 ? -1 : 1;
    }

    // get new coordinates
    let posX = e.deltaX + this.startPosX;
    let posY = e.deltaY + this.startPosY;

    // get ratio between swiped pixels and the axes
    let propX = e.deltaX / this.el.clientWidth;
    let propY = e.deltaY / this.el.clientHeight;

    // get swipe direction, left (-1) or right (1)
    let dirX = e.deltaX < 0 ? -1 : 1;

    // get degrees of rotation, between 0 and +/- 45
    let deg = this.isDraggingFrom * dirX * Math.abs(propX) * 45;

    // get scale ratio, between .95 and 1
    let scale = (95 + 5 * Math.abs(propX)) / 100;

    // move and rotate top card
    card.style.transform = `translateX(${posX}px) translateY(${posY}px) rotate(${deg}deg) rotateY(0deg) scale(1)`;

    if (e.isFinal) {
      this.isPanning = false;

      let successful = false;

      // set back transition properties
      card.style.transition = "transform 200ms ease-out";

      // check threshold and movement direction
      if (propX > 0.25 && e.direction == Hammer.DIRECTION_RIGHT) {
        successful = Hammer.DIRECTION_RIGHT;
        // get right border position
        posX = this.el.clientWidth;
        console.log("Swiped right");
      } else if (propX < -0.25 && e.direction == Hammer.DIRECTION_LEFT) {
        successful = Hammer.DIRECTION_LEFT;
        // get left border position
        posX = -(this.el.clientWidth + card.clientWidth);
        console.log("Swiped right");
        // } else if (propY < -0.25 && e.direction == Hammer.DIRECTION_UP) {
        //   successful = true;
        //   // get top border position
        //   posY = -(this.el.clientHeight + card.clientHeight);
      }

      if (successful) {
        // throw card in the chosen direction
        card.style.transform = `translateX(${posX}px) translateY(${posY}px) rotate(${deg}deg)`;

        // wait transition end
        setTimeout(() => {
          // remove swiped card
          this.el.removeChild(card);
          if (successful == Hammer.DIRECTION_LEFT)
            this.pushEvent(card.dataset.left);
          if (successful == Hammer.DIRECTION_RIGHT)
            this.pushEvent(card.dataset.right);
        }, 200);
      } else {
        // reset cards position and size
        card.style.transform =
          "translateX(0) translateY(0) rotate(0deg) rotateY(0deg) scale(1)";
      }
    }
  },

  onTap(e) {
    let card = e.target;
    console.log("tap");
    this.pushEvent(card.dataset.tap);
  },
};
