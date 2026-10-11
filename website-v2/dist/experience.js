(() => {
  'use strict';

  const modes = [
    { id: 'photo', title: 'Mit einem Foto starten', short: 'Foto', detail: 'Essen fotografieren. Vorschlag prüfen. Mengen bestätigen.', icon: 'camera', step: '01' },
    { id: 'barcode', title: 'Produkte kennenlernen', short: 'Barcode', detail: 'Ein Produkt finden und seine Nährwerte im Blick behalten.', icon: 'barcode', step: '02' },
    { id: 'recipes', title: 'Neue Ideen entdecken', short: 'Rezepte', detail: 'Zutaten auswählen und Inspiration zum Kochen finden.', icon: 'recipe', step: '03' },
    { id: 'calendar', title: 'Deinen Alltag verstehen', short: 'Tagebuch', detail: 'Einträge, Kalender und Makros an einem Ort entdecken.', icon: 'calendar', step: '04' },
  ];

  const paths = {
    camera: '<rect x="3" y="6" width="18" height="15" rx="4"/><path d="m8 6 1.5-3h5L16 6"/><circle cx="12" cy="13.5" r="4"/>',
    barcode: '<path d="M4 8V4h4M16 4h4v4M20 16v4h-4M8 20H4v-4M7 8v8M10 8v8M13 8v8M17 8v8"/>',
    recipe: '<path d="M8 3c-2.5 0-4 1.4-4 3.3C4 8 5.3 9 7 9h10c1.7 0 3-1 3-2.7C20 4.4 18.5 3 16 3c-1.3-2-6.7-2-8 0Z"/><path d="M7 9v11h10V9M8 17h8"/>',
    calendar: '<rect x="3" y="5" width="18" height="16" rx="3"/><path d="M7 3v4M17 3v4M3 10h18M8 14h1M15 14h1M8 18h1"/>',
    arrow: '<path d="M5 12h14m-6-6 6 6-6 6"/>',
    check: '<path d="m5 12 4 4L19 6"/>',
    sparkle: '<path d="m12 3 2.5 6.5L21 12l-6.5 2.5L12 21l-2.5-6.5L3 12l6.5-2.5Z"/>',
    lock: '<rect x="5" y="10" width="14" height="11" rx="3"/><path d="M8 10V7a4 4 0 0 1 8 0v3M12 14v3"/>',
    bowl: '<path d="M3 11h18c0 6-4 10-9 10S3 17 3 11ZM8 3v4M12 2v5M16 3v4"/>',
  };
  const icon = (name, className = '') => `<svg class="exp-icon ${className}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${paths[name] || paths.arrow}</svg>`;

  const recipes = [
    // Recipe facts and preparation text mirror the app's curated recipe content.
    { id: 'curry', name: 'Kichererbsen-Tomaten-Curry', image: 'chickpea-curry.webp', time: '30 Min.', servings: 3, type: 'Pflanzlich', ingredients: ['Kichererbsen', 'Dosentomaten', 'Zwiebeln', 'Knoblauch', 'Rapsöl', 'Currypulver', 'Kreuzkümmel', 'Zitronensaft', 'Salz'], subtitle: 'Würziges Curry aus Kichererbsen und Dosentomaten, fertig in 30 Minuten.', prep: ['Das Öl im Topf erhitzen und die Zwiebeln bei mittlerer Hitze 6 Minuten goldgelb braten.', 'Knoblauch, Currypulver und Kreuzkümmel zugeben und 1 Minute unter Rühren rösten, bis es duftet.', 'Dosentomaten, Kichererbsen und 150 ml Wasser zugeben und 15 Minuten offen köcheln lassen. Einige Kichererbsen mit dem Löffel zerdrücken. Mit Zitronensaft und Salz abschmecken und servieren.'] },
    { id: 'berries', name: 'Protein-Beeren-Oats', image: 'berry-oats.webp', time: '8 Min.', servings: 1, type: 'Frühstück', ingredients: ['Hafer', 'Skyr', 'Beeren'], subtitle: 'Cremiges Frühstück aus Haferflocken, Skyr und Beeren – ganz ohne Kochen.', prep: ['Die Haferflocken mit 4 EL Wasser in einer Schüssel verrühren und 3 Minuten quellen lassen.', 'Den Skyr dazugeben und alles glatt rühren, bis eine cremige Masse entsteht.', 'Die Beeren darauf verteilen und die Oats sofort servieren.'] },
    { id: 'apple', name: 'Apfel-Zimt-Porridge', image: 'apple-oats.webp', time: '12 Min.', servings: 1, type: 'Frühstück', ingredients: ['Hafer', 'Milch', 'Apfel', 'Zimt', 'Honig', 'Salz'], subtitle: 'Warmer Haferbrei mit Milch, gebratenen Apfelwürfeln und Zimt.', prep: ['Haferflocken, Milch und Salz in einem Topf aufkochen und bei niedriger Hitze unter Rühren 5 Minuten köcheln lassen.', 'Den Apfel würfeln und in einer kleinen Pfanne mit 2 EL Wasser, Honig und Zimt 4 Minuten weich dünsten.', 'Das Porridge in eine Schale füllen und die warmen Zimtäpfel darauf verteilen.'] },
  ];
  const pantry = ['Kichererbsen', 'Dosentomaten', 'Zwiebeln', 'Hafer', 'Beeren', 'Skyr', 'Apfel', 'Milch'];
  const ingredientLabels = { Hafer: 'Haferflocken', Skyr: 'Skyr natur', Beeren: 'Beeren-Mix', Dosentomaten: 'Dosentomaten, gehackt', Zimt: 'Zimt, gemahlen', Kreuzkümmel: 'Kreuzkümmel, gemahlen' };
  const ingredientLabel = (ingredient) => ingredientLabels[ingredient] || ingredient;
  const days = [
    { name: 'Mo', full: 'Montag', date: '12', count: 3, distribution: [45, 22, 33] },
    { name: 'Di', full: 'Dienstag', date: '13', count: 4, distribution: [48, 23, 29] },
    { name: 'Mi', full: 'Mittwoch', date: '14', count: 3, distribution: [44, 26, 30] },
    { name: 'Do', full: 'Donnerstag', date: '15', count: 3, distribution: [46, 24, 30] },
    { name: 'Fr', full: 'Freitag', date: '16', count: 4, distribution: [42, 27, 31] },
    { name: 'Sa', full: 'Samstag', date: '17', count: 2, distribution: [49, 21, 30] },
    { name: 'So', full: 'Sonntag', date: '18', count: 4, distribution: [47, 25, 28] },
  ];

  function mount() {
    const host = document.getElementById('experience-demo');
    if (!host || host.dataset.expMounted) return;
    host.dataset.expMounted = 'true';
    const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
    const state = { mode: 'photo', scan: null, photo: 'idle', barcode: 'idle', ingredients: new Set(['Kichererbsen', 'Dosentomaten', 'Zwiebeln']), recipe: 'curry', preparation: false, day: 2, view: 'entries' };
    let visible = !('IntersectionObserver' in window);
    let motionPaused = document.documentElement.classList.contains('motion-paused');
    let frame = 0;
    let lastTime = 0;

    host.innerHTML = `<div class="exp-layout">
      <div class="exp-navigation">
        <p class="exp-nav-kicker">Eine App. Viele kleine Erleichterungen.</p>
        <div class="exp-tabs" role="tablist" aria-label="Produktführung" aria-orientation="vertical">
          ${modes.map((mode, index) => `<button class="exp-tab${index === 0 ? ' exp-selected' : ''}" type="button" role="tab" id="exp-tab-${mode.id}" aria-controls="exp-panel" aria-selected="${index === 0}" tabindex="${index === 0 ? 0 : -1}" data-exp-mode="${mode.id}"><span class="exp-tab-top"><span class="exp-tab-icon">${icon(mode.icon)}</span><span class="exp-tab-number">${mode.step}</span></span><span class="exp-tab-title">${mode.title}</span><span class="exp-tab-description">${mode.detail}</span><span class="exp-tab-arrow">${icon('arrow')}</span></button>`).join('')}
        </div>
        <div class="exp-nav-note">${icon('lock')}<span>Du kannst alles ausprobieren.<br>Hier werden keine Daten gespeichert.</span></div>
      </div>
      <div class="exp-canvas">
        <div class="exp-demo-label"><span class="exp-demo-dot"></span>Interaktive Produktvorschau<span class="exp-demo-tag">Beispieldaten</span></div>
        <div id="exp-panel" class="exp-panel" role="tabpanel" aria-labelledby="exp-tab-photo" tabindex="0"></div>
        <div class="exp-footnote"><span>${icon('sparkle')}Entdecke den Ablauf, bevor du loslegst.</span><p>Illustrative Demo. Kein echter Scan, keine KI-Anfrage und keine Speicherung.</p></div>
      </div>
    </div><div class="exp-sr-only" role="status" aria-live="polite" id="exp-announcement"></div>`;

    const panel = host.querySelector('#exp-panel');
    const announce = (message) => { host.querySelector('#exp-announcement').textContent = message; };
    const phoneTop = (title, subtitle) => `<div class="exp-phone-top"><div class="exp-phone-brand"><img src="assets/lookin-icon.png" width="25" height="25" alt=""/><span>Lookin</span></div><span class="exp-phone-example">Vorschau</span></div><div class="exp-phone-heading"><strong>${title}</strong><span>${subtitle}</span></div>`;
    const heading = (step, title, text) => `<div class="exp-pane-heading"><span class="exp-pane-index">${step}</span><div><h3>${title}</h3><p>${text}</p></div></div>`;
    const steps = (labels, active) => `<ol class="exp-steps" aria-label="Ablauf">${labels.map((label, index) => `<li class="${index <= active ? 'exp-step-active' : ''}"><span>${index < active ? icon('check') : index + 1}</span>${label}</li>`).join('')}</ol>`;

    function photoMarkup() {
      const scanning = state.photo === 'scanning';
      const ready = state.photo === 'ready' || state.photo === 'confirmed';
      const confirmed = state.photo === 'confirmed';
      return `<div class="exp-pane exp-photo-pane">${heading('01', 'Dein Essen. Ein guter Anfang.', 'Ein Foto kann den Einstieg erleichtern. Die vorgeschlagenen Zutaten und Mengen bleiben prüfbar.')}
        ${steps(['Foto wählen', 'Vorschlag prüfen', 'Bewusst bestätigen'], confirmed ? 2 : ready ? 1 : 0)}
        <div class="exp-photo-content">
          <div class="exp-photo-visual">
            <div class="exp-photo-image${scanning ? ' exp-scanning' : ''}"><img src="assets/avocado-bowl.webp" alt="Beispiel einer Schüssel mit Avocado, Ei und Gemüse" loading="lazy"/><div class="exp-image-shade"></div><span class="exp-image-label">${icon('camera')}Dein Foto als Ausgangspunkt</span><span class="exp-viewfinder exp-viewfinder-tl"></span><span class="exp-viewfinder exp-viewfinder-tr"></span><span class="exp-viewfinder exp-viewfinder-bl"></span><span class="exp-viewfinder exp-viewfinder-br"></span>${scanning ? '<div class="exp-scan-light"></div><div class="exp-scan-message"><span class="exp-small-spinner"></span>Beispiel wird vorbereitet…</div>' : ready ? `<div class="exp-photo-result">${icon('check')}Vorschlag bereit</div>` : '<div class="exp-photo-caption"><span>FOTO → VORSCHLAG</span><strong>Weniger tippen.<br>Mehr Überblick.</strong></div>'}</div>
            <p class="exp-visual-note">Eine Fotoanalyse kann sich irren. Prüfe Lebensmittel, Zutaten und Mengen, bevor du einen Eintrag übernimmst.</p>
          </div>
          <div class="exp-phone">${phoneTop('Deine Mahlzeit', ready ? 'Vorschlag · Schätzung' : 'Fotoerfassung · Beispielszenario')}
            <div class="exp-meal-preview"><img src="assets/avocado-bowl.webp" alt="" loading="lazy"/><div><strong>Avocado-Ei-Bowl</strong><span>1 Beispielportion</span></div><span class="exp-meal-badge">${icon(ready ? 'check' : 'bowl')}</span></div>
            ${ready ? `<div class="exp-ingredient-list"><div><span>Avocado</span><strong>½ Stück</strong></div><div><span>Ei</span><strong>1 Stück</strong></div><div><span>Gemüse & Beilage</span><strong>1 Portion</strong></div></div><div class="exp-macros"><div><strong>420</strong><span>kcal</span></div><div><strong>18 g</strong><span>Eiweiß</span></div><div><strong>35 g</strong><span>Kohlenh.</span></div></div><p class="exp-phone-disclaimer">Illustrative Schätzung · keine Messung</p><button class="exp-action${confirmed ? ' exp-action-done' : ''}" type="button" data-exp-action="photo-confirm" data-exp-key="photo-confirm" ${confirmed ? 'disabled' : ''}>${icon(confirmed ? 'check' : 'arrow')}${confirmed ? 'In der Demo bestätigt' : 'Beispiel bestätigen'}</button>${confirmed ? '<p class="exp-confirm-message">Nur gezeigt, nicht gespeichert.</p>' : '<span class="exp-action-hint">In der App: erst prüfen und korrigieren.</span>'}` : `<div class="exp-placeholder-lines"><span></span><span></span><span></span></div><div class="exp-waiting-copy"><strong>${scanning ? 'Ein Moment für dein Beispiel.' : 'Schau dir den Ablauf an.'}</strong><p>${scanning ? 'Die Demo zeigt gleich einen prüfbaren Vorschlag.' : 'Der nächste Schritt zeigt, wie ein Foto-Vorschlag aussehen kann.'}</p></div><button class="exp-action" type="button" data-exp-action="photo-scan" data-exp-key="photo-scan" ${scanning ? 'disabled' : ''}>${icon(scanning ? 'sparkle' : 'camera')}${scanning ? 'Beispiel wird vorbereitet' : 'Foto-Demo starten'}</button>`}
          </div>
        </div>
      </div>`;
    }

    function barcodeMarkup() {
      const scanning = state.barcode === 'scanning';
      const ready = state.barcode === 'ready';
      return `<div class="exp-pane exp-barcode-pane">${heading('02', 'Eine Packung. Mehr Klarheit.', 'Über den Barcode führt der Weg zum Produkt. Nährwerte lassen sich anschließend mit der Verpackung abgleichen.')}
        ${steps(['Barcode erfassen', 'Produkt abgleichen', 'Portion auswählen'], ready ? 1 : 0)}
        <div class="exp-barcode-content"><div class="exp-package-stage${scanning ? ' exp-scanning' : ''}"><span class="exp-stage-label">Ein Beispielszenario</span><div class="exp-oat-package"><span class="exp-package-top">100 % BEISPIEL</span><div class="exp-package-word">HA<span>FER.</span></div><span class="exp-package-detail">Zarte Flocken<br>Demo-Packung · 500 g</span><span class="exp-package-emblem">${icon('bowl')}</span><div class="exp-barcode-lines" aria-hidden="true">${Array.from({ length: 31 }, (_, index) => `<i style="--exp-bar-width:${[1, 2, 1, 3, 1, 2, 3][index % 7]}px"></i>`).join('')}</div><span class="exp-package-code">BEISPIEL · KEIN ECHTER CODE</span></div><div class="exp-scanner-frame"><i></i><i></i><i></i><i></i>${scanning ? '<span class="exp-barcode-scan-light"></span>' : ''}</div><span class="exp-barcode-stage-bottom">${icon(ready ? 'check' : 'barcode')}${ready ? 'Demo-Produkt gefunden' : scanning ? 'Beispielsuche wird gezeigt…' : 'Kein Kamerazugriff erforderlich'}</span></div>
          <div class="exp-product-card"><div class="exp-card-eyebrow">${icon('barcode')}Produktdetails</div><h4>${ready ? 'Haferflocken' : 'Was steckt drin?'}</h4><p class="exp-product-summary">${ready ? 'Ein bewusst einfaches Demoprodukt. Die Werte dienen nur dazu, die Produktansicht zu zeigen.' : 'Starte die Führung und entdecke eine Beispielansicht mit Nährwerten, Zutaten und Portionsauswahl.'}</p>${ready ? `<div class="exp-product-verified">${icon('check')}Demoprodukt · kein Datenbankergebnis</div><div class="exp-nutrition-table"><div><span>Nährwert</span><span>pro 100 g · Beispiel</span></div><div><span>Energie</span><strong>370 kcal</strong></div><div><span>Eiweiß</span><strong>13 g</strong></div><div><span>Kohlenhydrate</span><strong>60 g</strong></div><div><span>Fett</span><strong>7 g</strong></div></div><div class="exp-product-ingredients"><span>Zutaten im Beispiel</span><strong>Haferflocken</strong><p>Bei echten Produkten bleiben Verpackung und aktuelle Zutatenliste maßgeblich.</p></div><button class="exp-secondary-action" type="button" data-exp-action="barcode-reset" data-exp-key="barcode-reset">Führung erneut ansehen${icon('arrow')}</button>` : `<div class="exp-barcode-benefits"><div><span>01</span><p><strong>Produkt erkennen</strong>Eine Suche führt zur passenden Produktansicht.</p></div><div><span>02</span><p><strong>Angaben vergleichen</strong>Prüfe Zutaten und Nährwerte auf der Verpackung.</p></div><div><span>03</span><p><strong>Portion bestimmen</strong>Die tatsächlich gegessene Menge zählt.</p></div></div><button class="exp-action" type="button" data-exp-action="barcode-scan" data-exp-key="barcode-scan" ${scanning ? 'disabled' : ''}>${icon(scanning ? 'sparkle' : 'barcode')}${scanning ? 'Beispiel wird vorbereitet' : 'Barcode-Demo starten'}</button>`}</div>
        </div>
      </div>`;
    }

    function recipesMarkup() {
      const recipe = recipes.find((item) => item.id === state.recipe);
      return `<div class="exp-pane exp-recipes-pane">${heading('03', 'Was könntest du heute kochen?', 'Entdecke Ideen mit Zutaten, die du magst. Die Auswahl hier zeigt das Prinzip und wird nicht gespeichert.')}
        <div class="exp-recipes-content"><div class="exp-recipe-discovery"><div class="exp-card-eyebrow">${icon('recipe')}Wähle ein paar Zutaten</div><div class="exp-pantry-chips" aria-label="Beispielzutaten auswählen">${pantry.map((ingredient, index) => `<button type="button" class="exp-pantry-chip${state.ingredients.has(ingredient) ? ' exp-chip-selected' : ''}" aria-pressed="${state.ingredients.has(ingredient)}" data-exp-action="ingredient" data-exp-ingredient="${ingredient}" data-exp-key="ingredient-${index}">${state.ingredients.has(ingredient) ? icon('check') : '<span class="exp-chip-plus" aria-hidden="true">+</span>'}${ingredientLabel(ingredient)}</button>`).join('')}</div><div class="exp-recipe-list-heading"><strong>Drei Ideen zum Entdecken</strong><span>Illustrative Auswahl</span></div><div class="exp-recipe-list">${recipes.map((item) => `<button type="button" class="exp-recipe-mini${state.recipe === item.id ? ' exp-recipe-selected' : ''}" aria-pressed="${state.recipe === item.id}" data-exp-action="recipe" data-exp-recipe="${item.id}" data-exp-key="recipe-${item.id}"><img src="assets/${item.image}" alt="" loading="lazy"/><span><strong>${item.name}</strong><small>${item.time} · ${item.type}</small><em>${item.ingredients.filter((ingredient) => state.ingredients.has(ingredient)).length} von ${item.ingredients.length} Beispielzutaten ausgewählt</em></span>${icon('arrow')}</button>`).join('')}</div><p class="exp-discovery-note">Rezepte entdecken statt jeden Tag neu überlegen. Ein Teil der Rezepte ist frei zugänglich, der vollständige Rezeptzugang gehört zu Premium.</p></div>
          <article class="exp-recipe-detail"><div class="exp-recipe-hero"><img src="assets/${recipe.image}" alt="${recipe.name} als Rezeptbeispiel" loading="lazy"/><span class="exp-recipe-type">${recipe.type}</span><span class="exp-recipe-photo-note">Rezeptbeispiel</span></div><div class="exp-recipe-detail-body"><div class="exp-recipe-meta"><span>${recipe.time}</span><span>${recipe.servings} ${recipe.servings === 1 ? 'Portion' : 'Portionen'}</span></div><h4>${recipe.name}</h4>${state.preparation ? `<ol class="exp-preparation">${recipe.prep.map((step, index) => `<li><span>${index + 1}</span>${step}</li>`).join('')}</ol>` : `<p>${recipe.subtitle}</p><div class="exp-recipe-match"><span>Mit deiner Auswahl</span><div>${recipe.ingredients.map((ingredient) => `<span class="exp-match-ingredient${state.ingredients.has(ingredient) ? ' exp-match-found' : ''}">${state.ingredients.has(ingredient) ? icon('check') : ''}${ingredientLabel(ingredient)}</span>`).join('')}</div></div>`}<button type="button" class="exp-secondary-action" data-exp-action="preparation" data-exp-key="preparation">${state.preparation ? 'Zur Rezeptübersicht' : 'Zubereitung ansehen'}${icon('arrow')}</button></div></article>
        </div>
      </div>`;
    }

    function calendarMarkup() {
      const day = days[state.day];
      const [carbs, protein, fat] = day.distribution;
      return `<div class="exp-pane exp-calendar-pane">${heading('04', 'Kleine Einträge. Ein klareres Bild.', 'Im Tagebuch kannst du einzelne Tage wiederfinden und die Zusammensetzung deiner erfassten Mahlzeiten ansehen.')}
        <div class="exp-calendar-content"><div class="exp-calendar-main"><div class="exp-calendar-header"><div><span class="exp-card-eyebrow">Dein Tagebuch</span><h4>Eine Woche im Blick</h4></div><span class="exp-calendar-period">12. – 18. · Beispiel</span></div><div class="exp-calendar-days" aria-label="Beispieltag auswählen">${days.map((item, index) => `<button type="button" class="exp-day${state.day === index ? ' exp-day-selected' : ''}" aria-pressed="${state.day === index}" aria-label="${item.full}, ${item.date}., ${item.count} Beispieleinträge" data-exp-action="day" data-exp-day="${index}" data-exp-key="day-${index}"><span>${item.name}</span><strong>${item.date}</strong><i aria-hidden="true"></i></button>`).join('')}</div><div class="exp-chart-switch" aria-label="Ansicht wählen"><button type="button" class="${state.view === 'entries' ? 'exp-view-selected' : ''}" aria-pressed="${state.view === 'entries'}" data-exp-action="view" data-exp-view="entries" data-exp-key="view-entries">Einträge</button><button type="button" class="${state.view === 'macros' ? 'exp-view-selected' : ''}" aria-pressed="${state.view === 'macros'}" data-exp-action="view" data-exp-view="macros" data-exp-key="view-macros">Makroübersicht</button></div>${state.view === 'entries' ? `<div class="exp-chart-caption"><strong>23</strong><span>erfasste Mahlzeiten<br>in dieser Beispielwoche</span></div><div class="exp-bars" aria-label="Beispieleinträge: Montag 3, Dienstag 4, Mittwoch 3, Donnerstag 3, Freitag 4, Samstag 2, Sonntag 4">${days.map((item, index) => `<div class="exp-bar-column${state.day === index ? ' exp-bar-selected' : ''}"><span>${item.count}</span><div class="exp-bar-track"><i style="--exp-bar-height:${item.count * 22}%;--exp-delay:${index * 60}ms"></i></div><small>${item.name}</small></div>`).join('')}</div>` : `<div class="exp-macro-overview"><div class="exp-macro-ring" style="--exp-carb-end:${carbs}%;--exp-protein-end:${carbs + protein}%"><div><strong>${day.name}</strong><span>Beispiel</span></div></div><div class="exp-macro-legend"><div><span class="exp-legend-dot exp-legend-carb"></span><span>Kohlenhydrate</span><strong>${carbs} %</strong></div><div><span class="exp-legend-dot exp-legend-protein"></span><span>Eiweiß</span><strong>${protein} %</strong></div><div><span class="exp-legend-dot exp-legend-fat"></span><span>Fett</span><strong>${fat} %</strong></div><p>Beispielhafte Energieverteilung. Keine Ernährungsempfehlung.</p></div></div>`}<div class="exp-tracking-note">${icon('calendar')}<div><strong>7 Tage mit Beispieleinträgen</strong><span>Eine Serie zeigt Regelmäßigkeit. Sie bewertet weder dich noch dein Essen.</span></div></div></div>
          <div class="exp-day-detail"><div class="exp-card-eyebrow">${icon('bowl')}Deine Beispieleinträge</div><h4>${day.full}</h4><p>${day.count} Mahlzeiten im Beispiel</p><div class="exp-day-meals"><div><img src="assets/berry-oats.webp" alt="" loading="lazy"/><span><small>Frühstück</small><strong>Protein-Beeren-Oats</strong><em>Eine Beispielportion</em></span>${icon('check')}</div><div><img src="assets/avocado-bowl.webp" alt="" loading="lazy"/><span><small>Mittagessen</small><strong>Avocado-Ei-Bowl</strong><em>Eine Beispielportion</em></span>${icon('check')}</div>${day.count > 2 ? `<div><img src="assets/chickpea-curry.webp" alt="" loading="lazy"/><span><small>Abendessen</small><strong>Kichererbsen-Tomaten-Curry</strong><em>1 von 3 Rezeptportionen</em></span>${icon('check')}</div>` : ''}${day.count > 3 ? `<div><img src="assets/apple-oats.webp" alt="" loading="lazy"/><span><small>Zwischendurch</small><strong>Apfel-Zimt-Porridge</strong><em>Eine Beispielportion</em></span>${icon('check')}</div>` : ''}</div><div class="exp-day-insight"><span>Mehr als eine einzelne Zahl.</span><p>Ein Tagebuch hilft dir, deinen Alltag bewusster wahrzunehmen – Mahlzeit für Mahlzeit.</p></div></div>
        </div>
      </div>`;
    }

    const renderers = { photo: photoMarkup, barcode: barcodeMarkup, recipes: recipesMarkup, calendar: calendarMarkup };
    function render(preserveFocus = true) {
      const focusKey = preserveFocus && panel.contains(document.activeElement) ? document.activeElement.dataset.expKey : null;
      panel.innerHTML = renderers[state.mode]();
      panel.setAttribute('aria-labelledby', `exp-tab-${state.mode}`);
      host.querySelectorAll('[data-exp-mode]').forEach((tab) => {
        const selected = tab.dataset.expMode === state.mode;
        tab.classList.toggle('exp-selected', selected);
        tab.setAttribute('aria-selected', selected);
        tab.tabIndex = selected ? 0 : -1;
      });
      if (focusKey) {
        const target = panel.querySelector(`[data-exp-key="${focusKey}"]`);
        if (target && !target.disabled) target.focus({ preventScroll: true });
        else panel.focus({ preventScroll: true });
      }
    }

    function stopScan() {
      cancelAnimationFrame(frame);
      frame = 0;
      if (state.scan) state[state.scan.mode] = 'idle';
      state.scan = null;
      lastTime = 0;
    }

    function finishScan(mode) {
      cancelAnimationFrame(frame);
      frame = 0;
      state[mode] = 'ready';
      state.scan = null;
      lastTime = 0;
      render();
      announce(mode === 'photo' ? 'Der Foto-Beispielvorschlag ist bereit. Die Mengen und Werte sind illustrative Schätzungen.' : 'Das Barcode-Beispielprodukt wird angezeigt. Es wurde keine echte Produktsuche durchgeführt.');
    }

    function tick(time) {
      frame = 0;
      if (!state.scan || !visible || document.hidden) { lastTime = 0; return; }
      if (lastTime && visible && !document.hidden && !motionPaused) state.scan.elapsed += Math.min(time - lastTime, 80);
      lastTime = time;
      if (state.scan.elapsed >= state.scan.duration) { finishScan(state.scan.mode); return; }
      frame = requestAnimationFrame(tick);
    }

    function updateScanVisibility() {
      if (!visible || document.hidden) {
        cancelAnimationFrame(frame);
        frame = 0;
        lastTime = 0;
      } else if (state.scan && !frame) {
        lastTime = 0;
        frame = requestAnimationFrame(tick);
      }
    }

    function startScan(mode) {
      stopScan();
      if (motionPaused || reducedMotion.matches) { finishScan(mode); return; }
      state[mode] = 'scanning';
      state.scan = { mode, elapsed: 0, duration: 1850 };
      render();
      lastTime = 0;
      frame = requestAnimationFrame(tick);
    }

    function setMode(mode) {
      if (state.mode === mode) return;
      stopScan();
      state.mode = mode;
      render(false);
      announce(`${modes.find((item) => item.id === mode).short}-Produktführung ausgewählt.`);
    }

    host.addEventListener('click', (event) => {
      const tab = event.target.closest('[data-exp-mode]');
      if (tab) { setMode(tab.dataset.expMode); return; }
      const button = event.target.closest('[data-exp-action]');
      if (!button || button.disabled) return;
      switch (button.dataset.expAction) {
        case 'photo-scan': startScan('photo'); break;
        case 'photo-confirm': state.photo = 'confirmed'; render(); announce('Das Beispiel wurde in der Demo bestätigt. Es wurden keine Daten gespeichert.'); break;
        case 'barcode-scan': startScan('barcode'); break;
        case 'barcode-reset': state.barcode = 'idle'; render(); break;
        case 'ingredient': {
          const ingredient = button.dataset.expIngredient;
          state.ingredients.has(ingredient) ? state.ingredients.delete(ingredient) : state.ingredients.add(ingredient);
          render();
          break;
        }
        case 'recipe': state.recipe = button.dataset.expRecipe; state.preparation = false; render(); break;
        case 'preparation': state.preparation = !state.preparation; render(); break;
        case 'day': state.day = Number(button.dataset.expDay); render(); break;
        case 'view': state.view = button.dataset.expView; render(); break;
      }
    });

    host.querySelector('.exp-tabs').addEventListener('keydown', (event) => {
      const activeTab = event.target.closest('[data-exp-mode]');
      if (!activeTab) return;
      const index = modes.findIndex((mode) => mode.id === activeTab.dataset.expMode);
      let nextIndex = index;
      if (event.key === 'ArrowDown' || event.key === 'ArrowRight') nextIndex = (index + 1) % modes.length;
      else if (event.key === 'ArrowUp' || event.key === 'ArrowLeft') nextIndex = (index - 1 + modes.length) % modes.length;
      else if (event.key === 'Home') nextIndex = 0;
      else if (event.key === 'End') nextIndex = modes.length - 1;
      else return;
      event.preventDefault();
      setMode(modes[nextIndex].id);
      host.querySelector(`[data-exp-mode="${modes[nextIndex].id}"]`).focus({ preventScroll: true });
    });

    if ('IntersectionObserver' in window) {
      const observer = new IntersectionObserver((entries) => {
        visible = entries[0].isIntersecting;
        host.classList.toggle('exp-in-view', visible);
        updateScanVisibility();
      }, { threshold: 0.05 });
      observer.observe(host);
    } else host.classList.add('exp-in-view');
    document.addEventListener('visibilitychange', () => {
      host.classList.toggle('exp-document-hidden', document.hidden);
      updateScanVisibility();
    });
    window.addEventListener('lookin:motion', (event) => {
      motionPaused = Boolean(event.detail?.paused);
      if (motionPaused && state.scan) finishScan(state.scan.mode);
    });
    reducedMotion.addEventListener?.('change', () => {
      if (reducedMotion.matches && state.scan) finishScan(state.scan.mode);
    });
    render(false);
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', mount, { once: true });
  else mount();
})();
