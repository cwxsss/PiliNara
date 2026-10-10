/*
 * Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
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

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URL Launcher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'URL Launcher'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final UrlLauncherPlatform launcher = UrlLauncherPlatform.instance;
  bool _hasCallSupport = false;
  Future<void>? _launched;
  String _phone = '';
  String? _launchAppGalleryLog = null;
  Map<PreferredLaunchMode, bool> _supportsModeResults = {};
  Map<PreferredLaunchMode, bool> _supportsCloseForModeResults = {};

  @override
  void initState() {
    super.initState();
    // Check for phone call support.
    launcher.canLaunch('tel:123').then((bool result) {
      setState(() {
        _hasCallSupport = result;
      });
    });
  }

  Future<void> _launchInBrowser(String url) async {
    if (!await launcher.launch(
      url,
      useSafariVC: false,
      useWebView: false,
      enableJavaScript: false,
      enableDomStorage: false,
      universalLinksOnly: false,
      headers: <String, String>{},
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchInWebView(String url) async {
    if (!await launcher.launch(
      url,
      useSafariVC: true,
      useWebView: true,
      enableJavaScript: false,
      enableDomStorage: false,
      universalLinksOnly: false,
      headers: <String, String>{
        'harmony_browser_page': 'pages/LaunchInAppPage'
      },
    )) {
      throw Exception('Could not launch $url');
    }
  }
  Future<void> _launchInWebViewHeader(String url) async {
    if (!await launcher.launch(
      url,
      useSafariVC: true,
      useWebView: true,
      enableJavaScript: false,
      enableDomStorage: false,
      universalLinksOnly: false,
      headers: <String, String>{
        'my_header_key': 'my_header_value',
        'harmony_browser_page': 'pages/LaunchInAppPage'
      },
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchInWebViewWithJavaScript(String url) async {
    if (!await launcher.launch(
      url,
      useSafariVC: true,
      useWebView: true,
      enableJavaScript: false,
      enableDomStorage: false,
      universalLinksOnly: false,
      headers: <String, String>{
        'harmony_browser_page': 'pages/LaunchInAppPage'
      },
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchInWebViewWithDomStorage(String url) async {
    if (!await launcher.launch(
      url,
      useSafariVC: true,
      useWebView: true,
      enableJavaScript: false,
      enableDomStorage: false,
      universalLinksOnly: false,
      headers: <String, String>{
        'harmony_browser_page': 'pages/LaunchInAppPage'
      },
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _launchStatus(BuildContext context, AsyncSnapshot<void> snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return const Text('');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Use `Uri` to ensure that `phoneNumber` is properly URL-encoded.
    // Just using 'tel:$phoneNumber' would create invalid URLs in some cases,
    // such as spaces in the input, which would cause `launch` to fail on some
    // platforms.
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launcher.launch(
      launchUri.toString(),
      useSafariVC: false,
      useWebView: false,
      enableJavaScript: false,
      enableDomStorage: false,
      universalLinksOnly: true,
      headers: <String, String>{},
    );
  }

  Future<void> _launchAppGalleryDetails(String url) async {
    //store://appgallery.huawei.com/app/detail?id=APPID'
    if (await launcher.canLaunch(url)) {
      var result = await launcher.launchUrl(
        url,
        const LaunchOptions(mode: PreferredLaunchMode.externalApplication),
      );
      if (result) {
        setState(() {
          _launchAppGalleryLog = "Launched $url";
        });
      } else {
        setState(() {
          _launchAppGalleryLog = "Could not launch $url";
        });
      }
    } else {
      setState(() {
        _launchAppGalleryLog = "canLaunch=false, $url";
      });
    }
  }

  Future<void> _checkSupportsMode() async {
    final modes = PreferredLaunchMode.values;
    final Map<PreferredLaunchMode, bool> results = {};
    for (final mode in modes) {
      results[mode] = await launcher.supportsMode(mode);
    }
    setState(() {
      _supportsModeResults = results;
    });
  }

  Future<void> _checkSupportsCloseForMode() async {
    final modes = PreferredLaunchMode.values;
    final Map<PreferredLaunchMode, bool> results = {};
    for (final mode in modes) {
      results[mode] = await launcher.supportsCloseForMode(mode);
    }
    setState(() {
      _supportsCloseForModeResults = results;
    });
  }

  String _modeName(PreferredLaunchMode mode) {
    switch (mode) {
      case PreferredLaunchMode.platformDefault:
        return 'platformDefault';
      case PreferredLaunchMode.inAppWebView:
        return 'inAppWebView';
      case PreferredLaunchMode.inAppBrowserView:
        return 'inAppBrowserView';
      case PreferredLaunchMode.externalApplication:
        return 'externalApplication';
      case PreferredLaunchMode.externalNonBrowserApplication:
        return 'externalNonBrowserApplication';
    }
  }

  @override
  Widget build(BuildContext context) {
    // onPressed calls using this URL are not gated on a 'canLaunch' check
    // because the assumption is that every device can launch a web URL.
    const String toLaunch = 'https://www.cylog.org/headers/';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                    onChanged: (String text) => _phone = text,
                    decoration: const InputDecoration(
                        hintText: 'Input the phone number to launch')),
              ),
              ElevatedButton(
                onPressed: _hasCallSupport
                    ? () => setState(() {
                  _launched = _makePhoneCall(_phone);
                })
                    : null,
                child: _hasCallSupport
                    ? const Text('Make phone call')
                    : const Text('Calling not supported'),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(toLaunch),
              ),
              ElevatedButton(
                /*onPressed: () => setState(() {
                  _launched = _launchInBrowser(toLaunch);
                }),*/
                onPressed: null,
                child: const Text('Launch in browser'),
              ),
              const Padding(padding: EdgeInsets.all(16.0)),
              ElevatedButton(
                onPressed: () => setState(() {
                  _launched = _launchInBrowser(toLaunch);
                }),
                child: const Text('Launch in Ohos browser'),
              ),
              const Padding(padding: EdgeInsets.all(16.0)),
              ElevatedButton(
                onPressed: () => setState(() {
                  _launched = _launchInWebView(toLaunch);
                }),
                child: const Text('Launch in web view'),
              ),
              ElevatedButton(
                onPressed: () => setState(() {
                  _launched = _launchInWebViewHeader(toLaunch);
                }),
                child: const Text('Launch in web view (Custom headers)'),
              ),
              ElevatedButton(
                onPressed: () => setState(() {
                  _launched = _launchInWebViewWithJavaScript(toLaunch);
                }),
                child: const Text('Launch in web view (JavaScript OFF)'),
              ),
              ElevatedButton(
                onPressed: () => setState(() {
                  _launched = _launchInWebViewWithDomStorage(toLaunch);
                }),
                child: const Text('Launch in web view (DOM storage OFF)'),
              ),
              const Padding(padding: EdgeInsets.all(16.0)),
              ElevatedButton(
                onPressed: () => setState(() {
                  _launched = _launchInWebView(toLaunch);
                  Timer(const Duration(seconds: 5), () {
                    launcher.closeWebView();
                  });
                }),
                child: const Text('Launch in web view + close after 5 seconds'),
              ),
              const Padding(padding: EdgeInsets.all(16.0)),
              ElevatedButton(
                onPressed: () => setState(() {
                  //此处包名应该更换成 C+AppID
                  const String url =
                      'store://appgallery.huawei.com/app/detail?id=com.huawei.hmsapp.himovie';
                  _launched = _launchAppGalleryDetails(url);
                }),
                child: const Text('Launch AppGallery Details'),
              ),
              if (_launchAppGalleryLog?.isNotEmpty ?? false)
                Text(_launchAppGalleryLog!),
              const Padding(padding: EdgeInsets.all(16.0)),
              const Divider(),
              const Text('supportsMode', style: TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: _checkSupportsMode,
                child: const Text('Check supportsMode'),
              ),
              if (_supportsModeResults.isNotEmpty)
                ..._supportsModeResults.entries.map((entry) => Text(
                    '${_modeName(entry.key)}: ${entry.value ? "Supported" : "Not supported"}')),
              const Padding(padding: EdgeInsets.all(16.0)),
              const Divider(),
              const Text('supportsCloseForMode', style: TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: _checkSupportsCloseForMode,
                child: const Text('Check supportsCloseForMode'),
              ),
              if (_supportsCloseForModeResults.isNotEmpty)
                ..._supportsCloseForModeResults.entries.map((entry) => Text(
                    '${_modeName(entry.key)}: ${entry.value ? "Can close" : "Cannot close"}')),
              const Padding(padding: EdgeInsets.all(16.0)),
              FutureBuilder<void>(future: _launched, builder: _launchStatus),
            ],
          ),
        ],
      ),
    );
  }
}