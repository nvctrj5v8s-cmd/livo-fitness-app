(() => {
  "use strict";
  const root = document.documentElement;
  root.classList.add("js");
  const motionQuery = matchMedia("(prefers-reduced-motion: reduce)");
  const motionButton = document.querySelector(".motion-toggle");
  let manuallyPaused = false;
  const motionAllowed = () => !motionQuery.matches && !manuallyPaused && !document.hidden;
  const escapeHtml = (value) => String(value).replace(/[&<>"']/g, (char) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[char]);
  const icon = (name) => `<svg class="icon" aria-hidden="true"><use href="#${name}"/></svg>`;
  const number = (value, decimals = 0) => new Intl.NumberFormat("de-DE", { minimumFractionDigits: decimals, maximumFractionDigits: decimals }).format(value);

  // All presentation data lives in this page's memory. No account, storage or API.
  const recipes = window.LOOKIN_RECIPES || [];
  const revealElements = document.querySelectorAll(".reveal");
  document.querySelectorAll(".stagger-group").forEach((group) => {
    group.querySelectorAll(".reveal").forEach((element, index) => element.style.setProperty("--delay", `${index * 85}ms`));
  });
  function showAllSections() { revealElements.forEach((element) => element.classList.add("is-visible")); }
  if ("IntersectionObserver" in window && !motionQuery.matches) {
    const reveals = new IntersectionObserver((entries, observer) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        entry.target.classList.add("is-visible");
        observer.unobserve(entry.target);
      });
    }, { threshold: 0.08 });
    revealElements.forEach((element) => reveals.observe(element));
  } else showAllSections();

  function updateMotion() {
    const paused = motionQuery.matches || manuallyPaused;
    root.classList.toggle("motion-paused", paused);
    motionButton.setAttribute("aria-pressed", String(paused));
    motionButton.setAttribute("aria-label", paused ? "Animationen fortsetzen" : "Animationen pausieren");
    motionButton.title = motionQuery.matches ? "Reduzierte Bewegung laut Systemeinstellung" : paused ? "Animationen fortsetzen" : "Animationen pausieren";
    motionButton.disabled = motionQuery.matches;
    motionButton.querySelector("span").textContent = paused ? "▷" : "Ⅱ";
    if (paused) {
      showAllSections();
      document.querySelector(".hero-stage").style.setProperty("--travel", "0");
      document.querySelector(".hero-stage").classList.remove("scan-visible");
      document.getAnimations().forEach((animation) => animation.finish());
    }
    window.dispatchEvent(new CustomEvent("lookin:motion", { detail: { paused } }));
  }
  motionButton.addEventListener("click", () => { manuallyPaused = !manuallyPaused; updateMotion(); });
  motionQuery.addEventListener("change", updateMotion);
  updateMotion();

  function animateContent(element) {
    if (!motionAllowed() || !element.animate) return;
    element.animate([{ opacity: 0, transform: "translateY(12px)" }, { opacity: 1, transform: "translateY(0)" }], { duration: 460, easing: "cubic-bezier(.22,1,.36,1)" });
  }

  const menu = document.querySelector(".main-nav");
  const menuButton = document.querySelector(".menu-toggle");
  function closeMenu(focus = false) {
    menu.classList.remove("is-open");
    menuButton.setAttribute("aria-expanded", "false");
    menuButton.setAttribute("aria-label", "Menü öffnen");
    if (focus) menuButton.focus();
  }
  menuButton.addEventListener("click", () => {
    const open = menuButton.getAttribute("aria-expanded") !== "true";
    menu.classList.toggle("is-open", open);
    menuButton.setAttribute("aria-expanded", String(open));
    menuButton.setAttribute("aria-label", open ? "Menü schließen" : "Menü öffnen");
  });
  menu.querySelectorAll("a").forEach((link) => link.addEventListener("click", () => closeMenu()));
  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && menu.classList.contains("is-open")) closeMenu(true);
  });
  matchMedia("(min-width:701px)").addEventListener("change", (event) => { if (event.matches) closeMenu(); });

  function setupTabs(tabs, onSelect) {
    function select(tab, focus = false) {
      tabs.forEach((item) => {
        const selected = item === tab;
        item.setAttribute("aria-selected", String(selected));
        item.tabIndex = selected ? 0 : -1;
      });
      onSelect(tab);
      if (focus) tab.focus();
    }
    tabs.forEach((tab, index) => {
      tab.addEventListener("click", () => select(tab));
      tab.addEventListener("keydown", (event) => {
        let next;
        if (event.key === "ArrowRight") next = (index + 1) % tabs.length;
        if (event.key === "ArrowLeft") next = (index - 1 + tabs.length) % tabs.length;
        if (event.key === "Home") next = 0;
        if (event.key === "End") next = tabs.length - 1;
        if (next === undefined) return;
        event.preventDefault();
        select(tabs[next], true);
      });
    });
  }
  const heroTabs = [...document.querySelectorAll("[data-hero-tab]")];
  const heroPanels = [...document.querySelectorAll("[data-hero-panel]")];
  heroTabs.forEach((tab) => { tab.id = `hero-tab-${tab.dataset.heroTab}`; tab.setAttribute("aria-controls", `hero-panel-${tab.dataset.heroTab}`); });
  heroPanels.forEach((panel) => { panel.id = `hero-panel-${panel.dataset.heroPanel}`; panel.setAttribute("role", "tabpanel"); panel.setAttribute("aria-labelledby", `hero-tab-${panel.dataset.heroPanel}`); });
  setupTabs(heroTabs, (tab) => heroPanels.forEach((panel) => { panel.hidden = panel.dataset.heroPanel !== tab.dataset.heroTab; }));

  const stage = document.querySelector(".hero-stage");
  let stageVisible = false;
  let scrollFrame = 0;
  const progress = document.querySelector(".scroll-progress");
  function updateScroll() {
    scrollFrame = 0;
    const scrollable = root.scrollHeight - innerHeight;
    progress.style.transform = `scaleX(${scrollable > 0 ? Math.min(1, scrollY / scrollable) : 0})`;
    if (!stageVisible || !motionAllowed()) return;
    const rect = stage.getBoundingClientRect();
    const amount = Math.max(-100, Math.min(500, innerHeight * .35 - rect.top));
    stage.style.setProperty("--travel", String(amount));
  }
  window.addEventListener("scroll", () => { if (!scrollFrame) scrollFrame = requestAnimationFrame(updateScroll); }, { passive: true });
  window.addEventListener("resize", updateScroll);
  if ("IntersectionObserver" in window) {
    const motionRegions = new IntersectionObserver((entries) => {
      entries.forEach((entry) => entry.target.classList.toggle("motion-in-view", entry.isIntersecting));
    });
    document.querySelectorAll(".hero-stage,.diary-visual,.recipe-grid").forEach((region) => {
      region.classList.add("motion-region");
      motionRegions.observe(region);
    });
    new IntersectionObserver(([entry]) => {
      stageVisible = entry.isIntersecting;
      if (stageVisible) stage.classList.add("stage-revealed");
      stage.classList.toggle("scan-visible", stageVisible && motionAllowed());
      updateScroll();
    }, { threshold: 0.1 }).observe(stage);
    const navLinks = [...menu.querySelectorAll("a")];
    const sections = navLinks.map((link) => document.querySelector(link.getAttribute("href")));
    // Each section is observed by the same lightweight navigation observer.
    const sectionObserver = new IntersectionObserver((entries) => {
      const current = entries.find((entry) => entry.isIntersecting);
      if (!current) return;
      navLinks.forEach((link) => {
        const selected = link.hash === `#${current.target.id}`;
        link.classList.toggle("is-current", selected);
        if (selected) link.setAttribute("aria-current", "location"); else link.removeAttribute("aria-current");
      });
    }, { rootMargin: "-12% 0px -70% 0px" });
    sections.filter(Boolean).forEach((section) => sectionObserver.observe(section));
  }
  document.addEventListener("visibilitychange", () => {
    if (document.hidden) {
      stage.classList.remove("scan-visible");
      document.getAnimations().forEach((animation) => animation.pause());
    } else {
      if (motionAllowed()) document.getAnimations().forEach((animation) => { if (animation.playState === "paused") animation.play(); });
      stage.classList.toggle("scan-visible", stageVisible && motionAllowed());
    }
  });
  updateScroll();

  document.querySelectorAll("[data-count]").forEach((element) => {
    const finalValue = Number(element.dataset.count);
    let completed = false;
    if (!("IntersectionObserver" in window)) return;
    const counterObserver = new IntersectionObserver(([entry]) => {
      if (!entry.isIntersecting || completed) return;
      completed = true;
      counterObserver.disconnect();
      if (!motionAllowed()) return;
      const started = performance.now();
      function frame(now) {
        const bounds = element.getBoundingClientRect();
        if (!motionAllowed() || bounds.bottom < 0 || bounds.top > innerHeight) { element.textContent = number(finalValue); return; }
        const percent = Math.min(1, (now - started) / 1100);
        const eased = 1 - Math.pow(1 - percent, 3);
        element.textContent = number(Math.round(finalValue * eased));
        if (percent < 1) requestAnimationFrame(frame);
      }
      requestAnimationFrame(frame);
    }, { threshold: .8 });
    counterObserver.observe(element);
  });

  const mealMap = {
    breakfast: { id: "livo-protein-oats", time: "08:30 · Frühstück", description: "Haferflocken, Skyr & frische Beeren" },
    lunch: { id: "livo-salmon-avocado-rice", time: "12:45 · Mittagessen", description: "Lachs, Reis, Avocado & Zitrone" },
    dinner: { id: "livo-nudeln-tomatensauce", time: "19:00 · Abendessen", description: "Pasta, Tomaten & Oregano" },
  };
  setupTabs([...document.querySelectorAll("[data-meal]")], (tab) => {
    const meal = mealMap[tab.dataset.meal];
    const recipe = recipes.find((item) => item.id === meal.id);
    if (!recipe) return;
    const photo = document.querySelector("#diary-meal-photo");
    photo.src = recipe.image; photo.alt = recipe.title;
    document.querySelector("#diary-meal-time").textContent = meal.time;
    document.querySelector("#diary-meal-name").textContent = recipe.title;
    document.querySelector("#diary-meal-description").textContent = meal.description;
    document.querySelector("#diary-meal-kcal").textContent = number(recipe.kcal);
    [["protein", recipe.protein], ["carbs", recipe.carbs], ["fat", recipe.fat]].forEach(([key, value]) => {
      document.querySelector(`#meal-${key}`).innerHTML = `${number(value, 1)} <small>g</small>`;
    });
    const fills = document.querySelectorAll(".diary-large-macros .macro-fill");
    [recipe.protein * 1.7, recipe.carbs * 1.5, recipe.fat * 2.7].forEach((value, index) => fills[index].style.setProperty("--fill", `${Math.min(93, Math.max(12, value))}%`));
    animateContent(document.querySelector(".diary-selected-meal"));
  });

  const gallery = document.querySelector("#recipe-grid");
  function recipeCard(recipe, index) {
    return `<button class="recipe-card" type="button" data-recipe="${escapeHtml(recipe.id)}" style="--index:${index}" aria-label="${escapeHtml(recipe.title)} – Zutaten und Zubereitung öffnen"><div class="recipe-photo"><img src="${escapeHtml(recipe.image)}" width="600" height="400" loading="lazy" alt="${escapeHtml(recipe.title)}"><div class="recipe-photo-top"><span class="recipe-tag">${escapeHtml(recipe.category)}</span>${recipe.premium ? `<span class="recipe-tag premium">${icon("spark")} PREMIUM</span>` : `<span class="recipe-tag">FREE</span>`}</div><span class="recipe-photo-time">${icon("clock")} ${recipe.minutes} Minuten</span></div><div class="recipe-card-copy"><h3>${escapeHtml(recipe.title)}</h3><div class="recipe-stats"><span><b>${number(recipe.kcal)}</b> kcal</span><span><b>${number(recipe.protein, 1)} g</b> Protein</span><span>pro Portion</span></div><span class="recipe-open-label">Zutaten &amp; Zubereitung ${icon("arrow-up")}</span></div></button>`;
  }
  function renderRecipes(filter = "all") {
    const selected = recipes.filter((recipe) => filter === "all" || filter === "quick" && recipe.minutes <= 15 || recipe.category === filter);
    gallery.innerHTML = selected.map(recipeCard).join("");
    document.querySelector("#recipe-count").textContent = `${selected.length} Rezeptideen`;
    gallery.querySelectorAll("[data-recipe]").forEach((button) => button.addEventListener("click", () => showRecipe(button.dataset.recipe)));
    attachImageFallbacks(gallery);
  }
  const filters = [...document.querySelectorAll("[data-filter]")];
  filters.forEach((button) => button.addEventListener("click", () => {
    filters.forEach((item) => { item.classList.toggle("is-active", item === button); item.setAttribute("aria-pressed", String(item === button)); });
    renderRecipes(button.dataset.filter);
  }));

  const dialogs = [...document.querySelectorAll("dialog")];
  function openDialog(dialog) { dialog.showModal(); document.body.classList.add("modal-open"); }
  function closeDialog(dialog) { dialog.close(); document.body.classList.remove("modal-open"); }
  dialogs.forEach((dialog) => {
    dialog.querySelectorAll(".dialog-close,.dialog-done").forEach((button) => button.addEventListener("click", () => closeDialog(dialog)));
    dialog.addEventListener("close", () => { if (!dialogs.some((item) => item.open)) document.body.classList.remove("modal-open"); });
    dialog.addEventListener("click", (event) => {
      if (event.target !== dialog) return;
      const bounds = dialog.getBoundingClientRect();
      if (event.clientX < bounds.left || event.clientX > bounds.right || event.clientY < bounds.top || event.clientY > bounds.bottom) closeDialog(dialog);
    });
  });
  function showRecipe(id) {
    const recipe = recipes.find((item) => item.id === id);
    if (!recipe) return;
    const body = document.querySelector("#recipe-dialog-body");
    body.innerHTML = `<div class="recipe-detail-header"><img class="recipe-detail-photo" src="${escapeHtml(recipe.image)}" width="500" height="400" alt="${escapeHtml(recipe.title)}"><div class="recipe-detail-intro"><span class="eyebrow">EINE REZEPTIDEE AUS LOOKIN</span><h2 id="recipe-dialog-title">${escapeHtml(recipe.title)}</h2><p>${escapeHtml(recipe.description)}</p><div class="recipe-detail-meta"><span>${icon("clock")} ${recipe.minutes} Minuten</span><span>${recipe.premium ? "Premium-Rezept" : "Free-Rezept"}</span></div></div></div><div class="recipe-detail-stats"><div><b>${number(recipe.kcal)}</b><span>kcal / Portion</span></div><div><b>${number(recipe.protein, 1)} g</b><span>Protein</span></div><div><b>${number(recipe.carbs, 1)} g</b><span>Kohlenhydrate</span></div><div><b>${number(recipe.fat, 1)} g</b><span>Fett</span></div></div><div class="recipe-detail-columns"><div><h3>Das kommt rein.<small>Zutaten für ${recipe.servings} ${recipe.servings === 1 ? "Portion" : "Portionen"}</small></h3><ul class="ingredients-list">${recipe.ingredients.map((item) => `<li><span>${escapeHtml(item.label)}</span><span>${escapeHtml(item.amount)}</span></li>`).join("")}</ul></div><div><h3>So wird's gemacht.</h3><ol class="recipe-steps">${recipe.steps.map((step) => `<li>${escapeHtml(step)}</li>`).join("")}</ol></div></div><div class="recipe-detail-footer"><p>Rezeptvorschau aus dem App-Katalog. Nährwerte sind Richtwerte pro Portion. In der App kannst du Portionen anpassen und das Gericht ins Tagebuch übernehmen.</p><a class="button recipe-explore" href="#download">Lookin entdecken ${icon("arrow")}</a></div>`;
    attachImageFallbacks(body);
    body.querySelector(".recipe-explore").addEventListener("click", () => closeDialog(document.querySelector("#recipe-dialog")));
    openDialog(document.querySelector("#recipe-dialog"));
    document.querySelector("#recipe-dialog").scrollTop = 0;
  }
  document.querySelectorAll("[data-store]").forEach((button) => button.addEventListener("click", () => {
    document.querySelector("#selected-store").textContent = button.dataset.store;
    openDialog(document.querySelector("#store-dialog"));
  }));

  const coachExamples = {
    breakfast: { question: "Ein schnelles Frühstück mit Haferflocken?", paragraphs: ["Wie wäre es mit <strong>Protein-Beeren-Oats</strong>?", "Haferflocken kurz mit Wasser quellen lassen, Skyr unterrühren und Beeren darauf. Das Rezept ist in 8 Minuten zubereitet."], title: "Protein-Beeren-Oats", image: "assets/berry-oats.webp" },
    snack: { question: "Eine schnelle vegetarische Snack-Idee?", paragraphs: ["Eine <strong>Skyr-Beeren-Bowl</strong> ist in 5 Minuten fertig.", "Skyr mit frischen oder aufgetauten Beeren in eine Schüssel geben. Die Zutaten und Mengen findest du in der Rezeptvorschau — und passt sie in der App selbst an."], title: "Skyr-Beeren-Bowl", image: "assets/skyr-bowl.webp" },
    dinner: { question: "Was könnte ich mit Reis kochen?", paragraphs: ["Reis passt gut zu einem <strong>Rote-Linsen-Dal</strong>.", "Linsen mit Gewürzen und Tomaten köcheln lassen und mit Reis servieren. Schau im Rezept nach den weiteren Zutaten und den einzelnen Schritten."], title: "Rote-Linsen-Dal mit Reis", image: "assets/lentil-dal.webp" },
  };
  document.querySelectorAll("[data-coach]").forEach((button) => button.addEventListener("click", () => {
    const sample = coachExamples[button.dataset.coach];
    document.querySelector("#coach-question").textContent = sample.question;
    document.querySelector("#coach-answer").innerHTML = `${sample.paragraphs.map((paragraph) => `<p>${paragraph}</p>`).join("")}<span class="answer-recipe"><img src="${sample.image}" width="54" height="54" alt="${sample.title}"><span><b>${sample.title}</b><small>Rezeptidee aus Lookin</small></span></span>`;
    document.querySelectorAll("[data-coach]").forEach((item) => { item.classList.toggle("is-active", item === button); item.setAttribute("aria-pressed", String(item === button)); });
    attachImageFallbacks(document.querySelector("#coach-answer"));
    document.querySelectorAll("#coach-answer>*").forEach((element) => animateContent(element));
  }));

  document.querySelectorAll("[data-billing]").forEach((button) => button.addEventListener("click", () => {
    const yearly = button.dataset.billing === "yearly";
    document.querySelector("#premium-equivalent").textContent = yearly ? "4,17" : "6,99";
    document.querySelector("#premium-billing").textContent = yearly ? "49,99 € einmal jährlich · entspricht 4,17 €/Monat" : "6,99 € jeden Monat · monatliche Abrechnung";
    document.querySelector("#savings-copy").textContent = yearly ? "Mit dem Jahresplan sparst du 33,89 € gegenüber zwölf Monatszahlungen." : "Zwölf Monatszahlungen kosten 83,88 €. Der Jahresplan kostet 49,99 €.";
    document.querySelectorAll("[data-billing]").forEach((item) => { item.classList.toggle("is-active", item === button); item.setAttribute("aria-pressed", String(item === button)); });
    animateContent(document.querySelector(".premium-card .plan-price"));
  }));

  document.querySelectorAll("[data-faq-filter]").forEach((button) => button.addEventListener("click", () => {
    document.querySelectorAll(".faq-list details").forEach((detail) => { detail.hidden = button.dataset.faqFilter !== "all" && detail.dataset.faq !== button.dataset.faqFilter; });
    document.querySelectorAll("[data-faq-filter]").forEach((item) => { item.classList.toggle("is-active", item === button); item.setAttribute("aria-pressed", String(item === button)); });
    animateContent(document.querySelector(".faq-list"));
  }));

  function attachImageFallbacks(container) {
    container.querySelectorAll("img").forEach((image) => {
      if (image.dataset.watched) return;
      image.dataset.watched = "true";
      function fallback() {
        if (image.dataset.fallback || image.getAttribute("src").includes("lookin-icon")) return;
        image.dataset.fallback = "true";
        image.src = "assets/lookin-icon.png";
        image.classList.add("image-fallback");
        image.alt = "Lookin – Bildvorschau nicht verfügbar";
      }
      image.addEventListener("error", fallback);
      if (image.complete && image.naturalWidth === 0) fallback();
    });
  }
  renderRecipes();
  attachImageFallbacks(document);
  document.querySelector("#copyright-year").textContent = String(new Date().getFullYear());
})();
