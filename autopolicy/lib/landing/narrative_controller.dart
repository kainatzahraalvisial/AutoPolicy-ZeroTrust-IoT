import 'package:flutter/foundation.dart';

enum RendererCommand {
  setChapter,
  setProgress,
  gotoStage,
  setTheme,
  setViewport,
  setInteractionEnabled,
  setRenderingEnabled,
  setReducedMotion,
  resetScene,
  clearSelection,
  dispose
}

const commandNames = {
  RendererCommand.setChapter: 'SET_CHAPTER',
  RendererCommand.setProgress: 'SET_PROGRESS',
  RendererCommand.gotoStage: 'GOTO_STAGE',
  RendererCommand.setTheme: 'SET_THEME',
  RendererCommand.setViewport: 'SET_VIEWPORT',
  RendererCommand.setInteractionEnabled: 'SET_INTERACTION_ENABLED',
  RendererCommand.setRenderingEnabled: 'SET_RENDERING_ENABLED',
  RendererCommand.setReducedMotion: 'SET_REDUCED_MOTION',
  RendererCommand.resetScene: 'RESET_SCENE',
  RendererCommand.dispose: 'DISPOSE',
  RendererCommand.clearSelection: 'CLEAR_SELECTION',
};
typedef RendererSender = void Function(
    RendererCommand command, Map<String, dynamic> data);

class NarrativeController extends ChangeNotifier {
  String chapter = 'explore';
  double targetProgress = 0, displayProgress = 0;
  bool ready = false;
  String? error;
  String? device;
  bool _selected = false;
  String deviceStatus = 'normal';
  Map<String, dynamic> parameters = {};
  List<Map<String, dynamic>> annotations = [];
  RendererSender? sender;
  int get stageCount => chapter == 'sec' ? 5 : 9;
  int get activeStage =>
      (displayProgress * (stageCount - 1)).round().clamp(0, stageCount - 1);
  bool get hero => displayProgress * (stageCount - 1) < .25;
  void selectChapter(String value) {
    if (!['explore', 'arch', 'sec'].contains(value)) return;
    chapter = value;
    targetProgress = displayProgress = 0;
    parameters = {};
    device = null;
    _selected = false;
    annotations = [];
    sender?.call(RendererCommand.setChapter, {'chapter': chapter});
    notifyListeners();
  }

  void progress(double value) {
    if (!ready) return;
    targetProgress = value.clamp(0, 1);
    sender?.call(RendererCommand.setProgress, {'progress': targetProgress});
  }

  void scroll(double delta, double viewportHeight) {
    progress(targetProgress + delta / (viewportHeight * (stageCount - 1)));
  }

  void gotoStage(int index) {
    if (!ready) return;
    targetProgress = index / (stageCount - 1);
    sender?.call(RendererCommand.gotoStage, {'stage': index});
  }

  void receive(Map<String, dynamic> message) {
    final data = Map<String, dynamic>.from(message['data'] as Map? ?? {});
    switch (message['type']) {
      case 'MODEL_READY':
        ready = true;
        error = null;
        sender?.call(RendererCommand.setChapter, {'chapter': chapter});
        break;
      case 'MODEL_ERROR':
        error = data['message']?.toString() ?? 'Could not initialize the model';
        ready = false;
        break;
      case 'RENDERER_STATUS':
        if (data['chapter'] != chapter) return;
        displayProgress = (data['progress'] as num? ?? 0).toDouble();
        parameters =
            Map<String, dynamic>.from(data['parameters'] as Map? ?? {});
        if (device != null) {
          deviceStatus = device == 'GlassSensor' && parameter('roq') > .1
              ? 'anomalous'
              : 'normal';
        }
        annotations = (data['annotations'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        break;
      case 'DEVICE_HOVER':
        if (_selected) return;
        device = data['device'] as String?;
        deviceStatus = data['status'] as String? ?? 'normal';
        break;
      case 'DEVICE_SELECTED':
        _selected = data['device'] != null;
        device = data['device'] as String?;
        deviceStatus = data['status'] as String? ?? 'normal';
        break;
      default:
        return;
    }
    notifyListeners();
  }

  double parameter(String name) => (parameters[name] as num? ?? 0).toDouble();
  void dismissDevice() {
    device = null;
    _selected = false;
    sender?.call(RendererCommand.clearSelection, {});
    notifyListeners();
  }
}
