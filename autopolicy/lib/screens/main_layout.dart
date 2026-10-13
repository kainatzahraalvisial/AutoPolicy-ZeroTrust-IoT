import '../widgets/console_row.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/security_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/navigation_provider.dart';
import '../theme/colors.dart';
import '../theme/responsive.dart';
import '../theme/text_styles.dart';
import '../widgets/cyber_grid.dart';
import '../landing/visual_polish.dart';
import '../widgets/sidebar_brand.dart';
import '../widgets/cyber_hud_frame.dart';

// Screens placeholder imports (we will write them next)
import 'dashboard_overview.dart';
import 'traffic_monitor.dart';
import 'anomaly_detection.dart';
import 'gnn_relationship.dart';
import 'policy_generator.dart';
import 'policy_deployment.dart';
import 'device_management.dart';
import 'reports_analytics.dart';
import 'simulation_testing.dart';
import 'settings_management.dart';
import 'rbac_access_screen.dart';
import 'notifications_screen.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout>
    with TickerProviderStateMixin {
  bool _isSidebarCollapsed = false;
  bool _signingOut = false;
  String? _hoveredCategory;
  bool get _showSidebarLabels => !_isSidebarCollapsed;
  double _lastRailCenterY = 78.0;
  late final Timer _clockTimer;
  String _currentTimeString = '';

  // Expandable Tree Sidebar Categories State (matching Image 2 media_1789025744076.png)
  final Map<String, bool> _expandedCategories = {
    'Dashboard': true,
    'Zero-Trust & Policies': true,
    'Threat Intelligence': true,
    'Fleet Assets': true,
    'Compliance & Governance': true,
    'Notifications': true,
    'System Settings': true,
  };

  // Circular Reveal Theme Transition State
  late final AnimationController _revealController;
  Offset? _revealCenter;
  double _revealRadius = 0.0;
  bool _isRevealing = false;
  bool _oldThemeMode = false;
  Offset? _lastTapPosition;
  Widget? _oldThemeUI;
  Widget? _newThemeUI;
  final GlobalKey _contentAreaKey = GlobalKey();
  final GlobalKey _toggleButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final String hour = now.hour.toString().padLeft(2, '0');
    final String min = now.minute.toString().padLeft(2, '0');
    final String sec = now.second.toString().padLeft(2, '0');
    _currentTimeString = '$hour:$min:$sec';

    _clockTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _revealController.addListener(() {
      if (mounted) {
        setState(() {
          _revealRadius = _revealController.value;
        });
      }
    });

    _revealController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isRevealing = false;
            _oldThemeUI = null;
            _newThemeUI = null;
            ref.read(themeModeProvider.notifier).state = !_oldThemeMode;
          });
        }
      }
    });
  }

  double _getMaxRadius(Offset center, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = center.dx;
    final double cy = center.dy;

    final d1 = math.sqrt(cx * cx + cy * cy);
    final d2 = math.sqrt((w - cx) * (w - cx) + cy * cy);
    final d3 = math.sqrt(cx * cx + (h - cy) * (h - cy));
    final d4 = math.sqrt((w - cx) * (w - cx) + (h - cy) * (h - cy));

    return [d1, d2, d3, d4].reduce(math.max);
  }

  void _triggerCircularReveal(bool isDarkMode, Offset globalCenter) {
    _oldThemeUI = ProviderScope(
      overrides: [
        themeModeProvider.overrideWith((ref) => isDarkMode),
      ],
      child: ThemeUIWrapper(
        builder: (ctx) => _buildContentUI(ctx, isDarkMode),
      ),
    );

    _newThemeUI = ProviderScope(
      overrides: [
        themeModeProvider.overrideWith((ref) => !isDarkMode),
      ],
      child: ThemeUIWrapper(
        builder: (ctx) => _buildContentUI(ctx, !isDarkMode),
      ),
    );

    setState(() {
      _revealCenter = globalCenter;
      _isRevealing = true;
      _oldThemeMode = isDarkMode;
    });

    _revealController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _revealController.dispose();
    super.dispose();
  }

  void _updateClock() {
    final now = DateTime.now();
    final String hour = now.hour.toString().padLeft(2, '0');
    final String min = now.minute.toString().padLeft(2, '0');
    final String sec = now.second.toString().padLeft(2, '0');
    if (mounted) {
      setState(() {
        _currentTimeString = '$hour:$min:$sec';
      });
    }
  }

  // Resolves screens based on active tab index
  Widget _getActiveScreen() {
    final activeTab = ref.watch(navigationTabProvider);
    switch (activeTab) {
      case 0:
        return const DashboardOverview();
      case 1:
        return const TrafficMonitor();
      case 2:
        return const AnomalyDetection();
      case 3:
        return const GNNRelationship();
      case 4:
        return const PolicyGenerator();
      case 5:
        return const PolicyDeployment();
      case 6:
        return const DeviceManagement();
      case 7:
        return const SimulationTesting();
      case 8:
        return const ReportsAnalytics();
      case 9:
        return const SettingsManagement();
      case 10:
        return const RbacAccessScreen();
      case 11:
        return const NotificationsScreen();
      default:
        return const DashboardOverview();
    }
  }

  // Returns tree navigation data structure tailored strictly for each user role
  List<Map<String, dynamic>> _getTreeNavigation(
      int unreadNotificationsCount, String role) {
    final bool isAdmin = role == 'Admin';
    final bool isEngineer = role == 'Security Engineer' || role == 'engineer';
    final bool isManager = role == 'Manager';

    if (isManager) {
      return [
        {
          'category': 'Executive Dashboard',
          'icon': Icons.dashboard_outlined,
          'index': 0,
        },
        {
          'category': 'Security Posture',
          'icon': Icons.security_outlined,
          'index': 2,
        },
        {
          'category': 'Compliance & Governance',
          'icon': Icons.analytics_outlined,
          'index': 8,
        },
        {
          'category': 'Device Overview',
          'icon': Icons.router_outlined,
          'index': 6,
        },
        {
          'category': 'Notifications',
          'icon': Icons.notifications_outlined,
          'index': 11,
          'badge':
              unreadNotificationsCount > 0 ? '$unreadNotificationsCount' : null,
        },
      ];
    }

    if (isEngineer) {
      return [
        {
          'category': 'Operational Dashboard',
          'icon': Icons.dashboard_outlined,
          'index': 0,
        },
        {
          'category': 'Live Traffic & IDS',
          'icon': Icons.radar_outlined,
          'index': 1,
        },
        {
          'category': 'Anomalies & Alerts',
          'icon': Icons.warning_amber_outlined,
          'index': 2,
        },
        {
          'category': 'AI Policy Generator',
          'icon': Icons.auto_awesome_outlined,
          'index': 4,
        },
        {
          'category': 'Device Graph (GNN)',
          'icon': Icons.hub_outlined,
          'index': 3,
        },
        {
          'category': 'Policy Deployments',
          'icon': Icons.rocket_launch_outlined,
          'index': 5,
        },
        {
          'category': 'Simulation Testing',
          'icon': Icons.science_outlined,
          'index': 7,
        },
        {
          'category': 'Device Directory',
          'icon': Icons.router_outlined,
          'index': 6,
        },
        {
          'category': 'Operational Reports',
          'icon': Icons.analytics_outlined,
          'index': 8,
        },
        {
          'category': 'Notifications',
          'icon': Icons.notifications_outlined,
          'index': 11,
          'badge':
              unreadNotificationsCount > 0 ? '$unreadNotificationsCount' : null,
        },
      ];
    }

    // Default / Admin Full System Access
    return [
      {
        'category': 'Dashboard Overview',
        'icon': Icons.dashboard_outlined,
        'index': 0,
      },
      {
        'category': 'Live Traffic & Alerts',
        'icon': Icons.radar_outlined,
        'index': 1,
      },
      {
        'category': 'Anomalies & Alerts',
        'icon': Icons.warning_amber_outlined,
        'index': 2,
      },
      {
        'category': 'Generated Policies',
        'icon': Icons.auto_awesome_outlined,
        'index': 4,
      },
      {
        'category': 'Device Graph',
        'icon': Icons.hub_outlined,
        'index': 3,
      },
      {
        'category': 'Policy Deployment',
        'icon': Icons.rocket_launch_outlined,
        'index': 5,
      },
      {
        'category': 'Simulation Testing',
        'icon': Icons.science_outlined,
        'index': 7,
      },
      {
        'category': 'Users & Roles',
        'icon': Icons.admin_panel_settings_outlined,
        'index': 10,
      },
      {
        'category': 'Logs & Reports',
        'icon': Icons.analytics_outlined,
        'index': 8,
      },
      {
        'category': 'Notifications',
        'icon': Icons.notifications_outlined,
        'index': 11,
        'badge':
            unreadNotificationsCount > 0 ? '$unreadNotificationsCount' : null,
      },
      {
        'category': 'System Settings',
        'icon': Icons.settings_outlined,
        'index': 9,
      },
    ];
  }

  Widget _buildTreeSidebar(BuildContext context, bool isDarkMode,
      String activeRole, int unreadCount) {
    final activeTab = ref.watch(navigationTabProvider);
    final treeNav = _getTreeNavigation(unreadCount, activeRole);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: treeNav.length,
      itemBuilder: (context, catIdx) {
        final cat = treeNav[catIdx];
        final String catTitle = cat['category'] as String;
        final IconData catIcon = cat['icon'] as IconData;
        final String? catBadge = cat['badge'] as String?;
        final bool isDirectPage = cat.containsKey('index');
        final int? directIndex = isDirectPage ? (cat['index'] as int) : null;
        final List<Map<String, dynamic>> subItems = cat.containsKey('subItems')
            ? List<Map<String, dynamic>>.from(cat['subItems'] as List)
            : [];

        final bool isSelectedDirect = isDirectPage && activeTab == directIndex;
        final bool hasSelectedChild = !isDirectPage &&
            subItems.any((sub) => (sub['index'] as int) == activeTab);
        final bool isExpanded = _expandedCategories[catTitle] ?? true;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Header / Direct Item Row
            Tooltip(
                message: catTitle,
                child: MouseRegion(
                    onEnter: (_) => setState(() => _hoveredCategory = catTitle),
                    onExit: (_) => setState(() => _hoveredCategory = null),
                    child: InkWell(
                      onTap: () {
                        if (isDirectPage && directIndex != null) {
                          ref
                              .read(navigationNotifierProvider.notifier)
                              .selectTab(directIndex);
                          if (Scaffold.maybeOf(context)?.isDrawerOpen == true) {
                            Navigator.pop(context);
                          }
                        } else {
                          setState(() {
                            _expandedCategories[catTitle] = !isExpanded;
                          });
                        }
                      },
                      hoverColor: Colors.white.withOpacity(0.05),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelectedDirect
                              ? (isDarkMode
                                  ? const Color(0xFF9D8DF1)
                                  : const Color(0xFFCBB9A4))
                              : (_hoveredCategory == catTitle
                                  ? (isDarkMode
                                      ? const Color(0xFFA69BCD)
                                      : const Color(0xFFDDD0BD))
                                  : Colors.transparent),
                          borderRadius: BorderRadius.circular(8),
                          border: null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              catIcon,
                              size: 20,
                              color: (isSelectedDirect || hasSelectedChild)
                                  ? (isDarkMode
                                      ? (isSelectedDirect
                                          ? const Color(0xFF211B35)
                                          : const Color(0xFF3E345C))
                                      : const Color(0xFF1A1612))
                                  : (isDarkMode
                                      ? const Color(0xFF3E345C)
                                      : const Color(0xFF5C5247)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                catTitle,
                                style: CyberTextStyles.technical(
                                  fontSize: 12.0,
                                  fontWeight:
                                      (isSelectedDirect || hasSelectedChild)
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                  color: (isSelectedDirect || hasSelectedChild)
                                      ? (isDarkMode
                                          ? (isSelectedDirect
                                              ? const Color(0xFF211B35)
                                              : const Color(0xFF3E345C))
                                          : const Color(0xFF1A1612))
                                      : (isDarkMode
                                          ? const Color(0xFF3E345C)
                                          : const Color(0xFF4A433A)),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (catBadge != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB91C1D),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  catBadge,
                                  style: const TextStyle(
                                      fontSize: 9.5,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            if (!isDirectPage)
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 18,
                                color: isDarkMode
                                    ? const Color(0xFF51436E)
                                    : const Color(0xFF64748B),
                              ),
                          ],
                        ),
                      ),
                    ))),

            // Nested Sub-Items List (for expandable categories like Policy Engine)
            if (!isDirectPage && isExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 14.0),
                child: Column(
                  children: subItems.map((sub) {
                    final int subIndex = sub['index'] as int;
                    final String subLabel = sub['label'] as String;
                    final String? subBadge = sub['badge'] as String?;
                    final bool isSelected = activeTab == subIndex;

                    return GestureDetector(
                      onTap: () {
                        ref
                            .read(navigationNotifierProvider.notifier)
                            .selectTab(subIndex);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 6, top: 2, bottom: 2, right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDarkMode
                                  ? const Color(0xFF9D8DF1)
                                  : const Color(0xFFCBB9A4))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? (isDarkMode
                                        ? const Color(0xFF211B35)
                                        : const Color(0xFF1A1612))
                                    : (isDarkMode
                                        ? const Color(0xFF6C802A)
                                        : const Color(0xFF9E9488)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                subLabel,
                                style: CyberTextStyles.technical(
                                  fontSize: 13.0,
                                  color: isSelected
                                      ? (isDarkMode
                                          ? const Color(0xFF211B35)
                                          : const Color(0xFF1A1612))
                                      : (isDarkMode
                                          ? const Color(0xFF3E345C)
                                          : const Color(0xFF4A433A)),
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (subBadge != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB91C1D),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  subBadge,
                                  style: const TextStyle(
                                      fontSize: 9.5,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildExpandedSidebar(BuildContext context, bool isDarkMode,
      String activeRole, int unreadCount, String username) {
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFFB1A9DA) : const Color(0xFFE6DAC8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with prominent tight-cropped logo and collapse button
            Container(
              height: 66,
              padding: const EdgeInsets.only(left: 8, right: 4),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: SidebarBrand(
                          dark: isDarkMode, lightSurface: isDarkMode),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 30, minHeight: 30),
                    tooltip: 'Collapse sidebar',
                    icon: SidebarToggleIcon(
                        color: isDarkMode
                            ? const Color(0xFF3E345C)
                            : const Color(0xFF4A433A)),
                    onPressed: () => setState(() => _isSidebarCollapsed = true),
                  ),
                ],
              ),
            ),
            // Navigation items list
            Expanded(
              child: _buildTreeSidebar(
                  context, isDarkMode, activeRole, unreadCount),
            ),
            // Bottom Profile Section
            _buildBottomProfileSection(
                context, username, activeRole, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsedSidebar(BuildContext context, bool isDarkMode,
      String activeRole, int unreadCount, String username) {
    final activeTab = ref.watch(navigationTabProvider);
    final treeNav = _getTreeNavigation(unreadCount, activeRole);

    int selectedNavIndex = treeNav.indexWhere(
        (cat) => cat.containsKey('index') && cat['index'] == activeTab);
    if (selectedNavIndex < 0) {
      selectedNavIndex = treeNav.indexWhere((cat) =>
          cat.containsKey('subItems') &&
          (cat['subItems'] as List).any((s) => s['index'] == activeTab));
    }
    if (selectedNavIndex < 0) selectedNavIndex = 0;

    const double pillLeft = 4.0;
    const double pillRight = 46.0;
    const double pillWidth = pillRight - pillLeft; // 42.0
    const double pillCenterX = pillLeft + pillWidth / 2; // 25.0
    const double circleCenterX = 43.5;
    const double circleRadius = 17.5; // diameter 35.0
    const double pocketGap = 5.0;

    const double itemHeight = 44.0;
    const double topPadding = 52.0;
    final double targetCenterY =
        topPadding + (selectedNavIndex * itemHeight) + (itemHeight / 2);
    final double fromY = _lastRailCenterY;
    _lastRailCenterY = targetCenterY;

    final sidebarBg =
        isDarkMode ? const Color(0xFF9589BF) : const Color(0xFFE6DAC8);
    final highlightBg =
        isDarkMode ? const Color(0xFF9D8DF1) : const Color(0xFFCBB9A4);
    final activeIconColor =
        isDarkMode ? const Color(0xFF211B35) : const Color(0xFF1A1612);
    final unselectedIconColor =
        isDarkMode ? const Color(0xFF3E345C) : const Color(0xFF5C5247);

    return Container(
      width: 64,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Standalone shield: no circular surface or shadow behind the asset.
          Padding(
            padding: const EdgeInsets.only(left: pillLeft, bottom: 8),
            child: SizedBox(
              width: pillWidth,
              height: pillWidth,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isSidebarCollapsed = false;
                  });
                },
                borderRadius: BorderRadius.circular(pillWidth / 2),
                child: Center(
                  child: Tooltip(
                      message: 'Expand sidebar',
                      child: SidebarShield(dark: isDarkMode, size: 38)),
                ),
              ),
            ),
          ),

          // 2. The Floating Pill Rail with deep concentric pocket & separated circular highlight
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return TweenAnimationBuilder<double>(
                  key: ValueKey(targetCenterY),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeInOutCubic,
                  builder: (context, t, child) {
                    final double animatedY =
                        fromY + (targetCenterY - fromY) * t;
                    final bool isMoving = (targetCenterY - fromY).abs() > 1.0;
                    final double midPop =
                        isMoving ? math.sin(t * math.pi) : 0.0;
                    final double activeX = circleCenterX + midPop * 2.5;

                    return CustomPaint(
                      painter: CollapsedRailPainter(
                        railColor: sidebarBg,
                        activeCenterY: animatedY,
                        pillLeft: pillLeft,
                        pillRight: pillRight,
                        circleCenterX: activeX,
                        pocketRadius: circleRadius + pocketGap - (midPop * 1.5),
                        filletRadius: 12.0,
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Separated circular highlight badge nestled inside the concave pocket
                          Positioned(
                            top: animatedY - circleRadius,
                            left: activeX - circleRadius,
                            child: Container(
                              width: circleRadius * 2,
                              height: circleRadius * 2,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: highlightBg,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(isDarkMode ? 0.30 : 0.10),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Rail Items Column
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top hamburger icon centered inside the vertical pill
                              SizedBox(
                                height: topPadding,
                                width: 64,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: pillCenterX - 18),
                                    child: SizedBox(
                                      width: 36,
                                      height: 36,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        tooltip: 'Expand navigation',
                                        icon: SidebarToggleIcon(
                                          color: isDarkMode
                                              ? const Color(0xFF3E345C)
                                              : const Color(0xFF4A433A),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isSidebarCollapsed = false;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // List of navigation icons
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children:
                                        List.generate(treeNav.length, (idx) {
                                      final cat = treeNav[idx];
                                      final String catTitle =
                                          cat['category'] as String;
                                      final IconData catIcon =
                                          cat['icon'] as IconData;
                                      final bool isDirect =
                                          cat.containsKey('index');
                                      final int? directIndex = isDirect
                                          ? (cat['index'] as int)
                                          : null;
                                      final bool isSelected =
                                          idx == selectedNavIndex;
                                      final double iconCenterX = isSelected
                                          ? circleCenterX
                                          : pillCenterX;

                                      return SizedBox(
                                        height: itemHeight,
                                        width: 64,
                                        child: AnimatedPadding(
                                          duration:
                                              const Duration(milliseconds: 360),
                                          curve: Curves.easeOutBack,
                                          padding: EdgeInsets.only(
                                              left: iconCenterX - 18),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Tooltip(
                                              message: catTitle,
                                              preferBelow: false,
                                              child: InkWell(
                                                onTap: () {
                                                  if (isDirect &&
                                                      directIndex != null) {
                                                    ref
                                                        .read(
                                                            navigationNotifierProvider
                                                                .notifier)
                                                        .selectTab(directIndex);
                                                  } else {
                                                    setState(() {
                                                      _isSidebarCollapsed =
                                                          false;
                                                    });
                                                  }
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                child: SizedBox(
                                                  width: 36,
                                                  height: 36,
                                                  child: Center(
                                                    child: Icon(
                                                      catIcon,
                                                      size: 19,
                                                      color: isSelected
                                                          ? activeIconColor
                                                          : unselectedIconColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),

                              // Bottom profile avatar & logout centered on pillCenterX
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: pillCenterX - 14),
                                child: Tooltip(
                                  message: '$username ($activeRole)',
                                  child: InkWell(
                                    onTap: () => _showUserProfileModal(context,
                                        username, activeRole, isDarkMode),
                                    borderRadius: BorderRadius.circular(16),
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: highlightBg,
                                      child: Text(
                                        username.isNotEmpty
                                            ? username
                                                .substring(0, 1)
                                                .toUpperCase()
                                            : 'A',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: activeIconColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: pillCenterX - 18),
                                child: SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    tooltip: 'Sign out',
                                    icon: Icon(
                                      Icons.logout,
                                      size: 18,
                                      color: isDarkMode
                                          ? const Color(0xFF51436E)
                                          : const Color(0xFF5C5247),
                                    ),
                                    onPressed: _signingOut ? null : _signOut,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider);
    return _buildMainUI(context, isDarkMode);
  }

  Widget _buildMainUI(BuildContext context, bool isDarkMode) {
    final authSession = ref.watch(authProvider);
    final securityState = ref.watch(securityProvider);

    CyberTextStyles.updateTheme(isDarkMode);

    final String activeRole = authSession?.role ?? 'Admin';
    final String username = authSession?.username ?? 'GUEST';
    final bool isMobile = MediaQuery.sizeOf(context).width < 900;
    final double screenWidth = MediaQuery.of(context).size.width;

    final hasCriticalThreats =
        securityState.anomalies.any((anm) => !anm.isMitigated);
    final int unreadCount = securityState.notifications.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final navNotifier = ref.read(navigationNotifierProvider.notifier);
        if (navNotifier.canGoBack()) {
          navNotifier.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: isMobile
            ? Drawer(
                backgroundColor: isDarkMode
                    ? const Color(0xFFB1A9DA)
                    : const Color(0xFFE6DAC8),
                child: SafeArea(
                    child: Column(children: [
                  Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                          width: 170,
                          height: 42,
                          child: AutoPolicyWordmark(dark: isDarkMode))),
                  Expanded(
                      child: _buildTreeSidebar(
                          context, isDarkMode, activeRole, unreadCount)),
                  _buildBottomProfileSection(
                      context, username, activeRole, isDarkMode),
                ])))
            : null,
        body: Stack(
          children: [
            // Base background color: when collapsed, provide clean contrasting backdrop
            // so the floating pill rail and separated circular pocket are crisp in both themes
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              decoration: BoxDecoration(
                color: _isSidebarCollapsed
                    ? (isDarkMode
                        ? const Color(0xFFB1A9DA)
                        : const Color(0xFFFAF8F4))
                    : (isDarkMode
                        ? const Color(0xFFB1A9DA)
                        : const Color(0xFFE6DAC8)),
              ),
            ),

            // Main Layout Row
            CyberGrid(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Row(
                      children: [
                        if (!isMobile)
                          AnimatedSize(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeInOutCubic,
                            alignment: Alignment.centerLeft,
                            clipBehavior: Clip.none,
                            child: _isSidebarCollapsed
                                ? _buildCollapsedSidebar(context, isDarkMode,
                                    activeRole, unreadCount, username)
                                : _buildExpandedSidebar(context, isDarkMode,
                                    activeRole, unreadCount, username),
                          ),
                        Expanded(
                          child: Container(
                            margin: isMobile
                                ? EdgeInsets.zero
                                : const EdgeInsets.only(
                                    top: 10, bottom: 10, right: 12, left: 6),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xFF141518)
                                  : Colors.white,
                              borderRadius: isMobile
                                  ? BorderRadius.zero
                                  : BorderRadius.circular(24),
                              border: null,
                              boxShadow: isMobile
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(
                                            isDarkMode ? 0.35 : 0.05),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),
                            child: ClipRRect(
                              borderRadius: isMobile
                                  ? BorderRadius.zero
                                  : BorderRadius.circular(24),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? const Color(0xFF141518)
                                          : Colors.white,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: isDarkMode
                                              ? const Color(0xFF22242A)
                                              : const Color(0xFFEFE8DD),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: ConsoleRow(
                                      compact: true,
                                      minimumWidth: 360,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Branding & Drawer toggle for mobile
                                        if (isMobile)
                                          Row(
                                            children: [
                                              Builder(
                                                builder: (ctx) => IconButton(
                                                  tooltip: 'Open navigation',
                                                  icon: SidebarToggleIcon(
                                                      color: isDarkMode
                                                          ? Colors.white70
                                                          : const Color(
                                                              0xFF4A433A)),
                                                  onPressed: () =>
                                                      Scaffold.of(ctx)
                                                          .openDrawer(),
                                                ),
                                              ),
                                              SizedBox(
                                                width: screenWidth < 450
                                                    ? 130
                                                    : 170,
                                                height: 42,
                                                child: AutoPolicyWordmark(
                                                    dark: isDarkMode),
                                              ),
                                            ],
                                          ),

                                        // Telemetry Health Status
                                        if (!isMobile && screenWidth > 1150)
                                          Builder(builder: (context) {
                                            final Color hudStatusColor =
                                                hasCriticalThreats
                                                    ? CyberColors.alertRed
                                                    : const Color(0xFF16A34A);
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: hudStatusColor,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: hudStatusColor
                                                              .withOpacity(0.5),
                                                          blurRadius: 4,
                                                          spreadRadius: 1,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    hasCriticalThreats
                                                        ? 'ALERT: INCIDENT ACTIVE'
                                                        : 'SYSTEM SHIELD: PROTECTED',
                                                    style: CyberTextStyles
                                                        .technical(
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: hudStatusColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),

                                        // Clock & Active User Controls
                                        Row(
                                          children: [
                                            // Theme Mode Switcher Pill (Dark / Light)
                                            InkWell(
                                              onTap: () {
                                                ref
                                                    .read(themeModeProvider
                                                        .notifier)
                                                    .state = !isDarkMode;
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: isDarkMode
                                                      ? const Color(0xFF22242A)
                                                      : const Color(0xFFEFE8DD),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: isDarkMode
                                                        ? const Color(
                                                            0xFF333640)
                                                        : const Color(
                                                            0xFFD4C5B3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      isDarkMode
                                                          ? Icons
                                                              .dark_mode_outlined
                                                          : Icons
                                                              .light_mode_outlined,
                                                      size: 13,
                                                      color: isDarkMode
                                                          ? Colors.white
                                                          : const Color(
                                                              0xFF4A433A),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      isDarkMode
                                                          ? 'DARK'
                                                          : 'LIGHT',
                                                      style: TextStyle(
                                                        fontFamily: 'monospace',
                                                        fontSize: 10.5,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isDarkMode
                                                            ? Colors.white
                                                            : const Color(
                                                                0xFF4A433A),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            // Clock
                                            if (screenWidth > 1050) ...[
                                              Text(
                                                _currentTimeString,
                                                style:
                                                    CyberTextStyles.technical(
                                                  color: isDarkMode
                                                      ? const Color(0xFF9E9EA8)
                                                      : const Color(0xFF4A433A),
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                            ],
                                            // Notifications Bell
                                            Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    Icons
                                                        .notifications_outlined,
                                                    color: isDarkMode
                                                        ? const Color(
                                                            0xFF9E9EA8)
                                                        : const Color(
                                                            0xFF4A433A),
                                                    size: 20,
                                                  ),
                                                  onPressed: () {
                                                    ref
                                                        .read(
                                                            navigationTabProvider
                                                                .notifier)
                                                        .state = 11;
                                                  },
                                                ),
                                                if (unreadCount > 0)
                                                  Positioned(
                                                    top: 6,
                                                    right: 6,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      decoration:
                                                          const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: CyberColors
                                                            .alertRed,
                                                      ),
                                                      child: Text(
                                                        '$unreadCount',
                                                        style: const TextStyle(
                                                            fontSize: 8,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildCentralContentArea(
                                        context, isDarkMode),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Bottom navigation shell optimized only for Mobile screen sizes
        bottomNavigationBar: isMobile
            ? Container(
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF101114)
                      : const Color(0xFFE6DAC8),
                  border: Border(
                    top: BorderSide(
                      color: isDarkMode
                          ? const Color(0xFF22242A)
                          : const Color(0xFFDDD0BD),
                      width: 1,
                    ),
                  ),
                ),
                child: Builder(
                  builder: (context) {
                    final activeTab = ref.watch(navigationTabProvider);
                    final mobileMenuItems = [
                      {
                        'index': 0,
                        'label': 'Dashboard',
                        'icon': Icons.dashboard_outlined
                      },
                      {
                        'index': 1,
                        'label': 'Traffic',
                        'icon': Icons.radar_outlined
                      },
                      {
                        'index': 10,
                        'label': 'RBAC',
                        'icon': Icons.shield_outlined
                      },
                      {
                        'index': 11,
                        'label': 'Alerts',
                        'icon': Icons.notifications_outlined
                      },
                      {
                        'index': 9,
                        'label': 'Settings',
                        'icon': Icons.settings_outlined
                      },
                    ];

                    final int activeIdx = mobileMenuItems
                            .any((item) => item['index'] == activeTab)
                        ? mobileMenuItems
                            .indexWhere((item) => item['index'] == activeTab)
                        : 0;

                    return BottomNavigationBar(
                      currentIndex: activeIdx,
                      onTap: (navIdx) {
                        ref.read(navigationTabProvider.notifier).state =
                            mobileMenuItems[navIdx]['index'] as int;
                      },
                      backgroundColor: isDarkMode
                          ? const Color(0xFF101114)
                          : const Color(0xFFE6DAC8),
                      selectedItemColor:
                          isDarkMode ? Colors.white : const Color(0xFF1A1612),
                      unselectedItemColor: isDarkMode
                          ? const Color(0xFF8E929E)
                          : const Color(0xFF5C5247),
                      selectedLabelStyle:
                          CyberTextStyles.technical(fontSize: 9.0),
                      unselectedLabelStyle:
                          CyberTextStyles.technical(fontSize: 8.0),
                      type: BottomNavigationBarType.fixed,
                      items: mobileMenuItems
                          .map((item) => BottomNavigationBarItem(
                                icon: Icon(item['icon'] as IconData, size: 18),
                                label: item['label'] as String,
                              ))
                          .toList(),
                    );
                  },
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildContentUI(BuildContext context, bool isDarkMode) {
    return _getActiveScreen();
  }

  Widget _buildCentralContentArea(BuildContext context, bool isDarkMode) {
    if (_isRevealing && _oldThemeUI != null && _newThemeUI != null) {
      final RenderBox? renderBox =
          _contentAreaKey.currentContext?.findRenderObject() as RenderBox?;
      final contentSize = renderBox?.size ?? MediaQuery.of(context).size;

      Offset localCenter = Offset.zero;
      if (_revealCenter != null) {
        if (renderBox != null) {
          localCenter = renderBox.globalToLocal(_revealCenter!);
        } else {
          final double sidebarWidth = _isSidebarCollapsed ? 70.0 : 240.0;
          localCenter = Offset(
            _revealCenter!.dx -
                (Responsive.isMobile(context) ? 0.0 : sidebarWidth),
            _revealCenter!.dy - 60.0,
          );
        }
      }

      final maxRadius = _getMaxRadius(localCenter, contentSize);

      return Stack(
        key: _contentAreaKey,
        children: [
          // 1. OLD THEME LAYOUT (Cached)
          _oldThemeUI!,

          // 2. NEW THEME LAYOUT (Cached & Clipped inside the growing circular reveal)
          ClipPath(
            clipper: CircleRevealClipper(
              center: localCenter,
              radius: _revealRadius * maxRadius,
            ),
            child: _newThemeUI!,
          ),
        ],
      );
    }

    return Container(
      key: _contentAreaKey,
      child: _buildContentUI(context, isDarkMode),
    );
  }

  Future<void> _signOut() async {
    if (_signingOut) return;
    setState(() => _signingOut = true);
    try {
      await ref.read(authProvider.notifier).signOut();
      if (!mounted) return;
      ref.invalidate(navigationNotifierProvider);
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Sign out failed. Please try again.')));
      }
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  Widget _buildBottomProfileSection(
      BuildContext context, String username, String role, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFFB1A9DA) : const Color(0xFFE6DAC8),
        border: Border(
          top: BorderSide(
            color:
                isDarkMode ? const Color(0xFF968ABF) : const Color(0xFFDDD0BD),
            width: 1,
          ),
        ),
      ),
      child: InkWell(
        onTap: () => _showUserProfileModal(context, username, role, isDarkMode),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color:
                isDarkMode ? const Color(0xFFA79CCE) : const Color(0xFFDDD0BD),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isDarkMode
                    ? const Color(0xFF9D8DF1)
                    : const Color(0xFFCBB9A4),
                child: Text(
                  username.isNotEmpty
                      ? username.substring(0, 1).toUpperCase()
                      : 'A',
                  style: CyberTextStyles.technical(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? const Color(0xFF211B35)
                        : const Color(0xFF1A1612),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      username.toUpperCase(),
                      style: CyberTextStyles.technical(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: isDarkMode
                            ? const Color(0xFF211B35)
                            : const Color(0xFF1A1612),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF9D8DF1)
                            : const Color(0xFFCBB9A4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: isDarkMode
                              ? const Color(0xFF3E345C)
                              : const Color(0xFF1A1612),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.unfold_more,
                size: 16,
                color: isDarkMode
                    ? const Color(0xFF51436E)
                    : const Color(0xFF5C5247),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserProfileModal(
      BuildContext context, String username, String role, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: CyberHudFrame(
            design: CyberFrameDesign.yellowTabNotch,
            baseBorderColor:
                isDarkMode ? const Color(0xFF333640) : const Color(0xFFCBB9A4),
            surfaceColor: isDarkMode ? const Color(0xEF141518) : Colors.white,
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor:
                                const Color(0xFF80A416).withOpacity(0.2),
                            child: const Icon(Icons.account_circle,
                                color: Color(0xFF80A416), size: 28),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('OPERATOR PROFILE & CREDENTIALS',
                                  style: CyberTextStyles.heading2
                                      .copyWith(fontSize: 15)),
                              Text('ZERO-TRUST IDENTITY ENCLAVE',
                                  style: CyberTextStyles.techMuted
                                      .copyWith(fontSize: 9.5)),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: CyberColors.textMuted, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(color: CyberColors.borderNeonCyan),
                  const SizedBox(height: 12),
                  _buildProfileRow('FULL NAME', username, CyberColors.neonCyan),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('WORK EMAIL (LOCKED)',
                          style:
                              CyberTextStyles.techMuted.copyWith(fontSize: 11)),
                      Row(
                        children: [
                          const Icon(Icons.lock_outline,
                              size: 12, color: Color(0xFF80A416)),
                          const SizedBox(width: 4),
                          Text(
                            '${username.toLowerCase().replaceAll(' ', '')}@autopolicy.zero-trust',
                            style: CyberTextStyles.technical(
                                color: const Color(0xFFC5C764),
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildProfileRow('ASSIGNED ROLE', role.toUpperCase(),
                      const Color(0xFF8B5CF6)),
                  const SizedBox(height: 8),
                  _buildProfileRow(
                      'LAST LOGIN',
                      'Today at 09:42 UTC (IP: 192.168.1.105)',
                      CyberColors.neonGreen),
                  const SizedBox(height: 8),
                  _buildProfileRow(
                      'SESSION TOKEN',
                      'ACTIVE (TLS 1.3 · ZERO-TRUST VALIDATED)',
                      CyberColors.neonGreen),
                  const SizedBox(height: 8),
                  _buildProfileRow(
                      'PERMISSIONS',
                      role == 'Admin'
                          ? 'ROOT ADMINISTRATOR (FULL CONTROL)'
                          : 'INCIDENT INVESTIGATION & TRIAGE',
                      const Color(0xFFFFE997)),
                  const SizedBox(height: 18),
                  const Divider(color: Color(0x3380A416)),
                  const SizedBox(height: 12),

                  // Action Buttons: Change Password, Edit Profile, Sign Out
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF80A416)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          icon: const Icon(Icons.key,
                              color: Color(0xFF80A416), size: 15),
                          label: Text(
                            'CHANGE PASSWORD',
                            style: CyberTextStyles.technical(
                                color: const Color(0xFF80A416),
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showChangePasswordDialog(context, isDarkMode);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF8B5CF6)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          icon: const Icon(Icons.edit,
                              color: Color(0xFF8B5CF6), size: 15),
                          label: Text(
                            'EDIT PROFILE',
                            style: CyberTextStyles.technical(
                                color: const Color(0xFF8B5CF6),
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showEditProfileDialog(
                                context, username, isDarkMode);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CyberColors.alertRed.withOpacity(0.2),
                        side: const BorderSide(color: CyberColors.alertRed),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.logout,
                          color: CyberColors.alertRed, size: 16),
                      label: Text(
                        'SIGN OUT FROM ZERO-TRUST CONSOLE',
                        style: CyberTextStyles.technical(
                            color: CyberColors.alertRed,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _signOut();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context, bool isDarkMode) {
    final curCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final cnfCtrl = TextEditingController();
    bool obscure = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor:
              isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAF9F6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFF80A416), width: 1.5),
          ),
          title: Row(
            children: [
              const Icon(Icons.key, color: Color(0xFF80A416)),
              const SizedBox(width: 10),
              Text('CHANGE OPERATOR ACCESS KEY',
                  style: CyberTextStyles.heading3For(isDarkMode)
                      .copyWith(fontSize: 14)),
            ],
          ),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: curCtrl,
                  obscureText: obscure,
                  style: CyberTextStyles.techBodyFor(isDarkMode),
                  decoration:
                      const InputDecoration(labelText: 'CURRENT ACCESS KEY'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: newCtrl,
                  obscureText: obscure,
                  style: CyberTextStyles.techBodyFor(isDarkMode),
                  decoration: const InputDecoration(
                      labelText: 'NEW ACCESS KEY (MIN 8 CHARS)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cnfCtrl,
                  obscureText: obscure,
                  style: CyberTextStyles.techBodyFor(isDarkMode),
                  decoration: const InputDecoration(
                      labelText: 'CONFIRM NEW ACCESS KEY'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => setDlgState(() => obscure = !obscure),
                      icon: Icon(
                          obscure ? Icons.visibility : Icons.visibility_off,
                          size: 16,
                          color: const Color(0xFF80A416)),
                      label: Text(obscure ? 'SHOW KEYS' : 'HIDE KEYS',
                          style: CyberTextStyles.technical(
                              color: const Color(0xFF80A416), fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('CANCEL',
                  style: CyberTextStyles.technical(
                      color: isDarkMode
                          ? Colors.white54
                          : const Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF80A416)),
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Access key updated successfully. TLS session re-keyed.'),
                    backgroundColor: Color(0xFF337418),
                  ),
                );
              },
              child: Text('UPDATE ACCESS KEY',
                  style: CyberTextStyles.technical(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(
      BuildContext context, String currentName, bool isDarkMode) {
    final nameCtrl = TextEditingController(text: currentName);
    final deptCtrl = TextEditingController(text: 'SOC Cyber Incident Response');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAF9F6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.edit, color: Color(0xFF8B5CF6)),
            const SizedBox(width: 10),
            Text('EDIT OPERATOR IDENTITY',
                style: CyberTextStyles.heading3For(isDarkMode)
                    .copyWith(fontSize: 14)),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: CyberTextStyles.techBody,
                decoration:
                    const InputDecoration(labelText: 'DISPLAY IDENTITY / NAME'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: deptCtrl,
                style: CyberTextStyles.techBody,
                decoration:
                    const InputDecoration(labelText: 'DEPARTMENT / ENCLAVE'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('CANCEL',
                style: CyberTextStyles.technical(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6)),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Operator profile attributes updated successfully.'),
                  backgroundColor: Color(0xFF8B5CF6),
                ),
              );
            },
            child: Text('SAVE ATTRIBUTES',
                style: CyberTextStyles.technical(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String val, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: CyberTextStyles.techMuted.copyWith(fontSize: 11)),
        Text(val,
            style: CyberTextStyles.technical(
                color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class CircleRevealClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  CircleRevealClipper({required this.center, required this.radius});

  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(covariant CircleRevealClipper oldClipper) {
    return oldClipper.center != center || oldClipper.radius != radius;
  }
}

class ThemeUIWrapper extends StatelessWidget {
  final Widget Function(BuildContext) builder;
  const ThemeUIWrapper({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}

class CollapsedRailPainter extends CustomPainter {
  final Color railColor;
  final double activeCenterY;
  final double pillLeft;
  final double pillRight;
  final double circleCenterX;
  final double pocketRadius;
  final double filletRadius;

  CollapsedRailPainter({
    required this.railColor,
    required this.activeCenterY,
    this.pillLeft = 4.0,
    this.pillRight = 46.0,
    this.circleCenterX = 43.5,
    this.pocketRadius = 22.5,
    this.filletRadius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = railColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final double h = size.height;
    final double pillWidth = pillRight - pillLeft;
    final double r = pillWidth / 2.0; // 21.0 semicircular top/bottom cap

    // Geometry for exact tangent-arc circular pocket on the right edge (x = pillRight)
    final double xf = pillRight - filletRadius;
    final double dx =
        (circleCenterX - xf).clamp(0.0, pocketRadius + filletRadius - 0.5);
    final double rSum = pocketRadius + filletRadius;
    final double dy = math.sqrt(rSum * rSum - dx * dx);
    final double alpha = math.atan2(dy, dx);

    // Clamp y0 so the top/bottom fillets never collide with the pill's top/bottom caps
    final double y0 = activeCenterY.clamp(
        r + dy + 1.0, math.max(r + dy + 2.0, h - r - dy - 1.0));

    final path = Path();
    // Start at top-left after top semicircular cap
    path.moveTo(pillLeft, r);
    // Top semicircular cap from (pillLeft, r) to (pillRight, r)
    path.arcTo(
      Rect.fromLTWH(pillLeft, 0, pillWidth, pillWidth),
      math.pi,
      math.pi,
      false,
    );

    // Right edge down to top fillet start
    path.lineTo(pillRight, y0 - dy);

    // 1. Top convex shoulder fillet arc turning smoothly into the pocket
    path.arcTo(
      Rect.fromCircle(center: Offset(xf, y0 - dy), radius: filletRadius),
      0.0,
      alpha,
      false,
    );

    // 2. Central concentric concave pocket wrapping around the active circle with uniform gap
    path.arcTo(
      Rect.fromCircle(center: Offset(circleCenterX, y0), radius: pocketRadius),
      alpha - math.pi,
      -2.0 * alpha,
      false,
    );

    // 3. Bottom convex shoulder fillet arc returning smoothly to the vertical right edge
    path.arcTo(
      Rect.fromCircle(center: Offset(xf, y0 + dy), radius: filletRadius),
      -alpha,
      alpha,
      false,
    );

    // Right edge down to bottom semicircular cap
    path.lineTo(pillRight, h - r);

    // Bottom semicircular cap from (pillRight, h - r) to (pillLeft, h - r)
    path.arcTo(
      Rect.fromLTWH(pillLeft, h - pillWidth, pillWidth, pillWidth),
      0.0,
      math.pi,
      false,
    );

    // Left vertical edge back to start
    path.lineTo(pillLeft, r);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CollapsedRailPainter oldDelegate) =>
      oldDelegate.railColor != railColor ||
      oldDelegate.activeCenterY != activeCenterY ||
      oldDelegate.pillLeft != pillLeft ||
      oldDelegate.pillRight != pillRight ||
      oldDelegate.circleCenterX != circleCenterX ||
      oldDelegate.pocketRadius != pocketRadius ||
      oldDelegate.filletRadius != filletRadius;
}
