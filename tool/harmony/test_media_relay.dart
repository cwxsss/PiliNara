import 'dart:io';
import 'dart:convert';
import '../../lib/utils/harmony_media_relay.dart';

void expect(bool condition, String description) {
  if (!condition) throw StateError(description);
}

Future<void> main() async {
  final upstream = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final payload = utf8.encode('abcdefgh');
  upstream.listen((request) async {
    expect(request.headers.value('referer') == 'https://www.bilibili.com',
      'Referer must be preserved');
    request.response.headers.set('accept-ranges', 'bytes');
    if (request.headers.value('range') == 'bytes=2-5') {
      request.response.statusCode = 206;
      request.response.headers.set('content-range', 'bytes 2-5/8');
      request.response.contentLength = 4;
      if (request.method != 'HEAD') request.response.add(payload.sublist(2, 6));
    } else {
      request.response.contentLength = payload.length;
      if (request.method != 'HEAD') request.response.add(payload);
    }
    await request.response.close();
  });
  final relay = HarmonyMediaRelay();
  final client = HttpClient();
  try {
    final route = Uri.parse(await relay.wrap('http://127.0.0.1:' +
      upstream.port.toString() + '/source?private=signed'));
    expect(!route.toString().contains('private'), 'Upstream URL must stay private');
    for (final method in ['GET', 'HEAD']) {
      final request = await client.openUrl(method, route);
      request.headers.set('range', 'bytes=2-5');
      request.headers.set('referer', 'https://www.bilibili.com');
      final response = await request.close();
      expect(response.statusCode == 206, 'Range status');
      expect(response.headers.value('content-range') == 'bytes 2-5/8', 'Range header');
      expect(response.contentLength == 4, 'Range content length');
      final body = await utf8.decoder.bind(response).join();
      expect(body == (method == 'HEAD' ? '' : 'cdef'), 'Range body / HEAD');
    }
    final request = await client.getUrl(route);
    request.headers.set('referer', 'https://www.bilibili.com');
    final response = await request.close();
    expect(await utf8.decoder.bind(response).join() == 'abcdefgh', 'Full stream');
    final invalid = await (await client.getUrl(route.replace(path: '/media/invalid'))).close();
    expect(invalid.statusCode == 404, 'Invalid capability must be rejected');
    await invalid.drain<void>();
    print('PASS: Range, HEAD, full stream, headers, private URLs, invalid route');
  } finally {
    client.close(force: true);
    await relay.close();
    await upstream.close(force: true);
  }
}
