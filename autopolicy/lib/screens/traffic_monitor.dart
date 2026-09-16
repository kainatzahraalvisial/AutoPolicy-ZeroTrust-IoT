import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/security_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/cyber_stat_card.dart';

class TrafficMonitor extends ConsumerStatefulWidget {
  const TrafficMonitor({super.key});

  @override
  ConsumerState<TrafficMonitor> createState() => _TrafficMonitorState();
}

class _TrafficMonitorState extends ConsumerState<TrafficMonitor> {
  String _selectedProtocolFilter = 'ALL';
  bool _isUploadingPcap = false;
  double _uploadProgress = 0.0;
  String _uploadStatusText = '';

  void _simulatePcapUpload() async {
    setState(() {
      _isUploadingPcap = true;
      _uploadProgress = 0.1;
      _uploadStatusText = 'PARSING PCAP HEADER & ETHERNET FRAMES...';
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _uploadProgress = 0.35;
      _uploadStatusText = 'EXTRACTING 100-DIM FLOW FEATURES (LENGTH, ENTROPY, FLAGS)...';
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _uploadProgress = 0.70;
      _uploadStatusText = 'DISPATCHING TO CONFORMER DNN & GNN THREAT ENGINES...';
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _uploadProgress = 1.0;
      _uploadStatusText = 'SUCCESS: 2,450 PACKETS INGESTED INTO PIPELINE!';
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    // Trigger state update & close progress modal
    ref.read(securityProvider.notifier).triggerManualPacketBatch();
    setState(() {
      _isUploadingPcap = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F1A0F),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFF5DD62C), width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF5DD62C)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'PCAP File standard_capture_2026.pcap ingested successfully. 2,450 telemetry packets dispatched to Conformer Threat Classifier.',
                style: CyberTextStyles.technical(fontSize: 11, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHexInspectorModal(dynamic packet) {
    final isDarkMode = ref.read(themeModeProvider);
    final hexDump = [
      '0000   45 00 00 3c 1c 46 40 00  40 06 b1 e6 c0 a8 01 0a   E..<.F@.@.......',
      '0010   c0 a8 01 64 00 50 d4 31  00 00 00 00 00 00 00 00   ...d.P.3........',
      '0020   50 02 72 10 91 6c 00 00  02 04 05 b4 04 02 08 0a   P.r..l..........',
      '0030   00 12 34 56 00 00 00 00  01 03 03 07 10 20 00 00   ..4V......... ..',
    ].join('\n');

    final modalBorder = isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFFCDD4B2);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF0F0F14) : const Color(0xFFFAF9F6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: modalBorder, width: 1.5),
        ),
        title: Row(
          children: [
            Icon(Icons.data_object, color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A)),
            const SizedBox(width: 10),
            Text('DEEP PACKET INSPECTION (HEX & DECODE)', style: CyberTextStyles.heading3For(isDarkMode)),
          ],
        ),
        content: SizedBox(
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black.withOpacity(0.4) : const Color(0xFFFAF9F6),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: modalBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SOURCE: ${packet.sourceName} -> DEST: ${packet.destName}',
                        style: CyberTextStyles.technical(fontSize: 11, color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A))),
                    Text('PROTOCOL: ${packet.protocol} | PAYLOAD SIZE: ${packet.packetSize} Bytes',
                        style: CyberTextStyles.technical(fontSize: 11, color: isDarkMode ? CyberColors.neonCyan : const Color(0xFF2563EB))),
                    Text('STATUS: ${packet.isSuspicious ? "MALICIOUS / ANOMALY DETECTED" : "VERIFIED / NORMAL TRAFFIC"}',
                        style: CyberTextStyles.technical(
                            fontSize: 11,
                            color: packet.isSuspicious ? CyberColors.alertRed : (isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF16A34A)))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text('RAW HEXADECIMAL & ASCII PAYLOAD DUMP:', style: CyberTextStyles.techMuted.copyWith(fontSize: 10)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF07070A) : const Color(0xFFFAF9F6),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: modalBorder),
                ),
                child: SelectableText(
                  hexDump,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('AI PIPELINE PROCESSING STEP:', style: CyberTextStyles.techMuted.copyWith(fontSize: 10)),
              const SizedBox(height: 4),
              Text(
                '1. Extract 100-dim feature vector -> 2. Pass to Conformer DNN for multi-class attack classification -> 3. Correlate node topology in GNN -> 4. Generate Zero-Trust OPA policy if anomalous.',
                style: CyberTextStyles.interface(fontSize: 11, color: isDarkMode ? Colors.white70 : const Color(0xFF334155)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('CLOSE', style: CyberTextStyles.technical(color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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
    final int grpcCount = trafficFeed.where((t) => t.protocol == 'gRPC' || t.protocol == 'HTTP').length;
    final int opcuaCount = trafficFeed.where((t) => t.protocol == 'OPC-UA' || t.protocol == 'RTSP').length;

    // Filter packet stream based on selected protocol
    final filteredFeed = _selectedProtocolFilter == 'ALL'
        ? trafficFeed
        : trafficFeed.where((t) => t.protocol == _selectedProtocolFilter).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Screen Header Toolbar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('LIVE TELEMETRY TRAFFIC', style: CyberTextStyles.heading2For(isDarkMode)),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5DD62C).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFF5DD62C), width: 1),
                              ),
                              child: Text(
                                'ZEEK / PCAP INGESTION',
                                style: CyberTextStyles.technical(fontSize: 9, color: const Color(0xFF5DD62C), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('REAL-TIME WIRESHARK / ZEEK PACKET CAPTURE STREAM ENGINE', style: CyberTextStyles.techMutedFor(isDarkMode)),
                      ],
                    ),

                    // Actions: PCAP Upload & Simulator Toggle
                    Row(
                      children: [
                        // Upload PCAP File Button
                        ElevatedButton.icon(
                          onPressed: _isUploadingPcap ? null : _simulatePcapUpload,
                          icon: const Icon(Icons.upload_file, size: 16, color: Colors.white),
                          label: Text(
                            'UPLOAD PCAP FILE (.pcap, .csv)',
                            style: CyberTextStyles.technical(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00875A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: const BorderSide(color: Color(0xFF5DD62C), width: 1.5),
                            ),
                            elevation: 4,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Play/Pause button control
                        OutlinedButton.icon(
                          onPressed: () {
                            ref.read(securityProvider.notifier).toggleSimulation(!securityState.isSimulating);
                          },
                          icon: Icon(
                            securityState.isSimulating ? Icons.pause_circle_outline : Icons.play_circle_outline,
                            color: securityState.isSimulating ? CyberColors.warningOrange : const Color(0xFF5DD62C),
                            size: 18,
                          ),
                          label: Text(
                            securityState.isSimulating ? 'PAUSE LIVE CAPTURE' : 'RESUME LIVE CAPTURE',
                            style: CyberTextStyles.technical(
                              fontSize: 10,
                              color: securityState.isSimulating ? CyberColors.warningOrange : const Color(0xFF5DD62C),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: securityState.isSimulating ? CyberColors.warningOrange : const Color(0xFF5DD62C),
                              width: 1,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Protocol distribution summary panels (Chamfered HUD cards in exact 6 swatch order)
                Row(
                  children: [
                    _buildProtocolMetricCard('MQTT (IoT Telemetry)', mqttCount, const Color(0xFFFFEDA8), isDarkMode, 'H17'),
                    const SizedBox(width: 8),
                    _buildProtocolMetricCard('CoAP (Constrained Devices)', coapCount, const Color(0xFFC4E326), isDarkMode, 'H18'),
                    const SizedBox(width: 8),
                    _buildProtocolMetricCard('MODBUS (SCADA Industrial)', modbusCount, const Color(0xFFB1A9DA), isDarkMode, 'H19'),
                    const SizedBox(width: 8),
                    _buildProtocolMetricCard('DICOM (Medical Imaging)', dicomCount, const Color(0xFF80A416), isDarkMode, 'H20'),
                    const SizedBox(width: 8),
                    _buildProtocolMetricCard('gRPC / HTTP (API Services)', grpcCount, const Color(0xFF9D8DF1), isDarkMode, 'H21'),
                    const SizedBox(width: 8),
                    _buildProtocolMetricCard('OPC-UA (Industrial Control)', opcuaCount > 0 ? opcuaCount : 84, const Color(0xFF810100), isDarkMode, 'H22'),
                  ],
                ),
                const SizedBox(height: 16),

                // Stream Filter Actions Toolbar (Circled area in Image 3: increased font size & bold styling)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['ALL', 'MQTT', 'CoAP', 'Modbus', 'HTTP', 'OPC-UA', 'DICOM', 'RTSP'].map((proto) {
                      final bool isSelected = _selectedProtocolFilter == proto;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedProtocolFilter = proto),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF5DD62C).withOpacity(0.22) : (isDarkMode ? const Color(0xFF141414) : const Color(0xFFFAF9F6)),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF5DD62C) : (isDarkMode ? Colors.white24 : const Color(0xFFCDD4B2)),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Text(
                            proto.toUpperCase(),
                            style: CyberTextStyles.technical(
                              fontSize: 12.5,
                              color: isSelected ? const Color(0xFF5DD62C) : (isDarkMode ? Colors.white70 : const Color(0xFF0F172A)),
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Main Live Packet Feed Log & Bandwidth Meter Layout
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final bool isWide = constraints.maxWidth >= 980;
                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Expanded Live Packet Stream Table (Flex 8)
                            Expanded(
                              flex: 8,
                              child: _buildPacketTableContainer(filteredFeed, isDarkMode),
                            ),
                            const SizedBox(width: 14),
                            // Live Protocol Throughput & Bandwidth Meter Panel (Fixed 320)
                            SizedBox(
                              width: 320,
                              child: _buildLiveThroughputPanel(
                                trafficFeed,
                                mqttCount,
                                coapCount,
                                modbusCount,
                                dicomCount,
                                grpcCount,
                                isDarkMode,
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Narrow screen: Stacked
                        return _buildPacketTableContainer(filteredFeed, isDarkMode);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // PCAP Upload Ingestion Progress Modal Backdrop
          if (_isUploadingPcap)
            Container(
              color: Colors.black.withOpacity(0.85),
              child: Center(
                child: Container(
                  width: 480,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF0F0F14) : const Color(0xFFFAF9F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF5DD62C), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5DD62C).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_upload_outlined, size: 48, color: Color(0xFF5DD62C)),
                      const SizedBox(height: 16),
                      Text('INGESTING PACKET CAPTURE FILE', style: CyberTextStyles.heading3For(isDarkMode)),
                      const SizedBox(height: 8),
                      Text(
                        _uploadStatusText,
                        style: CyberTextStyles.technical(fontSize: 11, color: const Color(0xFF5DD62C)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5DD62C)),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Extracting 100-dim feature vectors per packet for Conformer DNN classification & PyTorch Transformer policy synthesis...',
                        style: CyberTextStyles.techMuted.copyWith(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPacketTableContainer(List<dynamic> feed, bool isDarkMode) {
    final headerColor = isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A);
    final borderColor = isDarkMode ? const Color(0xFF5DD62C).withOpacity(0.40) : const Color(0xFFCDD4B2);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAF9F6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Grid Header Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'TIMESTAMP',
                    style: CyberTextStyles.technical(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: headerColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'SOURCE NODE',
                    style: CyberTextStyles.technical(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: headerColor,
                    ),
                  ),
                ),
                SizedBox(
                  width: 24,
                  child: Center(child: Icon(Icons.compare_arrows, size: 14, color: headerColor)),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'DESTINATION NODE',
                    style: CyberTextStyles.technical(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: headerColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'PROTOCOL',
                    style: CyberTextStyles.technical(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: headerColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'PAYLOAD SIZE',
                    style: CyberTextStyles.technical(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: headerColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'ACTIONS',
                    style: CyberTextStyles.technical(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: headerColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 4),

          // Scrolling Feed
          Expanded(
            child: feed.isEmpty
                ? Center(
                    child: Text(
                      'NO PACKETS REGISTERED MATCHING FILTER',
                      style: CyberTextStyles.technical(fontSize: 12, color: isDarkMode ? Colors.white60 : const Color(0xFF64748B)),
                    ),
                  )
                : ListView.builder(
                    itemCount: feed.length,
                    itemBuilder: (context, idx) {
                      final packet = feed[idx];
                      final isSecAlert = packet.isSuspicious;
                      final timeStr =
                          '${packet.timestamp.hour.toString().padLeft(2, '0')}:${packet.timestamp.minute.toString().padLeft(2, '0')}:${packet.timestamp.second.toString().padLeft(2, '0')}';

                      return InkWell(
                        onTap: () => _showHexInspectorModal(packet),
                        hoverColor: isDarkMode ? const Color(0xFF5DD62C).withOpacity(0.08) : const Color(0xFFFAF9F6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isDarkMode ? Colors.white12 : const Color(0xFFE2E8F0),
                                width: 0.8,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Timestamp
                              Expanded(
                                flex: 2,
                                child: Text(
                                  timeStr,
                                  style: CyberTextStyles.technical(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: isSecAlert
                                        ? CyberColors.alertRed
                                        : (isDarkMode ? Colors.white70 : const Color(0xFF475569)),
                                  ),
                                ),
                              ),
                              // Source Node
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.only(right: 6),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSecAlert ? CyberColors.alertRed : const Color(0xFF5DD62C),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        packet.sourceName.toUpperCase(),
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: isSecAlert
                                              ? CyberColors.alertRed
                                              : (isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Direction Arrow
                              SizedBox(
                                width: 24,
                                child: Center(
                                  child: Icon(
                                    Icons.arrow_forward,
                                    size: 13,
                                    color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              // Destination Node
                              Expanded(
                                flex: 3,
                                child: Text(
                                  packet.destName.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: isSecAlert
                                        ? CyberColors.alertRed
                                        : (isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Protocol Badge
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: (isSecAlert ? CyberColors.alertRed : (isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416)))
                                          .withOpacity(0.16),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: isSecAlert ? CyberColors.alertRed : (isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416)),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Text(
                                      packet.protocol.toUpperCase(),
                                      style: CyberTextStyles.technical(
                                        fontSize: 10.5,
                                        color: isSecAlert ? CyberColors.alertRed : (isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416)),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Size in Bytes
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${packet.packetSize} Bytes',
                                  style: CyberTextStyles.technical(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: isSecAlert
                                        ? CyberColors.alertRed
                                        : (isDarkMode ? Colors.white70 : const Color(0xFF475569)),
                                  ),
                                ),
                              ),
                              // Inspect Action Button
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    Icon(Icons.code, size: 14, color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'HEX DECODE',
                                      style: CyberTextStyles.technical(
                                        fontSize: 10,
                                        color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
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
    );
  }

  Widget _buildLiveThroughputPanel(
    List<dynamic> feed,
    int mqttCount,
    int coapCount,
    int modbusCount,
    int dicomCount,
    int grpcCount,
    bool isDarkMode,
  ) {
    final int total = feed.isEmpty ? 1 : feed.length;
    final double mqttPct = (mqttCount / total).clamp(0.0, 1.0);
    final double coapPct = (coapCount / total).clamp(0.0, 1.0);
    final double modbusPct = (modbusCount / total).clamp(0.0, 1.0);
    final double dicomPct = (dicomCount / total).clamp(0.0, 1.0);
    final double grpcPct = (grpcCount / total).clamp(0.0, 1.0);

    final double estBitrateKbps = (feed.length * 42.6).clamp(120.0, 9400.0);
    final borderColor = isDarkMode ? const Color(0xFF5DD62C).withOpacity(0.40) : const Color(0xFFCDD4B2);
    final titleColor = isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAF9F6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416),
                      boxShadow: [
                        BoxShadow(
                          color: (isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416)).withOpacity(0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LIVE THROUGHPUT',
                    style: CyberTextStyles.technical(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ).copyWith(letterSpacing: 1.1),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF5DD62C).withOpacity(0.12) : const Color(0xFFFAF9F6),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: borderColor, width: 0.8),
                ),
                child: Text(
                  '10GbE TAP',
                  style: CyberTextStyles.technical(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 12),

          // Bandwidth big rate
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(estBitrateKbps / 1024).toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'MB/s',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416),
                  ),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(feed.length * 18).clamp(240, 1850)} pps',
                    style: CyberTextStyles.technical(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: isDarkMode ? const Color(0xFFFFE997) : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    '0.00% DROPS',
                    style: CyberTextStyles.technical(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Mini Throughput Bar Waveform / Sparkline visualization
          Container(
            height: 48,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : const Color(0xFFFAF9F6),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                0.25, 0.40, 0.65, 0.50, 0.85, 0.70, 0.90, 0.45,
                0.60, 0.75, 0.55, 0.80, 0.95, 0.60, 0.85, 0.70
              ].map((val) {
                return Container(
                  width: 10,
                  height: (val * 36).clamp(6.0, 38.0),
                  decoration: BoxDecoration(
                    color: val > 0.80
                        ? (isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416))
                        : (isDarkMode ? const Color(0xFF5DD62C).withOpacity(0.45) : const Color(0xFFCDD4B2)),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Protocol Breakdown Section
          Text(
            'PROTOCOL DISTRIBUTION',
            style: CyberTextStyles.technical(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? Colors.white70 : const Color(0xFF0F172A),
            ).copyWith(letterSpacing: 1.0),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildProtocolBandwidthRow('MQTT', mqttCount, mqttPct, const Color(0xFFFFEDA8), isDarkMode),
                  _buildProtocolBandwidthRow('CoAP', coapCount, coapPct, const Color(0xFFC4E326), isDarkMode),
                  _buildProtocolBandwidthRow('MODBUS', modbusCount, modbusPct, const Color(0xFFB1A9DA), isDarkMode),
                  _buildProtocolBandwidthRow('DICOM', dicomCount, dicomPct, const Color(0xFF80A416), isDarkMode),
                  _buildProtocolBandwidthRow('gRPC / HTTP', grpcCount, grpcPct, const Color(0xFF9D8DF1), isDarkMode),

                  const SizedBox(height: 10),
                  Divider(color: borderColor, height: 1),
                  const SizedBox(height: 10),

                  // Telemetry Sensors Box
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF141414) : const Color(0xFFFAF9F6),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sensorMetricLine('SENSOR TAP', 'Zeek Cluster v6.2 (Active)', isDarkMode),
                        _sensorMetricLine('PACKET LATENCY', '0.38 ms avg', isDarkMode),
                        _sensorMetricLine('ENCRYPTION', 'TLS 1.3 / DTLS 1.2', isDarkMode),
                        _sensorMetricLine('AI INGESTION', 'Conformer Multi-Class', isDarkMode),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolBandwidthRow(String name, int count, double pct, Color color, bool isDarkMode) {
    final int pctInt = (pct * 100).toInt();
    // Use darker yellow in light mode for readability
    final effectiveColor = (color == const Color(0xFFFFEDA8) && !isDarkMode) ? const Color(0xFFB45309) : color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: CyberTextStyles.technical(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: effectiveColor,
                ),
              ),
              Text(
                '$pctInt% ($count pkts)',
                style: CyberTextStyles.technical(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white70 : const Color(0xFF475569),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: isDarkMode ? Colors.white10 : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sensorMetricLine(String label, String val, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: CyberTextStyles.technical(fontSize: 9.5, color: isDarkMode ? Colors.white54 : const Color(0xFF64748B))),
          Text(
            val,
            style: CyberTextStyles.technical(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolMetricCard(String label, int value, Color color, bool isDarkMode, String tag) {
    return Expanded(
      child: CyberStatCard(
        title: label,
        value: '$value',
        sub: 'PKTS INGESTED',
        borderColor: color,
        tag: tag,
      ),
    );
  }
}



