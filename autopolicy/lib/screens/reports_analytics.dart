import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../theme/responsive.dart';
import '../theme/text_styles.dart';
import '../widgets/cyber_hud_card.dart';

/// Redesigned Logs & Reports: 6-Tile Hub navigating to dedicated full-page audit views
class ReportsAnalytics extends ConsumerStatefulWidget {
  const ReportsAnalytics({super.key});

  @override
  ConsumerState<ReportsAnalytics> createState() => _ReportsAnalyticsState();
}

class _ReportsAnalyticsState extends ConsumerState<ReportsAnalytics> {
  // Navigation: null = Tile Hub (First View), 0..5 = Dedicated Full Pages
  int? _activeSectionIndex;
  int? _hoveredHubIdx;

  // Filter states
  String _dateRange = 'Last 24 Hours';
  String _userFilter = 'All Operators';
  String _actionFilter = 'All Actions';
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 1;
  static const int _pageSize = 8;

  // Export State
  bool _isExporting = false;
  double _exportProgress = 0.0;
  String _exportFormat = '';
  String _exportFeedback = '';

  // 6 Specified Tile Hub Definitions
  final List<Map<String, dynamic>> _hubTiles = [
    {
      'title': 'Security Audit Logs',
      'desc': 'View all security-related actions, logins and operational events',
      'icon': Icons.shield_outlined,
      'color': const Color(0xFF5DD62C),
      'tag': 'LOG-1',
    },
    {
      'title': 'Policy Change History',
      'desc': 'Track policy approvals, rejections and deployments across sidecars',
      'icon': Icons.history_toggle_off,
      'color': const Color(0xFFC4E320),
      'tag': 'LOG-2',
    },
    {
      'title': 'Alert & Threat Archive',
      'desc': 'Historical record of all detected anomalies, vectors and mitigations',
      'icon': Icons.archive_outlined,
      'color': const Color(0xFFDF2531),
      'tag': 'LOG-3',
    },
    {
      'title': 'System Health Logs',
      'desc': 'Zeek sensors, OPA proxies, GNN Model inference and service logs',
      'icon': Icons.monitor_heart_outlined,
      'color': const Color(0xFFA88AED),
      'tag': 'LOG-4',
    },
    {
      'title': 'Compliance Reports',
      'desc': 'SOC2, ISO 27001, HIPAA and regulatory compliance audit reports',
      'icon': Icons.verified_user_outlined,
      'color': const Color(0xFFFFE997),
      'tag': 'LOG-5',
    },
    {
      'title': 'Export Center',
      'desc': 'Generate, compile and download cryptographic PDF and CSV reports',
      'icon': Icons.file_download_outlined,
      'color': const Color(0xFF80A416),
      'tag': 'LOG-6',
    },
  ];

