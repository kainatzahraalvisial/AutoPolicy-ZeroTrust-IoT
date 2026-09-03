import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device.dart';
import '../providers/security_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/glass_container.dart';
import '../widgets/neon_button.dart';

class SimulationTesting extends ConsumerStatefulWidget {
  const SimulationTesting({super.key});

  @override
  ConsumerState<SimulationTesting> createState() => _SimulationTestingState();
}

class _SimulationTestingState extends ConsumerState<SimulationTesting> {
  IoTDevice? _selectedTargetDevice;
  String _selectedAttackType = 'DDoS Flood'; // DDoS, Port Scanner, Modbus MITM, Data Leak

  final List<String> _attackTypes = [
    'DDoS Flood',
    'Port Scanner API',
    'Modbus MITM Injection',
    'Data Exfiltration'
  ];

  @override
  Widget build(BuildContext context) {
    final securityState = ref.watch(securityProvider);
    final eligibleDevices = securityState.devices.where((d) => d.status == DeviceStatus.safe).toList();

    // Default select first safe device
    if (_selectedTargetDevice == null && eligibleDevices.isNotEmpty) {
      _selectedTargetDevice = eligibleDevices.first;
    }

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
                Text('SOC SIMULATION LABORATORY', style: CyberTextStyles.heading2),
                const SizedBox(height: 4),
                Text('MANUAL ATTACK INJECTION & MICRO-SEGMENTATION STRESS TESTS', style: CyberTextStyles.techMuted),
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Row(
                children: [
                  // Left panel: Simulation Controls
                  Expanded(
                    flex: 5,
                    child: GlassContainer(
                      borderColor: CyberColors.neonCyan,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('INJECTION PARAMETERS', style: CyberTextStyles.technical(color: Colors.white, fontSize: 12)),
                          const Divider(color: CyberColors.borderNeonCyan),
                          const SizedBox(height: 16),

                          // Target device selection dropdown
                          Text('TARGET SYSTEM ASSET', style: CyberTextStyles.techMuted.copyWith(fontSize: 10)),
                          const SizedBox(height: 8),
                          if (eligibleDevices.isEmpty)
                            Text(
                              'ALL DEVICES IN WARNING OR ISOLATED STATE. CANNOT INJECT ANOMALIES.',
                              style: CyberTextStyles.technical(color: CyberColors.warningOrange, fontSize: 11),
                            )
                          else
                            GlassContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              borderRadius: 8.0,
                              borderColor: CyberColors.neonCyan,
                              showHUDCorners: false,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<IoTDevice>(
                                  value: _selectedTargetDevice,
                                  isExpanded: true,
                                  dropdownColor: CyberColors.cardBg,
                                  style: CyberTextStyles.techBody,
                                  onChanged: (IoTDevice? val) {
                                    setState(() {
                                      _selectedTargetDevice = val;
                                    });
                                  },
                                  items: eligibleDevices.map((IoTDevice device) {
                                    return DropdownMenuItem<IoTDevice>(
                                      value: device,
                                      child: Text(
                                        '${device.name.toUpperCase()} (${device.ipAddress})',
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),

                          // Attack type selection dropdown
                          Text('INCIDENT VECTOR CLASS', style: CyberTextStyles.techMuted.copyWith(fontSize: 10)),
                          const SizedBox(height: 8),
                          GlassContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            borderRadius: 8.0,
                            borderColor: CyberColors.neonCyan,
                            showHUDCorners: false,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedAttackType,
                                isExpanded: true,
                                dropdownColor: CyberColors.cardBg,
                                style: CyberTextStyles.techBody,
                                onChanged: (String? val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedAttackType = val;
                                    });
                                  }
                                },
                                items: _attackTypes.map((String type) {
                                  return DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type.toUpperCase()),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          
                          const Spacer(),

                          // Big Red Inject Button
                          if (eligibleDevices.isNotEmpty && _selectedTargetDevice != null)
                            Center(
                              child: NeonButton(
                                text: 'INJECT SECURITY EXPLOIT',
                                color: CyberColors.alertRed,
                                isGlowing: true,
                                onPressed: () {
                                  ref.read(securityProvider.notifier).manualAttackTrigger(
                                        _selectedTargetDevice!.id,
                                        _selectedAttackType,
                                      );
                                  // Re-fetch next safe device
                                  setState(() {
                                    _selectedTargetDevice = null;
                                  });
                                  // Inform user
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: CyberColors.alertRed,
                                      content: Text('SECURITY INJECTOR: SIMULATING ATTACK PACKETS... Check GNN relationship graph and Anomalies Feed!'),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Right panel: Info HUD
                  Expanded(
                    flex: 4,
                    child: GlassContainer(
                      borderColor: CyberColors.neonGreen,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('INJECTOR COMPLIANCE MANIFEST', style: CyberTextStyles.technical(color: Colors.white, fontSize: 12)),
                          const Divider(color: CyberColors.borderNeonGreen),
                          const SizedBox(height: 12),

                          _buildInfoItem('SIMULATOR CLASSIFIER', 'AutoPolicy ML Stress Testing framework'),
                          _buildInfoItem('SAFETY PROTOCOL', 'SIMULATED ATTACKS OCCUR UNDER STRICT CONFINED VIRTUAL ENVIRONMENTS. 0 EFFECT ON COMPILING ENVOY GATEWAYS UNLESS MANUALLY APPROVED.'),
                          _buildInfoItem('SANDBOX SCOPE', 'REGULATED TO REGIONAL DEMO DOMAINS'),
                          _buildInfoItem('OPA TELEMETRY FEEDBACK', 'COMPILE RULES BUNDLE AUTO-GENERATES ONCE DETECTED ON GNN NODE TOPOLOGY.'),
                        ],
                      ),
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

  Widget _buildInfoItem(String header, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(header, style: CyberTextStyles.techMuted.copyWith(fontSize: 9.0)),
          const SizedBox(height: 4),
          Text(
            val.toUpperCase(),
            style: CyberTextStyles.interface(fontSize: 11, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
