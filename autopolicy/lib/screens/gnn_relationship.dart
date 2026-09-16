import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/device.dart';
import '../models/policy.dart';
import '../providers/security_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/responsive.dart';
import '../theme/text_styles.dart';

enum GraphLayoutMode { forceDirected, hierarchical, circular }
enum GraphFilter { all, criticalOnly, warningOnly, lateralOnly }

class GNNRelationship extends ConsumerStatefulWidget {
  const GNNRelationship({super.key});

  @override
  ConsumerState<GNNRelationship> createState() => _GNNRelationshipState();
}

class _GNNRelationshipState extends ConsumerState<GNNRelationship>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  IoTDevice? _selectedDevice;

  // Viewport transformation
  Offset _panOffset = Offset.zero;
  double _zoomScale = 1.0;
  Offset? _dragStart;

  // Layout & Filtering controls
  GraphLayoutMode _layoutMode = GraphLayoutMode.forceDirected;
  GraphFilter _filterMode = GraphFilter.all;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Node position map: maps device ID to relative coordinates
  final Map<String, Offset> _nodeCoords = {};

  // Interactive Drag & Hover states
  IoTDevice? _hoveredDevice;
  Offset _hoverPos = Offset.zero;
  String? _draggedDeviceId;
  bool _isDraggingNode = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _calculateNodePositions();
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _calculateNodePositions() {
    final devices = ref.read(securityProvider).devices;
    if (devices.isEmpty) return;

    _nodeCoords.clear();

    switch (_layoutMode) {
      case GraphLayoutMode.circular:
        final int n = devices.length;
        for (int i = 0; i < n; i++) {
          final double angle = (i * 2 * pi) / n;
          final bool isInner = i % 2 == 0;
          final double radius = isInner ? 120.0 : 205.0;
          _nodeCoords[devices[i].id] = Offset(
            cos(angle) * radius,
            sin(angle) * radius,
          );
        }
        break;

      case GraphLayoutMode.hierarchical:
        final gateways = <IoTDevice>[];
        final highValue = <IoTDevice>[];
        final fieldDevices = <IoTDevice>[];

        for (final d in devices) {
          if (_isGateway(d)) {
            gateways.add(d);
          } else if (_isHighValue(d)) {
            highValue.add(d);
          } else {
            fieldDevices.add(d);
          }
        }

        void layoutRow(List<IoTDevice> list, double y, double spacing) {
          final double startX = -((list.length - 1) * spacing) / 2.0;
          for (int i = 0; i < list.length; i++) {
            _nodeCoords[list[i].id] = Offset(startX + (i * spacing), y);
          }
        }

        layoutRow(gateways, -140.0, 160.0);
        layoutRow(highValue, 0.0, 135.0);
        layoutRow(fieldDevices, 140.0, 105.0);
        break;

      case GraphLayoutMode.forceDirected:
      default:
        final Random random = Random(42);
        for (int i = 0; i < devices.length; i++) {
          final d = devices[i];
          if (_isGateway(d)) {
            _nodeCoords[d.id] = Offset.zero;
          } else {
            final double angle = (i * 2 * pi) / (devices.length - 1);
            final double baseDist = _isHighValue(d) ? 120.0 : 195.0;
            final double jitter = (random.nextDouble() - 0.5) * 30.0;
            _nodeCoords[d.id] = Offset(
              cos(angle) * (baseDist + jitter),
              sin(angle) * (baseDist + jitter),
            );
          }
        }
        break;
    }
  }

  bool _isGateway(IoTDevice d) {
    final type = d.deviceType.toLowerCase();
    return type.contains('gateway') || type.contains('router') || d.id == 'DEV-001';
  }

  bool _isHighValue(IoTDevice d) {
    final type = d.deviceType.toLowerCase();
    return type.contains('server') ||
        type.contains('database') ||
        type.contains('medical') ||
        type.contains('infusion') ||
        type.contains('scada') ||
        d.id == 'DEV-005' ||
        d.id == 'DEV-010';
  }

  bool _isCritical(IoTDevice d) {
    return d.riskScore >= 0.70 || d.status == DeviceStatus.warning;
  }

  bool _isWarning(IoTDevice d) {
    return d.riskScore >= 0.35 && d.riskScore < 0.70 && d.status != DeviceStatus.warning;
  }

  bool _isNodeVisible(IoTDevice d) {
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      final match = d.name.toLowerCase().contains(q) ||
          d.ipAddress.toLowerCase().contains(q) ||
          d.deviceType.toLowerCase().contains(q) ||
          d.id.toLowerCase().contains(q);
      if (!match) return false;
    }

    switch (_filterMode) {
      case GraphFilter.criticalOnly:
        return _isCritical(d);
      case GraphFilter.warningOnly:
        return _isWarning(d);
      case GraphFilter.lateralOnly:
        return _isCritical(d) || _isWarning(d);
      case GraphFilter.all:
      default:
        return true;
    }
  }

  String? _findNodeAtPos(Offset localPos, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2 + 75.0);
    String? matchedId;
    double minDistance = 32.0;

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
        final currentCoord = _nodeCoords[_draggedDeviceId!] ?? Offset.zero;
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
    final isDarkMode = ref.watch(themeModeProvider);
    final isMobile = Responsive.isMobile(context);

    if (_selectedDevice != null) {
      _selectedDevice = securityState.devices.firstWhere(
        (d) => d.id == _selectedDevice!.id,
        orElse: () => _selectedDevice!,
      );
    }

    final totalNodes = securityState.devices.length;
    final criticalNodes = securityState.devices.where((d) => _isCritical(d)).length;
    final isolatedNodes = securityState.devices.where((d) => d.status == DeviceStatus.isolated).length;
    final lateralPaths = securityState.anomalies.where((a) => !a.isMitigated).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── 1. MAIN INTERACTIVE GRAPH CANVAS ──────────────────────────────
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

                return MouseRegion(
                  onHover: (event) => _handleMouseHover(event, canvasSize),
                  onExit: (_) => setState(() => _hoveredDevice = null),
                  child: GestureDetector(
                    onTapUp: (details) => _handleCanvasTap(details.localPosition, canvasSize),
                    onPanStart: (details) => _handlePanStart(details.localPosition, canvasSize),
                    onPanUpdate: _handlePanUpdate,
                    onPanEnd: (_) => _handlePanEnd(),
                    child: AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _UniqueGNNGraphPainter(
                            devices: securityState.devices,
                            nodeCoords: _nodeCoords,
                            pulseVal: _animController.value,
                            selectedId: _selectedDevice?.id,
                            hoveredId: _hoveredDevice?.id,
                            pan: _panOffset,
                            zoom: _zoomScale,
                            isDarkMode: isDarkMode,
                            isNodeVisible: _isNodeVisible,
                            filterMode: _filterMode,
                          ),
                          size: Size.infinite,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // ── 2. TOP TOOLBAR & CONTROLS HUD ─────────────────────────────────
          Positioned(
            top: 14,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAF9F6),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isDarkMode ? const Color(0xFF5DD62C).withOpacity(0.40) : const Color(0xFFCDD4B2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.hub_outlined, color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416), size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'GNN DEVICE TOPOLOGY & LATERAL MOVEMENT GRAPH',
                                style: CyberTextStyles.displayTitle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A),
                                ).copyWith(letterSpacing: 1.2),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'GRAPH NEURAL NETWORK (GraphSAGE) EMBEDDINGS · REAL-TIME THREAT PROPAGATION',
                            style: CyberTextStyles.technical(
                              fontSize: 9.5,
                              color: isDarkMode ? Colors.white70 : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Top-Right Compact Floating Stat Cards (Exact 4 Swatch Colors in Sequence)
                    if (!isMobile)
                      Row(
                        children: [
                          _buildMiniSwatchStatCard('TOTAL NODES', '$totalNodes', const Color(0xFFFFEDA8), Icons.router_outlined),
                          const SizedBox(width: 8),
                          _buildMiniSwatchStatCard('HIGH RISK', '$criticalNodes', const Color(0xFFC4E326), Icons.warning_amber_outlined),
                          const SizedBox(width: 8),
                          _buildMiniSwatchStatCard('ISOLATED', '$isolatedNodes', const Color(0xFFB1A9DA), Icons.lock_outline),
                          const SizedBox(width: 8),
                          _buildMiniSwatchStatCard('ATTACK PATHS', '$lateralPaths', const Color(0xFF80A416), Icons.alt_route),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Sub-Row: Layout Switcher + Filters + Search Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAF9F6),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: isDarkMode ? Colors.white12 : const Color(0xFFCDD4B2), width: 1),
                  ),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'LAYOUT:',
                            style: CyberTextStyles.technical(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white70 : const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildLayoutBtn('FORCE-DIRECTED', GraphLayoutMode.forceDirected, Icons.bubble_chart_outlined, isDarkMode),
                          const SizedBox(width: 6),
                          _buildLayoutBtn('HIERARCHICAL', GraphLayoutMode.hierarchical, Icons.account_tree_outlined, isDarkMode),
                          const SizedBox(width: 6),
                          _buildLayoutBtn('CIRCULAR', GraphLayoutMode.circular, Icons.radio_button_checked, isDarkMode),
                        ],
                      ),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'FILTER:',
                            style: CyberTextStyles.technical(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white70 : const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterBtn('ALL', GraphFilter.all, isDarkMode: isDarkMode),
                          const SizedBox(width: 6),
                          _buildFilterBtn('CRITICAL ONLY', GraphFilter.criticalOnly, color: const Color(0xFFDF2531), isDarkMode: isDarkMode),
                          const SizedBox(width: 6),
                          _buildFilterBtn('WARNING ONLY', GraphFilter.warningOnly, color: const Color(0xFFFF9F43), isDarkMode: isDarkMode),
                          const SizedBox(width: 6),
                          _buildFilterBtn('LATERAL PATHS ONLY', GraphFilter.lateralOnly, color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416), isDarkMode: isDarkMode),
                        ],
                      ),

                      SizedBox(
                        width: 220,
                        height: 32,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          style: CyberTextStyles.technical(fontSize: 11.5, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                          decoration: InputDecoration(
                            hintText: 'SEARCH ASSET / IP...',
                            hintStyle: CyberTextStyles.technical(fontSize: 10.5, color: isDarkMode ? Colors.white38 : const Color(0xFF94A3B8)),
                            prefixIcon: Icon(Icons.search, size: 15, color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A)),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear, size: 14, color: isDarkMode ? Colors.white54 : const Color(0xFF64748B)),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: isDarkMode ? const Color(0xFF141414) : const Color(0xFFFAF9F6),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3),
                              borderSide: BorderSide(color: isDarkMode ? Colors.white24 : const Color(0xFFCDD4B2)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3),
                              borderSide: BorderSide(color: isDarkMode ? Colors.white24 : const Color(0xFFCDD4B2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3),
                              borderSide: BorderSide(color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFFB8A9C1)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── 3. BOTTOM-LEFT MINI LEGEND ────────────────────────────────────
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAF9F6),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isDarkMode ? Colors.white30 : const Color(0xFFCDD4B2), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.black.withOpacity(0.85) : Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'NODE & PATH LEGEND',
                    style: CyberTextStyles.technical(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w900,
                      color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF0F172A),
                    ).copyWith(letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 10),
                  _legendItem(const Color(0xFF00B4D8), 'Gateway / Router (Hexagon)', Icons.router_outlined, isDarkMode),
                  _legendItem(const Color(0xFF9D8DF1), 'High-Value Asset (Diamond)', Icons.dns_outlined, isDarkMode),
                  _legendItem(const Color(0xFF5DD62C), 'Safe Device (Green Circle)', Icons.check_circle_outline, isDarkMode),
                  _legendItem(const Color(0xFFFF9F43), 'Warning (Orange Dashed Ring)', Icons.warning_amber_outlined, isDarkMode),
                  _legendItem(const Color(0xFFDF2531), 'Critical Compromised (Pulsing Red)', Icons.dangerous_outlined, isDarkMode),
                  _legendItem(const Color(0xFFA88AED), 'Quarantined / Isolated', Icons.lock_outline, isDarkMode),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF5722),
                          boxShadow: [BoxShadow(color: Color(0xFFFF5722), blurRadius: 6)],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Lateral Attack Vector (Dashed Red)',
                        style: CyberTextStyles.technical(
                          fontSize: 12.0,
                          color: const Color(0xFFFF5722),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── 4. BOTTOM ZOOM / PAN CONTROLS ─────────────────────────────────
          Positioned(
            bottom: 16,
            left: 280,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAF9F6),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: isDarkMode ? Colors.white24 : const Color(0xFFCDD4B2), width: 1),
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Zoom In',
                    icon: Icon(Icons.add, size: 17, color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416)),
                    onPressed: () => setState(() => _zoomScale = min(2.5, _zoomScale + 0.15)),
                  ),
                  IconButton(
                    tooltip: 'Zoom Out',
                    icon: Icon(Icons.remove, size: 17, color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416)),
                    onPressed: () => setState(() => _zoomScale = max(0.5, _zoomScale - 0.15)),
                  ),
                  IconButton(
                    tooltip: 'Fit to Screen',
                    icon: Icon(Icons.fullscreen, size: 17, color: isDarkMode ? Colors.white70 : const Color(0xFF475569)),
                    onPressed: () => setState(() {
                      _panOffset = Offset.zero;
                      _zoomScale = 1.0;
                    }),
                  ),
                  IconButton(
                    tooltip: 'Re-Center Canvas',
                    icon: Icon(Icons.center_focus_strong, size: 17, color: isDarkMode ? Colors.white70 : const Color(0xFF475569)),
                    onPressed: () => setState(() => _panOffset = Offset.zero),
                  ),
                ],
              ),
            ),
          ),

          // ── 5. HOLOGRAPHIC MOUSE HOVER TELEMETRY CARD ─────────────────────
          if (_hoveredDevice != null && _selectedDevice?.id != _hoveredDevice!.id)
            _buildHoverCard(_hoveredDevice!, isDarkMode),

          // ── 6. SLIDE-IN RIGHT SIDE PANEL (WHEN NODE CLICKED) ──────────────
          if (_selectedDevice != null)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: _buildDeviceInspectorPanel(_selectedDevice!, isDarkMode),
            ),
        ],
      ),
    );
  }

  Widget _buildMiniSwatchStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      width: 125,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF0F1410), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.barlow(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0A0A0E),
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, size: 14, color: const Color(0xFF0A0A0E)),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF050A07),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutBtn(String label, GraphLayoutMode mode, IconData icon, [bool isDarkMode = true]) {
    final bool isSelected = _layoutMode == mode;
    final Color activeColor = isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416);
    return GestureDetector(
      onTap: () {
        setState(() {
          _layoutMode = mode;
          _calculateNodePositions();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(isDarkMode ? 0.20 : 0.15)
              : (isDarkMode ? Colors.transparent : const Color(0xFFFAF9F6)),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: isSelected ? activeColor : (isDarkMode ? Colors.white24 : const Color(0xFFCDD4B2)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: isSelected ? activeColor : (isDarkMode ? Colors.white70 : const Color(0xFF475569))),
            const SizedBox(width: 5),
            Text(
              label,
              style: CyberTextStyles.technical(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? activeColor : (isDarkMode ? Colors.white70 : const Color(0xFF475569)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBtn(String label, GraphFilter filter, {Color? color, bool isDarkMode = true}) {
    final bool isSelected = _filterMode == filter;
    final Color activeColor = color ?? (isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416));

    return GestureDetector(
      onTap: () => setState(() => _filterMode = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(isDarkMode ? 0.20 : 0.15)
              : (isDarkMode ? Colors.transparent : const Color(0xFFFAF9F6)),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: isSelected ? activeColor : (isDarkMode ? Colors.white24 : const Color(0xFFCDD4B2)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: CyberTextStyles.technical(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected ? activeColor : (isDarkMode ? Colors.white70 : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label, IconData icon, [bool isDarkMode = true]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: CyberTextStyles.technical(
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoverCard(IoTDevice device, bool isDarkMode) {
    final bool isCritical = _isCritical(device);
    final Color color = isCritical ? const Color(0xFFDF2531) : (isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416));

    return Positioned(
      left: (_hoverPos.dx + 16).clamp(16.0, 900.0),
      top: (_hoverPos.dy + 16).clamp(16.0, 600.0),
      child: IgnorePointer(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAF9F6),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isDarkMode ? color : const Color(0xFFCDD4B2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? color.withOpacity(0.35) : Colors.black.withOpacity(0.08),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      device.name.toUpperCase(),
                      style: CyberTextStyles.technical(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w900,
                        color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                'TYPE: ${device.deviceType.toUpperCase()} · ${device.protocol}',
                style: CyberTextStyles.technical(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white70 : const Color(0xFF64748B),
                ),
              ),
              Divider(color: isDarkMode ? Colors.white24 : const Color(0xFFCDD4B2), height: 16),
              _hoverDetailLine('IP ADDRESS', device.ipAddress, isDarkMode: isDarkMode),
              _hoverDetailLine('RISK SCORE', '${(device.riskScore * 100).toInt()}%', isDarkMode: isDarkMode, valColor: color),
              _hoverDetailLine('CONNECTIONS', '${device.connections.length} ACTIVE LINKS', isDarkMode: isDarkMode),
              _hoverDetailLine('BANDWIDTH', '${device.bandwidth.toStringAsFixed(1)} KB/S', isDarkMode: isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hoverDetailLine(String k, String v, {required bool isDarkMode, Color? valColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: CyberTextStyles.technical(fontSize: 11.0, color: isDarkMode ? Colors.white60 : const Color(0xFF64748B))),
          Text(v, style: CyberTextStyles.technical(fontSize: 12.0, fontWeight: FontWeight.bold, color: valColor ?? (isDarkMode ? Colors.white : const Color(0xFF0F172A)))),
        ],
      ),
    );
  }

  Widget _buildDeviceInspectorPanel(IoTDevice device, bool isDarkMode) {
    final securityState = ref.watch(securityProvider);
    final bool isCritical = _isCritical(device);
    final bool isWarning = _isWarning(device);
    final bool isIsolated = device.status == DeviceStatus.isolated;

    final Color statusColor = isIsolated
        ? const Color(0xFFA88AED)
        : (isCritical
            ? const Color(0xFFDF2531)
            : (isWarning ? const Color(0xFFFF9F43) : (isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416))));

    final String statusLabel = isIsolated
        ? 'QUARANTINED / ISOLATED'
        : (isCritical ? 'CRITICAL COMPROMISE' : (isWarning ? 'ELEVATED RISK' : 'SECURED & NOMINAL'));

    final relatedAlerts = securityState.anomalies.where((a) => a.deviceId == device.id).toList();
    final relatedPolicies = securityState.policies.where((p) => p.deviceId == device.id).toList();

    return Container(
      width: 380,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0A0A0E) : const Color(0xFFFAF9F6),
        border: Border(
          left: BorderSide(
            color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFFCDD4B2),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.8) : Colors.black.withOpacity(0.12),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF141414) : const Color(0xFFFAF9F6),
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode ? statusColor.withOpacity(0.4) : const Color(0xFFCDD4B2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _isGateway(device)
                          ? Icons.router_outlined
                          : (_isHighValue(device) ? Icons.dns_outlined : Icons.devices_other),
                      color: statusColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name.toUpperCase(),
                          style: CyberTextStyles.displayTitle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'ID: ${device.id}',
                          style: CyberTextStyles.technical(
                            fontSize: 10,
                            color: isDarkMode ? Colors.white54 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: isDarkMode ? Colors.white70 : const Color(0xFF0F172A), size: 18),
                  onPressed: () => setState(() => _selectedDevice = null),
                ),
              ],
            ),
          ),

          // Scrollable Body Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(isDarkMode ? 0.12 : 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: statusColor, width: 1.2),
                    ),
                    child: Center(
                      child: Text(
                        statusLabel,
                        style: CyberTextStyles.technical(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 1. RISK SCORE GAUGE
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF141414) : const Color(0xFFFAF9F6),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: isDarkMode ? Colors.white12 : const Color(0xFFCDD4B2)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 76,
                          height: 76,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: device.riskScore,
                                strokeWidth: 7,
                                backgroundColor: isDarkMode ? Colors.white12 : const Color(0xFFE2E8F0),
                                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${(device.riskScore * 100).toInt()}%',
                                    style: CyberTextStyles.technical(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: statusColor,
                                    ),
                                  ),
                                  Text(
                                    'RISK',
                                    style: CyberTextStyles.technical(
                                      fontSize: 8.5,
                                      color: isDarkMode ? Colors.white38 : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GNN EMBEDDING SCORE',
                                style: CyberTextStyles.technical(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isDarkMode ? Colors.white70 : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isCritical
                                    ? 'Lateral attack propagation detected across neighbor nodes in cluster.'
                                    : 'Behavior matches baseline Zero-Trust profile.',
                                style: CyberTextStyles.technical(
                                  fontSize: 10,
                                  color: isDarkMode ? Colors.white54 : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. DEVICE SPECIFICATIONS
                  Text(
                    'TELEMETRY ATTRIBUTES',
                    style: CyberTextStyles.technical(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF141414) : const Color(0xFFFAF9F6),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: isDarkMode ? Colors.white12 : const Color(0xFFCDD4B2)),
                    ),
                    child: Column(
                      children: [
                        _specRow('TYPE', device.deviceType.toUpperCase(), isDarkMode: isDarkMode),
                        _specRow('PROTOCOL', device.protocol, isDarkMode: isDarkMode),
                        _specRow('IP ADDRESS', device.ipAddress, isDarkMode: isDarkMode),
                        _specRow('MAC ADDRESS', device.macAddress, isDarkMode: isDarkMode),
                        _specRow('BANDWIDTH', '${device.bandwidth.toStringAsFixed(1)} KB/S', isDarkMode: isDarkMode),
                        _specRow('CPU LOAD', '${device.cpuUsage.toStringAsFixed(1)}%', isDarkMode: isDarkMode),
                        _specRow('RAM USAGE', '${device.memoryUsage.toStringAsFixed(1)}%', isDarkMode: isDarkMode),
                        _specRow('MESH CONNECTIONS', '${device.connections.length} ACTIVE PATHS', isDarkMode: isDarkMode),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. RECENT INCIDENTS
                  Text(
                    'ASSOCIATED INCIDENTS (${relatedAlerts.length})',
                    style: CyberTextStyles.technical(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFDF2531),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (relatedAlerts.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF141414) : const Color(0xFFFAF9F6),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: isDarkMode ? Colors.white10 : const Color(0xFFCDD4B2)),
                      ),
                      child: Center(
                        child: Text(
                          'NO ACTIVE INCIDENTS FLAGGED ON THIS ASSET',
                          style: CyberTextStyles.technical(
                            fontSize: 9.5,
                            color: isDarkMode ? Colors.white38 : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: relatedAlerts.take(2).map((a) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF141414) : const Color(0xFFFAF9F6),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFDF2531).withOpacity(0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    a.attackType.toUpperCase(),
                                    style: CyberTextStyles.technical(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFDF2531),
                                    ),
                                  ),
                                  Text(
                                    '${(a.confidenceScore * 100).toInt()}% CONF',
                                    style: CyberTextStyles.technical(
                                      fontSize: 9.5,
                                      color: const Color(0xFFFF9F43),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                a.details,
                                style: CyberTextStyles.technical(
                                  fontSize: 9,
                                  color: isDarkMode ? Colors.white60 : const Color(0xFF475569),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),

                  // 4. RELATED POLICIES
                  Text(
                    'GOVERNING OPA REGO POLICIES (${relatedPolicies.length})',
                    style: CyberTextStyles.technical(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFA88AED),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (relatedPolicies.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF141414) : const Color(0xFFFAF9F6),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: isDarkMode ? Colors.white10 : const Color(0xFFCDD4B2)),
                      ),
                      child: Center(
                        child: Text(
                          'DEFAULT ZERO-TRUST BASELINE RULES ENFORCED',
                          style: CyberTextStyles.technical(
                            fontSize: 9.5,
                            color: isDarkMode ? Colors.white38 : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: relatedPolicies.take(2).map((p) {
                        final bool isDeployed = p.status == PolicyStatus.deployed;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF141414) : const Color(0xFFFAF9F6),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isDeployed
                                  ? (isDarkMode ? const Color(0xFF5DD62C).withOpacity(0.4) : const Color(0xFF80A416))
                                  : const Color(0xFFFF9F43).withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.id,
                                    style: CyberTextStyles.technical(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    isDeployed ? 'ACTIVE IN ENVOY SIDECAR' : 'PENDING REVIEW',
                                    style: CyberTextStyles.technical(
                                      fontSize: 9,
                                      color: isDeployed ? (isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416)) : const Color(0xFFFF9F43),
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                isDeployed ? Icons.verified : Icons.hourglass_top,
                                size: 16,
                                color: isDeployed ? (isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416)) : const Color(0xFFFF9F43),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 20),

                  // 5. QUICK ACTION BUTTONS
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isIsolated ? const Color(0xFF00875A) : const Color(0xFFDF2531),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        icon: Icon(isIsolated ? Icons.lock_open : Icons.lock_outline, size: 16, color: Colors.white),
                        label: Text(
                          isIsolated ? 'RE-ESTABLISH CONNECTION' : 'ISOLATE DEVICE (ZERO-TRUST)',
                          style: CyberTextStyles.technical(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        onPressed: () {
                          ref.read(securityProvider.notifier).toggleDeviceIsolation(device.id);
                        },
                      ),
                      const SizedBox(height: 8),

                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        icon: Icon(Icons.stream, size: 16, color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416)),
                        label: Text(
                          'VIEW LIVE TELEMETRY TRAFFIC',
                          style: CyberTextStyles.technical(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? const Color(0xFF5DD62C) : const Color(0xFF80A416),
                          ),
                        ),
                        onPressed: () {
                          ref.read(navigationNotifierProvider.notifier).selectTab(1);
                        },
                      ),
                      const SizedBox(height: 8),

                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFA88AED)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        icon: const Icon(Icons.auto_awesome, size: 16, color: Color(0xFFA88AED)),
                        label: Text(
                          'GENERATE OPA REGO POLICY',
                          style: CyberTextStyles.technical(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFA88AED)),
                        ),
                        onPressed: () {
                          ref.read(navigationNotifierProvider.notifier).selectTab(4);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _specRow(String k, String v, {required bool isDarkMode}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: CyberTextStyles.technical(fontSize: 9.5, color: isDarkMode ? Colors.white54 : const Color(0xFF64748B))),
          Text(v, style: CyberTextStyles.technical(fontSize: 10, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF0F172A))),
        ],
      ),
    );
  }
}

class _UniqueGNNGraphPainter extends CustomPainter {
  final List<IoTDevice> devices;
  final Map<String, Offset> nodeCoords;
  final double pulseVal;
  final String? selectedId;
  final String? hoveredId;
  final Offset pan;
  final double zoom;
  final bool isDarkMode;
  final bool Function(IoTDevice) isNodeVisible;
  final GraphFilter filterMode;

  _UniqueGNNGraphPainter({
    required this.devices,
    required this.nodeCoords,
    required this.pulseVal,
    this.selectedId,
    this.hoveredId,
    required this.pan,
    required this.zoom,
    required this.isDarkMode,
    required this.isNodeVisible,
    required this.filterMode,
  });

  bool _isGateway(IoTDevice d) {
    final type = d.deviceType.toLowerCase();
    return type.contains('gateway') || type.contains('router') || d.id == 'DEV-001';
  }

  bool _isHighValue(IoTDevice d) {
    final type = d.deviceType.toLowerCase();
    return type.contains('server') ||
        type.contains('database') ||
        type.contains('medical') ||
        type.contains('infusion') ||
        type.contains('scada') ||
        d.id == 'DEV-005' ||
        d.id == 'DEV-010';
  }

  bool _isCritical(IoTDevice d) {
    return d.riskScore >= 0.70 || d.status == DeviceStatus.warning;
  }

  bool _isWarning(IoTDevice d) {
    return d.riskScore >= 0.35 && d.riskScore < 0.70 && d.status != DeviceStatus.warning;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 75.0);

    // 1. SUBTLE CYBER GRID BACKGROUND
    final gridPaint = Paint()
      ..color = const Color(0xFF5DD62C).withOpacity(0.04)
      ..strokeWidth = 1.0;
    const double gridSize = 40.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. DRAW CONNECTIONS / EDGES
    for (final device in devices) {
      if (!isNodeVisible(device) || !nodeCoords.containsKey(device.id)) continue;
      final Offset srcPos = center + pan + (nodeCoords[device.id]! * zoom);

      for (final connId in device.connections) {
        if (!nodeCoords.containsKey(connId)) continue;
        if (device.id.hashCode > connId.hashCode) continue;

        final target = devices.firstWhere((d) => d.id == connId, orElse: () => device);
        if (!isNodeVisible(target)) continue;

        final Offset destPos = center + pan + (nodeCoords[connId]! * zoom);

        final bool isLateralPath = (_isCritical(device) && _isCritical(target)) ||
            (_isCritical(device) && _isWarning(target)) ||
            (_isWarning(device) && _isCritical(target));

        if (filterMode == GraphFilter.lateralOnly && !isLateralPath) {
          continue;
        }

        if (isLateralPath) {
          _drawDashedLateralPath(canvas, srcPos, destPos);
        } else {
          final bool isHighBw = device.bandwidth > 300 || target.bandwidth > 300 || _isGateway(device) || _isGateway(target);
          final Color edgeColor = isHighBw ? const Color(0xFF00F5FF) : const Color(0xFF5DD62C);

          canvas.drawLine(
            srcPos,
            destPos,
            Paint()
              ..color = edgeColor.withOpacity(isHighBw ? 0.35 : 0.18)
              ..strokeWidth = (isHighBw ? 2.0 : 1.0) * zoom,
          );

          final double t = (pulseVal + (device.id.hashCode % 10) / 10.0) % 1.0;
          final Offset packetPos = Offset.lerp(srcPos, destPos, t)!;
          canvas.drawCircle(
            packetPos,
            (isHighBw ? 3.0 : 2.0) * zoom,
            Paint()..color = edgeColor.withOpacity(0.85),
          );
        }
      }
    }

    // 3. DRAW DIFFERENTIATED NODES
    for (final device in devices) {
      if (!isNodeVisible(device) || !nodeCoords.containsKey(device.id)) continue;
      final Offset nodePos = center + pan + (nodeCoords[device.id]! * zoom);

      final bool isSelected = device.id == selectedId;
      final bool isHovered = device.id == hoveredId;

      final bool isGw = _isGateway(device);
      final bool isHv = _isHighValue(device);
      final bool isCrit = _isCritical(device);
      final bool isWarn = _isWarning(device);
      final bool isIso = device.status == DeviceStatus.isolated;

      if (isSelected || isHovered) {
        _drawSelectionBrackets(canvas, nodePos, (isGw ? 28.0 : 20.0) * zoom);
      }

      if (isIso) {
        _drawIsolatedNode(canvas, nodePos, device);
      } else if (isGw) {
        _drawGatewayHexagon(canvas, nodePos, device, isSelected || isHovered);
      } else if (isHv) {
        _drawHighValueDiamond(canvas, nodePos, device, isSelected || isHovered);
      } else if (isCrit) {
        _drawCriticalPulsingNode(canvas, nodePos, device);
      } else if (isWarn) {
        _drawWarningNode(canvas, nodePos, device);
      } else {
        _drawSafeNode(canvas, nodePos, device);
      }

      _drawNodeLabel(canvas, nodePos, device, isGw ? 26.0 * zoom : 18.0 * zoom);
    }
  }

  void _drawDashedLateralPath(Canvas canvas, Offset p1, Offset p2) {
    final double dist = (p2 - p1).distance;
    if (dist <= 0) return;

    final Offset dir = (p2 - p1) / dist;
    final double dashLen = 8.0 * zoom;
    final double gapLen = 5.0 * zoom;
    final double offset = (pulseVal * (dashLen + gapLen) * 2) % (dashLen + gapLen);

    final Paint glowPaint = Paint()
      ..color = const Color(0xFFDF2531).withOpacity(0.35)
      ..strokeWidth = 3.5 * zoom;

    final Paint dashPaint = Paint()
      ..color = const Color(0xFFFF5722)
      ..strokeWidth = 2.0 * zoom;

    double current = -offset;
    while (current < dist) {
      final double startD = max(0.0, current);
      final double endD = min(dist, current + dashLen);
      if (endD > startD) {
        final startPos = p1 + dir * startD;
        final endPos = p1 + dir * endD;
        canvas.drawLine(startPos, endPos, glowPaint);
        canvas.drawLine(startPos, endPos, dashPaint);
      }
      current += dashLen + gapLen;
    }
  }

  void _drawGatewayHexagon(Canvas canvas, Offset pos, IoTDevice d, bool isFocused) {
    final double r = (isFocused ? 24.0 : 20.0) * zoom;
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final double angle = (i * pi) / 3.0;
      final pt = Offset(pos.dx + r * cos(angle), pos.dy + r * sin(angle));
      if (i == 0) path.moveTo(pt.dx, pt.dy);
      else path.lineTo(pt.dx, pt.dy);
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF031625)
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF00F5FF)
        ..strokeWidth = 2.2 * zoom
        ..style = PaintingStyle.stroke,
    );

    _paintIconGlyph(canvas, pos, Icons.router_outlined, const Color(0xFF00F5FF), 15 * zoom);
  }

  void _drawHighValueDiamond(Canvas canvas, Offset pos, IoTDevice d, bool isFocused) {
    final double r = (isFocused ? 21.0 : 17.0) * zoom;
    final path = Path()
      ..moveTo(pos.dx, pos.dy - r)
      ..lineTo(pos.dx + r, pos.dy)
      ..lineTo(pos.dx, pos.dy + r)
      ..lineTo(pos.dx - r, pos.dy)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF140726)
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF9D8DF1)
        ..strokeWidth = 2.0 * zoom
        ..style = PaintingStyle.stroke,
    );

    final icon = d.deviceType.toLowerCase().contains('medical') ? Icons.local_hospital : Icons.dns_outlined;
    _paintIconGlyph(canvas, pos, icon, const Color(0xFF9D8DF1), 14 * zoom);
  }

  void _drawCriticalPulsingNode(Canvas canvas, Offset pos, IoTDevice d) {
    final double r = 16.0 * zoom;

    final double waveRadius = r + (pulseVal * 16.0 * zoom);
    final double waveOpacity = max(0.0, 0.45 * (1.0 - pulseVal));
    canvas.drawCircle(
      pos,
      waveRadius,
      Paint()
        ..color = const Color(0xFFDF2531).withOpacity(waveOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * zoom,
    );

    canvas.drawCircle(
      pos,
      r,
      Paint()..color = const Color(0xFF810100),
    );

    canvas.drawCircle(
      pos,
      r,
      Paint()
        ..color = const Color(0xFFDF2531)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2 * zoom,
    );

    _paintIconGlyph(canvas, pos, Icons.warning_amber_rounded, const Color(0xFFFFEA00), 14 * zoom);
  }

  void _drawWarningNode(Canvas canvas, Offset pos, IoTDevice d) {
    final double r = 15.0 * zoom;

    final double dashAngle = pi / 4.0;
    final ringPaint = Paint()
      ..color = const Color(0xFFFF9F43)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * zoom;

    for (int i = 0; i < 8; i += 2) {
      canvas.drawArc(
        Rect.fromCircle(center: pos, radius: r + 3.5 * zoom),
        i * dashAngle + (pulseVal * pi),
        dashAngle * 0.75,
        false,
        ringPaint,
      );
    }

    canvas.drawCircle(
      pos,
      r,
      Paint()..color = const Color(0xFF241505),
    );

    canvas.drawCircle(
      pos,
      r,
      Paint()
        ..color = const Color(0xFFFF9F43)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2 * zoom,
    );

    _paintIconGlyph(canvas, pos, Icons.priority_high, const Color(0xFFFF9F43), 13 * zoom);
  }

  void _drawSafeNode(Canvas canvas, Offset pos, IoTDevice d) {
    final double r = 14.0 * zoom;

    canvas.drawCircle(
      pos,
      r + 3.0 * zoom,
      Paint()..color = const Color(0xFF5DD62C).withOpacity(0.12),
    );

    canvas.drawCircle(
      pos,
      r,
      Paint()..color = const Color(0xFF071B0B),
    );

    canvas.drawCircle(
      pos,
      r,
      Paint()
        ..color = const Color(0xFF5DD62C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * zoom,
    );

    _paintIconGlyph(canvas, pos, Icons.check, const Color(0xFF5DD62C), 13 * zoom);
  }

  void _drawIsolatedNode(Canvas canvas, Offset pos, IoTDevice d) {
    final double r = 15.0 * zoom;

    canvas.drawCircle(
      pos,
      r,
      Paint()..color = const Color(0xFF1B0A26),
    );

    canvas.drawCircle(
      pos,
      r,
      Paint()
        ..color = const Color(0xFFA88AED)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8 * zoom,
    );

    _paintIconGlyph(canvas, pos, Icons.lock_outline, const Color(0xFFA88AED), 13 * zoom);
  }

  void _paintIconGlyph(Canvas canvas, Offset pos, IconData icon, Color color, double size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          inherit: false,
          fontSize: size,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
    );
  }

  void _drawNodeLabel(Canvas canvas, Offset pos, IoTDevice d, double offset) {
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final painter = TextPainter(
      text: TextSpan(
        text: d.name.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 9.5 * zoom,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
          shadows: isDarkMode
              ? const [
                  Shadow(color: Colors.black, blurRadius: 4),
                ]
              : null,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final Offset labelPos = Offset(pos.dx - painter.width / 2, pos.dy + offset + 4.0);

    // In light mode, draw a pill background behind each node label for clear contrast and readability
    if (!isDarkMode) {
      final RRect bgPill = RRect.fromRectAndRadius(
        Rect.fromLTWH(labelPos.dx - 5, labelPos.dy - 2, painter.width + 10, painter.height + 4),
        const Radius.circular(3),
      );
      canvas.drawRRect(
        bgPill,
        Paint()..color = const Color(0xFFFAF9F6).withOpacity(0.95),
      );
      canvas.drawRRect(
        bgPill,
        Paint()
          ..color = const Color(0xFFCDD4B2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }

    painter.paint(canvas, labelPos);
  }

  void _drawSelectionBrackets(Canvas canvas, Offset pos, double r) {
    final paint = Paint()
      ..color = const Color(0xFF5DD62C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * zoom;

    final double d = r + 6.0 * zoom;
    final double len = 6.0 * zoom;

    canvas.drawPath(
      Path()
        ..moveTo(pos.dx - d, pos.dy - d + len)
        ..lineTo(pos.dx - d, pos.dy - d)
        ..lineTo(pos.dx - d + len, pos.dy - d),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(pos.dx + d - len, pos.dy - d)
        ..lineTo(pos.dx + d, pos.dy - d)
        ..lineTo(pos.dx + d, pos.dy - d + len),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(pos.dx - d, pos.dy + d - len)
        ..lineTo(pos.dx - d, pos.dy + d)
        ..lineTo(pos.dx - d + len, pos.dy + d),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(pos.dx + d - len, pos.dy + d)
        ..lineTo(pos.dx + d, pos.dy + d)
        ..lineTo(pos.dx + d, pos.dy + d - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _UniqueGNNGraphPainter oldDelegate) {
    return true;
  }
}
