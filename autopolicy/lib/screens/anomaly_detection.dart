import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/anomaly.dart';
import '../providers/navigation_provider.dart';
import '../providers/security_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';


class AnomalyDetection extends ConsumerStatefulWidget {
  const AnomalyDetection({super.key});

  @override
  ConsumerState<AnomalyDetection> createState() => _AnomalyDetectionState();
}

class _AnomalyDetectionState extends ConsumerState<AnomalyDetection> {
  String _severityFilter = 'ALL';
  String _statusFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final securityState = ref.watch(securityProvider);
    final anomalies = securityState.anomalies;

    // Filters logic
    final filteredAnomalies = anomalies.where((anm) {
      final bool matchesSeverity = _severityFilter == 'ALL' ||
          anm.severity.toString().split('.').last.toUpperCase() == _severityFilter;
      
      final bool matchesStatus;
      if (_statusFilter == 'ALL') {
        matchesStatus = true;
      } else if (_statusFilter == 'ACTIVE') {
        matchesStatus = !anm.isMitigated;
      } else {
        matchesStatus = anm.isMitigated;
      }

      return matchesSeverity && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('INCIDENT ANALYSIS FEED', style: CyberTextStyles.heading2),
                    const SizedBox(height: 4),
                    Text('AI-POWERED ML THREAT DETECTION ALERTS', style: CyberTextStyles.techMuted),
                  ],
                ),
                // Summary pill (Increased font size & readable contrast)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: CyberColors.alertRed.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: CyberColors.alertRed, width: 1.2),
                  ),
                  child: Text(
                    '${anomalies.where((a) => !a.isMitigated).length} UNRESOLVED INCIDENTS',
                    style: CyberTextStyles.technical(
                      color: CyberColors.alertRed,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Advanced Filters Bar
            Row(
              children: [
                // Severity Filter Dropdowns
                _buildFilterLabel('SEVERITY:'),
                const SizedBox(width: 8),
                _buildFilterButton('ALL', 'severity', _severityFilter == 'ALL'),
                _buildFilterButton('CRITICAL', 'severity', _severityFilter == 'CRITICAL'),
                _buildFilterButton('HIGH', 'severity', _severityFilter == 'HIGH'),
                
                const SizedBox(width: 24),
                
                // Status Filters
                _buildFilterLabel('STATUS:'),
                const SizedBox(width: 8),
                _buildFilterButton('ALL', 'status', _statusFilter == 'ALL'),
                _buildFilterButton('ACTIVE', 'status', _statusFilter == 'ACTIVE'),
                _buildFilterButton('MITIGATED', 'status', _statusFilter == 'MITIGATED'),
              ],
            ),
            const SizedBox(height: 16),

            // Incident Feed Lists
            Expanded(
              child: filteredAnomalies.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F0F),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF5DD62C).withOpacity(0.3)),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.shield_outlined, color: Color(0xFF5DD62C), size: 42),
                            const SizedBox(height: 12),
                            Text(
                              'NO FLAGGED INCIDENTS MATCHING CRITERIA',
                              style: CyberTextStyles.technical(fontSize: 12.5, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredAnomalies.length,
                      itemBuilder: (context, idx) {
                        final anm = filteredAnomalies[idx];
                        final isCritical = anm.severity == SeverityLevel.critical;
                        final String timeStr =
                            '${anm.timestamp.hour.toString().padLeft(2, '0')}:${anm.timestamp.minute.toString().padLeft(2, '0')}:${anm.timestamp.second.toString().padLeft(2, '0')}';
                        final Color severityColor = isCritical ? const Color(0xFFDF2531) : const Color(0xFFFFA500);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F0F0F),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: severityColor.withOpacity(0.45),
                              width: 1.0,
                            ),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Left colored severity bar
                                Container(
                                  width: 5,
                                  decoration: BoxDecoration(
                                    color: severityColor,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(3),
                                      bottomLeft: Radius.circular(3),
                                    ),
                                  ),
                                ),

                                // Main Content Row
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    child: Row(
                                      children: [
                                        // Severity Tag & Confidence
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: severityColor.withOpacity(0.18),
                                                borderRadius: BorderRadius.circular(3),
                                                border: Border.all(color: severityColor, width: 1),
                                              ),
                                              child: Text(
                                                anm.severity.toString().split('.').last.toUpperCase(),
                                                style: CyberTextStyles.technical(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: severityColor,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${(anm.confidenceScore * 100).toStringAsFixed(1)}% CONF',
                                              style: CyberTextStyles.technical(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF5DD62C),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 14),

                                        // Threat Name, Target Device & Vector Details
                                        Expanded(
                                          flex: 5,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    anm.attackType.toUpperCase(),
                                                    style: const TextStyle(
                                                      fontFamily: 'Inter',
                                                      fontSize: 13.5,
                                                      fontWeight: FontWeight.w800,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF182218),
                                                      borderRadius: BorderRadius.circular(3),
                                                      border: Border.all(
                                                        color: const Color(0xFF5DD62C).withOpacity(0.4),
                                                        width: 0.8,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(Icons.router, size: 12, color: Color(0xFF5DD62C)),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '${anm.deviceName.toUpperCase()} (${anm.deviceId})',
                                                          style: CyberTextStyles.technical(
                                                            fontSize: 10.5,
                                                            fontWeight: FontWeight.bold,
                                                            color: const Color(0xFF5DD62C),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                anm.details.toUpperCase(),
                                                style: const TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white70,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 14),

                                        // Log Time & Status Indicator
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              timeStr,
                                              style: CyberTextStyles.technical(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              anm.isMitigated ? 'MITIGATED' : 'ACTIVE SURGE',
                                              style: CyberTextStyles.technical(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.bold,
                                                color: anm.isMitigated
                                                    ? const Color(0xFF5DD62C)
                                                    : severityColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 16),

                                        // Grouped Action Buttons
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Acknowledge Button / Badge
                                            if (!anm.isAcknowledged)
                                              OutlinedButton.icon(
                                                onPressed: () {
                                                  ref.read(securityProvider.notifier).acknowledgeAnomaly(anm.id);
                                                },
                                                icon: const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF5DD62C)),
                                                label: Text(
                                                  'ACKNOWLEDGE',
                                                  style: CyberTextStyles.technical(
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color(0xFF5DD62C),
                                                  ),
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  side: const BorderSide(color: Color(0xFF5DD62C), width: 1),
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                ),
                                              )
                                            else
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF5DD62C).withOpacity(0.12),
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(color: const Color(0xFF5DD62C).withOpacity(0.4)),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.check, size: 13, color: Color(0xFF5DD62C)),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'ACKNOWLEDGED',
                                                      style: CyberTextStyles.technical(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                        color: const Color(0xFF5DD62C),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            const SizedBox(width: 8),

                                            // Diagnose Button
                                            OutlinedButton.icon(
                                              onPressed: () => _showInvestigateDialog(context, anm),
                                              icon: const Icon(Icons.troubleshoot, size: 14, color: Color(0xFFA88AED)),
                                              label: Text(
                                                'DIAGNOSE',
                                                style: CyberTextStyles.technical(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFFA88AED),
                                                ),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(color: Color(0xFFA88AED), width: 1),
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                              ),
                                            ),
                                            const SizedBox(width: 8),

                                            // Isolate Button / Quarantined Badge
                                            if (!anm.isMitigated)
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  final policy = securityState.policies.firstWhere(
                                                    (p) => p.anomalyId == anm.id,
                                                    orElse: () => securityState.policies.first,
                                                  );
                                                  ref.read(securityProvider.notifier).deployPolicy(
                                                        policy.id,
                                                        policy.rawJsonPolicy,
                                                      );
                                                },
                                                icon: const Icon(Icons.security, size: 14, color: Colors.white),
                                                label: Text(
                                                  'ISOLATE DEVICE',
                                                  style: CyberTextStyles.technical(
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFFDF2531),
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                ),
                                              )
                                            else
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF5DD62C).withOpacity(0.12),
                                                  border: Border.all(color: const Color(0xFF5DD62C)),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.lock, size: 12, color: Color(0xFF5DD62C)),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'QUARANTINED',
                                                      style: CyberTextStyles.technical(
                                                        color: const Color(0xFF5DD62C),
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
    );
  }

  Widget _buildFilterLabel(String label) {
    return Text(
      label,
      style: CyberTextStyles.technical(
        color: Colors.white70,
        fontSize: 12.0,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildFilterButton(String label, String type, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (type == 'severity') {
            _severityFilter = label;
          } else {
            _statusFilter = label;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5DD62C).withOpacity(0.22) : const Color(0xFF141414),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? const Color(0xFF5DD62C) : Colors.white24,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: CyberTextStyles.technical(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? const Color(0xFF5DD62C) : Colors.white70,
          ),
        ),
      ),
    );
  }

  void _showInvestigateDialog(BuildContext context, Anomaly anm) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 540,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFDF2531), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFDF2531).withOpacity(0.2),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.troubleshoot, color: Color(0xFFDF2531), size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'INCIDENT FORENSICS & DEEP TRIAGE',
                          style: CyberTextStyles.heading2.copyWith(fontSize: 14, color: const Color(0xFFDF2531)),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Text(
                  'INCIDENT ID: ${anm.id} · DEVICE ASSET: ${anm.deviceName.toUpperCase()}',
                  style: CyberTextStyles.techMuted.copyWith(fontSize: 9),
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFF252525)),
                const SizedBox(height: 10),

                // Flow Telemetry Table
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF252525)),
                  ),
                  child: Column(
                    children: [
                      _forensicRow('TARGET DEVICE', '${anm.deviceName} (${anm.deviceId})', const Color(0xFFFFE997)),
                      _forensicRow('CLASSIFIED ATTACK', anm.attackType.toUpperCase(), const Color(0xFFDF2531)),
                      _forensicRow('CONFIDENCE SCORE', '${(anm.confidenceScore * 100).toStringAsFixed(1)}% (GNN GraphSAGE)', const Color(0xFF5DD62C)),
                      _forensicRow('RELATED GNN NODES', 'Gateway-01 <-> PLC-Sensor-04 <-> Mesh-Hub-02', const Color(0xFFA88AED)),
                      _forensicRow('FLOW PROTOCOL', 'MQTT / TLS 1.3 (Port 8883) · 4.8k pkts/s', Colors.white70),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Suggested Zero-Trust Policy
                Text('SUGGESTED ZERO-TRUST REGO POLICY SNIPPET', style: CyberTextStyles.technical(fontSize: 10, color: const Color(0xFFC4E320))),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFC4E320).withOpacity(0.35)),
                  ),
                  child: Text(
                    'package autopolicy.authz\n\ndefault allow = false\n\n# Drop lateral surge packets from suspicious device\nallow {\n  input.device_id == "${anm.deviceId}"\n  input.rate_per_sec <= 200\n  not input.anomaly_flagged\n}',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Color(0xFFC4E320)),
                  ),
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('CLOSE', style: CyberTextStyles.technical(color: Colors.white54)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC4E320)),
                      icon: const Icon(Icons.auto_awesome, color: Colors.black, size: 16),
                      label: Text(
                        'REVIEW IN POLICY GENERATOR',
                        style: CyberTextStyles.technical(color: Colors.black, fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Navigate directly to Generated Policies screen (Tab 4)
                        ref.read(navigationNotifierProvider.notifier).selectTab(4);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _forensicRow(String label, String value, Color valColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: CyberTextStyles.techMuted.copyWith(fontSize: 9.5)),
          Text(value, style: CyberTextStyles.technical(fontSize: 10, color: valColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
