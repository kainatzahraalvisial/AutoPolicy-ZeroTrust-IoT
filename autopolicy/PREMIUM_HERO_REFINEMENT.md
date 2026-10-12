# Cinematic hero reconstruction — 10 October 2026

Implemented in the existing Flutter landing screen and Three.js renderer. The production GLB, bridge protocol, narrative controller, three chapters, 23 stages, packet clips, anomaly/enforcement logic and zone transforms remain unchanged.

1. **Atmosphere implementation:** a static Flutter CustomPainter inside a RepaintBoundary draws four feathered elliptical radial fields beneath the transparent renderer. No extra model, video, texture download or volumetric rendering pass is introduced.
2. **Colors:** the dark base is #050A08. The outer forest field combines #17452E and #0D2119; the dominant halo combines #BCDA27 and #80A416; an upward narrow field adds #C4E326; a restrained side field uses lavender #B1A9DA and blue #CFE6F2. Light theme reduces their opacity against #FAF9F6.
3. **Placement:** all field centers and radii follow the dedicated model rectangle. The halo rises behind the tower and feathers before the stacked copy. Copy and model retain separate layout bounds; the iframe remains transparent.
4. **Real bloom:** the existing selective bloom remains restricted to semantic meshes such as packets, signals, indicators and shields. Strength is refined to 0.48 dark / 0.22 light and radius 0.24. The broad environment comes from the Flutter fields, allowing geometric edges to remain clear. The previous semantic emission and glass-edge improvements are retained.
5. **Sharpness cause:** EffectComposer captured DPR 1 when constructed. Later resize changed only renderer DPR, leaving its postprocessing render targets at logical resolution. Renderer antialiasing also did not antialias those offscreen buffers. The old width-under-700 heuristic could additionally treat a laptop's model iframe as a mobile viewport.
6. **Rendering changes:** canvas and both composers now receive the same DPR. The base composer's targets use up to four MSAA samples on desktop and two on mobile, bounded by GPU capability. Quality uses the existing viewport class rather than iframe width, caps DPR at 2 desktop / 1.5 mobile and caps pixel budgets at 2.6 / 1.1 million. Desktop gets modest supersampling on 1x displays. sRGB output, ACES exposure 0.72, GLTF texture handling and PCF soft shadows remain intact. Camera-fit margins are tighter and the vertical offset is reduced; model transforms are untouched. At 1366×768, the 754×668 model viewport reported matching 1131×1002 canvas/composite/bloom buffers and four samples.
7. **Short-height fit:** copy is vertically centered within the available area rather than placed at a fixed height fraction. Heights below 800 use 18px gaps, compact 44px CTAs and tighter paragraph leading. Heading size also respects available height and copy width. Portrait layouts reserve separate model/copy regions, with scrolling for longer content and unusually reduced heights. SafeArea and Scaffold resizing remain in place.
8. **Narrative input:** existing controller and renderer wheel/touch/keyboard commands remain. Wheel over fitting copy now advances the narrative; overflowing copy keeps its own readable scroll area. Arrow/Home/End controls continue working. Actual wheel input advanced Architecture to progress 0.187; End reached 1.000. Resizing across all thirteen sizes preserved the expanded Architecture state. Intro remains settled rather than replaying on resize; motion tests cover rebuild stability and reduced motion.
9. **Removed UI:** the full left numbered stage list, its reserved column, mobile stage tabs, demonstration/status footer and footer progress separator are gone. The separate olive AutoPolicy brand rail remains. Theme control moves into the header without adding a replacement footer.
10. **Redistributed space:** the copy begins immediately after the brand rail. Normal landscape layouts allocate about 39% of usable width to copy and the remainder to the renderer/gutter; large displays cap copy width at 600px so the model can use more space. The scene extends to 24px above the viewport bottom. Header chapter navigation, Orbitron/Space Grotesk, angular filled primary and outlined secondary CTAs remain. Light navigation uses a darker olive for contrast; secondary CTA depth is limited to its lower rim rather than filling its face.
11. **Actual verification:** Explore hero and expanded Architecture/SOC finale were visually inspected and captured at every size listed below. Security hero and final Zero Trust state were also exercised, including light theme and mobile resizing. 24 Flutter regression checks pass, including light navigation contrast and keyboard-height bounds; all six renderer tests pass. Production web build succeeds and focused analysis is clean. An existing missing CupertinoIcons font warning remains.
12. **Limits:** responsive browser viewports are not physical iOS/Android devices. Native WebView rendering, device GPU memory, sustained FPS/thermal behavior, touch hardware, real virtual keyboards, OS accessibility settings and native safe-area variations remain unverified. Pixel budgets limit rendering cost, but no physical-device performance claim is made. The application remains frontend-only with the existing mocked services.

| Browser viewport | Explore hero | Expanded Architecture |
|---|---|---|
| 1920×1080 | Inspected/captured | Inspected/captured |
| 1600×900 | Inspected/captured | Inspected/captured |
| 1440×900 | Inspected/captured | Inspected/captured |
| 1366×768 | Inspected/captured | Inspected/captured |
| 1280×720 | Inspected/captured | Inspected/captured |
| 1024×768 | Inspected/captured | Inspected/captured |
| 1024×1366 | Inspected/captured | Inspected/captured |
| 834×1194 | Inspected/captured | Inspected/captured |
| 768×1024 | Inspected/captured | Inspected/captured |
| 430×932 | Inspected/captured | Inspected/captured |
| 390×844 | Inspected/captured | Inspected/captured |
| 360×800 | Inspected/captured | Inspected/captured |
| 900×650 | Inspected/captured | Inspected/captured |

