AutoPolicy architectural lighting implementation

1. Tower materials: runtime-only changes to the 20 AP14_Front/Right_WindowRecess and BlueGlass pairs, four Core_Glass enclosure faces, Core_Roof, Core_LimeBand_1, and existing front/right Shield/Network accents. The production GLB is unchanged. Roof remains graphite metal with a separate thin purple perimeter.

2. Windows: 17 individual inset emissive panels, with three subdued windows, using a fixed lime/warm yellow/purple/cool-blue pattern. Panels are positioned between the original opaque frame backing and translucent window surface. No giant facade light plane. Glass no longer becomes an opaque occluder during the bloom pass.

3. Platforms: thin geometry-derived under-lip strips and corner emitters attached to Core_Step_01, Core_Step_02, Core_Glass_Base and the three original Zone slabs. Their existing parent controls move all these accents during tower lift and segmentation.

4. Devices: stronger existing LED/status/ring emission, especially Cylinder bands and top indicator; seven feathered additive contact pools at their platform surfaces, attached to complete device controls. GlassSensor pool changes to red during anomaly; Orb stays normal. Decorative effects cannot intercept raycast selection.

5. Beams: four feathered, transparent shader planes behind the tower, with depth testing and no depth writes. They face the camera, follow the tower, and use restrained green modulation; reduced-motion mode freezes modulation. These are lightweight beam approximations, not physical volumetric scattering.

6. Selective bloom: dark strength 0.62, light 0.28, radius 0.48, threshold 0.92. Tagged intended effects join existing packet/status targets. Opaque roof and slabs are masked; transparent glass uses a transparent mask. Bloom is rendered before tone mapping, then composited through the existing output pipeline. Signal emission is moderately increased; packet emission cap rises from 1.4 to 2.0 without changing transforms or route ownership.

7. Animation integration: lighting derives from the existing narrative each frame after traffic updates. No new narrative callbacks or forward-only timers. Camera bounds exclude runtime light geometry, so beams cannot shrink or offset model framing. Existing Blender/procedural traffic switching and DENY checkpoint behavior remain intact.

8. Performance: 92 simple runtime meshes, two non-shadow local lights and four beams on desktop. Tablet uses two beams and 80% bloom dimensions; mobile uses one beam, one local light and 65% bloom dimensions. Existing pixel budgets and 4/2 compositor samples remain. Signal targets and bloom masks are cached; no geometry is recreated in the frame loop. Runtime geometry, shader materials and lights are disposed on renderer teardown. No hardware FPS benchmark was performed.

9. Verification: nine Node integration tests passed using the real GLB, including window placement, deterministic reverse lighting, parent transform restoration, quality tiers, disposal, all 21 packets, DENY stopping and segmented-route restoration. Renderer bundling and Flutter web release build succeeded. Browser visual checks covered 1600x900, 1366x768 and 390x844, dark/light hero, Architecture separation and reverse, Security isolation/enforcement/Zero Trust and reverse. Matching Explore hero screenshots are saved as hero-before-1600x900.png and hero-after-1600x900.png; laptop and mobile after screenshots are included. Browser error/warning log was empty at the checked load. Flutter emitted an existing CupertinoIcons font-family warning; compilation succeeded.

Changed files for this task: renderer/src/architectural-lighting.js (new), renderer/src/scene.js, renderer/src/traffic.js, renderer/test/architectural-lighting.test.js (new), assets/renderer/runtime.js (generated), and these output artifacts. Prior sidebar, branding and SDK compatibility edits were preserved.

Run: npm --prefix renderer run build; flutter build web --no-pub; python -m http.server 8767 --directory build/web. Preview: http://127.0.0.1:8767/#/landing

Limits: local light pools are additive reflection/contact approximations, not ray-traced reflections. Reference matching is artistic rather than pixel exact. Tablet quality was tested programmatically; no separate tablet browser screenshot or physical mobile hardware benchmark was taken.

Window/platform validation refinement: verified all original tower/frame geometries and transforms are preserved. Added a production-asset test for all eight Step01/02_LimeEdge meshes; these exported strips now emit olive-green directly. Replaced central platform reflection pools with eight surface-local ribbons along the actual ledges, strengthening localized green spill. Internal window backing is dark rather than reflective, and enclosure tint is a restrained blue at 9% opacity. These changes are runtime materials and light effects only; no second tower or replacement hardware was created. Latest preview: windows-underlighting-validated.png.
