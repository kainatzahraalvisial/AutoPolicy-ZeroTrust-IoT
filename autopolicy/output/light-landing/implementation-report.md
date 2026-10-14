AutoPolicy light landing refinement and dashboard health-card sizing

Dashboard correction:
The right-hand dashboard Column used its default centered cross-axis alignment, and the health Container had no explicit width. Its intrinsic content width therefore left blank space on both sides. The right column now stretches its children and the health panel explicitly fills the available width. Its contents, data and functionality are unchanged. Checked in light and dark dashboard views at 1440x900.

Light landing design:
- Added LandingLightPalette in lib/theme/colors.dart: ivory #FAF9F6 / #F5F3EB, graphite #20251D / #646B60, heading olive #718D17, chartreuse #C4E326, mint #D7F8E7, lavender #E6DFFB / #9D8DF1, cyan #D9F2F5, and blush #F9E3EA.
- lib/landing/visual_polish.dart: a separate light-only atmosphere painter uses static blended elliptical fields. Mint/pistachio follows the projected tower anchor; lavender sits upper-right, blush lower-left, cyan lower-right, and a distinct pale-lime floor field sits below the platform. The orbital arc keeps its existing geometry but uses a thin olive/chartreuse stroke and restrained local bloom. The shared heavy green nebula and extra dark-mode technical filaments are bypassed in light mode.
- lib/screens/landing_screen.dart: light graphite heading/body colors, olive emphasized line, and opt-in light landing button treatment. Existing typography, left rail, content structure and navigation remain.
- lib/landing/cinematic_button.dart: light-only pale-lime/chartreuse primary face, ivory secondary face with olive/violet outline, small hover lift and localized glow. This is explicitly enabled only on landing buttons; authentication screens retain their existing treatment.

Renderer:
- renderer/src/scene.js: only the light arms changed. Key intensity 2.35 (previously 2.8), rim 0.85 (0.7), environment 0.45 (0.38), bloom strength 0.40 (0.28). Dark values remain 2.25, 1.35, 0.56 and 0.62 respectively. Threshold 0.92 and radius 0.48 are unchanged.
- renderer/src/architectural-lighting.js: light emission multiplier 0.78 (0.56), an additional 1.15 roof-rim gain only in light mode, and light enclosure opacity 0.075 (0.10). Dark values and exact GLB geometry, transforms, camera fitting, packet ownership and narrative mapping remain untouched.
- assets/renderer/runtime.js: regenerated bundle.
- renderer/test/architectural-lighting.test.js: extended the existing real-GLB test to verify that light/dark switching restores the dark material emission state exactly.

Verification:
- Renderer bundling and Flutter web release build passed.
- All nine real-GLB renderer tests passed, including all 23 narrative stages/intermediate states, packets, DENY stopping, reverse restoration and the theme round trip.
- Browser light hero screenshots inspected at 1920x1080, 1440x900, 1024x768 and 390x844. No new overlap or clipping was observed.
- Before/after screenshots for both themes were captured at 1440x900. Dark parameter/code branches are preserved and the rendered comparison was inspected; no claim of full-image pixel equality is made because packets and traffic remain animated.
- Security intermediate anomaly/isolation and chapter/scroll input were exercised in light mode. This pass did not manually inspect every stage in the browser; the complete deterministic stage suite is automated.
- Dashboard health panel inspected in both themes; it now matches the width of the panels above it.

Limits:
The requested Sidecar/WALOS screenshots were not included with this message, so the light design follows the written palette and composition requirements. Pastel gradients are intentionally restrained. No physical mobile-device performance benchmark was run. The successful Flutter build retains the pre-existing CupertinoIcons font-family warning.

Console observation: one un-attributed MutationObserver.observe error was recorded during browser iframe/route inspection. The dashboard and landing continued to render and respond normally. No application-defined MutationObserver is present in lib/, web/ or renderer/src/; the message was not treated as proof of a clean browser console or conclusively assigned to a component.
