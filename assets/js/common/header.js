window.toggle_user_profile_dropdown = function () {
  const element = document.querySelector(".header .user-profile-dropdown");
  element.classList.toggle("active");
};

window.addEventListener("click", (event) => {
  if (
    event.target.closest(".user-profile-dropdown") ||
    event.target.closest(".user-profile")
  ) {
    return;
  }

  const element = document.querySelector(".header .user-profile-dropdown");
  if (element) {
    element.classList.remove("active");
  }
});