Screenshots are stored outside the repository in D:/fyp-zahra/frontend-previews. Existing captures provide equivalent-size before views for 1920×1080, 1600×900, 1366×768, 1024×768, 834×1194, 430×932 and 360×800.

Before, 1366×768:

![Before laptop hero](D:/fyp-zahra/frontend-previews/hero-laptop.jpg)

After, 1366×768:

![Reconstructed laptop hero](D:/fyp-zahra/frontend-previews/reconstruction-1366x768.jpg)

Expanded Architecture at the same size:

![Expanded Architecture](D:/fyp-zahra/frontend-previews/architecture-1366x768.jpg)



11 October refinement: the green glow now follows the projected center between the front and back tower glass faces, transported through the existing annotation payload as an invisible presentation anchor. The dominant halo and chartreuse core share that center; the previous upward/right offsets are removed. No visible annotation or controller rewrite is introduced.

## 11 October — responsive auth, dashboard, and loader refinement

- Sign-in reserves a separate header and reduces form spacing on short viewports. The normal 665×524 and 390×844 layouts were inspected without needing to scroll the form. A scroll fallback remains for a keyboard, enlarged text, or validation messages.
- Sign-up field pairs stack on narrow widths, and its primary action uses the angular hero button.
- The dashboard shell uses a drawer below 900 px. Subscreens receive their actual available content size, so their breakpoints account for the sidebar. Overview cards use balanced 1/2/3/6-column rows, and chart headings, alerts, health labels, and footer content wrap.
- Explore's eyebrow contains text only. The primary hero arrow is `>`, and the navbar Sign In button shares the hero's angular shape and cream/lime/olive gradient.
- Secondary hero buttons have a lime/cream/lavender gradient border. Hover/focus glow is painted outside the shape with the face excluded; the interior remains clear.
- The user-provided 11 October MP4 supplies a four-second ribbon loop, recolored toward lime and purple, transcoded to a 189 KB animated WebP. A still asset serves reduced-motion users. The HTML startup view and Flutter loading views use the same asset.
- Validation: 21 existing motion, control, composition, and splash-navigation tests pass; focused analysis of the changed components reports no issues. Native phone keyboard behavior and physical-device performance remain unmeasured.

### October 11 — compact dashboard reference revision
- Viewed the supplied uiuxbunker dashboard video and adapted its compact charcoal shell, rounded panels, welcome header, purple feature surface, and dense event rows to the existing security console.
- All six role-specific cards stay in one row from 600 px of content width; phones use two columns (one below 340 px). Card contents scale down inside their bounds.
- The dashboard now uses the same vector shield and AutoPolicy wordmark as the landing page. Incident/health text has no rectangular border or background.
- Reduced desktop sidebar width to 200 px and tightened navigation spacing. Existing navigation and provider actions remain connected.
- Loader regenerated from the supplied recording at source resolution with direct color mapping, lossless encoding, subtle smoothing and high-quality image filtering. This replaces the previous low-quality 189 KB export with an 8.24 MB local asset, trading size for clean motion. Live generated assets refreshed without stopping the preview.
- Added responsive widget checks for 768, 1366, 1920 and 390 px widths; all four pass, including no layout exceptions and one-row assertions on tablet/desktop. Boot and updated theme-toggle checks also pass. The other 24 tests passed in the full run; its obsolete icon expectation was then corrected and both affected tests passed.
- Browser inspections at 1366 x 768, 768 x 1024 and 390 x 844 report no console errors.
Final verification: all 30 Flutter tests pass; focused analysis of the revised components and responsive tests reports no issues.

### October 11 — user correction: preserve visual identity
The prior video-inspired palette and rounded card redesign were rejected and removed. Original black/green shell, swatch fills, angular HUD geometry and chart-left/policy-right composition are restored. Only requested compact sizing, responsive rows, shared landing logo and borderless incident status remain. Sidebar hover highlights animate in the existing lime palette and collapse/expand uses a clipped 260 ms size transition. The loader now uses Flutter CustomPainter and an HTML canvas boot loop; neither uses an image or video. Old loader media assets were removed. Dashboard breakpoint and sidebar interaction tests pass; focused component analysis reports no issues. Future visual reference work must preserve the user's established palette and design unless explicitly requested.

### October 11 — full-height sidebar, requested frames, full-console density
- User explicitly selected hidden labels when expanded. Sidebar uses icons and tooltips in both widths; the brand remains visible in its own top section. Desktop right boundary now spans the full shell height, with the logo inside the sidebar. Existing lime/olive colors provide the animated gradient highlight. Collapse/expand animation and navigation handlers remain.
- Dashboard statistics use the first wide reference frame (top tab, stepped lower edge, diagonal stripes and corner cut). Existing fills are retained. Other system card frame designs are retained.
- Console content now scales at 0.9 on phones, 0.82 on tablets, and 0.88 on desktops; overview retains its established compact grid. MediaQuery and layout constraints use the same content bounds and scale, and hit testing follows the transform.
- Added responsive control rows, phone stat strips, fitted HUD card values and bounded content. Corrected overflowing filter bars, headers, graph controls, tables, simulation panels, settings rows, notification controls and role badges, preserving their children and callbacks.
- Audited all 12 pages at 320, 390, 768, 1024, 1366 and 1920 px, including scrolled content: 72 layout cases pass. Chart ticks retain spacing on the smallest screen. Native keyboard/soft-keyboard interactions in every dialog are outside this layout audit.
- No provider, model or service files changed. Live sidebar navigation and MQTT filtering verified. Existing MainLayout unused fields/theme-reveal warnings remain; focused new component analysis is clean.
Final full regression suite: all 104 Flutter tests pass. The additional top-boundary, logo, hidden-label, gradient and sidebar interaction assertions also pass.