  // Comprehensive mock log dataset
  final List<Map<String, String>> _allLogs = [
    {
      'time': '2026-09-12 15:20:12',
      'user': 'kainat.alvi (Admin)',
      'action': 'POLICY DEPLOY',
      'resource': 'OPA Sidecar #04 (Modbus Guard)',
      'ip': '10.128.4.12',
      'status': 'SUCCESS',
      'type': 'Policy Change History',
    },
    {
      'time': '2026-09-12 14:58:33',
      'user': 'system.gnn',
      'action': 'THREAT ANOMALY FLAGGED',
      'resource': 'Edge Gateway 01 (Syn Flood)',
      'ip': '10.128.4.12',
      'status': 'DETECTED',
      'type': 'Alert & Threat Archive',
    },
    {
      'time': '2026-09-12 14:45:00',
      'user': 'zeek.sensor0',
      'action': 'ZEEK ENGINE BUFFER CHECK',
      'resource': 'eth0 Ingress (Ring Buffer 512MB)',
      'ip': '127.0.0.1',
      'status': 'NOMINAL',
      'type': 'System Health Logs',
    },
    {
      'time': '2026-09-12 14:10:44',
      'user': 'kainat.alvi (Admin)',
      'action': 'OPERATOR LOGIN (MFA)',
      'resource': 'Management Enclave Console',
      'ip': '192.168.1.105',
      'status': 'SUCCESS',
      'type': 'Security Audit Logs',
    },
    {
      'time': '2026-09-12 13:52:19',
      'user': 'analyst.chen',
      'action': 'ANOMALY TRIAGED',
      'resource': 'Camera Edge Node #88',
      'ip': '10.128.8.88',
      'status': 'ISOLATED',
      'type': 'Alert & Threat Archive',
    },
    {
      'time': '2026-09-12 13:30:00',
      'user': 'auditor.soc2',
      'action': 'SOC2 TYPE II AUDIT RUN',
      'resource': 'Access Control CC6.1 Check',
      'ip': '10.100.0.4',
      'status': 'PASS (94.8%)',
      'type': 'Compliance Reports',
    },
    {
      'time': '2026-09-12 12:45:10',
      'user': 'kainat.alvi (Admin)',
      'action': 'POLICY REJECTED',
      'resource': 'Draft Rego Rule #POL-08',
      'ip': '192.168.1.105',
      'status': 'REJECTED',
      'type': 'Policy Change History',
    },
    {
      'time': '2026-09-12 12:15:00',
      'user': 'system.opa',
      'action': 'BUNDLE SYNC REST API',
      'resource': 'Kubernetes Envoy Sidecars (12 nodes)',
      'ip': '10.128.0.1',
      'status': 'HEALTHY',
      'type': 'System Health Logs',
    },
    {
      'time': '2026-09-12 11:30:22',
      'user': 'system.gnn',
      'action': 'LATERAL SURGE DETECTED',
      'resource': 'Smart Meter Alpha (Port Scan)',
      'ip': '10.128.4.45',
      'status': 'DETECTED',
      'type': 'Alert & Threat Archive',
    },
    {
      'time': '2026-09-12 10:20:00',
      'user': 'auditor.iso',
      'action': 'ISO 27001 REVISION',
      'resource': 'A.13 Network Security Microsegments',
      'ip': '10.100.0.8',
      'status': 'PASS (91.2%)',
      'type': 'Compliance Reports',
    },
    {
      'time': '2026-09-12 09:40:11',
      'user': 'kainat.alvi (Admin)',
      'action': 'UPDATE GNN THRESHOLD',
      'resource': 'Sensitivity Cutoff -> 0.85',
      'ip': '192.168.1.105',
      'status': 'CONFIGURED',
      'type': 'Security Audit Logs',
    },
    {
      'time': '2026-09-12 08:30:00',
      'user': 'system.zeek',
      'action': 'PACKET CAPTURE CYCLE',
      'resource': '2.45M pkts analyzed / 0 drops',
      'ip': '127.0.0.1',
      'status': 'NOMINAL',
      'type': 'System Health Logs',
    },
  ];

