import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/security_provider.dart';
import '../theme/colors.dart';
import '../theme/responsive.dart';
import '../theme/text_styles.dart';
import '../widgets/glass_container.dart';
import '../widgets/neon_button.dart';
import '../models/device.dart';

class ReportsAnalytics extends ConsumerStatefulWidget {
  const ReportsAnalytics({super.key});

  @override
  ConsumerState<ReportsAnalytics> createState() => _ReportsAnalyticsState();
}

class _ReportsAnalyticsState extends ConsumerState<ReportsAnalytics> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Simulated compliance export states
  bool _isExporting = false;
  double _exportProgress = 0.0;
  String _exportType = ''; // 'PDF' or 'CSV'
  String _exportConsoleLog = '';

  // Initial compliance metrics
  final Map<String, double> _complianceScores = {
    'SOC2 Type II': 94.8,
    'ISO 27001': 91.2,
    'HIPAA Safe Harbor': 98.4,
    'GDPR Art. 32': 89.5,
  };

  // Mock static historical ledger entries
  final List<Map<String, String>> _auditLedger = [
    {
      'timestamp': '2026-05-22 10:45:12',
      'standard': 'SOC2 Type II',
      'module': 'Access Control (CC6.1)',
      'status': 'PASS',
      'signature': 'SHA256:7f9c8a1b',
      'details': 'Verified MFA enforcements across 12 edge OPA sidecars.'
    },
    {
      'timestamp': '2026-05-22 09:12:05',
      'standard': 'GDPR Art. 32',
      'module': 'Data Isolation (Art. 32.1a)',
      'status': 'PASS',
      'signature': 'SHA256:0d2a8b9f',
      'details': 'GNN node segregation verified. Egress constraints enforced.'
    },
    {
      'timestamp': '2026-05-22 08:00:00',
      'standard': 'ISO 27001',
      'module': 'Asset Management (A.8)',
      'status': 'PASS',
      'signature': 'SHA256:3c8d1f2e',
      'details': 'Dynamic network inventory alignment check complete.'
    },
    {
      'timestamp': '2026-05-21 23:30:15',
      'standard': 'HIPAA Safe Harbor',
      'module': 'Transmission Security (164.312)',
      'status': 'PASS',
      'signature': 'SHA256:ef23ab56',
      'details': 'End-to-end telemetry packets encrypted over TLS 1.3.'
    },
    {
      'timestamp': '2026-05-21 17:40:02',
      'standard': 'SOC2 Type II',
      'module': 'System Monitoring (CC7.2)',
      'status': 'WARN',
      'signature': 'SHA256:5a9e3d8c',
      'details': 'Unmitigated anomaly active on target device Dev-3.'
    },
    {
      'timestamp': '2026-05-21 14:15:33',
      'standard': 'ISO 27001',
      'module': 'Access Logs Auditing (A.12.4)',
      'status': 'PASS',
      'signature': 'SHA256:9c0b1a2f',
      'details': 'OPA Rego logs archived and certified by cryptographic hash.'
    },
    {
      'timestamp': '2026-05-21 10:05:00',
      'standard': 'GDPR Art. 32',
      'module': 'Risk Assessment (Art. 32.2)',
      'status': 'PASS',
      'signature': 'SHA256:1a8f9c2d',
      'details': 'Incident report generated for DDoS Flood anomaly alert.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _triggerExport(String type) {
    if (_isExporting) return;
    setState(() {
      _isExporting = true;
      _exportProgress = 0.0;
      _exportType = type;
      _exportConsoleLog = 'Establishing secure cryptographic connection...\n';
    });

    const steps = [
      'Authenticating SOC Auditor signature...\n',
      'Accessing encrypted OPA Rego telemetry metrics...\n',
      'Generating GNN node topology mappings...\n',
      'Compiling Zero-Trust network health hashes...\n',
      'Hashing output document with SHA-256...\n',
      'Export complete! Package ready for secure download.\n'
    ];

    int stepIdx = 0;
    Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _exportProgress += 0.16;
        if (stepIdx < steps.length) {
          _exportConsoleLog += steps[stepIdx];
          stepIdx++;
        }
        if (_exportProgress >= 1.0) {
          _exportProgress = 1.0;
          _isExporting = false;
          timer.cancel();
          // Push notification downstream using provider if desired
          ref.read(securityProvider.notifier).toggleSimulation(ref.read(securityProvider).isSimulating);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final securityState = ref.watch(securityProvider);

    // Calculate actual live compliance adjustment based on compromised devices
    final compromisedCount = securityState.devices.where((d) => d.status != DeviceStatus.safe).length;
    final double liveDeduction = compromisedCount * 2.3;
    final Map<String, double> adjustedScores = _complianceScores.map((key, val) {
      return MapEntry(key, max(50.0, val - liveDeduction));
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headings and Action Panel
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AUDIT & COMPLIANCE LEDGER', style: CyberTextStyles.heading2),
                    const SizedBox(height: 4),
                    Text('CRYPTOGRAPHIC AUDITING FOR ZERO-TRUST REGULATORY COMPLIANCE', style: CyberTextStyles.techMuted),
                  ],
                ),
                if (!isMobile)
                  Row(
                    children: [
                      NeonButton(
                        text: 'EXPORT PDF',
                        onPressed: () => _triggerExport('PDF'),
                        icon: Icons.picture_as_pdf_outlined,
                      ),
                      const SizedBox(width: 8),
                      NeonButton(
                        text: 'EXPORT CSV',
                        onPressed: () => _triggerExport('CSV'),
                        icon: Icons.table_chart_outlined,
                        color: CyberColors.neonCyan,
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Export Progress Overlay Panel (Simulated System console)
            if (_isExporting || _exportProgress == 1.0) _buildExportConsole(),

            const SizedBox(height: 8),

            // Tab Navigation System
            TabBar(
              controller: _tabController,
              indicatorColor: CyberColors.neonGreen,
              labelColor: CyberColors.neonGreen,
              unselectedLabelColor: CyberColors.textMuted,
              labelStyle: CyberTextStyles.technical(fontSize: 12.0, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'STANDARDS INDEX'),
                Tab(text: 'AUDIT LEDGER'),
                Tab(text: 'HISTORICAL TRENDS'),
              ],
            ),
            const SizedBox(height: 16),

            // Active Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStandardsView(adjustedScores),
                  _buildLedgerView(),
                  _buildTrendsView(adjustedScores),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportConsole() {
    return GlassContainer(
      borderColor: _exportProgress < 1.0 ? CyberColors.neonCyan : CyberColors.neonGreen,
      glow: _exportProgress < 1.0 ? CyberColors.cyanGlow : CyberColors.greenGlow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _exportProgress < 1.0 
                    ? 'COMPILING SECURE CRYPTOGRAPHIC $_exportType REPORT...' 
                    : 'CRYPTOGRAPHIC REPORT GENERATED SUCCESSFUL',
                style: CyberTextStyles.technical(
                  color: _exportProgress < 1.0 ? CyberColors.neonCyan : CyberColors.neonGreen,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: CyberColors.textMuted, size: 16),
                onPressed: () {
                  setState(() {
                    _exportProgress = 0.0;
                    _isExporting = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _exportProgress,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(
              _exportProgress < 1.0 ? CyberColors.neonCyan : CyberColors.neonGreen,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(
              _exportConsoleLog,
              style: CyberTextStyles.technical(
                fontSize: 10.0,
                color: CyberColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardsView(Map<String, double> scores) {
    final bool isMobile = Responsive.isMobile(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cyber Dial Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 2.2 : 2.5,
            ),
            itemCount: scores.length,
            itemBuilder: (context, idx) {
              final String standard = scores.keys.elementAt(idx);
              final double score = scores[standard]!;
              final Color dialColor = score > 92 
                  ? CyberColors.neonGreen 
                  : (score > 85 ? CyberColors.warningOrange : CyberColors.alertRed);

              return GlassContainer(
                borderColor: dialColor,
                child: Row(
                  children: [
                    // Visual Radial custom painter dial
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CustomPaint(
                        painter: _ComplianceDialPainter(percentage: score, color: dialColor),
                        child: Center(
                          child: Text(
                            '${score.toStringAsFixed(1)}%',
                            style: CyberTextStyles.technical(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Standard details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            standard.toUpperCase(),
                            style: CyberTextStyles.displayTitle(fontSize: 14.0),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getStandardDescription(standard),
                            style: CyberTextStyles.interface(fontSize: 10.0, color: CyberColors.textMuted),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: dialColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                score > 92 ? 'COMPLIANT (SECURE)' : (score > 85 ? 'DEGRADED WARNING' : 'NON-COMPLIANT RISKS'),
                                style: CyberTextStyles.technical(fontSize: 9.0, color: dialColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Security Standards checklist / requirements compliance overview
          Text('CRITICAL REGULATORY THREAT ASSESSMENT', style: CyberTextStyles.technical(fontSize: 12.0, color: Colors.white)),
          const Divider(color: CyberColors.borderNeonCyan),
          const SizedBox(height: 12),
          _buildChecklistItem(
            'CC6.3 Network Boundary Controls',
            'Enforces micro-segmentation rule blockades on OPA sidecars.',
            true,
          ),
          _buildChecklistItem(
            'Art. 32.1b Encryption of Telemetry Packets',
            'Telemetry and control flows are cryptographically encrypted.',
            true,
          ),
          _buildChecklistItem(
            'CC7.2 Real-time Security Incident Alerts',
            'ML/GNN anomaly flags must route notifications in <2.0 seconds.',
            false, // Fail if alert is active
            customMsg: 'WARN: Compromised devices detected. Action recommended.',
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String title, String desc, bool isPass, {String? customMsg}) {
    final Color stateColor = isPass ? CyberColors.neonGreen : CyberColors.alertRed;
    final IconData icon = isPass ? Icons.check_circle_outline : Icons.report_problem_outlined;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        showHUDCorners: false,
        borderColor: stateColor,
        borderRadius: 6.0,
        child: Row(
          children: [
            Icon(icon, color: stateColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: CyberTextStyles.technical(fontSize: 11.0, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: CyberTextStyles.interface(fontSize: 10.0, color: CyberColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              customMsg ?? (isPass ? 'COMPLIANT' : 'AUDIT FAULT'),
              style: CyberTextStyles.technical(fontSize: 10.0, color: stateColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  String _getStandardDescription(String std) {
    switch (std) {
      case 'SOC2 Type II':
        return 'Trust Services Criteria detailing Security, Confidentiality, and Operations Integrity.';
      case 'ISO 27001':
        return 'International standard specifies requirements for establishing ISMS protocols.';
      case 'HIPAA Safe Harbor':
        return 'Healthcare technical guardrails governing patient IoT encryption and boundary controls.';
      case 'GDPR Art. 32':
        return 'European Union General Data Protection cybersecurity frameworks for network compartmentalization.';
      default:
        return 'Regulatory compliance metrics for Zero-Trust environment architectures.';
    }
  }

  Widget _buildLedgerView() {
    // Filter audit ledger entries based on search
    final filteredLedger = _auditLedger.where((entry) {
      return entry['standard']!.toLowerCase().contains(_searchQuery) ||
             entry['module']!.toLowerCase().contains(_searchQuery) ||
             entry['details']!.toLowerCase().contains(_searchQuery) ||
             entry['status']!.toLowerCase().contains(_searchQuery);
    }).toList();

    return Column(
      children: [
        // Search & Filter Panel
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                style: CyberTextStyles.technical(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'SEARCH LEDGER BY STANDARD, MODULE, STATUS OR SIG...',
                  hintStyle: CyberTextStyles.techMuted.copyWith(fontSize: 10),
                  prefixIcon: const Icon(Icons.search, color: CyberColors.neonCyan, size: 16),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: CyberColors.borderNeonCyan),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: CyberColors.neonCyan),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Ledger Grid/Table List
        Expanded(
          child: filteredLedger.isEmpty
              ? Center(child: Text('NO CORRESPONDING COMPLIANCE REGISTERS FOUND', style: CyberTextStyles.techMuted))
              : ListView.builder(
                  itemCount: filteredLedger.length,
                  itemBuilder: (context, idx) {
                    final item = filteredLedger[idx];
                    final isPass = item['status'] == 'PASS';
                    final Color statusColor = isPass ? CyberColors.neonGreen : CyberColors.warningOrange;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: GlassContainer(
                        showHUDCorners: false,
                        padding: EdgeInsets.zero,
                        borderRadius: 6.0,
                        borderColor: CyberColors.neonCyan,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: CyberColors.neonCyan,
                            ),
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                            iconColor: CyberColors.neonCyan,
                            collapsedIconColor: CyberColors.textMuted,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['standard']!.toUpperCase(),
                                  style: CyberTextStyles.technical(
                                    color: CyberColors.neonCyan,
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Text(
                                    item['status']!,
                                    style: CyberTextStyles.technical(color: statusColor, fontSize: 9.0, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                item['module']!.toUpperCase(),
                                style: CyberTextStyles.interface(fontSize: 10.0, color: Colors.white70),
                              ),
                            ),
                            children: [
                              const Divider(color: Colors.white10),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDetailRow('AUDITING SIG', item['signature']!, isCode: true),
                                    const SizedBox(height: 6),
                                    _buildDetailRow('TIMESTAMP', item['timestamp']!),
                                    const SizedBox(height: 6),
                                    _buildDetailRow('ACTION DESCRIPTION', item['details']!),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String val, {bool isCode = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            '$label:',
            style: CyberTextStyles.techMuted.copyWith(fontSize: 9.0),
          ),
        ),
        Expanded(
          child: Text(
            val.toUpperCase(),
            style: isCode
                ? CyberTextStyles.technical(fontSize: 9.0, color: CyberColors.neonGreen)
                : CyberTextStyles.interface(fontSize: 10.0, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendsView(Map<String, double> scores) {
    return GlassContainer(
      borderColor: CyberColors.neonCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '12-MONTH REGULATORY COMPLIANCE FLUCTUATIONS',
            style: CyberTextStyles.technical(color: Colors.white, fontSize: 12),
          ),
          const Divider(color: CyberColors.borderNeonCyan),
          const SizedBox(height: 16),
          // Custom Canvas graph for trends
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: CustomPaint(
                painter: _TrendGraphPainter(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Graph Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendLabel('SOC2', CyberColors.neonGreen),
              const SizedBox(width: 16),
              _buildLegendLabel('ISO27001', CyberColors.neonCyan),
              const SizedBox(width: 16),
              _buildLegendLabel('VULNERABILITIES', CyberColors.alertRed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendLabel(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: CyberTextStyles.technical(fontSize: 9.0, color: CyberColors.textMuted),
        ),
      ],
    );
  }
}

// Custom Painter to render Compliance Dial Dials in 60fps
class _ComplianceDialPainter extends CustomPainter {
  final double percentage;
  final Color color;

  _ComplianceDialPainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 4;

    // 1. Draw outer glowing circle track
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    canvas.drawCircle(center, radius, bgPaint);

    // 2. Draw active percentage arc
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.0;

    final double sweepAngle = 2 * pi * (percentage / 100.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from the top
      sweepAngle,
      false,
      arcPaint,
    );

    // 3. Optional tick details inside standard dial
    final tickPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius - 8, tickPaint);
  }

  @override
  bool shouldRepaint(covariant _ComplianceDialPainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}

// Custom Painter to draw a 60fps compliance fluctuations grid map
class _TrendGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Draw background fainted matrix grid lines
    final gridPaint = Paint()
      ..color = CyberColors.gridLine
      ..strokeWidth = 1.0;

    const int gridRows = 6;
    for (int i = 0; i <= gridRows; i++) {
      final double y = (height / gridRows) * i;
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    const int gridCols = 12;
    for (int i = 0; i <= gridCols; i++) {
      final double x = (width / gridCols) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }

    // Monthly data coordinates (percentage mappings)
    // SOC2 data path
    final soc2Points = [
      Offset(width * 0.05, height * 0.20),
      Offset(width * 0.15, height * 0.18),
      Offset(width * 0.25, height * 0.25),
      Offset(width * 0.35, height * 0.22),
      Offset(width * 0.45, height * 0.15),
      Offset(width * 0.55, height * 0.18),
      Offset(width * 0.65, height * 0.28), // alert spike
      Offset(width * 0.75, height * 0.12), // quarantined restore
      Offset(width * 0.85, height * 0.08),
      Offset(width * 0.95, height * 0.05),
    ];

    // ISO 27001 data path
    final isoPoints = [
      Offset(width * 0.05, height * 0.30),
      Offset(width * 0.15, height * 0.28),
      Offset(width * 0.25, height * 0.29),
      Offset(width * 0.35, height * 0.35), // minor decline
      Offset(width * 0.45, height * 0.28),
      Offset(width * 0.55, height * 0.24),
      Offset(width * 0.65, height * 0.32),
      Offset(width * 0.75, height * 0.20),
      Offset(width * 0.85, height * 0.18),
      Offset(width * 0.95, height * 0.15),
    ];

    // Vulnerability indices
    final threatPoints = [
      Offset(width * 0.05, height * 0.80),
      Offset(width * 0.15, height * 0.85),
      Offset(width * 0.25, height * 0.75),
      Offset(width * 0.35, height * 0.60), // spike
      Offset(width * 0.45, height * 0.78),
      Offset(width * 0.55, height * 0.85),
      Offset(width * 0.65, height * 0.45), // massive attack spike
      Offset(width * 0.75, height * 0.92), // mitigation absolute
      Offset(width * 0.85, height * 0.95),
      Offset(width * 0.95, height * 0.97),
    ];

    _drawPathLine(canvas, soc2Points, CyberColors.neonGreen);
    _drawPathLine(canvas, isoPoints, CyberColors.neonCyan);
    _drawPathLine(canvas, threatPoints, CyberColors.alertRed);

    // Draw bottom months labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final months = ['JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC', 'JAN', 'FEB', 'MAR'];
    for (int i = 0; i < months.length; i++) {
      final double x = width * 0.05 + (width * 0.9 / (months.length - 1)) * i;
      textPainter.text = TextSpan(
        text: months[i],
        style: CyberTextStyles.techMuted.copyWith(fontSize: 8.0),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - (textPainter.width / 2), height - 12));
    }
  }

  void _drawPathLine(Canvas canvas, List<Offset> points, Color color) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // Draw glowing node circles at coordinates
    final nodePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final nodeBg = Paint()
      ..color = CyberColors.backgroundDark
      ..style = PaintingStyle.fill;

    final nodeOutline = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (final pt in points) {
      canvas.drawCircle(pt, 4.0, nodePaint);
      canvas.drawCircle(pt, 2.5, nodeBg);
      canvas.drawCircle(pt, 1.5, nodeOutline);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendGraphPainter oldDelegate) => false;
}
