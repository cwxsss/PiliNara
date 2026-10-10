/*
* Copyright (c) 2024 Hunan OpenValley Digital Industry Development Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_ohos/flutter_inappwebview_ohos.dart';
import 'package:flutter_inappwebview_ohos/src/web_message/web_message_channel.dart';
import 'package:flutter_inappwebview_ohos/src/web_message/web_message_listener.dart';
import 'package:flutter_inappwebview_ohos/src/web_message/web_message_port.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_bindings.dart';

void main() {
  ensureTestBindings();

  group('OhosWebMessageChannel', () {
    test('fromMap should wire ports and dispose channel', () {
      final channel = OhosWebMessageChannel.static().fromMap({'id': 'wm-1'});
      expect(channel, isNotNull);
      expect(channel!.id, 'wm-1');
      expect(channel.port1, isA<OhosWebMessagePort>());
      expect(channel.port2, isA<OhosWebMessagePort>());

      final methodChannel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_web_message_channel_wm-1',
      );
      setMockMethodChannelHandler(methodChannel, (_) async => null);

      channel.dispose();
      setMockMethodChannelHandler(methodChannel, null);
    });

    test('onMessage should invoke port callback', () async {
      final channel = OhosWebMessageChannel.static().fromMap({'id': 'wm-2'});
      expect(channel, isNotNull);

      final methodChannel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_web_message_channel_wm-2',
      );
      setMockMethodChannelHandler(methodChannel, (_) async => null);

      WebMessage? received;
      await channel!.port1.setWebMessageCallback((message) {
        received = message;
      });

      await sendPlatformMethodCall(
        methodChannel,
        MethodCall('onMessage', {
          'index': 0,
          'message': {
            'data': 'hello',
            'type': WebMessageType.STRING.toNativeValue(),
          },
        }),
      );

      expect(received?.data, 'hello');
      setMockMethodChannelHandler(methodChannel, null);
    });
  });

  group('OhosWebMessagePort', () {
    test('setWebMessageCallback, postMessage, and close should delegate',
        () async {
      final channel = OhosWebMessageChannel.static().fromMap({'id': 'wm-3'});
      expect(channel, isNotNull);

      final methodChannel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_web_message_channel_wm-3',
      );
      final invoked = <String>[];
      setMockMethodChannelHandler(methodChannel, (call) async {
        invoked.add(call.method);
        return null;
      });

      await channel!.port1.setWebMessageCallback((_) {});
      await channel.port1.postMessage(WebMessage(data: 'ping'));
      await channel.port1.close();

      expect(invoked, contains('setWebMessageCallback'));
      expect(invoked, contains('postMessage'));
      expect(invoked, contains('close'));
      setMockMethodChannelHandler(methodChannel, null);
    });
  });

  group('OhosWebMessageListener', () {
    test('onPostMessage should parse ArrayBuffer payload', () async {
      WebMessage? receivedMessage;
      PlatformJavaScriptReplyProxy? replyProxy;

      final listener = OhosWebMessageListener(
        OhosWebMessageListenerCreationParams(
          allowedOriginRules: {'https://example.com'},
          jsObjectName: 'NativeBridge',
          onPostMessage: (message, sourceOrigin, isMainFrame, proxy) {
            receivedMessage = message;
            replyProxy = proxy;
          },
        ),
      );

      final listenerId = listener.toMap()['id'] as String;
      final methodChannel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_web_message_listener_${listenerId}_NativeBridge',
      );
      setMockMethodChannelHandler(methodChannel, (call) async {
        if (call.method == 'postMessage') {
          expect(call.arguments['type'],
              WebMessageType.ARRAY_BUFFER.toNativeValue());
          expect(call.arguments['data'], isA<List>());
          return null;
        }
        return null;
      });

      await sendPlatformMethodCall(
        methodChannel,
        MethodCall('onPostMessage', {
          'message': {
            'data': utf8.encode('JavaScript To Native'),
            'type': WebMessageType.ARRAY_BUFFER.toNativeValue(),
          },
          'sourceOrigin': 'https://www.example.com',
          'isMainFrame': true,
        }),
      );

      expect(receivedMessage?.data, isA<Uint8List>());
      expect(
          utf8.decode(receivedMessage!.data as Uint8List), 'JavaScript To Native');

      await replyProxy!.postMessage(WebMessage(
        data: utf8.encode('JavaScript To Native and back'),
        type: WebMessageType.ARRAY_BUFFER,
      ));
      listener.dispose();
      setMockMethodChannelHandler(methodChannel, null);
    });

    test('onPostMessage should invoke callback with reply proxy', () async {
      WebMessage? receivedMessage;
      PlatformJavaScriptReplyProxy? replyProxy;

      final listener = OhosWebMessageListener(
        OhosWebMessageListenerCreationParams(
          allowedOriginRules: {'https://example.com'},
          jsObjectName: 'NativeBridge',
          onPostMessage: (message, sourceOrigin, isMainFrame, proxy) {
            receivedMessage = message;
            replyProxy = proxy;
          },
        ),
      );

      final listenerId = listener.toMap()['id'] as String;
      final methodChannel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_web_message_listener_${listenerId}_NativeBridge',
      );
      setMockMethodChannelHandler(methodChannel, (call) async {
        if (call.method == 'postMessage') {
          return null;
        }
        return null;
      });

      await sendPlatformMethodCall(
        methodChannel,
        MethodCall('onPostMessage', {
          'message': {
            'data': 'from-web',
            'type': WebMessageType.STRING.toNativeValue(),
          },
          'sourceOrigin': 'https://example.com',
          'isMainFrame': true,
        }),
      );

      expect(receivedMessage?.data, 'from-web');
      expect(replyProxy, isA<OhosJavaScriptReplyProxy>());

      await replyProxy!.postMessage(WebMessage(data: 'reply'));
      listener.dispose();
      setMockMethodChannelHandler(methodChannel, null);
    });
  });
}
