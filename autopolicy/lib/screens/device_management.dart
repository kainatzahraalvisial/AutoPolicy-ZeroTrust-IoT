import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device.dart';
import '../providers/security_provider.dart';
import '../theme/colors.dart';
import '../theme/responsive.dart';
import '../theme/text_styles.dart';
import '../widgets/glass_container.dart';

class DeviceManagement extends ConsumerStatefulWidget {
  const DeviceManagement({super.key});

  @override
  ConsumerState<DeviceManagement> createState() => _DeviceManagementState();
}

class _DeviceManagementState extends ConsumerState<DeviceManagement> {
  String _searchQuery = '';
  String _statusFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final securityState = ref.watch(securityProvider);
    final devices = securityState.devices;
    final bool isMobile = Responsive.isMobile(context);

    // Apply search query and status filters
    final filteredDevices = devices.where((device) {
      final matchesSearch = device.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          device.ipAddress.contains(_searchQuery) ||
          device.deviceType.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesStatus = _statusFilter == 'ALL' ||
          device.status.toString().split('.').last.toUpperCase() == _statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FLEET DEPLOYED IOT ASSETS', style: CyberTextStyles.heading2),
                const SizedBox(height: 4),
                Text('ZERO-TRUST DEVICE DIRECTORY & STATUS GATEWAY', style: CyberTextStyles.techMuted),
              ],
            ),
            const SizedBox(height: 16),

            // Search & Filtering Bar Row
            Row(
              children: [
                // Search Input Box
                Expanded(
                  flex: 3,
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: CyberTextStyles.techBody,
                    decoration: InputDecoration(
                      hintText: 'SEARCH BY NAME, IP, TYPE...',
                      prefixIcon: const Icon(Icons.search, color: CyberColors.neonCyan, size: 18),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Status Filter options
                if (!isMobile) ...[
                  _buildStatusFilterButton('ALL', _statusFilter == 'ALL'),
                  _buildStatusFilterButton('SAFE', _statusFilter == 'SAFE'),
                  _buildStatusFilterButton('WARNING', _statusFilter == 'WARNING'),
                  _buildStatusFilterButton('ISOLATED', _statusFilter == 'ISOLATED'),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Devices grid view layout
            Expanded(
              child: filteredDevices.isEmpty
                  ? GlassContainer(
                      borderColor: CyberColors.neonCyan,
                      child: Center(
                        child: Text(
                          'NO DEVICES DETECTED MATCHING SEARCH CRITERIA',
                          style: CyberTextStyles.techMuted,
                        ),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 1 : (Responsive.isTablet(context) ? 2 : 3),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.35,
                      ),
                      itemCount: filteredDevices.length,
                      itemBuilder: (context, idx) {
                        final device = filteredDevices[idx];
                        return _buildDeviceGridCard(device);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilterButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.only(left: 6),
        decoration: BoxDecoration(
          color: isSelected ? CyberColors.panelBg : CyberColors.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? CyberColors.neonCyan : CyberColors.borderNeonCyan,
          ),
        ),
        child: Text(
          label,
          style: CyberTextStyles.technical(
            fontSize: 9.5,
            color: isSelected ? Colors.white : CyberColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceGridCard(IoTDevice device) {
    Color statusColor = CyberColors.neonGreen;
    String statusLabel = 'ACTIVE SAFE';
    if (device.status == DeviceStatus.warning) {
      statusColor = CyberColors.alertRed;
      statusLabel = 'WARNING';
    } else if (device.status == DeviceStatus.isolated) {
      statusColor = CyberColors.neonCyan;
      statusLabel = 'ISOLATED';
    }

    return GestureDetector(
      onTap: () => _showDeviceDetailsDialog(device),
      child: GlassContainer(
        borderColor: statusColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top device identifier row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name.toUpperCase(),
                        style: CyberTextStyles.displayTitle(fontSize: 12, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'TYPE: ${device.deviceType.toUpperCase()}',
                        style: CyberTextStyles.techMuted.copyWith(fontSize: 8.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    statusLabel,
                    style: CyberTextStyles.technical(color: statusColor, fontSize: 8.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Performance stats
            Column(
              children: [
                _buildCompactStatRow('IP ADDRESS', device.ipAddress),
                _buildCompactStatRow('CPU METRIC', '${device.cpuUsage.toStringAsFixed(1)}%'),
                _buildCompactStatRow('RAM METRIC', '${device.memoryUsage.toStringAsFixed(1)}%'),
              ],
            ),

            // Micro-progress health indicators
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: device.cpuUsage / 100.0,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 3.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStatRow(String name, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: CyberTextStyles.techMuted.copyWith(fontSize: 8.5)),
          Text(value, style: CyberTextStyles.technical(color: Colors.white, fontSize: 9.5)),
        ],
      ),
    );
  }

  void _showDeviceDetailsDialog(IoTDevice device) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: CyberColors.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: CyberColors.neonCyan),
          ),
          title: Text(
            'IOT DIAGNOSTIC PANEL: ${device.name.toUpperCase()}',
            style: CyberTextStyles.displayTitle(fontSize: 14.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetricDetailItem('DEVICE ID', device.id),
              _buildMetricDetailItem('IP NET ADDRESS', device.ipAddress),
              _buildMetricDetailItem('MAC HARDWARE ADDR', device.macAddress),
              _buildMetricDetailItem('TRANSFERRED BANDWIDTH', '${device.bandwidth.toStringAsFixed(1)} KB/S'),
              _buildMetricDetailItem('GNN RISK SCORE', '${(device.riskScore * 100).toStringAsFixed(1)}%'),
              _buildMetricDetailItem('COMMUNICATION PROTOCOL', device.protocol.toUpperCase()),
              _buildMetricDetailItem('GNN DIRECT CONNS', device.connections.join(' | ')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'CLOSE PROFILE',
                style: CyberTextStyles.technical(color: CyberColors.neonCyan, fontSize: 11),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: CyberTextStyles.techMuted.copyWith(fontSize: 9.0)),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              value,
              style: CyberTextStyles.technical(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
