import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/security_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/text_styles.dart';
import '../widgets/cyber_stat_card.dart';

/// Incident & System Notifications Dedicated Full-Page View
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _selectedFilter = 'ALL';
  int? _hoveredNotificationIdx;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider);
    final securityState = ref.watch(securityProvider);
    final notifications = securityState.notifications;

    final filteredList = notifications.where((n) {
      if (_selectedFilter == 'ALL') return true;
      if (_selectedFilter == 'THREATS') return n.type == 'threat';
      if (_selectedFilter == 'WARNINGS') return n.type == 'warning';
      if (_selectedFilter == 'DEPLOY') return n.type == 'deploy';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header & Actions Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SYSTEM INCIDENT & SECURITY NOTIFICATIONS',
                      style: CyberTextStyles.displayTitle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w900,
                        color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A),
                      ).copyWith(letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'REAL-TIME LOG STREAM, THREAT DETECTIONS & DEPLOYMENT INCIDENTS',
                      style: GoogleFonts.inter(
                        fontSize: 12.0,
                        color: isDarkMode ? Colors.white60 : const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(securityProvider.notifier).clearNotifications();
                  },
                  icon: const Icon(Icons.cleaning_services_outlined, size: 16),
                  label: Text(
                    'CLEAR ALL LOGS',
                    style: CyberTextStyles.technical(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD82734),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Top Stat Row for Alert Metrics (HUD Frames & Color Order Aligned)
            Row(
              children: [
                Expanded(
                  child: CyberStatCard(
                    title: 'TOTAL LOG ENTRIES',
                    value: '${notifications.length}',
                    sub: 'System & Sensor Events',
                    icon: Icons.receipt_long_outlined,
                    borderColor: const Color(0xFFFFF9E1),
                    tag: 'L01',
                    onTap: () => setState(() => _selectedFilter = 'ALL'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CyberStatCard(
                    title: 'REGO DEPLOYMENTS',
                    value: '${notifications.where((n) => n.type == 'deploy').length}',
                    sub: 'OPA Active Enforcements',
                    icon: Icons.rocket_launch_outlined,
                    borderColor: const Color(0xFFEBECCC),
                    tag: 'L02',
                    onTap: () => setState(() => _selectedFilter = 'DEPLOY'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CyberStatCard(
                    title: 'WARNING ALERTS',
                    value: '${notifications.where((n) => n.type == 'warning').length}',
                    sub: 'Triaged Anomaly Warnings',
                    icon: Icons.warning_amber_outlined,
                    borderColor: const Color(0xFFDCA278), // Clay Color
                    tag: 'L03',
                    onTap: () => setState(() => _selectedFilter = 'WARNINGS'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CyberStatCard(
                    title: 'CRITICAL THREATS',
                    value: '${notifications.where((n) => n.type == 'threat').length}',
                    sub: 'Immediate Blast Radius',
                    icon: Icons.gpp_bad_outlined,
                    borderColor: const Color(0xFFD82734), // Threat Red at end
                    isAlert: true,
                    tag: 'L04',
                    onTap: () => setState(() => _selectedFilter = 'THREATS'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category Filter Buttons (Solid fill with white text when selected)
            Row(
              children: [
                _buildFilterButton('ALL', const Color(0xFFCDD4B2), isDarkMode),
                _buildFilterButton('DEPLOY', const Color(0xFF08652C), isDarkMode),
                _buildFilterButton('WARNINGS', const Color(0xFFDCA278), isDarkMode),
                _buildFilterButton('THREATS', const Color(0xFFD82734), isDarkMode),
              ],
            ),
            const SizedBox(height: 16),

            // Notifications Feed Stream List
            Expanded(
              child: filteredList.isEmpty
                  ? _buildEmptyState(isDarkMode)
                  : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, idx) {
                        final n = filteredList[idx];
                        final isHovered = _hoveredNotificationIdx == idx;

                        Color statusColor = const Color(0xFF08652C); // default info
                        IconData iconData = Icons.info_outline;

                        if (n.type == 'threat') {
                          statusColor = const Color(0xFFD82734);
                          iconData = Icons.gpp_bad_outlined;
                        } else if (n.type == 'warning') {
                          statusColor = const Color(0xFFE87D85);
                          iconData = Icons.warning_amber_outlined;
                        } else if (n.type == 'deploy') {
                          statusColor = const Color(0xFF08652C);
                          iconData = Icons.verified_outlined;
                        }

                        final String formattedTime =
                            '${n.timestamp.hour.toString().padLeft(2, '0')}:${n.timestamp.minute.toString().padLeft(2, '0')}:${n.timestamp.second.toString().padLeft(2, '0')}';

                        return MouseRegion(
                          onEnter: (_) => setState(() => _hoveredNotificationIdx = idx),
                          onExit: (_) => setState(() => _hoveredNotificationIdx = null),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(bottom: 10),
                            transform: isHovered ? Matrix4.translationValues(0, -2, 0) : Matrix4.identity(),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xFF111116)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isDarkMode
                                    ? (isHovered ? statusColor : const Color(0xFF222233))
                                    : (isHovered ? statusColor : const Color(0xFFCDD4B2)),
                                width: isHovered ? 1.5 : 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(isDarkMode ? 0.25 : (isHovered ? 0.08 : 0.03)),
                                  blurRadius: isHovered ? 8 : 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Left Status Accent Bar
                                  Container(
                                    width: 5,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(6),
                                        bottomLeft: Radius.circular(6),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Icon in tinted box
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(9),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(isDarkMode ? 0.20 : 0.12),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: statusColor.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(iconData, color: statusColor, size: 20),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  // Content Column
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: statusColor.withOpacity(isDarkMode ? 0.22 : 0.12),
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(color: statusColor.withOpacity(0.4), width: 0.8),
                                                ),
                                                child: Text(
                                                  n.type.toUpperCase(),
                                                  style: TextStyle(
                                                    fontFamily: 'monospace',
                                                    color: statusColor,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 0.8,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(right: 14.0),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.access_time,
                                                      size: 11,
                                                      color: isDarkMode ? Colors.white54 : const Color(0xFF64748B),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      formattedTime,
                                                      style: TextStyle(
                                                        fontFamily: 'monospace',
                                                        fontSize: 10.5,
                                                        color: isDarkMode ? Colors.white60 : const Color(0xFF64748B),
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Padding(
                                            padding: const EdgeInsets.only(right: 14.0),
                                            child: Text(
                                              n.message,
                                              style: GoogleFonts.inter(
                                                fontSize: 13.0,
                                                color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                                                fontWeight: FontWeight.w600,
                                                height: 1.4,
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
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FILTER BUTTON BUILDER ──────────────────────────────────────────────────
  Widget _buildFilterButton(String label, Color activeFillColor, bool isDarkMode) {
    final bool isSelected = _selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(() => _selectedFilter = label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeFillColor
                  : (isDarkMode ? const Color(0xFF14141E) : const Color(0xFFFAF9F6)),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected
                    ? activeFillColor
                    : (isDarkMode ? Colors.white24 : const Color(0xFFCDD4B2)),
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: activeFillColor.withOpacity(0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: CyberTextStyles.technical(
                fontSize: 11.5,
                color: isSelected
                    ? Colors.white
                    : (isDarkMode ? Colors.white70 : const Color(0xFF475569)),
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── REDESIGNED EMPTY STATE ─────────────────────────────────────────────────
  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF0F0F14) : const Color(0xFFFAF9F6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDarkMode ? const Color(0xFF222233) : const Color(0xFFCDD4B2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? const Color(0xFF162316) : const Color(0xFFEBECCC),
                border: Border.all(
                  color: isDarkMode ? const Color(0xFF5DD62C).withOpacity(0.5) : const Color(0xFFCDD4B2),
                  width: 1.2,
                ),
              ),
              child: Icon(
                Icons.verified_user_outlined,
                color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF08652C),
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ALL SYSTEMS SECURE & OPERATIONAL',
              textAlign: TextAlign.center,
              style: CyberTextStyles.displayTitle(
                fontSize: 15.0,
                fontWeight: FontWeight.w900,
                color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
              ).copyWith(letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            Text(
              'No active alerts under the current filter ($_selectedFilter). Zero-Trust OPA sidecars and Zeek network sensors are actively inspecting telemetry traffic without policy violations.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.0,
                color: isDarkMode ? Colors.white60 : const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF08652C).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF08652C).withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF08652C),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ZERO UNRESOLVED INCIDENTS',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF08652C),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
