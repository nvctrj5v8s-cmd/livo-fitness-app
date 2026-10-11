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
      }
    });
  }
  final WebSocket socket;
  final calls = <int, Completer<Map<String, dynamic>>>{};
  final exceptions = <String>[];
  final requests = <String>[];
  int nextId = 0;

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

  Future<void> navigate(String url) async {
    await send('Page.navigate', {'url': url});
    for (var count = 0; count < 60; count++) {
      if (await evaluate(
            'document.readyState === "complete" && !!document.querySelector(".hero")',
          ) ==
          true) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    throw StateError('Website did not load');
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

void expectTrue(bool success, String description) {
  if (!success) throw StateError(description);
  stdout.writeln('PASS $description');
}

Future<void> main() async {
  final server = await serveWebsite(port: 0);
  final client = HttpClient();
  final temporary = await Directory.systemTemp.createTemp(
    'lookin-website-check-',
  );
  final profile = Directory('${temporary.path}/edge-profile');
  await profile.create();
  Process? browser;
  BrowserConnection? connection;
  try {
    final baseUrl = 'http://127.0.0.1:${server.port}/';
    for (final file
        in websiteRoot.listSync(recursive: true).whereType<File>()) {
      final relative = websiteRoot.uri.relativize(file.uri);
      final response = await (await client.getUrl(
        Uri.parse(baseUrl).resolveUri(relative),
      )).close();
      expectTrue(response.statusCode == 200, 'HTTP 200 ${relative.path}');
      await response.drain<void>();
      if (file.path.endsWith('.html')) {
        final html = await file.readAsString();
        final references = RegExp('(?:href|src)="([^"]+)"').allMatches(html);
        for (final reference in references) {
          final value = reference.group(1)!;
          if (value.startsWith('#') || Uri.parse(value).hasScheme) {
            continue;
          }
          expectTrue(
            await File.fromUri(file.uri.resolve(value)).exists(),
            'Local reference ${relative.path} -> $value',
          );
        }
      }
    }
    browser = await Process.start(
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
    browser.stdout.drain<void>();
    browser.stderr.drain<void>();
    final portFile = File('${profile.path}/DevToolsActivePort');
    for (var count = 0; count < 100 && !await portFile.exists(); count++) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
    if (!await portFile.exists()) {
      throw StateError('Edge did not expose a local debugging port');
    }
    final port = (await portFile.readAsLines()).first;
    final response = await (await client.getUrl(
      Uri.parse('http://127.0.0.1:$port/json/list'),
    )).close();
    final pages = jsonDecode(await utf8.decoder.bind(response).join()) as List;
    final page = pages.firstWhere((value) => value['type'] == 'page');
    connection = BrowserConnection(
      await WebSocket.connect(page['webSocketDebuggerUrl'] as String),
    );
    await connection.send('Page.enable');
    await connection.send('Runtime.enable');
    await connection.send('Network.enable');
    await connection.send('Emulation.setEmulatedMedia', {
      'features': [
        {'name': 'prefers-reduced-motion', 'value': 'reduce'},
      ],
    });
    await connection.send('Emulation.setDeviceMetricsOverride', {
      'width': 1440,
      'height': 1040,
      'deviceScaleFactor': 1,
      'mobile': false,
    });
    await connection.navigate(baseUrl);
    // QA loads offscreen photographs too; visitors retain lazy loading.
    await connection.evaluate(
      'document.querySelectorAll("img").forEach(img => {img.loading = "eager"})',
    );
    for (var count = 0; count < 50; count++) {
      if (await connection.evaluate(
            'Array.from(document.images).every(img => img.complete && img.naturalWidth > 0)',
          ) ==
          true) {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expectTrue(
      await connection.evaluate(
            'Array.from(document.images).every(img => img.complete && img.naturalWidth > 0)',
          ) ==
          true,
      'All photographs and logo loaded',
    );
    expectTrue(
      await connection.evaluate(
            'document.documentElement.scrollWidth <= innerWidth',
          ) ==
          true,
      'Desktop has no horizontal overflow',
    );
    expectTrue(
      await connection.evaluate(
            'getComputedStyle(document.body).backgroundColor === "rgb(5, 7, 8)"',
          ) ==
          true,
      'App background color preserved',
    );
    expectTrue(
      await connection.evaluate(
            'Array.from(document.querySelectorAll(".reveal")).every(el => getComputedStyle(el).opacity === "1")',
          ) ==
          true,
      'Reduced motion keeps every section visible',
    );

    final invalidLinks =
        await connection.evaluate('''(() => {
      const missing = [];
      document.querySelectorAll('a[href],link[href],script[src],img[src]').forEach(el => {
        const value = el.getAttribute('href') || el.getAttribute('src');
        if (value.startsWith('#')) { if (value.length > 1 && !document.querySelector(value)) missing.push(value); }
      });
      return missing;
    })()''')
            as List;
    expectTrue(invalidLinks.isEmpty, 'Anchor links resolve');
    await connection.evaluate(
      'document.querySelector("[data-tab=recipes]").click()',
    );
    expectTrue(
      await connection.evaluate(
            '!document.querySelector("[data-panel=recipes]").hidden && document.querySelector("[data-panel=diary]").hidden',
          ) ==
          true,
      'Recipe preview tab works',
    );
    await connection.evaluate(
      'document.querySelector("[data-tab=recipes]").dispatchEvent(new KeyboardEvent("keydown", {key:"ArrowRight",bubbles:true}))',
    );
    expectTrue(
      await connection.evaluate(
            'document.querySelector("[data-tab=progress]").getAttribute("aria-selected") === "true" && document.activeElement.dataset.tab === "progress"',
          ) ==
          true,
      'Keyboard switches and focuses preview tabs',
    );
    await connection.evaluate(
      'document.querySelector("[data-tab=diary]").click()',
    );
    expectTrue(
      await connection.evaluate(
            '''Array.from(document.querySelectorAll('.phone-tab')).every(tab => {
        const rect = tab.getBoundingClientRect();
        const hit = document.elementFromPoint(rect.x + rect.width / 2, rect.y + rect.height / 2);
        return hit && hit.closest('.phone-tab') === tab;
      })''',
          ) ==
          true,
      'Desktop preview tabs are physically clickable',
    );
    for (final store in ['Apple App Store', 'Google Play']) {
      await connection.evaluate(
        'document.querySelector(${jsonEncode('[data-store="$store"]')}).click()',
      );
      expectTrue(
        await connection.evaluate(
              'document.querySelector("#store-dialog").open && document.querySelector("#selected-store").textContent === ${jsonEncode(store)}',
            ) ==
            true,
        '$store opens placeholder dialog',
      );
      expectTrue(
        await connection.evaluate(
              'document.querySelector("#store-dialog").contains(document.activeElement)',
            ) ==
            true,
        'Dialog contains keyboard focus',
      );
      await connection.evaluate(
        'document.querySelector(".dialog-done").click()',
      );
      expectTrue(
        await connection.evaluate(
              '!document.querySelector("#store-dialog").open && !document.body.classList.contains("modal-open")',
            ) ==
            true,
        'Dialog closes and restores scrolling',
      );
    }
    await connection.evaluate(
      'document.querySelector(".faq-list details:nth-child(2) summary").click()',
    );
    expectTrue(
      await connection.evaluate(
            'document.querySelector(".faq-list details:nth-child(2)").open',
          ) ==
          true,
      'FAQ expands',
    );
    await connection.evaluate('window.scrollTo({top:0,behavior:"instant"})');
    await connection.screenshot(File('${temporary.path}/desktop.png'));
    await connection.screenshot(
      File('${temporary.path}/desktop-full.png'),
      full: true,
    );
    for (final width in [320, 375, 390, 700, 768, 1024, 1440, 1920]) {
      await connection.send('Emulation.setDeviceMetricsOverride', {
        'width': width,
        'height': 900,
        'deviceScaleFactor': 1,
        'mobile': false,
      });
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final layout = await connection.evaluate(
        '({width: innerWidth, scroll: document.documentElement.scrollWidth})',
      );
      expectTrue(
        layout['scroll'] <= layout['width'],
        '$width px has no horizontal overflow (${layout['scroll']})',
      );
    }
    await connection.send('Emulation.setDeviceMetricsOverride', {
      'width': 390,
      'height': 844,
      'deviceScaleFactor': 1,
      'mobile': true,
    });
    await connection.evaluate('window.scrollTo({top:0,behavior:"instant"})');
    await connection.evaluate('document.querySelector(".menu-toggle").click()');
    expectTrue(
      await connection.evaluate(
            'document.querySelector(".menu-toggle").getAttribute("aria-expanded") === "true" && getComputedStyle(document.querySelector(".main-nav")).display !== "none"',
          ) ==
          true,
      'Mobile menu opens',
    );
    await connection.evaluate(
      'document.querySelector(".main-nav a[href=\\"#rezepte\\"]").click()',
    );
    expectTrue(
      await connection.evaluate(
            'document.querySelector(".menu-toggle").getAttribute("aria-expanded") === "false"',
          ) ==
          true,
      'Mobile navigation closes after selection',
    );
    await connection.evaluate('window.scrollTo({top:0,behavior:"instant"})');
    await connection.screenshot(File('${temporary.path}/mobile.png'));
    await connection.screenshot(
      File('${temporary.path}/mobile-full.png'),
      full: true,
    );
    final external = connection.requests
        .where(
          (url) =>
              !url.startsWith(baseUrl) &&
              !url.startsWith('data:') &&
              url != 'about:blank',
        )
        .toList();
    expectTrue(external.isEmpty, 'Website makes no external network requests');
    expectTrue(connection.exceptions.isEmpty, 'No JavaScript exceptions');
    await connection.send('Emulation.setEmulatedMedia', {
      'features': [
        {'name': 'prefers-reduced-motion', 'value': 'no-preference'},
      ],
    });
    await connection.navigate(baseUrl);
    await connection.evaluate(
      'document.querySelector(".photo-feature").scrollIntoView({behavior:"instant"})',
    );
    await Future<void>.delayed(const Duration(milliseconds: 500));
    expectTrue(
      await connection.evaluate(
            'document.querySelector(".photo-feature").classList.contains("is-visible")',
          ) ==
          true,
      'Scroll reveal works with normal motion',
    );
    await connection.evaluate('window.scrollTo({top:0,behavior:"instant"})');
    await Future<void>.delayed(const Duration(milliseconds: 250));
    expectTrue(
      await connection.evaluate(
            '!document.querySelector(".photo-feature").classList.contains("scan-active")',
          ) ==
          true,
      'Photo scan stops outside viewport',
    );
    await connection.navigate(
      File('${websiteRoot.path}/index.html').uri.toString(),
    );
    expectTrue(
      await connection.evaluate(
            'Array.from(document.images).filter(img => !img.loading || img.loading !== "lazy").every(img => img.naturalWidth > 0)',
          ) ==
          true,
      'Direct file preview loads without a server',
    );
    stdout.writeln('SCREENSHOTS ${temporary.path}');
  } finally {
    try {
      await connection?.send('Browser.close');
    } catch (_) {}
    await connection?.socket.close();
    browser?.kill();
    client.close(force: true);
    await server.close(force: true);
  }
}

extension _RelativeUri on Uri {
  Uri relativize(Uri child) => Uri(path: child.path.substring(path.length));
}
