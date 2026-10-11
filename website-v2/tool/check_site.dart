import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'serve.dart';

class BrowserConnection {
  BrowserConnection(this.socket) {
    socket.listen((raw) {
      final message = jsonDecode(raw as String) as Map<String, dynamic>;
      final id = message['id'];
      if (id is int) {
        final pending = calls.remove(id);
        if (message.containsKey('error')) {
          pending?.completeError(StateError('${message['error']}'));
        } else {
          pending?.complete(
            (message['result'] as Map?)?.cast<String, dynamic>() ?? {},
          );
        }
      } else if (message['method'] == 'Runtime.exceptionThrown') {
        exceptions.add('${message['params']}');
      } else if (message['method'] == 'Network.requestWillBeSent') {
        requests.add(message['params']['request']['url'] as String);
      } else if (message['method'] == 'Page.loadEventFired') {
        pageLoads++;
      }
    });
  }

  final WebSocket socket;
  final calls = <int, Completer<Map<String, dynamic>>>{};
  final exceptions = <String>[];
  final requests = <String>[];
  int nextId = 0;
  int pageLoads = 0;

  Future<Map<String, dynamic>> send(
    String method, [
    Map<String, dynamic> params = const {},
  ]) {
    final id = ++nextId;
    final completer = Completer<Map<String, dynamic>>();
    calls[id] = completer;
    socket.add(jsonEncode({'id': id, 'method': method, 'params': params}));
    return completer.future.timeout(const Duration(seconds: 15));
  }

  Future<dynamic> evaluate(String expression) async {
    final result = await send('Runtime.evaluate', {
      'expression': expression,
      'returnByValue': true,
      'awaitPromise': true,
    });
    if (result['exceptionDetails'] != null) {
      throw StateError('${result['exceptionDetails']}');
    }
    return result['result']['value'];
  }

