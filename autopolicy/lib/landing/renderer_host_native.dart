import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'narrative_controller.dart';

class RendererHost extends StatefulWidget {
  final NarrativeController controller;
  final ValueChanged<double> onScroll;
  const RendererHost(
      {super.key, required this.controller, required this.onScroll});
  @override
  State<RendererHost> createState() => _RendererHostState();
}

class _RendererHostState extends State<RendererHost> {
  HttpServer? _server;
  InAppWebViewController? _webview;
  String? _url;
  String? _error;
  @override
  void initState() {
    super.initState();
    widget.controller.sender = _send;
    if (Platform.isLinux) {
      _error =
          'The cinematic renderer requires a browser on Linux. Existing application routes remain available.';
    } else {
      _start();
    }
  }

  Future<void> _start() async {
    try {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      if (!mounted) {
        await server.close(force: true);
        return;
      }
      _server = server;
      server.listen((request) async {
        try {
          final path = request.uri.path.substring(1);
          if (!path.startsWith('assets/renderer/') &&
              !path.startsWith('assets/3Dmodel/')) {
            request.response.statusCode = 403;
          } else if (path.contains('..')) {
            request.response.statusCode = 403;
          } else {
            final bytes = await rootBundle.load(path);
            request.response.headers.set(
                'Content-Type',
                path.endsWith('.js')
                    ? 'text/javascript'
                    : path.endsWith('.html')
                        ? 'text/html'
                        : path.endsWith('.json')
                            ? 'application/json'
                            : 'model/gltf-binary');
            request.response.add(bytes.buffer
                .asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
          }
        } catch (_) {
          request.response.statusCode = 404;
        }
        await request.response.close();
      });
      final host =
          Platform.isIOS || Platform.isMacOS ? 'localhost' : '127.0.0.1';
      setState(() => _url =
          'http://$host:${server.port}/assets/renderer/index.html?session=native');
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
        widget.controller.receive({
          'type': 'MODEL_ERROR',
          'data': {'message': _error}
        });
      }
    }
  }

  void _send(RendererCommand command, Map<String, dynamic> data) {
    _webview?.evaluateJavascript(
        source: 'window.AutoPolicyBridge?.receive(${jsonEncode({
          'protocol': 'autopolicy.v1',
          'session': 'native',
          'type': commandNames[command],
          'data': data
        })});');
  }

  @override
  void dispose() {
    _send(RendererCommand.dispose, {});
    widget.controller.sender = null;
    _server?.close(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(child: Text(_error!, textAlign: TextAlign.center));
    }
    if (_url == null) return const SizedBox.expand();
    return InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(_url!)),
        initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            disableVerticalScroll: true,
            disableHorizontalScroll: true),
        onWebViewCreated: (controller) {
          _webview = controller;
          controller.addJavaScriptHandler(
              handlerName: 'AutoPolicy',
              callback: (arguments) {
                if (arguments.isEmpty || arguments.first is! Map) return;
                final message =
                    Map<String, dynamic>.from(arguments.first as Map);
                if (message['protocol'] != 'autopolicy.v1' ||
                    message['session'] != 'native') return;
                if (message['type'] == 'SCROLL_INPUT') {
                  widget.onScroll(
                      ((message['data'] as Map)['delta'] as num).toDouble());
                } else {
                  widget.controller.receive(message);
                }
              });
        },
        onReceivedError: (controller, request, error) {
          if (request.isForMainFrame == true) {
            widget.controller.receive({
              'type': 'MODEL_ERROR',
              'data': {'message': error.description}
            });
          }
        });
  }
}
