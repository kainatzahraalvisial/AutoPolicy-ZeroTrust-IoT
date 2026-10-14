AutoPolicy dashboard ambient chrome refinement

Changed for this request:
- lib/theme/colors.dart: added DashboardDarkPalette, separate from existing light and semantic alert/chart colors.
- lib/widgets/dashboard_chrome.dart (new): static, pointer-transparent ambient gradient painter and reusable dark navigation interaction surface.
- lib/screens/main_layout.dart: carbon expanded sidebar and compact dark rail, localized active markers, dark shell with a restrained border/shadow, and environmental backdrop. Fixed the drawer-close context check found during phone testing. Existing role-based navigation data, auth services, destinations, dashboard panels and charts are preserved.
- test/dashboard_chrome_test.dart (new): focused hover restoration and keyboard focus/activation checks.

Visual decisions:
The outer layer uses #090A07 with a broad upper-left #E6FF05 glow fading through #8BAC01 and a weaker #B4FF36 lower-left wash. Most of the canvas remains carbon. The dark shell is #11120D with a low-opacity #303523 border and black separation shadow, rather than an illuminated perimeter. Expanded navigation and the rail use a subtle dark olive/carbon gradient. Selected destinations use #1B2110, a chartreuse label/icon and a two-pixel content-facing marker. Hover uses #171910; focus has a crisp outline independent of glow. Navigation transitions are 180ms and disabled when reduced motion is requested. No large raster backgrounds, animated blurs or new dependencies were added. Light-theme surface colors remain on their existing branches.

Verification:
- Flutter web build succeeded.
- Two focused Flutter widget tests passed: keyboard Tab focus and Enter activation; mouse hover brightening and return to the muted state.
- Browser-rendered views inspected at 1920x1080 (expanded), 1440x900 (collapsed, expanded light and collapsed light), 1024x768 (expanded), 834x1194 (tablet layout), 390x844 (dark drawer), and 360x800 (phone dashboard and menu interaction).
- Selected navigation, collapse/expand, dark/light switching and phone drawer dismissal were checked. No new horizontal layout overlap or overflow was observed. Some existing narrow KPI captions use ellipsis as before.
- Light-theme screenshots confirm the existing beige surround and purple shield remain.
- Browser warning/error logs were empty at the checked dashboard load. The build still prints the existing CupertinoIcons font-family warning, but compiles successfully.

Screenshots in this directory record the inspected viewport states. The screenshot named dark-collapsed-focus records a browser navigation view; explicit hover and keyboard-focus correctness are established by the Flutter interaction tests.

No sign-out or external backend action was performed as part of visual verification. The lighting is a static native Flutter gradient; no physical-device GPU benchmark was performed.
