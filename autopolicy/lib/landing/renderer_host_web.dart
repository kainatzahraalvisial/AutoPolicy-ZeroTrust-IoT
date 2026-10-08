// Browser platform view: only the renderer is HTML; UI and routing stay Flutter.
import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
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
  static int _nextId = 0;
  late final String _id = 'autopolicy-renderer-${_nextId++}';
  late final html.IFrameElement _frame;
  StreamSubscription<html.MessageEvent>? _messages;
  @override
  void initState() {
    super.initState();
    _frame = html.IFrameElement()
      ..src = Uri.base
          .resolve('assets/assets/renderer/index.html?session=$_id')
          .toString()
      ..style.border = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..title = 'AutoPolicy cinematic 3D system';
    ui_web.platformViewRegistry.registerViewFactory(_id, (_) => _frame);
    widget.controller.sender = _send;
    _messages = html.window.onMessage.listen((event) {
      if (event.origin != html.window.location.origin || event.data is! Map) {
        return;
      }
      final message = Map<String, dynamic>.from(event.data as Map);
      if (message['protocol'] != 'autopolicy.v1' || message['session'] != _id) {
        return;
      }
      if (message['type'] == 'SCROLL_INPUT') {
        widget.onScroll(((message['data'] as Map)['delta'] as num).toDouble());
        return;
      }
      final data = message['data'];
      if (message['type'] == 'RENDERER_STATUS' &&
          data is Map &&
          data['renderingEnabled'] is bool) {
        _frame.dataset['renderingEnabled'] =
            data['renderingEnabled'].toString();
      }
      widget.controller.receive(message);
    });
  }

  void _send(RendererCommand command, Map<String, dynamic> data) {
    _frame.contentWindow?.postMessage({
      'protocol': 'autopolicy.v1',
      'session': _id,
      'type': commandNames[command],
      'data': data
    }, html.window.location.origin);
  }

  @override
  void dispose() {
    _send(RendererCommand.dispose, {});
    widget.controller.sender = null;
    _messages?.cancel();
    _frame.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _id);
}
