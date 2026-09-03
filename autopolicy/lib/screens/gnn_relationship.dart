import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device.dart';
import '../providers/security_provider.dart';
import '../theme/colors.dart';
import '../theme/responsive.dart';
import '../theme/text_styles.dart';
import '../widgets/glass_container.dart';
import '../widgets/neon_button.dart';
import '../models/policy.dart';
import '../providers/theme_provider.dart';

// Premium responsive color palette
class CyberColorsExtended {
  static const Color neonCyan = Color(0xFF00F5FF);
  static const Color neonGreen = Color(0xFF00FF9F);
  static const Color electricPurple = Color(0xFFA855F7);
  static const Color alertRed = Color(0xFFFF4757);
  static const Color alertOrange = Color(0xFFFF9F43);
}

class GNNRelationship extends ConsumerStatefulWidget {
  const GNNRelationship({super.key});

  @override
  ConsumerState<GNNRelationship> createState() => _GNNRelationshipState();
}

class _GNNRelationshipState extends ConsumerState<GNNRelationship> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  IoTDevice? _selectedDevice;
  
  // Canvas translate and zoom configurations
  Offset _panOffset = Offset.zero;
  double _zoomScale = 1.0;
  Offset? _dragStart;

  // Node position map: maps device ID to relative coordinates
  final Map<String, Offset> _nodeCoords = {};

  // Interactive Hover & Drag states
  IoTDevice? _hoveredDevice;
  Offset _hoverPos = Offset.zero;
  String? _draggedDeviceId;
  bool _isDraggingNode = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Smooth 4-second breathing cycle
    )..repeat();

    _initializeNodeCoordinates();
  }

  // Set up balanced layout coordinates representing network connections clearly
  void _initializeNodeCoordinates() {
    final Random random = Random(1337);
    final devices = ref.read(securityProvider).devices;
    
    // Distribute nodes in two concentric orbits for clean visual hierarchy and zero overlap
    for (int i = 0; i < devices.length; i++) {
      final double angle = (i * 2 * pi) / devices.length;
      final double radius = (i % 2 == 0) ? 130.0 : 220.0;
      
      _nodeCoords[devices[i].id] = Offset(
        cos(angle) * radius + (random.nextDouble() - 0.5) * 20.0,
        sin(angle) * radius + (random.nextDouble() - 0.5) * 20.0,
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Find node coordinate near pointer position
  String? _findNodeAtPos(Offset localPos, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    String? matchedId;
    double minDistance = 28.0; // Click hit radius in pixels

    _nodeCoords.forEach((id, coord) {
      final Offset projectedCoord = center + _panOffset + (coord * _zoomScale);
      final double distance = (localPos - projectedCoord).distance;

      if (distance < minDistance) {
        minDistance = distance;
        matchedId = id;
      }
    });

    return matchedId;
  }

  void _handleCanvasTap(Offset localPos, Size canvasSize) {
    final matchedId = _findNodeAtPos(localPos, canvasSize);
    final devices = ref.read(securityProvider).devices;

    setState(() {
      if (matchedId != null) {
        _selectedDevice = devices.firstWhere((d) => d.id == matchedId);
      } else {
        _selectedDevice = null;
      }
    });
  }

  void _handlePanStart(Offset localPos, Size canvasSize) {
    final matchedId = _findNodeAtPos(localPos, canvasSize);
    if (matchedId != null) {
      setState(() {
        _draggedDeviceId = matchedId;
        _isDraggingNode = true;
      });
    } else {
      _dragStart = localPos;
      _isDraggingNode = false;
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_isDraggingNode && _draggedDeviceId != null) {
      setState(() {
        // Move node adjusted by zoom scale for accurate tracking
        final currentCoord = _nodeCoords[_draggedDeviceId!]!;
        _nodeCoords[_draggedDeviceId!] = currentCoord + (details.delta / _zoomScale);
      });
    } else {
      if (_dragStart == null) return;
      setState(() {
        _panOffset += details.delta;
      });
    }
  }

  void _handlePanEnd() {
    setState(() {
      _draggedDeviceId = null;
      _isDraggingNode = false;
      _dragStart = null;
    });
  }

  void _handleMouseHover(PointerEvent event, Size canvasSize) {
    final localPos = event.localPosition;
    final matchedId = _findNodeAtPos(localPos, canvasSize);
    final devices = ref.read(securityProvider).devices;

    setState(() {
      if (matchedId != null) {
        _hoveredDevice = devices.firstWhere((d) => d.id == matchedId);
        _hoverPos = localPos;
      } else {
        _hoveredDevice = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final securityState = ref.watch(securityProvider);
    final bool isMobile = Responsive.isMobile(context);
    final isDarkMode = ref.watch(themeModeProvider);

    // Sync selected device details
    if (_selectedDevice != null) {
      _selectedDevice = securityState.devices.firstWhere(
        (d) => d.id == _selectedDevice!.id,
        orElse: () => _selectedDevice!,
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          // 1. CLEAN INTERACTIVE GRAPH CANVAS
          Expanded(
            flex: 3,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

                return MouseRegion(
                  onHover: (event) => _handleMouseHover(event, canvasSize),
                  onExit: (_) => setState(() => _hoveredDevice = null),
                  child: Stack(
                    children: [
                      // Canvas gestures
                      GestureDetector(
                        onTapUp: (details) => _handleCanvasTap(details.localPosition, canvasSize),
                        onPanStart: (details) => _handlePanStart(details.localPosition, canvasSize),
                        onPanUpdate: _handlePanUpdate,
                        onPanEnd: (_) => _handlePanEnd(),
                        child: Container(
                          color: Colors.transparent,
                          width: double.infinity,
                          height: double.infinity,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: _GNNGraphPainter(
                                  devices: securityState.devices,
                                  nodeCoords: _nodeCoords,
                                  pulseVal: _pulseController.value,
                                  selectedId: _selectedDevice?.id,
                                  pan: _panOffset,
                                  zoom: _zoomScale,
                                  isDarkMode: isDarkMode,
                                  hoveredId: _hoveredDevice?.id,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Headers
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GNN DEVICE RELATIONSHIP MAP', 
                              style: CyberTextStyles.technical(
                                color: isDarkMode ? Colors.white : Colors.black, 
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              )
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'DRAG CORES TO RE-ARRANGE | HOVER TO AUDIT NODE METRICS', 
                              style: CyberTextStyles.techMuted.copyWith(
                                fontSize: 9,
                                color: isDarkMode ? CyberColors.textMuted : Colors.black54
                              )
                            ),
                          ],
                        ),
                      ),

                      // Zoom HUD
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: GlassContainer(
                          borderColor: isDarkMode ? CyberColors.neonCyan : const Color(0xFF6D28D9),
                          padding: const EdgeInsets.all(4),
                          showHUDCorners: false,
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.zoom_in, color: isDarkMode ? CyberColors.neonCyan : const Color(0xFF6D28D9), size: 18),
                                onPressed: () => setState(() => _zoomScale = min(2.2, _zoomScale + 0.15)),
                              ),
                              IconButton(
                                icon: Icon(Icons.zoom_out, color: isDarkMode ? CyberColors.neonCyan : const Color(0xFF6D28D9), size: 18),
                                onPressed: () => setState(() => _zoomScale = max(0.6, _zoomScale - 0.15)),
                              ),
                              IconButton(
                                icon: Icon(Icons.refresh, color: isDarkMode ? CyberColors.neonCyan : const Color(0xFF6D28D9), size: 18),
                                onPressed: () => setState(() {
                                  _panOffset = Offset.zero;
                                  _zoomScale = 1.0;
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 3. HOLOGRAPHIC MOUSE HOVER INFORMATION CARD
                      if (_hoveredDevice != null)
                        _buildHolographicTooltipCard(_hoveredDevice!, canvasSize),
                    ],
                  ),
                );
              },
            ),
          ),

          // 2. DEVICE PROFILE INSPECTOR SIDEBAR
          if (_selectedDevice != null && !isMobile)
            _buildDeviceProfileSidebar(_selectedDevice!, isDarkMode),
        ],
      ),
    );
  }

  // Clean, highly readable holographic tooltip card
  Widget _buildHolographicTooltipCard(IoTDevice device, Size canvasSize) {
    Color riskColor = CyberColorsExtended.neonCyan;
    String trustLevel = 'SECURED NETWORK';
    if (device.riskScore > 0.70) {
      riskColor = CyberColorsExtended.alertRed;
      trustLevel = 'COMPROMISED CORE';
    } else if (device.riskScore > 0.35) {
      riskColor = CyberColorsExtended.alertOrange;
      trustLevel = 'SUSPICIOUS ACTIVITY';
    } else if (device.status == DeviceStatus.isolated) {
      riskColor = CyberColorsExtended.electricPurple;
      trustLevel = 'ISOLATED NODE';
    }

    // Adaptive positioning to avoid clipping at the screen boundaries
    double left = _hoverPos.dx + 16.0;
    double top = _hoverPos.dy + 16.0;
    const double cardWidth = 240.0;
    const double cardHeight = 180.0;

    if (left > canvasSize.width - cardWidth - 20) {
      left = _hoverPos.dx - cardWidth - 16.0;
    }
    if (top > canvasSize.height - cardHeight - 20) {
      top = _hoverPos.dy - cardHeight - 16.0;
    }

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: GlassContainer(
            borderColor: riskColor,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        device.name.toUpperCase(),
                        style: CyberTextStyles.displayTitle(fontSize: 12, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: riskColor,
                        boxShadow: [BoxShadow(color: riskColor, blurRadius: 4)],
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white12, height: 10),
                
                _buildTooltipRow('IP ADDRESS', device.ipAddress),
                _buildTooltipRow('MAC COPE', device.macAddress.toUpperCase()),
                _buildTooltipRow('BANDWIDTH', '${device.bandwidth.toStringAsFixed(1)} KB/S'),
                _buildTooltipRow('COMM LINKS', '${device.connections.length} ACTIVE PATHS'),
                const SizedBox(height: 6),

                // Risk progress bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('RISK SCORE', style: CyberTextStyles.techMuted.copyWith(fontSize: 8.0)),
                    Text(
                      '${(device.riskScore * 100).toStringAsFixed(0)}%',
                      style: CyberTextStyles.technical(color: riskColor, fontSize: 9.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: device.riskScore,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(riskColor),
                    minHeight: 3.0,
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    trustLevel,
                    style: CyberTextStyles.technical(color: riskColor, fontSize: 8.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTooltipRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: CyberTextStyles.techMuted.copyWith(fontSize: 8.0)),
          Text(val, style: CyberTextStyles.technical(color: Colors.white, fontSize: 8.5)),
        ],
      ),
    );
  }

  Widget _buildDeviceProfileSidebar(IoTDevice device, bool isDarkMode) {
    final bool isCompromised = device.status == DeviceStatus.warning;
    final bool isIsolated = device.status == DeviceStatus.isolated;

    return Container(
      width: 320,
      margin: const EdgeInsets.all(16),
      child: GlassContainer(
        borderColor: isCompromised 
            ? CyberColorsExtended.alertRed 
            : (isIsolated ? CyberColorsExtended.neonCyan : CyberColorsExtended.neonGreen),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NODE REACTOR INSPECTION', 
                    style: CyberTextStyles.technical(
                      color: isDarkMode ? Colors.white : Colors.black, 
                      fontSize: 12
                    )
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: isDarkMode ? CyberColors.textMuted : Colors.black54, size: 16),
                    onPressed: () => setState(() => _selectedDevice = null),
                  ),
                ],
              ),
              const Divider(color: CyberColors.borderNeonCyan),
              const SizedBox(height: 12),

              // Device header
              Text(
                device.name.toUpperCase(),
                style: CyberTextStyles.displayTitle(
                  fontSize: 16,
                  color: isCompromised 
                      ? CyberColorsExtended.alertRed 
                      : (isDarkMode ? Colors.white : Colors.black),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'TYPE: ${device.deviceType.toUpperCase()} | ${device.protocol.toUpperCase()}',
                style: CyberTextStyles.techMuted.copyWith(
                  fontSize: 10,
                  color: isDarkMode ? CyberColors.textMuted : Colors.black54
                ),
              ),
              const SizedBox(height: 16),

              // Metrics stats list
              _buildDetailMetric('DEVICE ID', device.id, isDarkMode),
              _buildDetailMetric('IP ADDRESS', device.ipAddress, isDarkMode),
              _buildDetailMetric('MAC ADDRESS', device.macAddress, isDarkMode),
              _buildDetailMetric('RISK FACTOR', '${(device.riskScore * 100).toStringAsFixed(1)}%', isDarkMode, riskColor: isCompromised ? CyberColorsExtended.alertRed : null),
              _buildDetailMetric('BANDWIDTH', '${device.bandwidth.toStringAsFixed(1)} KB/S', isDarkMode),
              _buildDetailMetric('CPU METRIC', '${device.cpuUsage.toStringAsFixed(1)}%', isDarkMode),
              _buildDetailMetric('RAM UTILIZATION', '${device.memoryUsage.toStringAsFixed(1)}%', isDarkMode),
              const SizedBox(height: 16),

              // Actions buttons
              if (isCompromised) ...[
                Text(
                  'GNN WARNING: COMPROMISED CLUSTER DETECTED. IMMEDIATE PROTOCOL ENFORCEMENT MANDATED.',
                  style: CyberTextStyles.technical(color: CyberColorsExtended.alertRed, fontSize: 10),
                ),
                const SizedBox(height: 12),
                NeonButton(
                  text: 'Enforce Microsegment',
                  color: CyberColorsExtended.alertRed,
                  onPressed: () {
                    final policy = ref.read(securityProvider).policies.firstWhere(
                          (p) => p.deviceId == device.id && p.status == PolicyStatus.pending,
                          orElse: () => ref.read(securityProvider).policies.first,
                        );
                    ref.read(securityProvider.notifier).deployPolicy(policy.id, policy.rawJsonPolicy);
                  },
                ),
              ] else if (isIsolated) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CyberColorsExtended.neonCyan.withOpacity(0.08),
                    border: Border.all(color: CyberColorsExtended.neonCyan),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock, size: 14, color: CyberColorsExtended.neonCyan),
                      const SizedBox(width: 8),
                      Text('NODE ISOLATED & SECURED', style: CyberTextStyles.technical(color: CyberColorsExtended.neonCyan, fontSize: 11)),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  'NODE STATUS: STABLE REGULATORY HEALTH.',
                  style: CyberTextStyles.technical(
                    color: isDarkMode ? CyberColorsExtended.neonGreen : const Color(0xFF00875A), 
                    fontSize: 10
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailMetric(String label, String val, bool isDarkMode, {Color? riskColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: CyberTextStyles.techMuted.copyWith(
              fontSize: 10,
              color: isDarkMode ? CyberColors.textMuted : Colors.black54
            )
          ),
          Text(
            val, 
            style: CyberTextStyles.technical(
              color: riskColor ?? (isDarkMode ? Colors.white : Colors.black), 
              fontSize: 11, 
              fontWeight: FontWeight.bold
            )
          ),
        ],
      ),
    );
  }
}

