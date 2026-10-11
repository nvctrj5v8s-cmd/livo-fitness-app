import 'dart:io';

final websiteRoot = Directory.fromUri(Platform.script.resolve('../dist/'));

const contentTypes = {
  'html': 'text/html; charset=utf-8',
  'css': 'text/css; charset=utf-8',
  'js': 'text/javascript; charset=utf-8',
  'png': 'image/png',
  'webp': 'image/webp',
  'svg': 'image/svg+xml',
};

Future<HttpServer> serveWebsite({int port = 8787}) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  server.listen((request) async {
    try {
      final segments = request.uri.pathSegments;
      if (segments.any(
        (part) => part == '..' || part.contains('\\') || part.contains('/'),
      )) {
        request.response.statusCode = HttpStatus.forbidden;
      } else {
        final path = segments.isEmpty || segments.last.isEmpty
            ? '${segments.join('/')}index.html'
            : segments.join('/');
        final file = File.fromUri(websiteRoot.uri.resolve(path));
        if (!await file.exists()) {
          request.response.statusCode = HttpStatus.notFound;
          request.response.write('Nicht gefunden');
        } else {
          request.response.headers.set(
            HttpHeaders.contentTypeHeader,
            contentTypes[path.split('.').last] ?? 'application/octet-stream',
          );
          request.response.headers.set('Cache-Control', 'no-store');
          request.response.headers.set('X-Content-Type-Options', 'nosniff');
          await request.response.addStream(file.openRead());
        }
      }
    } catch (_) {
      request.response.statusCode = HttpStatus.internalServerError;
    } finally {
      await request.response.close();
    }
  });
  return server;
}

Future<void> main() async {
  final server = await serveWebsite();
  stdout.writeln('Lookin: http://127.0.0.1:${server.port}');
  stdout.writeln('Lokale Vorschau. Beenden mit Strg+C.');
}