  void _triggerExport(String format) {
    setState(() {
      _isExporting = true;
      _exportProgress = 0.0;
      _exportFormat = format;
      _exportFeedback = 'INITIALIZING CRYPTOGRAPHIC COMPILATION...';
    });

    Timer.periodic(const Duration(milliseconds: 250), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _exportProgress += 0.25;
        if (_exportProgress >= 0.5 && _exportProgress < 0.75) {
          _exportFeedback = 'COMPUTING SHA-256 INTEGRITY CHECKSUM HASH...';
        }
        if (_exportProgress >= 1.0) {
          _exportProgress = 1.0;
          _isExporting = false;
          _exportFeedback = 'SUCCESS: AutoPolicy_${format.toUpperCase()}_Report_Generated.sha256 (Ready for Download)';
          t.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header (Unified Administrator Style)
            _buildPageHeader(isDarkMode),
            const SizedBox(height: 14),

            // Main Content: If no tile selected -> 6-Tile Hub. Otherwise -> Dedicated Full Page!
            if (_activeSectionIndex == null)
              _buildTileHubView(isDarkMode)
            else
              _buildDedicatedFullPageView(isDarkMode),
          ],
        ),
      ),
    );
  }

  // ── PAGE HEADER ────────────────────────────────────────────────────────────
  Widget _buildPageHeader(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LOGS & REPORTS',
              style: CyberTextStyles.displayTitle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A),
              ).copyWith(letterSpacing: 2.0),
            ),
            const SizedBox(height: 3),
            Text(
              'Audit trails, policy history and compliance reports',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDarkMode ? Colors.white70 : const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (_activeSectionIndex != null)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFAF9F6),
              foregroundColor: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A),
              side: BorderSide(color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFFCDD4B2), width: 1.0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: Text(
              '← BACK TO LOGS & REPORTS',
              style: CyberTextStyles.technical(fontSize: 11, fontWeight: FontWeight.bold, color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A)),
            ),
            onPressed: () => setState(() {
              _activeSectionIndex = null;
              _currentPage = 1;
            }),
          ),
      ],
    );
  }

  // ── FIRST VIEW: 6-TILE HUB (3×2 GRID) ──────────────────────────────────────
  Widget _buildTileHubView(bool isDarkMode) {
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _hubTiles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: isMobile ? 2.5 : 1.9,
          ),
          itemBuilder: (context, idx) {
            final tile = _hubTiles[idx];
            Color color = tile['color'] as Color;
            if (!isDarkMode) {
              if (color == const Color(0xFFFFE997)) {
                color = const Color(0xFFB45309); // High contrast amber in light mode
              } else if (color == const Color(0xFFC4E320)) {
                color = const Color(0xFF15803D); // High contrast deep green in light mode
              }
            }

            final bool isHovered = _hoveredHubIdx == idx;

            return MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _hoveredHubIdx = idx),
              onExit: (_) => setState(() => _hoveredHubIdx = null),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: isHovered
                      ? [
                          BoxShadow(
                            color: color.withOpacity(isDarkMode ? 0.55 : 0.22),
                            blurRadius: 22,
                            spreadRadius: 3,
                          ),
                        ]
                      : [],
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _activeSectionIndex = idx;
                      _currentPage = 1;
                      _searchCtrl.clear();
                      _searchQuery = '';
                    });
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: CyberHudCard(
                    tag: tile['tag'] as String,
                    borderColor: isHovered 
                        ? color 
                        : (isDarkMode ? color.withOpacity(0.7) : const Color(0xFFCDD4B2)),
                    borderWidth: isHovered ? 2.0 : 1.2,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(isHovered ? 0.30 : (isDarkMode ? 0.15 : 0.20)),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: color.withOpacity(isHovered ? 0.9 : 0.5)),
                                ),
                                child: Icon(tile['icon'] as IconData, color: color, size: 22),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'OPEN SECTION',
                                    style: CyberTextStyles.technical(
                                      fontSize: 10, 
                                      color: isDarkMode ? color : const Color(0xFF0F172A), 
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_ios, size: 10, color: isDarkMode ? color : const Color(0xFF0F172A)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (tile['title'] as String).toUpperCase(),
                                style: CyberTextStyles.technical(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                                ).copyWith(letterSpacing: 0.8),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tile['desc'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isDarkMode ? Colors.white70 : const Color(0xFF475569),
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── DEDICATED FULL-PAGE VIEW FOR EACH TILE ──────────────────────────────────
  Widget _buildDedicatedFullPageView(bool isDarkMode) {
    final activeTile = _hubTiles[_activeSectionIndex!];
    Color color = activeTile['color'] as Color;
    if (!isDarkMode) {
      if (color == const Color(0xFFFFE997)) {
        color = const Color(0xFFB45309); // High contrast amber in light mode
      } else if (color == const Color(0xFFC4E320)) {
        color = const Color(0xFF15803D); // High contrast deep green in light mode
      }
    }
    final String activeTitle = activeTile['title'] as String;

    // Filter logs for this view
    final filtered = _allLogs.where((log) {
      if (_activeSectionIndex! < 5 && log['type'] != activeTitle) {
        // Show matching category logs, or all logs in general
        if (_activeSectionIndex == 0 && log['type'] != 'Security Audit Logs') return false;
        if (_activeSectionIndex == 1 && log['type'] != 'Policy Change History') return false;
        if (_activeSectionIndex == 2 && log['type'] != 'Alert & Threat Archive') return false;
        if (_activeSectionIndex == 3 && log['type'] != 'System Health Logs') return false;
        if (_activeSectionIndex == 4 && log['type'] != 'Compliance Reports') return false;
      }
      if (_userFilter != 'All Operators' && !log['user']!.contains(_userFilter.split(' ').first)) return false;
      if (_actionFilter != 'All Actions' && !log['action']!.contains(_actionFilter.toUpperCase())) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = log['action']!.toLowerCase().contains(q) ||
            log['resource']!.toLowerCase().contains(q) ||
            log['user']!.toLowerCase().contains(q) ||
            log['ip']!.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();

    final int totalPages = (filtered.length / _pageSize).ceil().clamp(1, 999);
    final int startIdx = (_currentPage - 1) * _pageSize;
    final int endIdx = (startIdx + _pageSize).clamp(0, filtered.length);
    final pagedItems = filtered.sublist(startIdx, endIdx);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dedicated Section Action Ribbon
        CyberHudCard(
          tag: activeTile['tag'] as String,
          borderColor: isDarkMode ? color : const Color(0xFFCDD4B2),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(activeTile['icon'] as IconData, color: color, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          activeTitle.toUpperCase(),
                          style: CyberTextStyles.technical(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold, 
                            color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildExportBtn('EXPORT PDF', Icons.picture_as_pdf_outlined, () => _triggerExport('PDF'), isDarkMode),
                        const SizedBox(width: 10),
                        _buildExportBtn('EXPORT CSV', Icons.table_view_outlined, () => _triggerExport('CSV'), isDarkMode),
                      ],
                    ),
                  ],
                ),
                if (_isExporting || _exportFeedback.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _exportProgress,
                    backgroundColor: isDarkMode ? const Color(0xFF222222) : const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                  const SizedBox(height: 6),
                  Text(_exportFeedback, style: CyberTextStyles.technical(fontSize: 11, color: isDarkMode ? color : const Color(0xFF0F172A), fontWeight: FontWeight.bold)),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Filters Row
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAF9F6),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: isDarkMode ? Colors.white12 : const Color(0xFFCDD4B2)),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Date Range Filter
              _buildDropdownFilter('RANGE', _dateRange, ['Last 24 Hours', 'Last 7 Days', 'Last 30 Days', 'All Time'], (v) {
                if (v != null) setState(() => _dateRange = v);
              }, isDarkMode),
              // User Filter
              _buildDropdownFilter('USER', _userFilter, ['All Operators', 'kainat.alvi', 'system', 'analyst', 'zeek'], (v) {
                if (v != null) setState(() => _userFilter = v);
              }, isDarkMode),
              // Action Type Filter
              _buildDropdownFilter('ACTION', _actionFilter, ['All Actions', 'Policy', 'Threat', 'Engine', 'Login', 'Audit'], (v) {
                if (v != null) setState(() => _actionFilter = v);
              }, isDarkMode),
              // Search Input Box
              SizedBox(
                width: 240,
                child: TextField(
                  controller: _searchCtrl,
                  style: GoogleFonts.inter(fontSize: 12.5, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                  onChanged: (v) => setState(() {
                    _searchQuery = v.trim();
                    _currentPage = 1;
                  }),
                  decoration: InputDecoration(
                    hintText: 'Search logs, IPs, actions...',
                    hintStyle: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white38 : const Color(0xFF94A3B8)),
                    prefixIcon: Icon(Icons.search, size: 16, color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    filled: true,
                    fillColor: isDarkMode ? const Color(0xFF161616) : const Color(0xFFFAF9F6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: isDarkMode ? Colors.white24 : const Color(0xFFCDD4B2))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: isDarkMode ? Colors.white24 : const Color(0xFFCDD4B2))),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Full-Width Wide Table
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFFAF9F6),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: isDarkMode ? color.withOpacity(0.35) : const Color(0xFFCDD4B2)),
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: isDarkMode ? const Color(0xFF222222) : const Color(0xFFE2E8F0), width: 1)),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text('TIMESTAMP', style: CyberTextStyles.technical(fontSize: 11.5, fontWeight: FontWeight.bold, color: isDarkMode ? color : const Color(0xFF0F172A)))),
                    Expanded(flex: 3, child: Text('OPERATOR / ACTOR', style: CyberTextStyles.technical(fontSize: 11.5, fontWeight: FontWeight.bold, color: isDarkMode ? color : const Color(0xFF0F172A)))),
                    Expanded(flex: 4, child: Text('ACTION DESCRIPTION', style: CyberTextStyles.technical(fontSize: 11.5, fontWeight: FontWeight.bold, color: isDarkMode ? color : const Color(0xFF0F172A)))),
                    Expanded(flex: 4, child: Text('TARGET RESOURCE', style: CyberTextStyles.technical(fontSize: 11.5, fontWeight: FontWeight.bold, color: isDarkMode ? color : const Color(0xFF0F172A)))),
                    Expanded(flex: 2, child: Text('SOURCE IP', style: CyberTextStyles.technical(fontSize: 11.5, fontWeight: FontWeight.bold, color: isDarkMode ? color : const Color(0xFF0F172A)))),
                    Expanded(flex: 2, child: Text('STATUS', style: CyberTextStyles.technical(fontSize: 11.5, fontWeight: FontWeight.bold, color: isDarkMode ? color : const Color(0xFF0F172A)))),
                  ],
                ),
              ),

              // Table Body Rows
              if (pagedItems.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Center(
                    child: Text('NO LOG RECORDS MATCH CURRENT FILTERS', style: GoogleFonts.inter(fontSize: 13, color: isDarkMode ? Colors.white38 : const Color(0xFF94A3B8))),
                  ),
                )
              else
                ...pagedItems.map((log) {
                  final bool isOk = log['status']!.contains('SUCCESS') || log['status']!.contains('PASS') || log['status']!.contains('NOMINAL') || log['status']!.contains('HEALTHY');
                  final Color stColor = isOk 
                      ? (isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF15803D))
                      : (log['status']!.contains('DETECTED') 
                          ? const Color(0xFFDF2531) 
                          : (isDarkMode ? const Color(0xFFFFE997) : const Color(0xFFB45309)));

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: isDarkMode ? const Color(0xFF181818) : const Color(0xFFF1F5F9), width: 1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text(log['time']!, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: isDarkMode ? const Color(0xFFC5C764) : const Color(0xFF80A416)))),
                        Expanded(flex: 3, child: Text(log['user']!, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)))),
                        Expanded(flex: 4, child: Text(log['action']!, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white70 : const Color(0xFF334155)))),
                        Expanded(flex: 4, child: Text(log['resource']!, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: isDarkMode ? Colors.white60 : const Color(0xFF64748B)))),
                        Expanded(flex: 2, child: Text(log['ip']!, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: isDarkMode ? const Color(0xFFA88AED) : const Color(0xFF7C3AED)))),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: stColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(color: stColor, width: 0.8),
                              ),
                              child: Text(
                                log['status']!,
                                style: GoogleFonts.spaceGrotesk(fontSize: 10.5, fontWeight: FontWeight.bold, color: stColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 12),

              // Pagination Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${filtered.isEmpty ? 0 : startIdx + 1}–$endIdx of ${filtered.length} entries',
                    style: GoogleFonts.inter(fontSize: 12, color: isDarkMode ? Colors.white54 : const Color(0xFF64748B)),
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: isDarkMode ? Colors.white24 : const Color(0xFFCDD4B2)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                        child: Text('‹ PREV', style: CyberTextStyles.technical(fontSize: 11, color: isDarkMode ? Colors.white : const Color(0xFF0F172A))),
                      ),
                      const SizedBox(width: 8),
                      Text('PAGE $_currentPage OF $totalPages', style: CyberTextStyles.technical(fontSize: 11, color: isDarkMode ? color : const Color(0xFF0F172A))),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: isDarkMode ? Colors.white24 : const Color(0xFFCDD4B2)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                        child: Text('NEXT ›', style: CyberTextStyles.technical(fontSize: 11, color: isDarkMode ? Colors.white : const Color(0xFF0F172A))),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownFilter(String label, String value, List<String> items, ValueChanged<String?> onChanged, bool isDarkMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: CyberTextStyles.technical(fontSize: 11, color: isDarkMode ? Colors.white54 : const Color(0xFF64748B))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF161616) : const Color(0xFFFAF9F6),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: isDarkMode ? Colors.white24 : const Color(0xFFCDD4B2)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: isDarkMode ? const Color(0xFF161616) : const Color(0xFFFAF9F6),
              style: GoogleFonts.inter(fontSize: 12, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
              items: items.map((i) => DropdownMenuItem(
                value: i, 
                child: Text(i, style: TextStyle(color: isDarkMode ? Colors.white : const Color(0xFF0F172A))),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExportBtn(String label, IconData icon, VoidCallback onTap, bool isDarkMode) {
    final btnColor = isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416);
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14, color: btnColor),
      label: Text(label, style: CyberTextStyles.technical(fontSize: 11, fontWeight: FontWeight.bold, color: btnColor)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFFCDD4B2), width: 1.0),
        backgroundColor: isDarkMode ? Colors.transparent : const Color(0xFFFAF9F6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
