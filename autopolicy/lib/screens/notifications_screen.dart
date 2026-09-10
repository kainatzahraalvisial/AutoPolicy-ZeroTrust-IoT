import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/security_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/glass_container.dart';
import '../widgets/neon_button.dart';
import '../widgets/cyber_hud_card.dart';

/// Incident & System Notifications Dedicated Full-Page View
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
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
                    Text('SYSTEM INCIDENT & SECURITY NOTIFICATIONS', style: CyberTextStyles.heading2),
                    const SizedBox(height: 4),
                    Text('REAL-TIME LOG STREAM, THREAT DETECTIONS & DEPLOYMENT INCIDENTS', style: CyberTextStyles.techMuted),
                  ],
                ),
                Row(
                  children: [
                    NeonButton(
                      text: 'CLEAR ALL LOGS',
                      onPressed: () {
                        ref.read(securityProvider.notifier).clearNotifications();
                      },
                      icon: Icons.cleaning_services_outlined,
                      color: CyberColors.alertRed,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Top Stat Row for Alert Metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard('TOTAL LOG ENTRIES', '${notifications.length}', const Color(0xFFFFE997), 'H17'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard('CRITICAL THREATS', '${notifications.where((n) => n.type == 'threat').length}', const Color(0xFFB91C1D), 'H18'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard('WARNING ALERTS', '${notifications.where((n) => n.type == 'warning').length}', const Color(0xFFA88AED), 'H19'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard('REGO DEPLOYMENTS', '${notifications.where((n) => n.type == 'deploy').length}', const Color(0xFFC4E320), 'H20'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category Filter Buttons
            Row(
              children: ['ALL', 'THREATS', 'WARNINGS', 'DEPLOY'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFC4E320).withOpacity(0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFC4E320) : Colors.white24,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      filter,
                      style: CyberTextStyles.technical(
                        fontSize: 11,
                        color: isSelected ? const Color(0xFFC4E320) : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Notifications Feed Stream List
            Expanded(
              child: filteredList.isEmpty
                  ? CyberHudCard(
                      tag: 'EMPTY',
                      borderColor: const Color(0xFFC4E320),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shield_outlined, color: Color(0xFFC4E320), size: 48),
                            const SizedBox(height: 12),
                            Text('ALL SYSTEMS OPERATIONAL. NO UNRESOLVED NOTIFICATIONS.', style: CyberTextStyles.technical(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, idx) {
                        final n = filteredList[idx];
                        Color statusColor = const Color(0xFFC4E320);
                        if (n.type == 'threat') statusColor = const Color(0xFFB91C1D);
                        if (n.type == 'warning') statusColor = const Color(0xFFA88AED);
                        if (n.type == 'deploy') statusColor = const Color(0xFFFFE997);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F0F0F),
                            borderRadius: BorderRadius.circular(4),
                            border: Border(left: BorderSide(color: statusColor, width: 4)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                n.type == 'threat' ? Icons.warning_amber : (n.type == 'warning' ? Icons.error_outline : Icons.check_circle_outline),
                                color: statusColor,
                                size: 24,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'CATEGORY: ${n.type.toUpperCase()}',
                                          style: CyberTextStyles.technical(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${n.timestamp.hour.toString().padLeft(2, '0')}:${n.timestamp.minute.toString().padLeft(2, '0')}:${n.timestamp.second.toString().padLeft(2, '0')}',
                                          style: CyberTextStyles.techMuted.copyWith(fontSize: 9.5),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      n.message,
                                      style: CyberTextStyles.interface(fontSize: 12.0, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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

  Widget _buildMetricCard(String title, String val, Color color, String tag) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: CyberTextStyles.technical(fontSize: 9, color: Colors.white70)),
          const SizedBox(height: 6),
          Text(val, style: TextStyle(fontFamily: 'monospace', fontSize: 24, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}
