function flashClose() {
  document.querySelectorAll(".flash .close").forEach(function(e) {
    e.addEventListener("click", function(){
      this.parentElement.classList.remove("active");
    })
  })
}
