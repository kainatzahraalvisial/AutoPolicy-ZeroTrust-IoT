# AutoPolicy cinematic landing integration

## Integration and source assets

The existing Flutter application remains the application shell. `lib/screens/landing_screen.dart` replaces the old landing presentation. Login, signup, dashboard, Riverpod theme state and backend/service code remain in place. Authentication in this repository is a simulated service; the cinematic HUD and policy are explicitly demonstrations.

The behavioral reference is the complete workspace `AutoPolicy v9.html`. Its S/AR/SC chapter content, K/KA/KS camera arrays and chapter() smoothstep curves are preserved in `renderer/src/narrative.js`. `assets/renderer/story.json` supplies the same stage text to Flutter. `renderer/extract-content.js` records the content extraction workflow.

The original, unchanged production model is `assets/3Dmodel/AutoPolicy_Production.glb`. Capitalization matters. It contains 943 nodes, 916 meshes, 164 source materials, 78 clips and 21 animated packet bodies. Loaded bounds show the four AP16B plates span 9.6 units, rather than the specified 4.8: a runtime scale of 0.5 corrects the conceptual stack without changing the asset.

## Responsibility and lifecycle

Flutter owns layout, authentication routes, chapter selection, target progress, theme persistence, reduced-motion preference, stage rail, narrative text, policy panel, HUD and device details. The renderer is a canvas-only local HTML document, not a second application. Web uses an `HtmlElementView` iframe; native adapters use `flutter_inappwebview` and a restricted device-local HTTP asset server. Linux native is explicitly unsupported by that WebView package; use the web target there.

`lib/landing/narrative_controller.dart` maps Dart command enums to a versioned, session-scoped bridge. `renderer/src/protocol.d.ts` specifies payload types. Every envelope has `protocol: autopolicy.v1`, a unique `session`, `type`, and `data`. Web messages require the same origin and session; renderer commands also require the parent window. Native uses the AutoPolicy JavaScript handler and the same protocol. Progress input sends target changes; renderer status is limited to 10 Hz. Rendering runs locally on one requestAnimationFrame loop. A RouteObserver pauses and cancels that loop when the landing route is covered, including cached routes created by deep links, and resumes it when revealed. Authentication navigation replaces the landing route, disposing its iframe, listeners, mixer, materials, geometry, composers and render targets. Context loss produces an actionable retry screen.

Supported commands: SET_CHAPTER, SET_PROGRESS, GOTO_STAGE, SET_THEME, SET_INTERACTION_ENABLED, SET_RENDERING_ENABLED, SET_REDUCED_MOTION, RESET_SCENE, CLEAR_SELECTION, DISPOSE. Events: MODEL_READY, MODEL_ERROR, DEVICE_HOVER, DEVICE_SELECTED, RENDERER_STATUS, SCROLL_INPUT. GOTO_STAGE is zero-based. Progress is normalized to [0,1]. StageFloat is displayProgress*(stageCount-1); activeStage is rounded.

The renderer indexes exact GLB names and extras, validates required controls, clones independently controlled materials, groups full devices/zones with attach() to preserve world transforms, records immutable baselines, hides stage-only assets, configures lighting and the assembled camera, renders, then emits MODEL_READY. No additional axis rotation is applied. Missing objects fail explicitly.

## Narrative and animation ownership

A single chapter() evaluator yields obs, ins, fx, gr, det, roq, gen, evd, iso, enf, zt, sys, dash, ex, lift, act and ptl, plus camera values. Scroll and direct stage selection feed the same evaluator. Damping uses frame delta; object transforms and materials derive from saved baselines, never accumulated offsets. Chapter switches reset chapter-specific state and selection. Reduced motion removes continuous packet/pulse motion and converges directly to the selected narrative position.

All 78 Blender clips are discovered and played in the assembled/normal traffic state. The 21 packet-body clips are verified; all 84 attached packet details retain their parent relationships. Clip duration is approximately 10.0417 seconds. When anomaly, isolation, enforcement or segmentation requires moving endpoints or a precise stop, packet body clip actions stop and procedural positions follow the seven exported waypoint lists. Child-detail clips continue. Reverse navigation restores body clip ownership. Only one controller owns each packet transform at a time. Normal segmented routes extend to their original core endpoints; isolated sensor traffic is suppressed before DENY. Checkpoint jaw motion uses actual `ap_open_x` and `ap_closed_x` metadata.

Camera keyframes retain the prototype sequences, scaled to loaded hero bounds, with separate portrait framing. Inspection panels and scan lines, four Architecture layers, three progressive policy plates/data lines, warnings, evidence, complete-device isolation, enforcement, boundaries and SOC bars remain distinct concepts. Selective bloom excludes metallic structure and roof. Dynamic graph edges preserve the prototype E relationships; device endpoints update as assemblies move, dashboard edges appear only when introduced, and the glass sensor's affected edges become red. The orb stays normal green.

The management slab is a secondary runtime-only object distinct from the exported SOC display. Zone perimeters are children of their zones, so separation moves both together. Seven physical route meshes are retained, including their engineered right-angle layout.

## Implemented stages

