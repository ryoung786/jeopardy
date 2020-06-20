export default {
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
