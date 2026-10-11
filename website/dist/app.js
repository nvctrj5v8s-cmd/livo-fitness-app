"use strict";

document.documentElement.classList.add("js");

const motionPreference = window.matchMedia("(prefers-reduced-motion: reduce)");
const revealElements = document.querySelectorAll(".reveal");
if ("IntersectionObserver" in window && !motionPreference.matches) {
  const revealObserver = new IntersectionObserver((entries, observer) => {
    for (const entry of entries) {
      if (!entry.isIntersecting) continue;
      entry.target.classList.add("is-visible");
      observer.unobserve(entry.target);
    }
  }, { threshold: 0.08 });
  revealElements.forEach((element) => revealObserver.observe(element));
} else {
  revealElements.forEach((element) => element.classList.add("is-visible"));
}
motionPreference.addEventListener("change", () => {
  if (motionPreference.matches) revealElements.forEach((element) => element.classList.add("is-visible"));
});

const menuButton = document.querySelector(".menu-toggle");
const navigation = document.querySelector(".main-nav");
function closeMenu() {
  navigation.classList.remove("is-open");
  menuButton.setAttribute("aria-expanded", "false");
  menuButton.setAttribute("aria-label", "Menü öffnen");
}
menuButton.addEventListener("click", () => {
  const open = menuButton.getAttribute("aria-expanded") !== "true";
  menuButton.setAttribute("aria-expanded", String(open));
  menuButton.setAttribute("aria-label", open ? "Menü schließen" : "Menü öffnen");
  navigation.classList.toggle("is-open", open);
});
navigation.querySelectorAll("a").forEach((link) => link.addEventListener("click", closeMenu));
document.addEventListener("keydown", (event) => {
  if (event.key === "Escape" && navigation.classList.contains("is-open")) {
    closeMenu();
    menuButton.focus();
  }
});
window.matchMedia("(min-width: 701px)").addEventListener("change", (event) => {
  if (event.matches) closeMenu();
});

const tabs = [...document.querySelectorAll(".phone-tab")];
const panels = [...document.querySelectorAll(".phone-panel")];
panels.forEach((panel) => {
  panel.id = `panel-${panel.dataset.panel}`;
  panel.setAttribute("role", "tabpanel");
  panel.setAttribute("aria-labelledby", `tab-${panel.dataset.panel}`);
});
function selectTab(tab, focus = false) {
  tabs.forEach((item) => {
    const selected = item === tab;
    item.classList.toggle("is-active", selected);
    item.setAttribute("aria-selected", String(selected));
    item.tabIndex = selected ? 0 : -1;
  });
  panels.forEach((panel) => { panel.hidden = panel.dataset.panel !== tab.dataset.tab; });
  if (focus) tab.focus();
}
tabs.forEach((tab, index) => {
  tab.addEventListener("click", () => selectTab(tab));
  tab.addEventListener("keydown", (event) => {
    let next;
    if (event.key === "ArrowRight") next = (index + 1) % tabs.length;
    if (event.key === "ArrowLeft") next = (index - 1 + tabs.length) % tabs.length;
    if (event.key === "Home") next = 0;
    if (event.key === "End") next = tabs.length - 1;
    if (next === undefined) return;
    event.preventDefault();
    selectTab(tabs[next], true);
  });
});

const scanCard = document.querySelector(".photo-feature");
if ("IntersectionObserver" in window) {
  const scanObserver = new IntersectionObserver(([entry]) => {
    const running = entry.isIntersecting && !document.hidden && !motionPreference.matches;
    // A short, finite scan plays only while the card is visible.
    scanCard.classList.toggle("scan-active", running);
  }, { threshold: 0.35 });
  scanObserver.observe(scanCard);
  document.addEventListener("visibilitychange", () => {
    if (document.hidden) scanCard.classList.remove("scan-active");
  });
}

const storeDialog = document.querySelector("#store-dialog");
const selectedStore = document.querySelector("#selected-store");
document.querySelectorAll("[data-store]").forEach((button) => {
  button.addEventListener("click", () => {
    selectedStore.textContent = button.dataset.store;
    storeDialog.showModal();
    document.body.classList.add("modal-open");
  });
});
function closeStoreDialog() {
  storeDialog.close();
  document.body.classList.remove("modal-open");
}
storeDialog.querySelector(".dialog-close").addEventListener("click", closeStoreDialog);
storeDialog.querySelector(".dialog-done").addEventListener("click", closeStoreDialog);
storeDialog.addEventListener("close", () => document.body.classList.remove("modal-open"));
storeDialog.addEventListener("click", (event) => {
  if (event.target !== storeDialog) return;
  const bounds = storeDialog.getBoundingClientRect();
  if (event.clientX < bounds.left || event.clientX > bounds.right || event.clientY < bounds.top || event.clientY > bounds.bottom) closeStoreDialog();
});

document.querySelector("#copyright-year").textContent = String(new Date().getFullYear());

// Local assets only. If a food photograph is unavailable, use the brand icon.
document.querySelectorAll("img").forEach((image) => {
  function fallback() {
    if (image.dataset.fallback || image.getAttribute("src").includes("lookin-icon")) return;
    image.dataset.fallback = "true";
    image.src = image.closest(".legal-main") ? "../assets/lookin-icon.png" : "assets/lookin-icon.png";
    image.classList.add("image-fallback");
    image.alt = "Lookin – Bildvorschau nicht verfügbar";
  }
  image.addEventListener("error", fallback);
  if (image.complete && image.naturalWidth === 0) fallback();
});
