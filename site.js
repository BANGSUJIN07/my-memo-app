// 기획서·스크립트 페이지 공통 동작: 다크 모드 (메모장에서 고른 설정을 그대로 따라가요)
(function () {
  var t = null;
  try { t = localStorage.getItem("theme-v1"); } catch (e) {}
  if (t !== "dark" && t !== "light") t = window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
  document.documentElement.dataset.theme = t;

  document.addEventListener("DOMContentLoaded", function () {
    var b = document.getElementById("themeBtn");
    if (!b) return;
    function paint() { b.textContent = document.documentElement.dataset.theme === "dark" ? "☀️" : "🌙"; }
    paint();
    b.onclick = function () {
      var n = document.documentElement.dataset.theme === "dark" ? "light" : "dark";
      document.documentElement.dataset.theme = n;
      try { localStorage.setItem("theme-v1", n); } catch (e) {}
      paint();
    };
  });
})();
