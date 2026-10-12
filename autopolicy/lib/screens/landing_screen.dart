import 'dart:convert';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../landing/narrative_controller.dart';
import '../landing/landing_composition.dart';
import '../landing/cinematic_button.dart';
import '../landing/visual_polish.dart';
import '../landing/landing_route_observer.dart';
import '../landing/renderer_host.dart';
import '../providers/theme_provider.dart';
import '../widgets/system_loader.dart';

class LandingScreen extends ConsumerStatefulWidget {
  final String initialChapter;
  const LandingScreen({super.key, this.initialChapter = 'explore'});
  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> with RouteAware {
  PageRoute<dynamic>? _observedRoute;
  final NarrativeController _story = NarrativeController();
  Map<String, dynamic>? _content;
  bool _menu = false, _wasReady = false, _reduced = false;
  Key _rendererKey = UniqueKey();
  late LandingComposition _layout;
  String? _sentViewport;
  final ScrollController _copyScroll = ScrollController();
  Color get _accent => ref.read(themeModeProvider)
      ? const Color(0xFF94B51A)
      : const Color(0xFF708B0E);
  @override
  void initState() {
    super.initState();
    _story.chapter = widget.initialChapter;
    _story.addListener(_updated);
    _load();
  }

  Future<void> _load() async {
    final data =
        jsonDecode(await rootBundle.loadString('assets/renderer/story.json'))
            as Map<String, dynamic>;
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final saved = prefs.getBool('autopolicy.darkTheme');
    if (saved != null) ref.read(themeModeProvider.notifier).state = saved;
    setState(() => _content = data);
  }

  void _updated() {
    if (!mounted) return;
    if (_story.ready && !_wasReady) {
      _wasReady = true;
      _syncSettings();
      _syncRouteVisibility();
    }
    setState(() {});
  }

  void _syncSettings() {
    _story.sender
        ?.call(RendererCommand.setTheme, {'dark': ref.read(themeModeProvider)});
    _story.sender
        ?.call(RendererCommand.setReducedMotion, {'enabled': _reduced});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic> && route != _observedRoute) {
      landingRouteObserver.unsubscribe(this);
      _observedRoute = route;
      landingRouteObserver.subscribe(this, route);
    }
    _reduced = MediaQuery.of(context).disableAnimations;
    _syncSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncRouteVisibility();
    });
  }

  void _syncRouteVisibility() {
    _story.sender?.call(RendererCommand.setRenderingEnabled,
        {'enabled': _observedRoute?.isCurrent ?? true});
  }

  @override
  void didPushNext() {
    _story.sender
        ?.call(RendererCommand.setRenderingEnabled, {'enabled': false});
  }

  @override
  void didPopNext() {
    _syncSettings();
    _story.sender?.call(RendererCommand.setRenderingEnabled, {'enabled': true});
  }

  void _scroll(double delta) {
    _story.scroll(delta, MediaQuery.sizeOf(context).height);
  }

  void _chapter(String chapter) {
    setState(() => _menu = false);
    _story.selectChapter(chapter);
    _syncSettings();
  }

  void _toggleTheme() async {
    final dark = !ref.read(themeModeProvider);
    ref.read(themeModeProvider.notifier).state = dark;
    _story.sender?.call(RendererCommand.setTheme, {'dark': dark});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autopolicy.darkTheme', dark);
  }

  void _retry() {
    _story.ready = false;
    _story.error = null;
    _wasReady = false;
    _sentViewport = null;
    setState(() => _rendererKey = UniqueKey());
  }

  @override
  void dispose() {
    landingRouteObserver.unsubscribe(this);
    _story.removeListener(_updated);
    _copyScroll.dispose();
    _story.dispose();
    super.dispose();
  }

  Widget _button(String label, VoidCallback action, {bool filled = false}) =>
      CinematicButton(
          label: label,
          onPressed: action,
          filled: filled,
          compact: _layout.compact,
          angular: true);
  List<dynamic> get _stages =>
      _content?[_story.chapter] as List<dynamic>? ?? [];
  Widget _navLink(String chapter, Color fg) => CinematicNavLink(
      label: chapter == 'arch'
          ? 'Architecture'
          : chapter == 'sec'
              ? 'Security'
              : 'Explore',
      active: _story.chapter == chapter,
      compact: _layout.width < 900,
      foreground: fg,
      onPressed: () => _chapter(chapter));
  Widget _header(bool narrow, Color foreground) => Container(
      height: _layout.header,
      padding: EdgeInsets.symmetric(horizontal: _layout.width < 900 ? 16 : 24),
      child: Row(children: [
        Semantics(
            label: 'AutoPolicy',
            image: true,
            child: SizedBox(
                width: _layout.phone
                    ? 120
                    : _layout.width < 900
                        ? 132
                        : 166,
                height: _layout.width < 900 ? 34 : 38,
                child: AutoPolicyWordmark(dark: ref.read(themeModeProvider)))),
        const Spacer(),
        if (!narrow)
          Row(
              mainAxisSize: MainAxisSize.min,
              children: ['explore', 'arch', 'sec']
                  .map((c) => _navLink(c, foreground))
                  .toList()),
        if (!narrow) const Spacer(),
        Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
              tooltip:
                  ref.read(themeModeProvider) ? 'Light theme' : 'Dark theme',
              onPressed: _toggleTheme,
              icon: Icon(
                  ref.read(themeModeProvider)
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  size: 15,
                  color: foreground)),
          CinematicButton(
              label: 'Sign in',
              compact: true,
              navbar: true,
              filled: true,
              angular: true,
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/login')),
          if (narrow)
            IconButton(
                tooltip:
                    'Chapter menu · ${_story.chapter == 'arch' ? 'Architecture' : _story.chapter == 'sec' ? 'Security' : 'Explore'}',
                onPressed: () => setState(() => _menu = !_menu),
                icon: Icon(_menu ? Icons.close : Icons.menu, color: _accent))
        ])
      ]));

  Widget _brandRail() => LayoutBuilder(builder: (context, constraints) {
        const fill = Color(0xFF80A416), ink = Color(0xFF152000);
        final h = constraints.maxHeight;
        final mainWidth = constraints.maxWidth * 38 / 58;
        Widget word() => RotatedBox(
            quarterTurns: 3,
            child: Text('AUTOPOLICY',
                style: TextStyle(
                    fontFamily: 'Orbitron',
                    color: ink,
                    fontWeight: FontWeight.w700,
                    fontSize: _layout.phone ? 6 : 9,
                    letterSpacing: _layout.phone ? 1.5 : 2)));
        return Stack(clipBehavior: Clip.none, children: [
          Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: mainWidth,
              child: Container(
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFB4CC40), fill, Color(0xFF68861A)]),
                      border: Border.all(
                          color: const Color(0xFFD1E678).withOpacity(.3),
                          width: .6),
                      borderRadius: BorderRadius.circular(mainWidth / 2),
                      boxShadow: [
                    BoxShadow(
                        color: fill.withOpacity(.19),
                        blurRadius: 22,
                        spreadRadius: 1)
                  ]))),
          Positioned(
              left: 0,
              top: h * .045,
              width: mainWidth,
              child: Center(child: word())),
          Positioned(
              left: mainWidth / 2 - .6,
              top: h * .445,
              width: 1.2,
              height: h * .108,
              child: const ColoredBox(color: ink)),
          if (!_layout.phone)
            Positioned(
                left: 0,
                bottom: h * .045,
                width: mainWidth,
                child: Center(child: word())),
          Positioned(
              right: 0,
              bottom: 0,
              width: constraints.maxWidth * 14 / 58,
              height: h * .143,
              child: Container(
                  decoration: BoxDecoration(
                      color: fill,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: fill.withOpacity(.22), blurRadius: 14)
                      ]),
                  child: Center(
                      child:
                          Container(width: 1, height: h * .065, color: ink))))
        ]);
      });

  Widget _copy(bool portrait, Color fg, Color muted) {
    if (!_story.ready) return const SizedBox.shrink();
    final hero = _story.hero;
    final darkAccent = ref.read(themeModeProvider)
        ? const Color(0xFFC5C764)
        : const Color(0xFF6D8415);
    final stage =
        _stages.isEmpty ? null : _stages[_story.activeStage] as List<dynamic>;
    final chapter = _story.chapter;
    final heading = hero
        ? (chapter == 'arch'
            ? 'From devices.\nto zero trust.'
            : chapter == 'sec'
                ? 'Detect. Respond.\nStay protected.'
                : 'Every device.\nZero trust.')
        : stage?[1].toString() ?? '';
    final description = hero
        ? (chapter == 'arch'
            ? 'AutoPolicy transforms raw IoT network activity into intelligent, enforceable zero-trust security policies.'
            : chapter == 'sec'
                ? 'Continuously monitor, detect and respond to threats across your IoT network.'
                : 'AutoPolicy detects anomalies in IoT networks and generates enforceable zero-trust security policies.')
        : stage?[2].toString() ?? '';
    final gen = _story.parameter('gen');
    final showPolicy = !hero &&
        gen > .05 &&
        (_story.activeStage == 5 ||
            _story.activeStage == 6 ||
            chapter == 'sec' &&
                (_story.activeStage == 2 || _story.activeStage == 3));
    Widget entrance(Widget child, int delay) =>
        hero ? HeroEntrance(delay: delay, child: child) : child;
    final children = <Widget>[
      entrance(
          hero && chapter == 'explore'
              ? ExploreEyebrow(dark: ref.read(themeModeProvider))
              : Text(
                  hero
                      ? (chapter == 'explore'
                          ? 'ANOMALY DETECTION · ZERO TRUST · POLICY AUTOMATION'
                          : chapter == 'arch'
                              ? 'SYSTEM ARCHITECTURE'
                              : 'SECURITY')
                      : '0${_story.activeStage + 1} / ${stage?[0] ?? ''}',
                  style: TextStyle(
                      fontFamily: 'Orbitron',
                      color: _accent,
                      fontSize: 9,
                      letterSpacing: 1.6)),
          520),
      SizedBox(height: _layout.gap),
      HeroHeading(
          text: heading,
          foreground: fg,
          accent: darkAccent,
          size: _layout.headingSize,
          emphasize: hero,
          delay: hero ? 700 : 0),
      SizedBox(height: _layout.gap),
      TypingParagraph(
          text: description,
          delay: hero ? 1080 : 180,
          style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              color: muted,
              fontSize: _layout.phone ? 14 : 16,
              height: _layout.compact ? 1.5 : 1.65)),
      SizedBox(height: _layout.gap + 4),
      if (hero)
        entrance(
            Wrap(spacing: 14, runSpacing: 16, children: [
              _button(
                  _layout.compact
                      ? (chapter == 'sec' ? 'SECURITY >' : 'EXPLORE >')
                      : chapter == 'sec'
                          ? 'EXPLORE SECURITY >'
                          : 'EXPLORE SYSTEM >',
                  () => _story.progress(.4 / (_story.stageCount - 1)),
                  filled: true),
              _button(
                  _layout.phone
                      ? (chapter == 'arch' ? 'SECURITY' : 'ARCHITECTURE')
                      : chapter == 'arch'
                          ? 'VIEW SECURITY'
                          : 'VIEW ARCHITECTURE',
                  () => _chapter(chapter == 'arch' ? 'sec' : 'arch'))
            ]),
            1080 + description.characters.length * 22 + 100)
      else
        Text(stage?[3].toString() ?? '',
            style: TextStyle(color: _accent, fontSize: 10, letterSpacing: 1.3)),
      if (showPolicy) ...[const SizedBox(height: 22), _policy(gen, fg)],
      if (_story.chapter == 'sec') ...[const SizedBox(height: 24), _workflow()],
      if (_story.chapter == 'sec')
        ExpansionTile(
            tilePadding: EdgeInsets.zero,
            dense: true,
            iconColor: _accent,
            collapsedIconColor: _accent,
            title: Text('THREAT CATEGORIES',
                style: TextStyle(
                    fontFamily: 'Orbitron',
                    color: muted,
                    fontSize: 9,
                    letterSpacing: 1)),
            children: (_content?['threats'] as List? ?? [])
                .map((t) => Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text((t as List)[0].toString(),
                            style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                color: muted,
                                fontSize: 12)))))
                .toList()),
      if (_story.device != null) ...[
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: Text('${_story.device} · ${_story.deviceStatus}',
                  style: TextStyle(
                      color: _story.deviceStatus == 'anomalous'
                          ? const Color(0xFFD92949)
                          : _accent,
                      fontSize: 12))),
          IconButton(
              tooltip: 'Dismiss device details',
              onPressed: _story.dismissDevice,
              icon: const Icon(Icons.close, size: 16))
        ])
      ]
    ];
    final copyKey = ValueKey('$chapter/$hero/${_story.activeStage}');
    return hero
        ? Column(
            key: copyKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: children)
        : StaggeredCopy(key: copyKey, children: children);
  }

  Widget _policy(double gen, Color foreground) {
    const lines = [
      '{',
      '  "device": "glass-sensor",',
      '  "action": "isolate",',
      '  "trust": "low",',
      '  "network": "restricted",',
      '  "source": "graph-anomaly",',
      '  "enforce": "opa"',
      '}'
    ];
    final count = (gen * 8).ceil().clamp(0, 8);
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: foreground.withOpacity(.04),
            border: Border.all(color: foreground.withOpacity(.15)),
            borderRadius: BorderRadius.circular(8)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('GENERATED POLICY · DEMONSTRATION',
              style:
                  TextStyle(color: foreground, fontSize: 9, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(lines.take(count).join('\n'),
              style: TextStyle(
                  fontFamily: 'monospace',
                  color: ref.read(themeModeProvider)
                      ? const Color(0xFFFFEDA8)
                      : const Color(0xFF665629),
                  fontSize: 11,
                  height: 1.4))
        ]));
  }

  Widget _workflow() {
    final f = _story.displayProgress * 4;
    final active = f < .5
        ? -1
        : f < 1.2
            ? 0
            : f < 1.7
                ? 1
                : f < 2.6
                    ? 2
                    : f < 3.4
                        ? 3
                        : 4;
    return Wrap(
        spacing: 5,
        runSpacing: 4,
        children: ['DETECT', 'ANALYZE', 'GENERATE', 'ENFORCE', 'ISOLATE']
            .asMap()
            .entries
            .map((e) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                    color: e.key == active ? _accent : Colors.transparent,
                    border: Border.all(color: _accent.withOpacity(.4)),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(e.value, style: const TextStyle(fontSize: 8))))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    final dark = ref.watch(themeModeProvider);
    final fg = dark ? const Color(0xFFEDF3E8) : const Color(0xFF1F2418);
    final muted = dark ? const Color(0xFFB0B8A6) : const Color(0xFF5F6552);
    final bg = dark ? const Color(0xFF050A08) : const Color(0xFFFAF9F6);
    return Scaffold(
        backgroundColor: bg,
        body: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth, height = constraints.maxHeight;
          _layout = LandingComposition(width, height);
          final area = _layout.sceneRect;
          final towerAnchors = _story.annotations
              .where((a) => a['id'] == '_tower-anchor')
              .toList();
          final glowCenter = towerAnchors.isEmpty
              ? null
              : Offset(
                  area.left +
                      (towerAnchors.first['x'] as num).toDouble() * area.width,
                  area.top +
                      (towerAnchors.first['y'] as num).toDouble() *
                          area.height);
          final viewport = _layout.kind.name;
          if (_story.ready && _sentViewport != viewport) {
            _sentViewport = viewport;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _story.sender
                    ?.call(RendererCommand.setViewport, {'class': viewport});
              }
            });
          }
          final copyArea = _layout.copyRect;
          return CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                    _scroll(height * .6),
                const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                    _scroll(-height * .6),
                const SingleActivator(LogicalKeyboardKey.home): () =>
                    _story.progress(0),
                const SingleActivator(LogicalKeyboardKey.end): () =>
                    _story.progress(1),
              },
              child: Focus(
                  autofocus: true,
                  child: Listener(
                      onPointerSignal: (event) {
                        if (event is PointerScrollEvent &&
                            (!copyArea.contains(event.localPosition) ||
                                !_copyScroll.hasClients ||
                                _copyScroll.position.maxScrollExtent <= 0)) {
                          _scroll(event.scrollDelta.dy);
                        }
                      },
                      child: Stack(children: [
                        Positioned.fill(
                            child: HeroAtmosphere(
                                scene: area,
                                dark: dark,
                                glowCenter: glowCenter)),
                        Positioned.fromRect(
                            rect: area,
                            child: RendererHost(
                                key: _rendererKey,
                                controller: _story,
                                onScroll: _scroll)),
                        Positioned(
                            left: 12,
                            top: _layout.header + 18,
                            width: _layout.brandWidth,
                            height: _layout.phone
                                ? 132
                                : height - _layout.header - 48,
                            child: IgnorePointer(
                                child: HeroEntrance(
                                    delay: 160,
                                    distance: 8,
                                    child: _brandRail()))),
                        Positioned.fromRect(
                            rect: copyArea,
                            child: PointerInterceptor(
                                child: LayoutBuilder(
                                    builder: (context, bounds) => SingleChildScrollView(
                                        controller: _copyScroll,
                                        child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                                minHeight: bounds.maxHeight),
                                            child: Align(
                                                alignment: _layout.stacked
                                                    ? Alignment.topLeft
                                                    : Alignment.centerLeft,
                                                child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 8),
                                                    child: _copy(
                                                        _layout.stacked,
                                                        fg,
                                                        muted)))))))),
                        ..._story.annotations
                            .where((a) => a['id'] != '_tower-anchor')
                            .where((a) =>
                                !_layout.phone ||
                                (_story.parameter('dash') > .3
                                    ? ['soc', 'core'].contains(a['id'])
                                    : ['allow', 'deny', 'restricted', 'device']
                                        .contains(a['id'])))
                            .where((a) =>
                                (a['x'] as num) > .02 &&
                                (a['x'] as num) < .9 &&
                                (a['y'] as num) > .02 &&
                                (a['y'] as num) < .94)
                            .map((a) => Positioned(
                                left: (area.left + (a['x'] as num).toDouble() * area.width)
                                    .clamp(area.left, area.right - 126),
                                top: area.top +
                                    (a['y'] as num).toDouble() * area.height,
                                child: IgnorePointer(
                                    child: Container(
                                        constraints:
                                            const BoxConstraints(maxWidth: 126),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 4),
                                        decoration: BoxDecoration(color: bg.withOpacity(.72), border: Border(left: BorderSide(color: _accent.withOpacity(.5)))),
                                        child: Text(a['label'].toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontFamily: 'SpaceGrotesk',
                                                color: a['id'] == 'deny' || a['id'] == 'restricted'
                                                    ? const Color(0xFFD92949)
                                                    : dark
                                                        ? const Color(0xFFBFD46D)
                                                        : const Color(0xFF607810),
                                                fontSize: _layout.phone ? 8 : 9)))))),
                        Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: PointerInterceptor(
                                child: HeroEntrance(
                                    distance: -8,
                                    child: _header(_layout.menu, fg)))),
                        if (_menu)
                          Positioned(
                              top: _layout.header,
                              right: 16,
                              width: _layout.phone ? width - 32 : 270,
                              child: PointerInterceptor(
                                  child: Material(
                                      color: bg,
                                      elevation: 12,
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ...[
                                              'explore',
                                              'arch',
                                              'sec'
                                            ].map((c) => ListTile(
                                                selected: c == _story.chapter,
                                                selectedColor: _accent,
                                                title: Text(
                                                    c == 'arch'
                                                        ? 'Architecture'
                                                        : c == 'sec'
                                                            ? 'Security'
                                                            : 'Explore',
                                                    style: const TextStyle(
                                                        fontFamily: 'Orbitron',
                                                        fontSize: 12)),
                                                onTap: () => _chapter(c))),
                                          ])))),
                        if (!_story.ready)
                          Positioned.fill(
                              child: PointerInterceptor(
                                  child: ColoredBox(
                                      color: bg,
                                      child: Center(
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                            if (_story.error == null) ...[
                                              const SystemLoader()
                                            ] else ...[
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.all(24),
                                                  child: Text(_story.error!,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: fg))),
                                              _button('RETRY', _retry),
                                              const SizedBox(height: 12),
                                              _button(
                                                  'SIGN IN',
                                                  () => Navigator
                                                      .pushReplacementNamed(
                                                          context, '/login'))
                                            ]
                                          ])))))
                      ]))));
        })));
  }
}
