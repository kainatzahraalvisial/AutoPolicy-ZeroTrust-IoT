import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/security_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/glass_container.dart';

class TrafficMonitor extends ConsumerStatefulWidget {
  const TrafficMonitor({super.key});

  @override
  ConsumerState<TrafficMonitor> createState() => _TrafficMonitorState();
}

class _TrafficMonitorState extends ConsumerState<TrafficMonitor> {
  String _selectedProtocolFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final securityState = ref.watch(securityProvider);
    final isDarkMode = ref.watch(themeModeProvider);
    final trafficFeed = securityState.trafficFeed;

    // Aggregate protocol stats for telemetry cards
    final int mqttCount = trafficFeed.where((t) => t.protocol == 'MQTT').length;
    final int coapCount = trafficFeed.where((t) => t.protocol == 'CoAP').length;
    final int modbusCount = trafficFeed.where((t) => t.protocol == 'Modbus').length;
    final int dicomCount = trafficFeed.where((t) => t.protocol == 'DICOM').length;

    // Filter packet stream based on selected protocol
    final filteredFeed = _selectedProtocolFilter == 'ALL'
        ? trafficFeed
        : trafficFeed.where((t) => t.protocol == _selectedProtocolFilter).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LIVE TELEMETRY TRAFFIC', style: CyberTextStyles.heading2),
                    const SizedBox(height: 4),
                    Text('PACKET CAPTURE STREAM ENGINE', style: CyberTextStyles.techMuted),
                  ],
                ),
                // Play/Pause button control
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        securityState.isSimulating ? Icons.pause_circle_outline : Icons.play_circle_outline,
                        color: securityState.isSimulating ? CyberColors.warningOrange : CyberColors.neonGreen,
                        size: 28,
                      ),
                      onPressed: () {
                        ref.read(securityProvider.notifier).toggleSimulation(!securityState.isSimulating);
                      },
                    ),
                    Text(
                      securityState.isSimulating ? 'SIMULATOR ACTIVE' : 'SIMULATOR PAUSED',
                      style: CyberTextStyles.technical(
                        fontSize: 10,
                        color: securityState.isSimulating ? CyberColors.neonGreen : CyberColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Protocol distribution summary panels
            Row(
              children: [
                _buildProtocolMetricCard('MQTT', mqttCount, CyberColors.neonGreen, isDarkMode),
                const SizedBox(width: 10),
                _buildProtocolMetricCard('CoAP', coapCount, CyberColors.neonCyan, isDarkMode),
                const SizedBox(width: 10),
                _buildProtocolMetricCard('MODBUS', modbusCount, CyberColors.warningOrange, isDarkMode),
                const SizedBox(width: 10),
                _buildProtocolMetricCard('DICOM', dicomCount, isDarkMode ? Colors.white : const Color(0xFF0F172A), isDarkMode),
              ],
            ),
            const SizedBox(height: 16),

            // Stream Filter Actions Toolbar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['ALL', 'MQTT', 'CoAP', 'Modbus', 'HTTP', 'OPC-UA', 'DICOM', 'RTSP'].map((proto) {
                  final bool isSelected = _selectedProtocolFilter == proto;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedProtocolFilter = proto),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? CyberColors.neonCyan.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isSelected ? CyberColors.neonCyan : CyberColors.borderNeonCyan,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        proto.toUpperCase(),
                        style: CyberTextStyles.technical(
                          fontSize: 10,
                          color: isSelected ? (isDarkMode ? Colors.white : const Color(0xFF0F172A)) : CyberColors.textMuted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Main Live Packet Feed Log
            Expanded(
              child: GlassContainer(
                borderColor: CyberColors.neonCyan,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grid Columns Header
                    Row(
                      children: [
                        Expanded(flex: 2, child: Text('TIMESTAMP', style: CyberTextStyles.techMuted.copyWith(fontSize: 10))),
                        Expanded(flex: 3, child: Text('SOURCE NODE', style: CyberTextStyles.techMuted.copyWith(fontSize: 10))),
                        Expanded(flex: 1, child: _buildArrowHeader()),
                        Expanded(flex: 3, child: Text('DESTINATION NODE', style: CyberTextStyles.techMuted.copyWith(fontSize: 10))),
                        Expanded(flex: 2, child: Text('PROTOCOL', style: CyberTextStyles.techMuted.copyWith(fontSize: 10))),
                        Expanded(flex: 2, child: Text('SIZE', style: CyberTextStyles.techMuted.copyWith(fontSize: 10))),
                      ],
                    ),
                    const Divider(color: CyberColors.borderNeonCyan),
                    const SizedBox(height: 8),
                    // Scrolling Packets
                    Expanded(
                      child: filteredFeed.isEmpty
                          ? Center(child: Text('NO PACKETS REGISTERED', style: CyberTextStyles.techMuted))
                          : ListView.builder(
                              itemCount: filteredFeed.length,
                              itemBuilder: (context, idx) {
                                final packet = filteredFeed[idx];
                                final isSecAlert = packet.isSuspicious;

                                final timeStr = '${packet.timestamp.hour.toString().padLeft(2, '0')}:${packet.timestamp.minute.toString().padLeft(2, '0')}:${packet.timestamp.second.toString().padLeft(2, '0')}';

                                return Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: isDarkMode ? Colors.white12 : Colors.black12)),
                                  ),
                                  child: Row(
                                    children: [
                                      // Timestamp
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          timeStr,
                                          style: CyberTextStyles.technical(
                                            fontSize: 11,
                                            color: isSecAlert ? CyberColors.alertRed : (isDarkMode ? CyberColors.textMuted : Colors.black54),
                                          ),
                                        ),
                                      ),
                                      // Source Device Name
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          packet.sourceName.toUpperCase(),
                                          style: CyberTextStyles.interface(
                                            fontSize: 11,
                                            color: isSecAlert ? CyberColors.alertRed : (isDarkMode ? Colors.white : const Color(0xFF6D28D9)),
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Connector arrow
                                      Expanded(
                                        flex: 1,
                                        child: Icon(
                                          Icons.arrow_forward,
                                          size: 12,
                                          color: isSecAlert ? CyberColors.alertRed : (isDarkMode ? CyberColors.neonGreen : const Color(0xFF00875A)),
                                        ),
                                      ),
                                      // Dest Device Name
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          packet.destName.toUpperCase(),
                                          style: CyberTextStyles.interface(
                                            fontSize: 11,
                                            color: isSecAlert ? CyberColors.alertRed : (isDarkMode ? Colors.white : const Color(0xFF6D28D9)),
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Protocol Badge
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          packet.protocol.toUpperCase(),
                                          style: CyberTextStyles.technical(
                                            fontSize: 11,
                                            color: isSecAlert ? CyberColors.alertRed : (isDarkMode ? CyberColors.neonCyan : const Color(0xFF007A87)),
                                          ),
                                        ),
                                      ),
                                      // Size In Bytes
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          '${packet.packetSize} B',
                                          style: CyberTextStyles.technical(
                                            fontSize: 11,
                                            color: isSecAlert ? CyberColors.alertRed : (isDarkMode ? Colors.white : const Color(0xFF6D28D9)),
                                          ),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtocolMetricCard(String label, int value, Color color, bool isDarkMode) {
    final Color displayColor = isDarkMode 
        ? color 
        : (color == Colors.white 
            ? const Color(0xFF0F172A) 
            : (color == CyberColors.neonGreen 
                ? const Color(0xFF00875A) 
                : (color == CyberColors.neonCyan ? const Color(0xFF007A87) : color)));
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderColor: displayColor,
        showHUDCorners: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: CyberTextStyles.techMuted.copyWith(fontSize: 9.0)),
            const SizedBox(height: 2),
            Text(
              '$value PKTS',
              style: CyberTextStyles.displayTitle(fontSize: 14.0, color: displayColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrowHeader() {
    return const SizedBox(width: 10);
  }
}
