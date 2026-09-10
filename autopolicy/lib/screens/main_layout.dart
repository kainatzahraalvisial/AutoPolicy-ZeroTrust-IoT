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

class _MainLayoutState extends ConsumerState<MainLayout> with TickerProviderStateMixin {
  bool _isSidebarCollapsed = false;
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

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());

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

  // Returns tree navigation data structure with direct single-click items and expandable categories
  List<Map<String, dynamic>> _getTreeNavigation(int unreadNotificationsCount, String role) {
    return [
      {
        'category': 'Dashboard',
        'icon': Icons.dashboard_outlined,
        'index': 0,
      },
      {
        'category': 'Real-Time Traffic & IDS',
        'icon': Icons.radar_outlined,
        'index': 1,
      },
      {
        'category': 'Threat Intelligence & GNN',
        'icon': Icons.hub_outlined,
        'index': 3,
      },
      {
        'category': 'Zero-Trust Policy Engine',
        'icon': Icons.shield_outlined,
        'subItems': [
          {'index': 4, 'label': 'AI Policy Generator'},
          {'index': 5, 'label': 'Policy Deployments'},
        ],
      },
      {
        'category': 'Role-Based Access (RBAC)',
        'icon': Icons.admin_panel_settings_outlined,
        'index': 10,
      },
      {
        'category': 'Device Directory',
        'icon': Icons.router_outlined,
        'index': 6,
      },
      if (role == 'Manager' || role == 'Admin')
        {
          'category': 'Compliance & Governance',
          'icon': Icons.analytics_outlined,
          'index': 8,
        },
      {
        'category': 'Notifications',
        'icon': Icons.notifications_outlined,
        'index': 11,
        'badge': unreadNotificationsCount > 0 ? '$unreadNotificationsCount' : null,
      },
      {
        'category': 'System Settings',
        'icon': Icons.settings_outlined,
        'index': 9,
      },
    ];
  }

  Widget _buildTreeSidebar(BuildContext context, bool isDarkMode, String activeRole, int unreadCount) {
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
        final bool hasSelectedChild = !isDirectPage && subItems.any((sub) => (sub['index'] as int) == activeTab);
        final bool isExpanded = _expandedCategories[catTitle] ?? true;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Header / Direct Item Row
            InkWell(
              onTap: () {
                if (isDirectPage && directIndex != null) {
                  ref.read(navigationNotifierProvider.notifier).selectTab(directIndex);
                } else {
                  setState(() {
                    _expandedCategories[catTitle] = !isExpanded;
                  });
                }
              },
              hoverColor: Colors.white.withOpacity(0.05),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelectedDirect
                      ? (isDarkMode ? const Color(0xFFC4E320).withOpacity(0.20) : const Color(0xFF1E3A8A).withOpacity(0.12))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelectedDirect
                      ? Border.all(color: isDarkMode ? const Color(0xFFC4E320) : const Color(0xFF1E3A8A), width: 1)
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      catIcon,
                      size: 20,
                      color: (isSelectedDirect || hasSelectedChild)
                          ? (isDarkMode ? const Color(0xFFC4E320) : const Color(0xFF1E3A8A))
                          : (isDarkMode ? Colors.white70 : Colors.black87),
                    ),
                    if (!_isSidebarCollapsed) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          catTitle,
                          style: CyberTextStyles.technical(
                            fontSize: 14.0,
                            fontWeight: (isSelectedDirect || hasSelectedChild) ? FontWeight.bold : FontWeight.w600,
                            color: (isSelectedDirect || hasSelectedChild)
                                ? (isDarkMode ? const Color(0xFFC4E320) : const Color(0xFF1E3A8A))
                                : (isDarkMode ? Colors.white : Colors.black87),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (catBadge != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB91C1D),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            catBadge,
                            style: const TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (!isDirectPage)
                        Icon(
                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 18,
                          color: isDarkMode ? Colors.white54 : Colors.black45,
                        ),
                    ],
                  ],
                ),
              ),
            ),

            // Nested Sub-Items List (for expandable categories like Policy Engine)
            if (!isDirectPage && isExpanded && !_isSidebarCollapsed)
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
                        ref.read(navigationNotifierProvider.notifier).selectTab(subIndex);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 6, top: 2, bottom: 2, right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDarkMode ? const Color(0xFFC4E320).withOpacity(0.20) : const Color(0xFF1E3A8A).withOpacity(0.12))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? Border.all(color: isDarkMode ? const Color(0xFFC4E320) : const Color(0xFF1E3A8A), width: 1)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? (isDarkMode ? const Color(0xFFC4E320) : const Color(0xFF1E3A8A))
                                    : (isDarkMode ? Colors.white30 : Colors.black26),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                subLabel,
                                style: CyberTextStyles.technical(
                                  fontSize: 13.0,
                                  color: isSelected
                                      ? (isDarkMode ? Colors.white : Colors.black87)
                                      : (isDarkMode ? Colors.white60 : Colors.black54),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (subBadge != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB91C1D),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  subBadge,
                                  style: const TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.bold),
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
    final bool isMobile = Responsive.isMobile(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double sidebarWidth = _isSidebarCollapsed ? 70.0 : 260.0;

    final hasCriticalThreats = securityState.anomalies.any((anm) => !anm.isMitigated);
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
      body: Stack(
        children: [
          // Base background color or Midnight Indigo / Lavender-Blue gradient
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF000000) : const Color(0xFFE5DEFF),
              gradient: isDarkMode 
                  ? null // Pure obsidian black for authentic cyber hacking terminal
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFDCD6FD), // Soft periwinkle lavender
                        Color(0xFFFEE8DF), // Pastel peach-pink glow (matches the warm light)
                        Color(0xFFD2E3FC), // Soft periwinkle sky blue
                        Color(0xFFE5DEFF), // Soft warm lavender
                      ],
                    ),
            ),
          ),

          // Main Layout Grid & Elements
          CyberGrid(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      // 1. TOP INTERACTIVE DASHBOARD TELEMETRY HUD BAR
                      Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? const Color(0xFF0F0F0F) 
                            : Colors.white.withOpacity(0.15), // frosted light glass
                        border: Border(
                          bottom: BorderSide(
                            color: isDarkMode 
                                ? const Color(0xFF337418).withOpacity(0.45) 
                                : const Color(0xFFD6D6F2).withOpacity(0.40), // thin soft lavender border
                            width: 1,
                          ),
                        ),
                      ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Branding & Collapse Switch
                      Row(
                        children: [
                          if (!isMobile)
                            IconButton(
                              icon: Icon(
                                _isSidebarCollapsed ? Icons.menu_open : Icons.menu,
                                color: isDarkMode ? CyberColors.neonCyan : const Color(0xFF1E3A8A),
                                size: 18,
                              ),
                              onPressed: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
                            ),
                          Icon(
                            Icons.shield,
                            color: isDarkMode ? const Color(0xFF80A416) : const Color(0xFF1E3A8A), // Palette Olive Cyber Green shield
                            size: 26,
                          ),
                          if (screenWidth > 450) ...[
                            const SizedBox(width: 10),
                            Text(
                              'AUTOPOLICY',
                              style: CyberTextStyles.displayTitle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w900,
                                color: isDarkMode ? Colors.white : const Color(0xFF1E3A8A), // Metallic white brand title
                              ).copyWith(letterSpacing: 2.0),
                            ),
                          ],
                        ],
                      ),

                      // Telemetry Health Status
                      if (!isMobile && screenWidth > 880)
                        Builder(
                          builder: (context) {
                            final Color hudStatusColor = hasCriticalThreats 
                                ? CyberColors.alertRed 
                                : const Color(0xFF80A416);
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: hudStatusColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: hudStatusColor,
                                  width: 1,
                                ),
                              ),
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
                                          color: hudStatusColor,
                                          blurRadius: 4,
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    hasCriticalThreats ? 'ALERT: INCIDENT ACTIVE' : 'SYSTEM SHIELD: PROTECTED',
                                    style: CyberTextStyles.technical(
                                      fontSize: 10.0,
                                      color: hudStatusColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        ),

                      // Clock & Active User Scopes
                      Row(
                        children: [
                          // Clock
                          if (screenWidth > 620) ...[
                            Text(
                              _currentTimeString,
                              style: CyberTextStyles.technical(
                                color: isDarkMode ? CyberColors.neonCyan : const Color(0xFF1E3A8A), 
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          // Theme Toggle Button
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapDown: (details) {
                              _lastTapPosition = details.globalPosition;
                            },
                            child: Container(
                              key: _toggleButtonKey,
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDarkMode ? CyberColors.neonCyan.withOpacity(0.4) : const Color(0xFF1E3A8A).withOpacity(0.4), 
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
                                    color: isDarkMode ? CyberColors.neonCyan : const Color(0xFF1E3A8A),
                                    size: 16,
                                  ),
                                  onPressed: () {
                                    final RenderBox? buttonBox = _toggleButtonKey.currentContext?.findRenderObject() as RenderBox?;
                                    Offset centerGlobal;
                                    if (buttonBox != null) {
                                      final size = buttonBox.size;
                                      centerGlobal = buttonBox.localToGlobal(Offset(size.width / 2, size.height / 2));
                                    } else {
                                      centerGlobal = _lastTapPosition ?? Offset(MediaQuery.of(context).size.width - 150, 30);
                                    }
                                    Future.microtask(() {
                                      if (mounted) {
                                        _triggerCircularReveal(isDarkMode, centerGlobal);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth > 600 ? 16 : 8),
                          // Notifications Bell
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.notifications_outlined, 
                                  color: isDarkMode ? CyberColors.neonCyan : const Color(0xFF1E3A8A), 
                                  size: 20,
                                ),
                                onPressed: () {
                                  // Navigate directly to dedicated Notifications full-page view
                                  ref.read(navigationTabProvider.notifier).state = 11;
                                },
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: CyberColors.alertRed,
                                    ),
                                    child: Text(
                                      '$unreadCount',
                                      style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(width: screenWidth > 600 ? 8 : 4),
                          
                          // Interactive User Badge (Clicking opens Profile & Settings Modal)
                          GestureDetector(
                            onTap: () => _showUserProfileModal(context, username, activeRole, isDarkMode),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: screenWidth > 500 ? 12 : 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF0F0F0F) : Colors.white.withOpacity(0.35),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isDarkMode ? const Color(0xFF80A416).withOpacity(0.6) : const Color(0xFF1E3A8A).withOpacity(0.50),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.account_circle, color: isDarkMode ? const Color(0xFF80A416) : const Color(0xFF1E3A8A), size: 18),
                                  if (screenWidth > 500) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      screenWidth > 720 ? '$username | ${activeRole.toUpperCase()}' : username,
                                      style: CyberTextStyles.technical(
                                        fontSize: 11, 
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.arrow_drop_down, color: isDarkMode ? CyberColors.textMuted : Colors.black54, size: 16),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth > 600 ? 8 : 4),
                          // Quick Sign Out Button
                          IconButton(
                            icon: const Icon(Icons.logout, color: CyberColors.alertRed, size: 18),
                            onPressed: () {
                              ref.read(authProvider.notifier).signOut();
                              Navigator.of(context).pushReplacementNamed('/login');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 2. MAIN SPLIT BODY PANELS (SIDEBAR + ACTIVE SCREEN CONTAINER)
                Expanded(
                  child: Row(
                    children: [
                      // Collapsible tree sidebar for Web/Desktop views (Matching Image 2 media_1789025744076.png)
                      if (!isMobile)
                        Container(
                          width: sidebarWidth,
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? const Color(0xFF0F0F0F) 
                                : Colors.white.withOpacity(0.15), // frosted light glass
                            border: Border(
                              right: BorderSide(
                                color: isDarkMode 
                                    ? const Color(0xFF337418).withOpacity(0.45) 
                                    : const Color(0xFFD6D6F2).withOpacity(0.40), // thin warm purple border
                                width: 1,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildTreeSidebar(context, isDarkMode, activeRole, unreadCount),
                              ),
                            ],
                          ),
                        ),

                      // Main dashboard subscreen view
                      Expanded(
                        child: _buildCentralContentArea(context, isDarkMode),
                      ),
                    ],
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
                color: isDarkMode ? const Color(0xFF0F0F0F) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDarkMode 
                        ? const Color(0xFF337418).withOpacity(0.45) 
                        : const Color(0xFF0F1530).withOpacity(0.08), 
                    width: 1,
                  ),
                ),
              ),
              child: Builder(
                builder: (context) {
                  final activeTab = ref.watch(navigationTabProvider);
                  final mobileMenuItems = [
                    {'index': 0, 'label': 'Dashboard', 'icon': Icons.dashboard_outlined},
                    {'index': 1, 'label': 'Traffic', 'icon': Icons.radar_outlined},
                    {'index': 10, 'label': 'RBAC', 'icon': Icons.shield_outlined},
                    {'index': 11, 'label': 'Alerts', 'icon': Icons.notifications_outlined},
                    {'index': 9, 'label': 'Settings', 'icon': Icons.settings_outlined},
                  ];

                  final int activeIdx = mobileMenuItems.any((item) => item['index'] == activeTab)
                      ? mobileMenuItems.indexWhere((item) => item['index'] == activeTab)
                      : 0;

                  return BottomNavigationBar(
                    currentIndex: activeIdx,
                    onTap: (navIdx) {
                      ref.read(navigationTabProvider.notifier).state = mobileMenuItems[navIdx]['index'] as int;
                    },
                    backgroundColor: isDarkMode ? const Color(0xFF0F0F0F) : Colors.white,
                    selectedItemColor: isDarkMode ? const Color(0xFFC4E320) : const Color(0xFF1E3A8A),
                    unselectedItemColor: isDarkMode ? const Color(0xFF888888) : const Color(0xFF64748B),
                    selectedLabelStyle: CyberTextStyles.technical(fontSize: 9.0),
                    unselectedLabelStyle: CyberTextStyles.technical(fontSize: 8.0),
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: _getActiveScreen(),
    );
  }

  Widget _buildCentralContentArea(BuildContext context, bool isDarkMode) {
    if (_isRevealing && _oldThemeUI != null && _newThemeUI != null) {
      final RenderBox? renderBox = _contentAreaKey.currentContext?.findRenderObject() as RenderBox?;
      final contentSize = renderBox?.size ?? MediaQuery.of(context).size;
      
      Offset localCenter = Offset.zero;
      if (_revealCenter != null) {
        if (renderBox != null) {
          localCenter = renderBox.globalToLocal(_revealCenter!);
        } else {
          final double sidebarWidth = _isSidebarCollapsed ? 70.0 : 240.0;
          localCenter = Offset(
            _revealCenter!.dx - (Responsive.isMobile(context) ? 0.0 : sidebarWidth),
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

  void _showUserProfileModal(BuildContext context, String username, String role, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: CyberHudFrame(
            design: CyberFrameDesign.yellowTabNotch,
            baseBorderColor: const Color(0xFF80A416),
            surfaceColor: isDarkMode ? const Color(0xEF0F0F0F) : Colors.white,
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_circle, color: Color(0xFF80A416), size: 28),
                          const SizedBox(width: 10),
                          Text('OPERATOR PROFILE & ACCESS', style: CyberTextStyles.heading2.copyWith(fontSize: 16)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: CyberColors.textMuted, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(color: CyberColors.borderNeonCyan),
                  const SizedBox(height: 14),
                  _buildProfileRow('USERNAME', username, CyberColors.neonCyan),
                  const SizedBox(height: 8),
                  _buildProfileRow('SECURITY ROLE', role.toUpperCase(), const Color(0xFF80A416)),
                  const SizedBox(height: 8),
                  _buildProfileRow('JWT SESSION', 'ACTIVE (TLS 1.3 ENCRYPTED)', CyberColors.neonGreen),
                  const SizedBox(height: 8),
                  _buildProfileRow('PERMISSIONS', role == 'Admin' ? 'FULL SYSTEM CONTROL' : 'INCIDENT RESPONSE', const Color(0xFFC5C764)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF80A416)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.settings, color: Color(0xFF80A416), size: 16),
                          label: Text(
                            'SYSTEM SETTINGS',
                            style: CyberTextStyles.technical(color: const Color(0xFF80A416), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            ref.read(navigationTabProvider.notifier).state = 9;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CyberColors.alertRed.withOpacity(0.2),
                            side: const BorderSide(color: CyberColors.alertRed),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.logout, color: CyberColors.alertRed, size: 16),
                          label: Text(
                            'SIGN OUT',
                            style: CyberTextStyles.technical(color: CyberColors.alertRed, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            ref.read(authProvider.notifier).signOut();
                            Navigator.of(context).pushReplacementNamed('/login');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileRow(String label, String val, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: CyberTextStyles.techMuted.copyWith(fontSize: 11)),
        Text(val, style: CyberTextStyles.technical(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
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
