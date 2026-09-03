import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/security_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/colors.dart';
import '../theme/responsive.dart';
import '../theme/text_styles.dart';
import '../widgets/cyber_grid.dart';
import '../widgets/glass_container.dart';

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
import 'login_screen.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> with TickerProviderStateMixin {
  int _activeTab = 0;
  bool _isSidebarCollapsed = false;
  bool _isNotificationPanelOpen = false;
  late final Timer _clockTimer;
  String _currentTimeString = '';

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
    
    // Set initial clock time without calling setState to prevent LateInitializationError
    final now = DateTime.now();
    final String hour = now.hour.toString().padLeft(2, '0');
    final String min = now.minute.toString().padLeft(2, '0');
    final String sec = now.second.toString().padLeft(2, '0');
    _currentTimeString = '$hour:$min:$sec';

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650), // Elegant cinematic speed
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
            // Set the final state of the theme provider globally
            ref.read(themeModeProvider.notifier).state = !_oldThemeMode;
          });
        }
      }
    });
  }

  // Calculate the maximum screen radius needed to cover all 4 screen corners from reveal origin
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
    // Use ThemeUIWrapper to defer _buildContentUI evaluation to Flutter's build phase.
    // This prevents executing ref.watch inside _triggerCircularReveal (which throws Riverpod exceptions outside of build).
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
    switch (_activeTab) {
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
      default:
        return const DashboardOverview();
    }
  }

  // Returns menu configuration items based on authenticated role RBAC controls
  List<Map<String, dynamic>> _getMenuItems(String role) {
    final List<Map<String, dynamic>> baseMenu = [
      {'index': 0, 'label': 'Overview', 'icon': Icons.dashboard_outlined},
      {'index': 1, 'label': 'Live Traffic', 'icon': Icons.radar_outlined},
      {'index': 2, 'label': 'Anomalies Feed', 'icon': Icons.crisis_alert},
      {'index': 3, 'label': 'GNN Graph View', 'icon': Icons.hub_outlined},
      {'index': 4, 'label': 'Auto Policy', 'icon': Icons.settings_suggest_outlined},
      {'index': 5, 'label': 'OPA Deployments', 'icon': Icons.rocket_launch_outlined},
      {'index': 6, 'label': 'Devices List', 'icon': Icons.router_outlined},
    ];

    // Security Engineer specific menu
    if (role == 'Security Engineer' || role == 'Admin') {
      baseMenu.add({'index': 7, 'label': 'Attack Simulator', 'icon': Icons.science_outlined});
    }

    // High level compliance management for Manager or Admin
    if (role == 'Manager' || role == 'Admin') {
      baseMenu.add({'index': 8, 'label': 'SOC Compliance', 'icon': Icons.analytics_outlined});
    }

    // System configurations only for Admins
    if (role == 'Admin') {
      baseMenu.add({'index': 9, 'label': 'User Access Control', 'icon': Icons.admin_panel_settings_outlined});
    }

    return baseMenu;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider);
    return _buildMainUI(context, isDarkMode);
  }

  Widget _buildMainUI(BuildContext context, bool isDarkMode) {
    final authSession = ref.watch(authProvider);
    final securityState = ref.watch(securityProvider);

    // Synchronize all static text styles globally with the current theme mode
    CyberTextStyles.updateTheme(isDarkMode);

    final String activeRole = authSession?.role ?? 'Admin';
    final String username = authSession?.username ?? 'GUEST';

    final menuItems = _getMenuItems(activeRole);
    final bool isMobile = Responsive.isMobile(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double sidebarWidth = _isSidebarCollapsed ? 70.0 : 240.0;

    final hasCriticalThreats = securityState.anomalies.any((anm) => !anm.isMitigated);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Base background color or Midnight Indigo / Lavender-Blue gradient
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF0C071A) : const Color(0xFFE5DEFF),
              gradient: isDarkMode 
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF06040C), // Deepest warm violet-black
                        Color(0xFF0D081E), // Rich warm midnight-violet
                        Color(0xFF050308), // Deep black-violet
                      ],
                    )
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
          
          // Aurora Glow Clouds (Disabled to keep Light Mode clean and plain white)
          if (false) ...[
            // Top Right Blue Glow
            Positioned(
              top: -150,
              right: -150,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0052D4).withOpacity(0.06),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F5FF).withOpacity(0.05),
                      blurRadius: 150,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Left Violet Glow
            Positioned(
              bottom: -150,
              left: -150,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF7000FF).withOpacity(0.05),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC700FF).withOpacity(0.04),
                      blurRadius: 150,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
          ],

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
                            ? const Color(0xFF0D081E).withOpacity(0.40) 
                            : Colors.white.withOpacity(0.15), // frosted light glass
                        border: Border(
                          bottom: BorderSide(
                            color: isDarkMode 
                                ? const Color(0xFF261545).withOpacity(0.40) 
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
                            color: isDarkMode ? CyberColors.neonGreen : const Color(0xFF1E3A8A),
                            size: 24,
                          ),
                          if (screenWidth > 450) ...[
                            const SizedBox(width: 8),
                            Text(
                              'AUTOPOLICY',
                              style: CyberTextStyles.displayTitle(
                                fontSize: 16.0,
                                color: isDarkMode ? CyberColors.neonGreen : const Color(0xFF1E3A8A), // Premium brand color
                              ),
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
                                : CyberColors.neonGreen;
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
                                  setState(() {
                                    _isNotificationPanelOpen = !_isNotificationPanelOpen;
                                  });
                                },
                              ),
                              if (securityState.notifications.isNotEmpty)
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
                                      '${securityState.notifications.length}',
                                      style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(width: screenWidth > 600 ? 8 : 4),
                          // User Badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth > 500 ? 10 : 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDarkMode ? CyberColors.panelBg : Colors.white.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(4),
                              border: isDarkMode ? null : Border.all(color: const Color(0xFFD6D6F2).withOpacity(0.50)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.account_circle, color: isDarkMode ? CyberColors.textMuted : const Color(0xFF1E3A8A), size: 16),
                                if (screenWidth > 500) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    screenWidth > 720 ? '$username | ${activeRole.toUpperCase()}' : username,
                                    style: CyberTextStyles.technical(
                                      fontSize: 10, 
                                      color: isDarkMode ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(width: screenWidth > 600 ? 8 : 4),
                          // Sign Out Button
                          IconButton(
                            icon: const Icon(Icons.logout, color: CyberColors.alertRed, size: 18),
                            onPressed: () {
                              ref.read(authProvider.notifier).signOut();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => LoginScreen()),
                              );
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
                      // Collapsible sidebar for Web/Desktop views
                      if (!isMobile)
                        Container(
                          width: sidebarWidth,
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? const Color(0xFF06040C).withOpacity(0.50) 
                                : Colors.white.withOpacity(0.15), // frosted light glass
                            border: Border(
                              right: BorderSide(
                                color: isDarkMode 
                                    ? const Color(0xFF261545).withOpacity(0.40) 
                                    : const Color(0xFFD6D6F2).withOpacity(0.40), // thin warm purple border
                                width: 1,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: menuItems.length,
                                  itemBuilder: (context, idx) {
                                    final item = menuItems[idx];
                                    final int screenIdx = item['index'] as int;
                                    final bool isSelected = _activeTab == screenIdx;
                                    final itemColor = isSelected
                                        ? const Color(0xFF7B96EC) // Premium Periwinkle Selected
                                        : (isDarkMode ? const Color(0xFF64748B) : Colors.black54);
 
                                    return GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => setState(() => _activeTab = screenIdx),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isSelected 
                                              ? CyberColors.panelBg.withOpacity(0.4) 
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isSelected 
                                                ? CyberColors.neonGreen.withOpacity(0.3) 
                                                : Colors.transparent,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              item['icon'] as IconData,
                                              size: 18,
                                              color: itemColor,
                                            ),
                                            if (!_isSidebarCollapsed) ...[
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  (item['label'] as String).toUpperCase(),
                                                  style: CyberTextStyles.technical(
                                                    fontSize: 11.0,
                                                    color: isSelected
                                                        ? (isDarkMode ? Colors.white : Colors.black)
                                                        : (isDarkMode ? const Color(0xFF64748B) : Colors.black54),
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
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

            // 3. FLOATING GLASS GLOBAL NOTIFICATIONS DRAWER OVERLAY
            if (_isNotificationPanelOpen)
              Positioned(
                top: 60,
                right: 16,
                bottom: isMobile ? 80 : 20,
                child: GlassContainer(
                  width: isMobile ? Responsive.screenWidth(context) - 32 : 360,
                  borderColor: CyberColors.neonCyan,
                  glow: CyberColors.cyanGlow,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SOC LOG CONSOLE',
                            style: CyberTextStyles.displayTitle(fontSize: 14.0),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: CyberColors.textMuted, size: 18),
                            onPressed: () => setState(() => _isNotificationPanelOpen = false),
                          ),
                        ],
                      ),
                      const Divider(color: CyberColors.borderNeonCyan),
                      const SizedBox(height: 8),
                      // List notifications
                      Expanded(
                        child: securityState.notifications.isEmpty
                            ? Center(
                                child: Text(
                                  'NO ACTIVE INCIDENTS YET',
                                  style: CyberTextStyles.techMuted,
                                ),
                              )
                            : ListView.builder(
                                itemCount: securityState.notifications.length,
                                itemBuilder: (context, idx) {
                                  final n = securityState.notifications[idx];
                                  Color statusColor = CyberColors.neonCyan;
                                  if (n.type == 'threat') statusColor = CyberColors.alertRed;
                                  if (n.type == 'warning') statusColor = CyberColors.warningOrange;
                                  if (n.type == 'deploy') statusColor = CyberColors.neonGreen;

                                  return Container(
                                    padding: const EdgeInsets.all(8),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white10,
                                      border: Border(left: BorderSide(color: statusColor, width: 3)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              n.type.toUpperCase(),
                                              style: CyberTextStyles.technical(color: statusColor, fontSize: 9.0),
                                            ),
                                            Text(
                                              '${n.timestamp.hour.toString().padLeft(2, '0')}:${n.timestamp.minute.toString().padLeft(2, '0')}:${n.timestamp.second.toString().padLeft(2, '0')}',
                                              style: CyberTextStyles.techMuted.copyWith(fontSize: 8.0),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          n.message.toUpperCase(),
                                          style: CyberTextStyles.interface(fontSize: 11.0, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 8),
                      // Clear button
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            ref.read(securityProvider.notifier).clearNotifications();
                          },
                          child: Text(
                            'CLEAR CONSOLE',
                            style: CyberTextStyles.technical(color: CyberColors.alertRed, fontSize: 11.0),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                color: isDarkMode ? CyberColors.cardBg : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDarkMode 
                        ? CyberColors.borderNeonCyan 
                        : const Color(0xFF0F1530).withOpacity(0.08), 
                    width: 1,
                  ),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: menuItems.any((item) => item['index'] == _activeTab)
                    ? menuItems.indexWhere((item) => item['index'] == _activeTab)
                    : 0,
                onTap: (navIdx) {
                  setState(() {
                    _activeTab = menuItems[navIdx]['index'] as int;
                  });
                },
                backgroundColor: isDarkMode ? CyberColors.cardBg : Colors.white,
                selectedItemColor: isDarkMode ? CyberColors.neonGreen : const Color(0xFF00875A),
                unselectedItemColor: isDarkMode ? CyberColors.textMuted : const Color(0xFF64748B),
                selectedLabelStyle: CyberTextStyles.technical(fontSize: 9.0),
                unselectedLabelStyle: CyberTextStyles.technical(fontSize: 8.0),
                type: BottomNavigationBarType.fixed,
                items: menuItems
                    .map((item) => BottomNavigationBarItem(
                          icon: Icon(item['icon'] as IconData, size: 18),
                          label: item['label'] as String,
                        ))
                    .toList(),
              ),
            )
          : null,
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
