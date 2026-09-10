import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/security_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/cyber_hud_card.dart';
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF0F0F14) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF5DD62C), width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.data_object, color: Color(0xFF5DD62C)),
            const SizedBox(width: 10),
            Text('DEEP PACKET INSPECTION (HEX & DECODE)', style: CyberTextStyles.heading3),
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
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SOURCE: ${packet.sourceName} -> DEST: ${packet.destName}',
                        style: CyberTextStyles.technical(fontSize: 11, color: const Color(0xFF5DD62C))),
                    Text('PROTOCOL: ${packet.protocol} | PAYLOAD SIZE: ${packet.packetSize} Bytes',
                        style: CyberTextStyles.technical(fontSize: 11, color: CyberColors.neonCyan)),
                    Text('STATUS: ${packet.isSuspicious ? "MALICIOUS / ANOMALY DETECTED" : "VERIFIED / NORMAL TRAFFIC"}',
                        style: CyberTextStyles.technical(
                            fontSize: 11,
                            color: packet.isSuspicious ? CyberColors.alertRed : const Color(0xFF5DD62C))),
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
                  color: const Color(0xFF07070A),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF5DD62C).withOpacity(0.3)),
                ),
                child: SelectableText(
                  hexDump,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Color(0xFF5DD62C),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('AI PIPELINE PROCESSING STEP:', style: CyberTextStyles.techMuted.copyWith(fontSize: 10)),
              const SizedBox(height: 4),
              Text(
                '1. Extract 100-dim feature vector -> 2. Pass to Conformer DNN for multi-class attack classification -> 3. Correlate node topology in GNN -> 4. Generate Zero-Trust OPA policy if anomalous.',
                style: CyberTextStyles.interface(fontSize: 11, color: isDarkMode ? Colors.white70 : Colors.black87),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('CLOSE', style: CyberTextStyles.technical(color: const Color(0xFF5DD62C))),
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
                            Text('LIVE TELEMETRY TRAFFIC', style: CyberTextStyles.heading2),
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
                        Text('REAL-TIME WIRESHARK / ZEEK PACKET CAPTURE STREAM ENGINE', style: CyberTextStyles.techMuted),
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

                // Protocol distribution summary panels (Chamfered HUD cards matching Image 1 & Image 2)
                Row(
                  children: [
                    _buildProtocolMetricCard('MQTT (IoT Telemetry)', mqttCount, const Color(0xFFFFE997), isDarkMode, 'H17'),
                    const SizedBox(width: 10),
                    _buildProtocolMetricCard('CoAP (Constrained Devices)', coapCount, const Color(0xFFA88AED), isDarkMode, 'H18'),
                    const SizedBox(width: 10),
                    _buildProtocolMetricCard('MODBUS (SCADA Industrial)', modbusCount, const Color(0xFFC4E320), isDarkMode, 'H19'),
                    const SizedBox(width: 10),
                    _buildProtocolMetricCard('DICOM (Medical Imaging)', dicomCount, const Color(0xFF80A416), isDarkMode, 'H20'),
                    const SizedBox(width: 10),
                    _buildProtocolMetricCard('gRPC / HTTP (API Services)', grpcCount, const Color(0xFFB91C1D), isDarkMode, 'H21'),
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
                            color: isSelected ? const Color(0xFF5DD62C).withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF5DD62C) : (isDarkMode ? Colors.white24 : Colors.black26),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            proto.toUpperCase(),
                            style: CyberTextStyles.technical(
                              fontSize: 10,
                              color: isSelected ? const Color(0xFF5DD62C) : CyberColors.textMuted,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Main Live Packet Feed Log Card (Matched with Dashboard Card HUD UI Style)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F0F), // Dark obsidian matching Dashboard cards
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color(0xFF5DD62C).withOpacity(0.40), // Cyber green border matching Dashboard
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Grid Columns Header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Text('TIMESTAMP', style: CyberTextStyles.technical(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF5DD62C)))),
                              Expanded(flex: 3, child: Text('SOURCE NODE', style: CyberTextStyles.technical(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF5DD62C)))),
                              Expanded(flex: 1, child: _buildArrowHeader()),
                              Expanded(flex: 3, child: Text('DESTINATION NODE', style: CyberTextStyles.technical(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF5DD62C)))),
                              Expanded(flex: 2, child: Text('PROTOCOL', style: CyberTextStyles.technical(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF5DD62C)))),
                              Expanded(flex: 2, child: Text('SIZE', style: CyberTextStyles.technical(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF5DD62C)))),
                              Expanded(flex: 2, child: Text('INSPECT', style: CyberTextStyles.technical(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF5DD62C)))),
                            ],
                          ),
                        ),
                        Divider(color: const Color(0xFF5DD62C).withOpacity(0.3), height: 1),
                        const SizedBox(height: 4),
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

                                    return InkWell(
                                      onTap: () => _showHexInspectorModal(packet),
                                      hoverColor: const Color(0xFF5DD62C).withOpacity(0.08),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide(color: isDarkMode ? Colors.white10 : Colors.black12)),
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
                                                  color: isSecAlert ? CyberColors.alertRed : (isDarkMode ? Colors.white : const Color(0xFF0F172A)),
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
                                                color: isSecAlert ? CyberColors.alertRed : const Color(0xFF5DD62C),
                                              ),
                                            ),
                                            // Dest Device Name
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                packet.destName.toUpperCase(),
                                                style: CyberTextStyles.interface(
                                                  fontSize: 11,
                                                  color: isSecAlert ? CyberColors.alertRed : (isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            // Protocol Badge
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: (isSecAlert ? CyberColors.alertRed : const Color(0xFF5DD62C)).withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: (isSecAlert ? CyberColors.alertRed : const Color(0xFF5DD62C)).withOpacity(0.4),
                                                    width: 0.8,
                                                  ),
                                                ),
                                                child: Text(
                                                  packet.protocol.toUpperCase(),
                                                  style: CyberTextStyles.technical(
                                                    fontSize: 10,
                                                    color: isSecAlert ? CyberColors.alertRed : const Color(0xFF5DD62C),
                                                    fontWeight: FontWeight.bold,
                                                  ),
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
                                                  color: isSecAlert ? CyberColors.alertRed : (isDarkMode ? Colors.white70 : Colors.black87),
                                                ),
                                              ),
                                            ),
                                            // Inspect Action Icon
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.search, size: 14, color: Color(0xFF5DD62C)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'HEX DECODE',
                                                    style: CyberTextStyles.technical(fontSize: 9, color: const Color(0xFF5DD62C), fontWeight: FontWeight.bold),
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
                    color: isDarkMode ? const Color(0xFF0F0F14) : Colors.white,
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
                      Text('INGESTING PACKET CAPTURE FILE', style: CyberTextStyles.heading3),
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

  Widget _buildArrowHeader() {
    return const SizedBox(width: 10);
  }
}


