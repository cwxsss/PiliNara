import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

/// Keeps remote HTTPS in Dart while the OHOS native player reads loopback HTTP.
/// Routes are process-local capabilities; upstream URLs are never sent to logs.

/// Transfers media outside the UI isolate so network chunks cannot delay gestures.
class HarmonyMediaRelay {
  final void Function(String)? log;
  Future<_RelayHandle>? _starting;
  bool _closed = false;

  HarmonyMediaRelay({this.log});

  Future<String> wrap(String source) async {
    final uri = Uri.tryParse(source);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) return source;
    if (_closed) throw StateError('Media relay is closed');
    final handle = await (_starting ??= _start());
    if (_closed) throw StateError('Media relay is closed');
    return await handle.request('wrap', source) as String;
  }

  Future<_RelayHandle> _start() async {
    final ready = ReceivePort();
    final logs = ReceivePort();
    logs.listen((message) {
      if (message is String) log?.call(message);
    });
    Isolate? isolate;
    try {
      isolate = await Isolate.spawn(_runMediaRelay, [ready.sendPort, logs.sendPort]);
      final port = await ready.first.timeout(const Duration(seconds: 15));
      return _RelayHandle(port as SendPort, isolate, logs);
    } catch (_) {
      isolate?.kill(priority: Isolate.immediate);
      logs.close();
      rethrow;
    } finally {
      ready.close();
    }
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    final starting = _starting;
    if (starting == null) return;
    final handle = await starting;
    try {
      await handle.request('close', null);
    } finally {
      handle.isolate.kill(priority: Isolate.immediate);
      handle.logs.close();
    }
  }
}

class _RelayHandle {
  final SendPort port;
  final Isolate isolate;
  final ReceivePort logs;
  _RelayHandle(this.port, this.isolate, this.logs);

  Future<Object?> request(String command, String? argument) async {
    final reply = ReceivePort();
    try {
      port.send([command, argument, reply.sendPort]);
      final result = await reply.first.timeout(const Duration(seconds: 15)) as List;
      if (result[0] != true) throw StateError('Media relay: ${result[1]}');
      return result[1];
    } finally {
      reply.close();
    }
  }
}

Future<void> _runMediaRelay(List<SendPort> ports) async {
  final commands = ReceivePort();
  final relay = _MediaRelayWorker(log: (message) => ports[1].send(message));
  ports[0].send(commands.sendPort);
  await for (final message in commands) {
    final command = message as List;
    final reply = command[2] as SendPort;
    try {
      if (command[0] == 'wrap') {
        reply.send([true, await relay.wrap(command[1] as String)]);
      } else if (command[0] == 'close') {
        await relay.close();
        reply.send([true, null]);
        commands.close();
        break;
      } else {
        reply.send([false, 'Unknown command']);
      }
    } catch (error) {
      reply.send([false, error.runtimeType.toString()]);
    }
  }
}

class _MediaRelayWorker {
  final void Function(String)? log;
  final HttpClient _client = _RelayHttpOverrides().createHttpClient(null)
    ..autoUncompress = false;
  final Map<String, Uri> _routes = {};
  Future<HttpServer>? _starting;
  bool _closed = false;

  _MediaRelayWorker({this.log}) {
    _client.connectionTimeout = const Duration(seconds: 15);
  }

  Future<String> wrap(String source) async {
    final uri = Uri.tryParse(source);
    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
      return source;
    }
    if (_closed) throw StateError('Media relay is closed');
    final server = await (_starting ??= _start());
    if (_closed) throw StateError('Media relay is closed');
    final random = Random.secure();
    final token = base64Url.encode(List.generate(24, (_) => random.nextInt(256)));
    if (_routes.length >= 512) _routes.remove(_routes.keys.first);
    _routes[token] = uri;
    return Uri(scheme: 'http', host: '127.0.0.1', port: server.port,
      path: '/media/' + token).toString();
  }

  Future<HttpServer> _start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) => unawaited(_handle(request)));
    return server;
  }

  Future<void> _handle(HttpRequest request) async {
    HttpClientRequest? outgoing;
    try {
      final segments = request.uri.pathSegments;
      final upstreamUri = segments.length == 2 && segments.first == 'media'
          ? _routes[segments.last] : null;
      if (upstreamUri == null) {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }
      if (request.method != 'GET' && request.method != 'HEAD') {
        request.response.statusCode = HttpStatus.methodNotAllowed;
        await request.response.close();
        return;
      }
      outgoing = await _client.openUrl(request.method, upstreamUri);
      for (final name in ['range', 'if-range', 'user-agent', 'referer', 'accept']) {
        final value = request.headers[name];
        if (value != null) outgoing.headers.set(name, value);
      }
      outgoing.headers.set('accept-encoding', 'identity');
      final upstream = await outgoing.close();
      request.response.statusCode = upstream.statusCode;
      for (final name in ['content-type', 'content-range', 'accept-ranges',
        'content-encoding', 'etag', 'last-modified', 'cache-control']) {
        final value = upstream.headers[name];
        if (value != null) request.response.headers.set(name, value);
      }
      if (upstream.contentLength >= 0) {
        request.response.contentLength = upstream.contentLength;
      }
      log?.call('[HarmonyMediaRelay] response ' + upstream.statusCode.toString());
      await request.response.addStream(upstream);
      await request.response.close();
    } catch (error) {
      outgoing?.abort();
      log?.call('[HarmonyMediaRelay] transfer failed: ' + error.runtimeType.toString());
      try {
        request.response.statusCode = HttpStatus.badGateway;
        await request.response.close();
      } catch (_) {}
    }
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _client.close(force: true);
    final starting = _starting;
    if (starting != null) await (await starting).close(force: true);
    _routes.clear();
  }
}

// Use the standard verified TLS client independently of app debug overrides.
class _RelayHttpOverrides extends HttpOverrides {}