Explore: CONNECT, OBSERVE, ANALYZE, DETECT, ANOMALY, GENERATE, ENFORCE, ZERO TRUST, SYSTEM.

Architecture: IoT Devices, Traffic Observation, Zeek Network Telemetry, Feature Extraction, ML + GNN, Transformer, OPA, Zero Trust, Dashboard.

Security: Threats Overview, Anomaly Detection, Device Isolation, Policy Enforcement, Zero Trust.

Direct routes: /landing, /landing/explore, /landing/arch, /landing/sec. Existing /login, /signup, /dashboard and splash routes remain.

## Install, run and build

From `autopolicy/renderer`: `npm ci`, `npm run build`, `npm test`.

From `autopolicy`: `flutter pub get`, `flutter run -d chrome`, `flutter build web --pwa-strategy none`.

Checks: `flutter analyze lib/landing lib/screens/landing_screen.dart lib/main.dart --no-pub`; `flutter test test/narrative_controller_test.dart --no-pub`.

For the installed Flutter 3.24 toolchain's cached plugin registrant, the verified build command was `flutter build web --no-pub --pwa-strategy none --dart-define=AUTOPOLICY_RENDERER=1`. A normal successful `flutter pub get` regenerates plugin registration. The bundled Three.js runtime is committed application asset output and does not require a CDN at runtime.

## Verification and limits

Six Node regression tests pass: finite/history-independent state through all 23 stages and 161 positions per chapter; world-transform preservation and initial stage visibility; all 21 packet bodies animating with 84 attached details; enforcement blocking and reverse clip ownership; segmented core endpoints and reverse route restoration; visible procedural/reduced-motion packet scale from the exported clip peak. Three Flutter controller tests and one navigation regression test pass: gated/clamped continuous input, stale chapter status rejection, actionable model errors/selection dismissal, and preventing background splash redirects from replacing a directly opened route. Focused Flutter analysis is clean. Flutter Web release builds succeed. The existing project emits a CupertinoIcons font warning.

Native adapter code and narrow loopback platform configuration are present, but native builds/device behavior have not been validated. Flutter dependency resolution on this Windows machine stops during plugin symlink setup because Developer Mode is disabled. No OS setting was changed. Windows also needs its normal WebView2/native toolchain; iOS/macOS require their respective Apple build environments. Linux native reports a clear unsupported-renderer error.

Android allows HTTP only for loopback hosts; other cleartext traffic remains disabled, following https://developer.android.com/privacy-and-security/security-config. Apple local asset hosting uses NSAllowsLocalNetworking, following https://developer.apple.com/documentation/bundleresources/information-property-list/nsapptransportsecurity/nsallowslocalnetworking. The native server binds only loopback and serves only the renderer/model asset directories.

Final font/button/decorative design remains provisional as requested. This implementation does not connect the demonstrative threat/policy state to a live security backend.

## File map

Modified: lib/main.dart, lib/screens/landing_screen.dart, lib/screens/splash_screen.dart (direct-route guard), pubspec.yaml, pubspec.lock, web/index.html. Added: web/flutter_bootstrap.js; lib/landing/{narrative_controller,renderer_host,renderer_host_web,renderer_host_native,landing_route_observer}.dart; renderer/package.json and lock; renderer/src/{scene,registry,traffic,narrative}.js and protocol.d.ts; renderer/test/narrative.test.js; renderer/extract-content.js; assets/renderer/{index.html,runtime.js,story.json}; test/narrative_controller_test.dart; test/splash_navigation_test.dart; this document. Native loopback configuration updates Android manifest/network security XML and Apple plist/entitlements.

Removed unused old landing widgets: three_particle_canvas.dart, pipeline_stage_widget.dart, end_cta_widget.dart, chamfered_cyber_button.dart. Existing user platform directories, model assets and .metadata changes were preserved.


Runtime verification in the actual built Flutter app: all nine Explore, nine Architecture and five Security stage destinations were exercised via Flutter controls. Explore and Security were exercised in reverse through their full stage sequences; Architecture layer retraction, intermediate reverse states and return to the assembled start were inspected. Glass-sensor isolation, progressively generated policy, ALLOW/DENY, segmented zones and SOC finale were inspected visually. Desktop and 390x844 portrait layouts, light/dark theme switching, phone chapter/stage navigation, real-mesh glass-sensor selection/dismissal, preserved login navigation and renderer iframe removal/recreation were checked. Initial runtime inspection found a bloom texture cloning warning and a non-PWA service-worker startup warning. The bloom texture is now assigned after ShaderPass uniform construction, and web/flutter_bootstrap.js loads Flutter without requesting a service worker. This is functional inspection, not a GPU performance benchmark or automated browser coverage of every visual assertion.
Final fresh-origin runtime check: no renderer warning/error entries were captured. Route coverage acknowledges SET_RENDERING_ENABLED=false, browser back resumes the original renderer, and the departing iframe is removed after the route transition. Six renderer tests and all four Flutter tests were rerun successfully after the lifecycle changes.

Visual refinement is implemented separately from the narrative baseline. See docs/visual-refinement/IMPLEMENTATION.md for the seven composition classes, camera fitting, selected fonts, custom buttons, removed Architecture duplication, soft-floor treatment and twelve-size verification.
