import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/policy.dart';
import '../providers/security_provider.dart';
import '../theme/colors.dart';
import '../theme/responsive.dart';
import '../theme/text_styles.dart';
import '../widgets/glass_container.dart';
import '../widgets/chamfered_cyber_button.dart';
import '../widgets/cyber_stat_card.dart';
import '../widgets/cyber_hud_card.dart';

class PolicyGenerator extends ConsumerStatefulWidget {
  const PolicyGenerator({super.key});

  @override
  ConsumerState<PolicyGenerator> createState() => _PolicyGeneratorState();
}

class _PolicyGeneratorState extends ConsumerState<PolicyGenerator> {
  SecurityPolicy? _selectedPolicy;
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _syncCodeEditor(SecurityPolicy policy) {
    if (_codeController.text != policy.rawJsonPolicy) {
      _codeController.text = policy.rawJsonPolicy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final securityState = ref.watch(securityProvider);
    final pendingPolicies = securityState.policies
        .where((p) => p.status == PolicyStatus.pending || p.status == PolicyStatus.approved)
        .toList();

    if (_selectedPolicy == null && pendingPolicies.isNotEmpty) {
      _selectedPolicy = pendingPolicies.first;
    }

    if (_selectedPolicy != null) {
      _selectedPolicy = securityState.policies.firstWhere(
        (p) => p.id == _selectedPolicy!.id,
        orElse: () => _selectedPolicy!,
      );
      _syncCodeEditor(_selectedPolicy!);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Title Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRANSFORMER POLICY WORKSTATION',
                  style: CyberTextStyles.heading2.copyWith(color: const Color(0xFF5DD62C)),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI REGO JSON CODE COMPILER & INTER-AGENT DEPLOYER',
                  style: CyberTextStyles.techMuted,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Top Stat Cards Row
            Row(
              children: [
                Expanded(
                  child: CyberStatCard(
                    title: 'TOTAL REGO RULES',
                    value: '${securityState.policies.length}',
                    sub: 'Synthesized Rules',
                    borderColor: const Color(0xFFFFE997), // 1. Yellow (#FFE997)
                    tag: 'H17',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CyberStatCard(
                    title: 'ENFORCED POLICIES',
                    value: '${securityState.policies.where((p) => p.status == PolicyStatus.deployed).length}',
                    sub: 'Active OPA Sidecars',
                    borderColor: const Color(0xFFA88AED), // 2. Indigo Purple (#A88AED)
                    tag: 'H18',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CyberStatCard(
                    title: 'PENDING APPROVAL',
                    value: '${pendingPolicies.length}',
                    sub: 'Awaiting Sign-off',
                    borderColor: const Color(0xFFC4E320), // 3. Bright Light Green (#C4E320)
                    tag: 'H19',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CyberStatCard(
                    title: 'SYNTHESIS LATENCY',
                    value: '1.4ms',
                    sub: 'Sub-Millisecond Rego',
                    borderColor: const Color(0xFF80A416), // 4. Olive Green (#80A416)
                    tag: 'H20',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main Workstation Split Panel
            Expanded(
              child: pendingPolicies.isEmpty
                  ? GlassContainer(
                      borderColor: const Color(0xFF5DD62C),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.verified, color: Color(0xFF5DD62C), size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'ALL TELEMETRIES CLEAR. NO POLICIES PENDING DEPLOYMENT.',
                              style: CyberTextStyles.technical(color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ResponsiveLayout(
                      mobile: _buildMobileList(pendingPolicies),
                      desktop: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Panel: Pending Deploys List
                          Expanded(
                            flex: 3,
                            child: _buildPendingPoliciesSidebar(pendingPolicies),
                          ),
                          const SizedBox(width: 14),

                          // Middle Panel: Incident Analysis Diagnostic
                          Expanded(
                            flex: 4,
                            child: _selectedPolicy != null
                                ? _buildIncidentAnalysisCard(_selectedPolicy!)
                                : const SizedBox(),
                          ),
                          const SizedBox(width: 14),

                          // Right Panel: Rego Policy Builder Code Workstation
                          Expanded(
                            flex: 5,
                            child: _selectedPolicy != null
                                ? _buildRegoEditorCard(_selectedPolicy!)
                                : const SizedBox(),
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

  Widget _buildMobileList(List<SecurityPolicy> policies) {
    return ListView.builder(
      itemCount: policies.length,
      itemBuilder: (context, idx) {
        final policy = policies[idx];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: CyberHudCard(
            tag: 'POL-${idx + 1}',
            borderColor: const Color(0xFF5DD62C),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(policy.deviceName.toUpperCase(), style: CyberTextStyles.technical(fontSize: 13, color: Colors.white)),
                Text('ID: ${policy.id}', style: CyberTextStyles.techMuted.copyWith(fontSize: 10)),
                const SizedBox(height: 12),
                _buildIncidentAnalysisCard(policy),
                const SizedBox(height: 12),
                _buildRegoEditorCard(policy),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPendingPoliciesSidebar(List<SecurityPolicy> policies) {
    return GlassContainer(
      borderColor: const Color(0xFF5DD62C),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'PENDING DEPLOYS',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5DD62C),
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'H17',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 9,
                  color: Color(0xFF80A416),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: const Color(0xFF5DD62C).withOpacity(0.35)),
          const SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              itemCount: policies.length,
              itemBuilder: (context, idx) {
                final policy = policies[idx];
                final bool isSelected = _selectedPolicy?.id == policy.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: CyberHudCard(
                    tag: 'SYS-0${idx + 1}',
                    borderColor: isSelected ? const Color(0xFF5DD62C) : const Color(0xFF3A3D4A),
                    backgroundColor: isSelected ? const Color(0xFF122414) : const Color(0xFF0C0D10),
                    onTap: () {
                      setState(() {
                        _selectedPolicy = policy;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          policy.deviceName.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.grey[400],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${policy.id}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9.5,
                            color: Color(0xFF80A416),
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

  Widget _buildIncidentAnalysisCard(SecurityPolicy policy) {
    final bool isDeploying = policy.status == PolicyStatus.approved;

    return GlassContainer(
      borderColor: const Color(0xFF9D4EDD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'INCIDENT ANALYSIS DIAGNOSTIC',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9D4EDD),
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'H18',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 9,
                  color: Color(0xFF9D4EDD),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: const Color(0xFF9D4EDD).withOpacity(0.35)),
          const SizedBox(height: 14),

          Text(
            policy.deviceName.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF9D4EDD),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'TARGET DEVICE ID: ${policy.deviceId}',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              color: Color(0xFFC5C764),
            ),
          ),
          const SizedBox(height: 16),

          _buildDiagItem('CONFIDENCE LEVEL', '${(policy.confidence * 100).toStringAsFixed(1)}%'),
          _buildDiagItem('AI RATIONALE', policy.explanation),
          _buildDiagItem('SEGMENTATION PROTOCOL', 'Zero-Trust OPA Microsegmentation Rule'),
          _buildDiagItem('PIPELINE TARGET', 'Kubernetes Envoy Gateway Edge Sidecars'),
          
          const Spacer(),
          
          if (isDeploying)
            const Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9D4EDD))),
            )
          else ...[
            Center(
              child: TextButton(
                onPressed: () {
                  ref.read(securityProvider.notifier).rejectPolicy(policy.id);
                  setState(() {
                    _selectedPolicy = null;
                  });
                },
                child: const Text(
                  'REJECT SECURITY RECOMMENDATION',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: Color(0xFFFF3344),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiagItem(String header, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 9.0,
              color: Color(0xFF80A416),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            val.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'sans-serif',
              fontSize: 11.5,
              color: Colors.white,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegoEditorCard(SecurityPolicy policy) {
    final bool isDeploying = policy.status == PolicyStatus.approved;

    return GlassContainer(
      borderColor: const Color(0xFF5DD62C),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  Icon(Icons.code, color: Color(0xFF5DD62C), size: 15),
                  SizedBox(width: 6),
                  Text(
                    'REGO POLICY BUILDER',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5DD62C),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Text(
                'H19',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 9,
                  color: Color(0xFF80A416),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: const Color(0xFF5DD62C).withOpacity(0.35)),
          const SizedBox(height: 12),

          // Code text editor panel with dark obsidian terminal styling
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF050608),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF5DD62C).withOpacity(0.40), width: 1.0),
              ),
              child: TextField(
                controller: _codeController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Color(0xFF5DD62C),
                  fontSize: 12,
                  height: 1.4,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Action Compile Button
          if (!isDeploying)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ChamferedCyberButton(
                  text: 'APPROVE & COMPILE OPA',
                  onTap: () {
                    ref.read(securityProvider.notifier).deployPolicy(policy.id, _codeController.text);
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}
