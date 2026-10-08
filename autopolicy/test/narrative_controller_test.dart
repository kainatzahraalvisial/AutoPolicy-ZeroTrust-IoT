import 'package:flutter_test/flutter_test.dart';
import 'package:autopolicy/landing/narrative_controller.dart';

void main() {
  test('loading gates input; scroll clamps and preserves continuous progress',
      () {
    final c = NarrativeController();
    final commands = <RendererCommand>[];
    c.sender = (command, data) => commands.add(command);
    c.progress(.5);
    expect(commands, isEmpty);
    c.receive({'type': 'MODEL_READY'});
    c.scroll(400, 800);
    expect(c.targetProgress, .0625);
    c.scroll(-10000, 800);
    expect(c.targetProgress, 0);
    c.gotoStage(8);
    expect(c.targetProgress, 1);
    c.dispose();
  });
  test(
      'chapter change rejects stale renderer status and clears previous overlays',
      () {
    final c = NarrativeController();
    c.receive({
      'type': 'RENDERER_STATUS',
      'data': {
        'chapter': 'explore',
        'progress': .75,
        'parameters': {'enf': 1}
      }
    });
    c.selectChapter('sec');
    c.receive({
      'type': 'RENDERER_STATUS',
      'data': {
        'chapter': 'explore',
        'progress': 1,
        'parameters': {'enf': 1}
      }
    });
    expect(c.displayProgress, 0);
    expect(c.parameters, isEmpty);
    expect(c.stageCount, 5);
    c.receive({
      'type': 'RENDERER_STATUS',
      'data': {
        'chapter': 'sec',
        'progress': .5,
        'parameters': {'iso': .5}
      }
    });
    expect(c.activeStage, 2);
    expect(c.parameter('iso'), .5);
    c.dispose();
  });
  test(
      'device dismissal clears the renderer selection; model errors remain actionable',
      () {
    final c = NarrativeController();
    RendererCommand? last;
    c.sender = (command, data) => last = command;
    c.receive({
      'type': 'DEVICE_SELECTED',
      'data': {'device': 'GlassSensor', 'status': 'anomalous'}
    });
    expect(c.device, 'GlassSensor');
    c.dismissDevice();
    expect(last, RendererCommand.clearSelection);
    expect(c.device, isNull);
    c.receive({
      'type': 'MODEL_ERROR',
      'data': {'message': 'Missing production asset'}
    });
    expect(c.ready, false);
    expect(c.error, 'Missing production asset');
    c.dispose();
  });
}
