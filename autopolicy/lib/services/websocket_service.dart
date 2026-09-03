import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class WebSocketService {
  final String socketUrl;
  final _streamController = StreamController<Map<String, dynamic>>.broadcast();
  bool _isConnected = false;

  WebSocketService({this.socketUrl = 'wss://socket.autopolicy.cyber-defense.local/stream'});

  Stream<Map<String, dynamic>> get stream => _streamController.stream;
  bool get isConnected => _isConnected;

  void connect() {
    if (_isConnected) return;
    _isConnected = true;
    if (kDebugMode) {
      print('[WS-CONNECT] Connected to $socketUrl');
    }
  }

  void disconnect() {
    if (!_isConnected) return;
    _isConnected = false;
    if (kDebugMode) {
      print('[WS-DISCONNECT] Disconnected from $socketUrl');
    }
  }

  // Sends command/payload upstream to WebSocket server
  void send(String event, Map<String, dynamic> data) {
    if (!_isConnected) {
      if (kDebugMode) {
        print('[WS-ERROR] Cannot send message, socket is disconnected.');
      }
      return;
    }
    if (kDebugMode) {
      print('[WS-SEND] Sent event "$event": ${jsonEncode(data)}');
    }
  }

  // System call to push simulated WebSocket frame downstream
  void injectWebsocketFrame(String event, Map<String, dynamic> data) {
    if (!_isConnected) return;
    _streamController.add({
      'event': event,
      'timestamp': DateTime.now().toIso8601String(),
      'data': data,
    });
  }

  void dispose() {
    _streamController.close();
  }
}