// Custom painter that focuses on absolute clean layout lines and smooth, readable node animations
class _GNNGraphPainter extends CustomPainter {
  final List<IoTDevice> devices;
  final Map<String, Offset> nodeCoords;
  final double pulseVal;
  final String? selectedId;
  final String? hoveredId;
  final Offset pan;
  final double zoom;
  final bool isDarkMode;

  const _GNNGraphPainter({
    required this.devices,
    required this.nodeCoords,
    required this.pulseVal,
    this.selectedId,
    this.hoveredId,
    required this.pan,
    required this.zoom,
    required this.isDarkMode,
  });

  bool _isHub(IoTDevice device) {
    return device.connections.length >= 3 || device.id == 'DEV-001' || device.id == 'DEV-010';
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. DRAW PITCH-BLACK VOID BACKGROUND WITH INDIGO NEBULAE AND GRID LINES
    if (isDarkMode) {
      final cosmicVoidPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF03050F), // Polished high-contrast blue-black core
            const Color(0xFF000000), // Pure highly-polished pitch black rim
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRect(Offset.zero & size, cosmicVoidPaint);

      // Distant cosmic nebulae cloud (cosmic indigo)
      final purpleNebula = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF1E1B4B).withOpacity(0.08),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center + pan * 0.1, radius: size.width * 0.8));
      canvas.drawRect(Offset.zero & size, purpleNebula);
    }

    // 2. GENERATE HIGH-FIDELITY STARFIELD (BOKEH POINTS)
    final Random rand = Random(1337);
    for (int layer = 0; layer < 3; layer++) {
      final double starScale = 0.5 + (layer * 0.5);
      final int starsCount = layer == 0 ? 120 : (layer == 1 ? 80 : 45);
      final double starOpacity = 0.15 + (layer * 0.15);

      for (int i = 0; i < starsCount; i++) {
        final double x = rand.nextDouble() * size.width;
        final double y = rand.nextDouble() * size.height;

        final double pulse = 0.85 + 0.15 * sin(pulseVal * 2 * pi + i.hashCode);
        final double radius = (rand.nextDouble() * 2.5 + 0.5) * starScale * zoom * pulse;

        final Color starColor = rand.nextDouble() > 0.15 
            ? Colors.white 
            : const Color(0xFFB0BEC5);

        // Faint bokeh glow
        canvas.drawCircle(
          Offset(x, y),
          radius * 2.5,
          Paint()..color = starColor.withOpacity(0.05 * starOpacity),
        );

        // Core star dot
        canvas.drawCircle(
          Offset(x, y),
          radius,
          Paint()..color = starColor.withOpacity(0.80 * starOpacity),
        );
      }
    }

    // 3. DRAW STRAIGHT GLOWING LINKS & FLOWING PACKETS
    for (final device in devices) {
      final Offset srcPos = center + pan + (nodeCoords[device.id]! * zoom);

      for (final connId in device.connections) {
        if (device.id.hashCode > connId.hashCode) continue;

        final targetDevice = devices.firstWhere((d) => d.id == connId, orElse: () => device);
        final Offset destPos = center + pan + (nodeCoords[connId]! * zoom);

        Color edgeColor = const Color(0xFFFF5722); // Fiery orange link
        if (device.status == DeviceStatus.warning || targetDevice.status == DeviceStatus.warning) {
          edgeColor = const Color(0xFFFF1744); // Incident red
        } else if (device.status == DeviceStatus.isolated || targetDevice.status == DeviceStatus.isolated) {
          edgeColor = const Color(0xFF9C27B0); // Isolated purple
        }

        // Underlay glow path
        canvas.drawLine(
          srcPos,
          destPos,
          Paint()
            ..color = edgeColor.withOpacity(0.08)
            ..strokeWidth = 3.2 * zoom
            ..style = PaintingStyle.stroke,
        );

        // Sharp vector line
        canvas.drawLine(
          srcPos,
          destPos,
          Paint()
            ..color = edgeColor.withOpacity(0.24)
            ..strokeWidth = 0.8 * zoom
            ..style = PaintingStyle.stroke,
        );

        // Flowing specular energy packet
        final double t = (pulseVal * 1.0 + (device.id.hashCode % 10) / 10.0) % 1.0;
        final Offset packetPos = Offset.lerp(srcPos, destPos, t)!;

        // Core specular white dot
        canvas.drawCircle(packetPos, 1.8 * zoom, Paint()..color = Colors.white);
        // Outer thin neon ring
        canvas.drawCircle(
          packetPos,
          3.6 * zoom,
          Paint()
            ..color = edgeColor.withOpacity(0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8 * zoom,
        );
      }
    }

    // 4. DRAW FIERY ORANGE-RED SPECULAR 3D ORBS WITH ROTATING WIREFRAMES & TARGET HUD BRACKETS
    for (final device in devices) {
      final Offset nodePos = center + pan + (nodeCoords[device.id]! * zoom);

      final bool isSelected = device.id == selectedId;
      final bool isHovered = device.id == hoveredId;
      final bool isHub = _isHub(device);

      final double baseRadius = isHub 
          ? (isSelected || isHovered ? 21.0 : 16.5) 
          : (isSelected || isHovered ? 10.0 : 6.5);
      
      final double breath = sin(pulseVal * 2 * pi + device.id.hashCode) * (isHub ? 1.0 : 0.4);
      final double currentRadius = (baseRadius + breath) * zoom;

      // Base theme color mapping
      Color nodeColor = const Color(0xFFFF3D00); // Glowing fiery orange-red by default
      List<Color> gradientColors;

      if (device.status == DeviceStatus.warning) {
        nodeColor = const Color(0xFFFF1744);
        gradientColors = [
          Colors.white,
          const Color(0xFFFF1744),
          const Color(0xFFB71C1C),
        ];
      } else if (device.status == DeviceStatus.isolated) {
        nodeColor = const Color(0xFF9C27B0);
        gradientColors = [
          Colors.white,
          const Color(0xFFE040FB),
          const Color(0xFF4A148C),
        ];
      } else if (isHub) {
        nodeColor = const Color(0xFFFF5722);
        gradientColors = [
          const Color(0xFFFFF176), // Specs highlight core
          const Color(0xFFFF7043),
          const Color(0xFFD84315),
        ];
      } else {
        nodeColor = const Color(0xFFFF3D00);
        gradientColors = [
          const Color(0xFFFFEE58), // Satellites fiery spec highlight
          const Color(0xFFFF3D00),
          const Color(0xFF9E0D0D),
        ];
      }

      // 4.1 Solar halo ambient glow ring
      final double haloRadius = currentRadius * (isHub ? 1.85 : 1.4) + sin(pulseVal * 2 * pi) * (isHub ? 3.0 : 0.8) * zoom;
      final haloPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            nodeColor.withOpacity(isHovered ? 0.38 : 0.16),
            nodeColor.withOpacity(0.01),
            Colors.transparent,
          ],
          stops: const [0.0, 0.65, 1.0],
        ).createShader(Rect.fromCircle(center: nodePos, radius: haloRadius));
      canvas.drawCircle(nodePos, haloRadius, haloPaint);

      // 4.2 Pulsing alert wave outlines
      if (device.status == DeviceStatus.warning) {
        final double warningWave = currentRadius + (12.0 * zoom) + (pulseVal * 16.0 * zoom) % (12.0 * zoom);
        final double opacity = max(0.0, 0.25 - ((warningWave - currentRadius) / (12.0 * zoom)) * 0.25);
        canvas.drawCircle(
          nodePos,
          warningWave,
          Paint()
            ..color = const Color(0xFFFF1744).withOpacity(opacity)
            ..strokeWidth = 1.0 * zoom
            ..style = PaintingStyle.stroke,
        );
      }

      // 4.3 High-Fidelity 3D Specular Orb
      final Paint nodePaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.35),
          colors: gradientColors,
          stops: const [0.05, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: nodePos, radius: currentRadius));
      canvas.drawCircle(nodePos, currentRadius, nodePaint);

      // Specular highlight white reflection dot
      canvas.drawCircle(
        nodePos - Offset(currentRadius * 0.28, currentRadius * 0.28),
        currentRadius * 0.15,
        Paint()..color = Colors.white.withOpacity(0.82),
      );

      // 4.4 Orange/Amber 3D wireframe polyhedral cage enclosing hubs
      if (isHub) {
        final double wireframeRadius = currentRadius * 1.55;
        final double rotationAngle = pulseVal * 0.35 * pi + (device.id.hashCode % 100);
        
        final wirePaint = Paint()
          ..color = const Color(0xFFFF9800).withOpacity(0.26)
          ..strokeWidth = 0.5 * zoom
          ..style = PaintingStyle.stroke;

        final List<Offset> polyPoints = [];
        for (int v = 0; v < 8; v++) {
          final double angle = rotationAngle + (v * pi / 4.0);
          final double offsetZ = (v % 2 == 0) ? -wireframeRadius * 0.3 : wireframeRadius * 0.3;
          polyPoints.add(
            nodePos + Offset(
              cos(angle) * (wireframeRadius + offsetZ * 0.25),
              sin(angle) * (wireframeRadius + offsetZ * 0.25),
            ),
          );
        }

        for (int e = 0; e < 8; e++) {
          canvas.drawLine(polyPoints[e], polyPoints[(e + 1) % 8], wirePaint);
          canvas.drawLine(polyPoints[e], polyPoints[(e + 4) % 8], wirePaint);
        }
      }

      // 4.5 Active scanner target crosshair HUD brackets
      if (isSelected || isHovered) {
        final bracketPaint = Paint()
          ..color = nodeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2 * zoom;
        
        final double d = currentRadius + 6.0 * zoom;
        final double len = 6.0 * zoom;
        
        // Top-Left
        canvas.drawPath(
          Path()
            ..moveTo(nodePos.dx - d, nodePos.dy - d + len)
            ..lineTo(nodePos.dx - d, nodePos.dy - d)
            ..lineTo(nodePos.dx - d + len, nodePos.dy - d),
          bracketPaint,
        );
        
        // Top-Right
        canvas.drawPath(
          Path()
            ..moveTo(nodePos.dx + d - len, nodePos.dy - d)
            ..lineTo(nodePos.dx + d, nodePos.dy - d)
            ..lineTo(nodePos.dx + d, nodePos.dy - d + len),
          bracketPaint,
        );
        
        // Bottom-Left
        canvas.drawPath(
          Path()
            ..moveTo(nodePos.dx - d, nodePos.dy + d - len)
            ..lineTo(nodePos.dx - d, nodePos.dy + d)
            ..lineTo(nodePos.dx - d + len, nodePos.dy + d),
          bracketPaint,
        );
        
        // Bottom-Right
        canvas.drawPath(
          Path()
            ..moveTo(nodePos.dx + d - len, nodePos.dy + d)
            ..lineTo(nodePos.dx + d, nodePos.dy + d)
            ..lineTo(nodePos.dx + d, nodePos.dy + d - len),
          bracketPaint,
        );
      }

      // 4.6 Technical Shorthand Labels (Tag box for hubs, underneath text for satellites)
      final String shorthand = device.name.split('-').last.toUpperCase();

      if (isHub) {
        final double textOffset = currentRadius + 12.0 * zoom;
        final double boxWidth = 52.0 * zoom;
        final double boxHeight = 15.0 * zoom;
        
        final tagRect = Rect.fromLTWH(
          nodePos.dx + textOffset,
          nodePos.dy - boxHeight / 2,
          boxWidth,
          boxHeight,
        );

        // Box background
        canvas.drawRRect(
          RRect.fromRectAndRadius(tagRect, const Radius.circular(2)),
          Paint()..color = const Color(0xFF030A16).withOpacity(0.68),
        );

        // Cyan/blue border
        canvas.drawRRect(
          RRect.fromRectAndRadius(tagRect, const Radius.circular(2)),
          Paint()
            ..color = const Color(0xFF00E5FF).withOpacity(0.45)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8 * zoom,
        );

        // Shorthand text centered inside tag box
        final textPainter = TextPainter(
          text: TextSpan(
            text: shorthand,
            style: TextStyle(
              color: const Color(0xFFFFB74D), // Amber orange text
              fontSize: 7.5 * zoom,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              letterSpacing: 1.0,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(
            tagRect.left + (boxWidth - textPainter.width) / 2,
            tagRect.top + (boxHeight - textPainter.height) / 2,
          ),
        );
      } else {
        // Satellites display underneath node
        final textPainter = TextPainter(
          text: TextSpan(
            text: shorthand,
            style: TextStyle(
              color: isSelected 
                  ? Colors.white 
                  : (isDarkMode ? const Color(0xFFCFD8DC) : Colors.black87),
              fontSize: 7.5 * zoom,
              fontWeight: FontWeight.normal,
              fontFamily: 'monospace',
              letterSpacing: 0.5,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(
            nodePos.dx - textPainter.width / 2,
            nodePos.dy + currentRadius + 8.0,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GNNGraphPainter oldDelegate) {
    return oldDelegate.devices != devices ||
        oldDelegate.nodeCoords != nodeCoords ||
        oldDelegate.pulseVal != pulseVal ||
        oldDelegate.selectedId != selectedId ||
        oldDelegate.hoveredId != hoveredId ||
        oldDelegate.pan != pan ||
        oldDelegate.zoom != zoom ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}