  Future<void> waitFor(String expression, {int seconds = 8}) async {
    final timer = Stopwatch()..start();
    while (timer.elapsed < Duration(seconds: seconds)) {
      if (await evaluate(expression) == true) return;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    throw StateError('Timed out waiting for: $expression');
  }

  Future<void> navigate(String url) async {
    final previousLoads = pageLoads;
    await send('Page.navigate', {'url': url});
    for (var count = 0; count < 80 && pageLoads == previousLoads; count++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    await waitFor(
      'location.href === ${jsonEncode(url)} && document.readyState === "complete" && '
      '!!document.querySelector(".hero") && '
      '!!document.querySelector("#experience-demo[data-exp-mounted=true] [data-exp-mode]") && '
      'document.querySelector("#recipe-grid").children.length > 0',
    );
    await evaluate('document.fonts.ready');
  }

  Future<void> setSize(int width, int height, {bool mobile = false}) async {
    await send('Emulation.setDeviceMetricsOverride', {
      'width': width,
      'height': height,
      'deviceScaleFactor': 1,
      'mobile': mobile,
    });
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  Future<void> motion(String value) async {
    await send('Emulation.setEmulatedMedia', {
      'features': [
        {'name': 'prefers-reduced-motion', 'value': value},
      ],
    });
  }

  Future<void> click(String selector) async {
    await evaluate('document.querySelector(${jsonEncode(selector)}).click()');
  }

  Future<void> tap(String selector) async {
    await evaluate(
      'document.querySelector(${jsonEncode(selector)}).scrollIntoView({block:"center",behavior:"instant"})',
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final point = await evaluate(
      '(() => {const r = document.querySelector(${jsonEncode(selector)}).getBoundingClientRect();return {x:r.left+r.width/2,y:r.top+r.height/2}})()',
    );
    await send('Input.dispatchMouseEvent', {
      'type': 'mousePressed',
      'x': point['x'],
      'y': point['y'],
      'button': 'left',
      'clickCount': 1,
    });
    await send('Input.dispatchMouseEvent', {
      'type': 'mouseReleased',
      'x': point['x'],
      'y': point['y'],
      'button': 'left',
      'clickCount': 1,
    });
  }

  Future<void> screenshot(File file, {bool full = false}) async {
    final params = <String, dynamic>{
      'format': 'png',
      'captureBeyondViewport': full,
    };
    if (full) {
      final size = await evaluate(
        '({width: innerWidth, height: document.documentElement.scrollHeight})',
      );
      params['clip'] = {
        'x': 0,
        'y': 0,
        'width': size['width'],
        'height': size['height'],
        'scale': 1,
      };
    }
    final result = await send('Page.captureScreenshot', params);
    await file.writeAsBytes(base64Decode(result['data'] as String));
  }
}

int passed = 0;

void expectTrue(bool success, String description) {
  if (!success) throw StateError(description);
  passed++;
  stdout.writeln('PASS ${passed.toString().padLeft(2, '0')} $description');
}

Future<void> assertJs(
  BrowserConnection browser,
  String expression,
  String description,
) async {
  expectTrue(await browser.evaluate(expression) == true, description);
}

Future<void> inspectFiles(HttpClient client, String baseUrl) async {
  final errors = <String>[];
  var fileCount = 0;
  var referenceCount = 0;
  for (final file in websiteRoot.listSync(recursive: true).whereType<File>()) {
    fileCount++;
    final relative = file.uri.path.substring(websiteRoot.uri.path.length);
    final response = await (await client.getUrl(
      Uri.parse(baseUrl).resolve(relative),
    )).close();
    if (response.statusCode != 200) {
      errors.add('HTTP ${response.statusCode}: $relative');
    }
    await response.drain<void>();
    if (!file.path.endsWith('.html') && !file.path.endsWith('.css')) continue;
    final source = await file.readAsString();
    final references = file.path.endsWith('.html')
        ? RegExp('(?:href|src)="([^"]+)"').allMatches(source)
        : RegExp(r'''url\(\s*["']?([^"')\s]+)''').allMatches(source);
    for (final reference in references) {
      final value = reference.group(1)!;
      if (value.startsWith('#') || Uri.parse(value).hasScheme) continue;
      referenceCount++;
      final local = File.fromUri(file.uri.resolve(value).replace(fragment: ''));
      if (!await local.exists()) errors.add('$relative -> $value');
    }
  }
  expectTrue(
    errors.isEmpty,
    '$fileCount local resources return HTTP 200; errors: $errors',
  );
  expectTrue(
    errors.isEmpty,
    '$referenceCount HTML/CSS references resolve locally',
  );
}

Future<void> loadImages(BrowserConnection browser) async {
  await browser.evaluate(
    'document.querySelectorAll("img").forEach(img => {img.loading = "eager"})',
  );
  await browser.waitFor(
    'Array.from(document.images).every(img => img.complete && img.naturalWidth > 0)',
  );
}

Future<void> checkInteractions(BrowserConnection browser) async {
  for (final tab in ['recipes', 'coach', 'diary']) {
    await browser.click('[data-hero-tab="$tab"]');
    await assertJs(browser, '''(() => {
        const tab = ${jsonEncode(tab)};
        return document.querySelector('[data-hero-tab="' + tab + '"]').getAttribute('aria-selected') === 'true'
          && [...document.querySelectorAll('[data-hero-panel]')].every(panel => panel.hidden === (panel.dataset.heroPanel !== tab));
      })()''', 'Hero preview switches to $tab');
  }
  await browser.evaluate(
    '''document.querySelector('[data-hero-tab="diary"]').dispatchEvent(new KeyboardEvent('keydown', {key: 'ArrowRight', bubbles: true}))''',
  );
  await assertJs(
    browser,
    'document.querySelector("[data-hero-tab=recipes]").getAttribute("aria-selected") === "true" && document.activeElement.dataset.heroTab === "recipes"',
    'Hero tabs support keyboard focus and selection',
  );
  await browser.click('[data-hero-tab="diary"]');
  await browser.evaluate(
    'document.querySelector(".hero-phone-tabs").scrollIntoView({block:"center",behavior:"instant"})',
  );
  await assertJs(
    browser,
    '''[...document.querySelectorAll('[data-hero-tab]')].every(tab => {
    const rect = tab.getBoundingClientRect();
    const hit = document.elementFromPoint(rect.x + rect.width / 2, rect.y + rect.height / 2);
    return hit && hit.closest('[data-hero-tab]') === tab;
  })''',
    'Hero preview tabs are physically clickable',
  );

  final initialMeal = await browser.evaluate(
    'document.getElementById("diary-meal-name").textContent',
  );
  await browser.click('[data-meal="lunch"]');
  await assertJs(
    browser,
    'document.getElementById("diary-meal-name").textContent !== ${jsonEncode(initialMeal)} && document.querySelector("[data-meal=lunch]").getAttribute("aria-selected") === "true"',
    'Diary lunch selection updates photograph, text and nutrition',
  );
  await browser.click('[data-meal="dinner"]');
  await assertJs(
    browser,
    'document.querySelector("[data-meal=dinner]").getAttribute("aria-selected") === "true"',
    'Diary dinner selection works',
  );
  await browser.click('[data-meal="breakfast"]');

  final allRecipeCount =
      await browser.evaluate(
            'document.getElementById("recipe-grid").children.length',
          )
          as int;
  expectTrue(
    allRecipeCount >= 6,
    'Recipe gallery contains at least six detailed recipes',
  );
  for (final filter in ['Frühstück', 'Hauptgerichte', 'quick']) {
    await browser.click('[data-filter="$filter"]');
    final filteredCount =
        await browser.evaluate(
              'document.getElementById("recipe-grid").children.length',
            )
            as int;
    expectTrue(
      filteredCount > 0 && filteredCount < allRecipeCount,
      'Recipe filter $filter limits the gallery',
    );
    await assertJs(
      browser,
      'document.querySelector(${jsonEncode('[data-filter="$filter"]')}).getAttribute("aria-pressed") === "true"',
      'Recipe filter $filter exposes its selected state',
    );
  }
  await browser.click('[data-filter="all"]');
  await browser.click('#recipe-grid button');
  await assertJs(
    browser,
    'document.getElementById("recipe-dialog").open && document.getElementById("recipe-dialog-body").textContent.includes("Haferflocken")',
    'Recipe dialog opens with original ingredients',
  );
  await assertJs(
    browser,
    'document.getElementById("recipe-dialog").contains(document.activeElement)',
    'Recipe dialog owns keyboard focus',
  );
  final stepsTab =
      await browser.evaluate(
        '!!document.querySelector("[data-recipe-tab=steps]")',
      ) ==
      true;
  if (stepsTab) await browser.click('[data-recipe-tab="steps"]');
  await assertJs(
    browser,
    'document.getElementById("recipe-dialog-body").textContent.toLowerCase().includes("quellen")',
    'Recipe dialog includes real preparation steps',
  );
  if (stepsTab) await browser.click('[data-recipe-tab="ingredients"]');
  await browser.click('#recipe-dialog .dialog-close');
  await assertJs(
    browser,
    '!document.getElementById("recipe-dialog").open && !document.body.classList.contains("modal-open")',
    'Recipe dialog closes and unlocks scrolling',
  );

  await browser.click('[data-billing="monthly"]');
  await assertJs(
    browser,
    'document.getElementById("premium-equivalent").textContent.includes("6,99") && document.querySelector("[data-billing=monthly]").getAttribute("aria-pressed") === "true"',
    'Monthly plan shows 6,99 €',
  );
  await browser.click('[data-billing="yearly"]');
  await assertJs(
    browser,
    'document.getElementById("premium-equivalent").textContent.includes("4,17") && document.getElementById("premium-billing").textContent.includes("49,99")',
    'Yearly plan shows 49,99 € and 4,17 €/month equivalent',
  );

  for (final coach in ['snack', 'dinner', 'breakfast']) {
    await browser.click('[data-coach="$coach"]');
    await assertJs(
      browser,
      'document.querySelector(${jsonEncode('[data-coach="$coach"]')}).getAttribute("aria-pressed") === "true" && document.getElementById("coach-answer").textContent.trim().length > 70',
      'Coach example $coach shows a detailed reply',
    );
  }
  for (final filter in ['start', 'ai', 'data']) {
    await browser.click('[data-faq-filter="$filter"]');
    await assertJs(browser, '''(() => {
      const details = [...document.querySelectorAll('[data-faq]')];
      const visible = details.filter(item => !item.hidden && getComputedStyle(item).display !== 'none');
      return visible.length > 0 && visible.length < details.length && visible.every(item => item.dataset.faq === ${jsonEncode(filter)});
    })()''', 'FAQ filter $filter shows the matching category');
  }
  await browser.click('[data-faq-filter="all"]');
  await browser.evaluate('document.querySelector("[data-faq]").open = false');
  await browser.click('[data-faq] summary');
  await assertJs(
    browser,
    'document.querySelector("[data-faq]").open',
    'FAQ answer expands',
  );

  for (final store in ['Apple App Store', 'Google Play']) {
    await browser.click('[data-store="$store"]');
    await assertJs(
      browser,
      'document.getElementById("store-dialog").open && document.getElementById("selected-store").textContent === ${jsonEncode(store)}',
      '$store opens its coming-soon dialog',
    );
    await assertJs(
      browser,
      'document.getElementById("store-dialog").contains(document.activeElement)',
      'Store dialog owns keyboard focus',
    );
    await browser.click('#store-dialog .dialog-done');
    await assertJs(
      browser,
      '!document.getElementById("store-dialog").open && !document.body.classList.contains("modal-open")',
      'Store dialog closes and restores scrolling',
    );
  }
}

Future<void> checkExperience(BrowserConnection browser) async {
  await browser.click('[data-exp-mode="photo"]');
  await browser.click('[data-exp-action="photo-scan"]');
  await browser.waitFor(
    '!!document.querySelector("[data-exp-action=photo-confirm]")',
  );
  await assertJs(
    browser,
    'document.querySelector(".exp-macros").textContent.includes("420") && document.querySelector(".exp-phone-disclaimer").textContent.includes("Schätzung")',
    'Photo demo produces a clearly labeled estimate',
  );
  await browser.click('[data-exp-action="photo-confirm"]');
  await assertJs(
    browser,
    'document.querySelector("[data-exp-action=photo-confirm]").disabled && document.querySelector(".exp-confirm-message").textContent.includes("nicht gespeichert")',
    'Photo confirmation stays illustrative and stores no data',
  );

  await browser.click('[data-exp-mode="barcode"]');
  await browser.click('[data-exp-action="barcode-scan"]');
  await browser.waitFor('!!document.querySelector(".exp-nutrition-table")');
  await assertJs(
    browser,
    'document.querySelector(".exp-nutrition-table").textContent.includes("370 kcal") && document.querySelector(".exp-product-verified").textContent.includes("kein Datenbankergebnis")',
    'Barcode demo shows nutrition without pretending to query a database',
  );
  await browser.click('[data-exp-action="barcode-reset"]');
  await assertJs(
    browser,
    '!!document.querySelector("[data-exp-action=barcode-scan]")',
    'Barcode demo resets',
  );

  await browser.click('[data-exp-mode="recipes"]');
  await browser.click(
    '[data-exp-action="ingredient"][data-exp-ingredient="Hafer"]',
  );
  await assertJs(
    browser,
    'document.querySelector("[data-exp-ingredient=Hafer]").getAttribute("aria-pressed") === "true"',
    'Recipe ingredient chips update selection',
  );
  await browser.click('[data-exp-action="recipe"][data-exp-recipe="berries"]');
  await assertJs(
    browser,
    'document.querySelector(".exp-recipe-detail h4").textContent === "Protein-Beeren-Oats"',
    'Recipe discovery changes the detailed example',
  );
  await browser.click('[data-exp-action="preparation"]');
  await assertJs(
    browser,
    'document.querySelectorAll(".exp-preparation li").length === 3',
    'Interactive recipe shows three preparation steps',
  );
  await browser.click('[data-exp-action="preparation"]');
  await assertJs(
    browser,
    '!!document.querySelector(".exp-recipe-match")',
    'Interactive recipe returns to ingredient comparison',
  );

  await browser.click('[data-exp-mode="calendar"]');
  await browser.click('[data-exp-action="day"][data-exp-day="5"]');
  await assertJs(
    browser,
    'document.querySelector(".exp-day-detail h4").textContent === "Samstag" && document.querySelectorAll(".exp-day-meals > div").length === 2',
    'Calendar selects Saturday and its two example meals',
  );
  await browser.click('[data-exp-action="view"][data-exp-view="macros"]');
  await assertJs(
    browser,
    'document.querySelector(".exp-macro-legend").textContent.includes("49 %")',
    'Calendar switches to daily macro distribution',
  );
  await browser.click('[data-exp-action="view"][data-exp-view="entries"]');
  await assertJs(
    browser,
    'document.querySelectorAll(".exp-bar-column").length === 7',
    'Calendar switches back to the weekly entry chart',
  );
  await browser.evaluate(
    'document.querySelector("[data-exp-mode=calendar]").dispatchEvent(new KeyboardEvent("keydown", {key:"Home",bubbles:true}))',
  );
  await assertJs(
    browser,
    'document.activeElement.dataset.expMode === "photo" && document.querySelector("[data-exp-mode=photo]").getAttribute("aria-selected") === "true"',
    'Product tour tabs support keyboard navigation',
  );
}

Future<void> main() async {
  final server = await serveWebsite(port: 0);
  final client = HttpClient();
  final temporary = await Directory.systemTemp.createTemp(
    'lookin-website-v2-check-',
  );
  final profile = await Directory('${temporary.path}/edge-profile').create();
  Process? edge;
  BrowserConnection? browser;
  try {
    final baseUrl = 'http://127.0.0.1:${server.port}/';
    await inspectFiles(client, baseUrl);
    edge = await Process.start(
      'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe',
      [
        '--headless=new',
        '--disable-gpu',
        '--no-first-run',
        '--no-default-browser-check',
        '--disable-extensions',
        '--disable-background-networking',
        '--disable-component-update',
        '--remote-debugging-port=0',
        '--remote-debugging-address=127.0.0.1',
        '--user-data-dir=${profile.path}',
        '--window-size=1440,1100',
        'about:blank',
      ],
    );
    unawaited(edge.stdout.drain<void>());
    unawaited(edge.stderr.drain<void>());
    final portFile = File('${profile.path}/DevToolsActivePort');
    for (var count = 0; count < 100 && !await portFile.exists(); count++) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
    if (!await portFile.exists()) {
      throw StateError(
        'Edge did not expose CDP within 15 seconds. Run in the authorized browser execution environment.',
      );
    }
    final port = (await portFile.readAsLines()).first;
    final response = await (await client.getUrl(
      Uri.parse('http://127.0.0.1:$port/json/list'),
    )).close();
    final pages = jsonDecode(await utf8.decoder.bind(response).join()) as List;
    final page = pages.firstWhere((value) => value['type'] == 'page');
    browser = BrowserConnection(
      await WebSocket.connect(page['webSocketDebuggerUrl'] as String),
    );
    await browser.send('Page.enable');
    await browser.send('Runtime.enable');
    await browser.send('Network.enable');
    await browser.motion('reduce');
    await browser.setSize(1440, 1040);
    await browser.navigate(baseUrl);
    await loadImages(browser);
    await assertJs(
      browser,
      'getComputedStyle(document.body).backgroundColor === "rgb(5, 7, 8)"',
      'App background color is preserved',
    );
    await assertJs(
      browser,
      '[...document.querySelectorAll(".reveal")].every(el => getComputedStyle(el).opacity === "1")',
      'Reduced motion keeps all content visible',
    );
    final brokenAnchors =
        await browser.evaluate(
              '''[...document.querySelectorAll('a[href^="#"]')].map(el => el.getAttribute('href')).filter(value => value.length > 1 && !document.getElementById(value.slice(1)))''',
            )
            as List;
    expectTrue(brokenAnchors.isEmpty, 'Anchor links resolve: $brokenAnchors');
    await checkInteractions(browser);
    await checkExperience(browser);
    await loadImages(browser);
    await browser.evaluate('window.scrollTo({top:0,behavior:"instant"})');
    await browser.screenshot(File('${temporary.path}/desktop.png'));
    await browser.screenshot(
      File('${temporary.path}/desktop-full.png'),
      full: true,
    );

    await browser.click('[data-filter="all"]');
    for (final section in ['erleben', 'rezepte', 'premium']) {
      await browser.evaluate(
        'document.getElementById("$section").scrollIntoView({block:"start",behavior:"instant"})',
      );
      await browser.screenshot(File('${temporary.path}/desktop-$section.png'));
    }

    for (final width in [320, 375, 390, 700, 768, 1024, 1440, 1920]) {
      await browser.setSize(width, 900);
      final overflowing = <String>[];
      for (final mode in ['photo', 'barcode', 'recipes', 'calendar']) {
        await browser.click('[data-exp-mode="$mode"]');
        final layout = await browser.evaluate(
          '({width:innerWidth,scroll:document.documentElement.scrollWidth})',
        );
        if (layout['scroll'] > layout['width']) {
          overflowing.add('$mode:${layout['scroll']}');
        }
      }
      expectTrue(
        overflowing.isEmpty,
        '$width px has no horizontal overflow in all four tour modes: $overflowing',
      );
    }
    await browser.setSize(390, 844, mobile: true);
    await browser.click('[data-exp-mode="photo"]');
    await browser.evaluate('window.scrollTo({top:0,behavior:"instant"})');
    await browser.click('.menu-toggle');
    await assertJs(
      browser,
      'document.querySelector(".menu-toggle").getAttribute("aria-expanded") === "true" && getComputedStyle(document.querySelector(".main-nav")).display !== "none"',
      'Mobile menu opens',
    );
    await browser.click('.main-nav a[href="#rezepte"]');
    await assertJs(
      browser,
      'document.querySelector(".menu-toggle").getAttribute("aria-expanded") === "false"',
      'Mobile menu closes after navigation',
    );
    await browser.evaluate('window.scrollTo({top:0,behavior:"instant"})');
    await browser.screenshot(File('${temporary.path}/mobile.png'));
    await browser.screenshot(
      File('${temporary.path}/mobile-full.png'),
      full: true,
    );
    for (final section in ['erleben', 'rezepte']) {
      await browser.evaluate(
        'document.getElementById("$section").scrollIntoView({block:"start",behavior:"instant"})',
      );
      await browser.screenshot(File('${temporary.path}/mobile-$section.png'));
    }
    await browser.tap('[data-exp-mode="recipes"]');
    await assertJs(
      browser,
      'document.querySelector("[data-exp-mode=recipes]").getAttribute("aria-selected") === "true"',
      'Mobile product navigation accepts a real pointer click',
    );
    await browser.tap('[data-filter="quick"]');
    await assertJs(
      browser,
      'document.querySelectorAll("#recipe-grid > *").length === 3',
      'Mobile recipe filter accepts a real pointer click',
    );
    await browser.tap('.recipe-card');
    await assertJs(
      browser,
      'document.getElementById("recipe-dialog").open',
      'Mobile recipe card opens with a real pointer click',
    );
    await browser.tap('#recipe-dialog .dialog-close');
    await assertJs(
      browser,
      '!document.getElementById("recipe-dialog").open',
      'Mobile recipe dialog closes with a real pointer click',
    );

    await browser.motion('no-preference');
    await browser.setSize(1440, 1040);
    await browser.navigate(baseUrl);
    await browser.evaluate(
      'document.getElementById("erleben").scrollIntoView({behavior:"instant",block:"start"})',
    );
    await browser.waitFor(
      'document.querySelector("#experience-demo").classList.contains("exp-in-view")',
    );
    await browser.click('[data-exp-action="photo-scan"]');
    await assertJs(
      browser,
      '!!document.querySelector(".exp-scanning")',
      'Normal motion starts the visible photo scan',
    );
    await browser.waitFor(
      '!!document.querySelector("[data-exp-action=photo-confirm]")',
    );
    await assertJs(
      browser,
      '!document.querySelector(".exp-scanning")',
      'Normal-motion scan finishes after its finite animation',
    );
    await browser.click('.motion-toggle');
    await assertJs(
      browser,
      'document.querySelector(".motion-toggle").getAttribute("aria-pressed") === "true" && document.documentElement.classList.contains("motion-paused")',
      'Animation control pauses motion',
    );
    await browser.click('[data-exp-mode="barcode"]');
    await browser.click('[data-exp-action="barcode-scan"]');
    await assertJs(
      browser,
      '!!document.querySelector(".exp-nutrition-table") && !document.querySelector(".exp-scanning")',
      'Paused motion provides immediate barcode results',
    );
    await browser.click('.motion-toggle');
    await assertJs(
      browser,
      'document.querySelector(".motion-toggle").getAttribute("aria-pressed") === "false"',
      'Animation control resumes motion',
    );
    await browser.evaluate(
      'document.querySelector(".diary-visual").scrollIntoView({behavior:"instant",block:"center"})',
    );
    await browser.waitFor(
      'document.querySelector(".diary-visual").classList.contains("is-visible")',
    );
    await assertJs(
      browser,
      'getComputedStyle(document.querySelector(".diary-visual")).opacity === "1"',
      'Normal-motion scroll reveal makes the section visible',
    );
    await browser.evaluate('window.scrollTo({top:0,behavior:"instant"})');
    await browser.waitFor(
      '!document.getElementById("experience-demo").classList.contains("exp-in-view")',
    );
    await assertJs(
      browser,
      '!document.querySelector(".exp-scanning")',
      'Product animations are inactive outside the viewport',
    );

    await browser.motion('reduce');
    await browser.navigate(
      File('${websiteRoot.path}/index.html').uri.toString(),
    );
    await loadImages(browser);
    await assertJs(
      browser,
      'document.querySelector("#experience-demo").dataset.expMounted === "true" && document.querySelectorAll("#recipe-grid > *").length >= 6',
      'Standalone file preview runs scripts and interactive product tour',
    );
    await browser.click('[data-store="Google Play"]');
    await assertJs(
      browser,
      'document.getElementById("store-dialog").open',
      'Standalone file preview supports modal interactions',
    );
    await browser.click('#store-dialog .dialog-close');
    await assertJs(
      browser,
      'Array.from(document.images).every(img => img.complete && img.naturalWidth > 0)',
      'Standalone preview loads all local logo and recipe images',
    );

    await browser.setSize(1440, 1040);
    final comparison = File.fromUri(
      Platform.script.resolve('../../website-compare/index.html'),
    ).uri.toString();
    await browser.send('Page.navigate', {'url': comparison});
    await browser.waitFor(
      'location.href === ${jsonEncode(comparison)} && document.readyState === "complete" && !!document.querySelector("#tab-v2")',
    );
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await assertJs(
      browser,
      'document.getElementById("tab-v2").getAttribute("aria-selected") === "true" && !document.getElementById("panel-v2").hidden && document.querySelectorAll("iframe").length === 2',
      'Comparison keeps both versions and opens Version 2',
    );
    await browser.tap('#tab-v1');
    await assertJs(
      browser,
      '!document.getElementById("panel-v1").hidden && document.getElementById("panel-v2").hidden',
      'Comparison switches to the preserved Version 1',
    );
    await browser.tap('#tab-v2');
    await browser.tap('button[data-device="mobile"]');
    await assertJs(
      browser,
      'document.querySelector(".viewport").getBoundingClientRect().width === 390 && document.getElementById("status").textContent.includes("Handy")',
      'Comparison supports the 390 px phone view',
    );
    await browser.tap('button[data-device="desktop"]');
    await browser.screenshot(File('${temporary.path}/comparison.png'));
    await browser.setSize(320, 900);
    await assertJs(
      browser,
      'document.documentElement.scrollWidth === innerWidth && document.querySelector("iframe").getBoundingClientRect().width <= innerWidth',
      'Comparison itself fits a narrow phone screen',
    );

    final external = browser.requests
        .where(
          (url) =>
              Uri.tryParse(url)?.scheme == 'http' ||
              Uri.tryParse(url)?.scheme == 'https',
        )
        .where((url) => !url.startsWith(baseUrl))
        .toSet();
    expectTrue(external.isEmpty, 'No third-party network requests: $external');
    expectTrue(
      browser.exceptions.isEmpty,
      'No JavaScript exceptions: ${browser.exceptions}',
    );
    stdout.writeln('COMPLETE $passed browser and resource checks passed.');
    stdout.writeln('SCREENSHOTS ${temporary.path}');
  } finally {
    try {
      await browser?.send('Browser.close');
    } catch (_) {}
    await browser?.socket.close();
    edge?.kill();
    client.close(force: true);
    await server.close(force: true);
  }
}
