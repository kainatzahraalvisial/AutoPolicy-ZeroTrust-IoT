import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/policy.dart';
import '../providers/navigation_provider.dart';
import '../providers/security_provider.dart';
import '../theme/responsive.dart';
import '../theme/text_styles.dart';

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
                    borderColor: const Color(0xFFFFEDA8), // 1. #FFEDA8 (Pale Cream Yellow)
                    tag: 'H17',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CyberStatCard(
                    title: 'ENFORCED POLICIES',
                    value: '${securityState.policies.where((p) => p.status == PolicyStatus.deployed).length}',
                    sub: 'Active OPA Sidecars',
                    borderColor: const Color(0xFFC4E326), // 2. #C4E326 (Bright Neon Lime-Green)
                    tag: 'H18',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CyberStatCard(
                    title: 'PENDING APPROVAL',
                    value: '${pendingPolicies.length}',
                    sub: 'Awaiting Sign-off',
                    borderColor: const Color(0xFFB1A9DA), // 3. #B1A9DA (Pastel Lavender)
                    tag: 'H19',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CyberStatCard(
                    title: 'SYNTHESIS LATENCY',
                    value: '1.4ms',
                    sub: 'Sub-Millisecond Rego',
                    borderColor: const Color(0xFF80A416), // 4. #80A416 (Olive Green)
                    tag: 'H20',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main Equal-Height Workstation Split Panel
            Expanded(
              child: pendingPolicies.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F0F),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF5DD62C).withOpacity(0.3)),
                      ),
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
                      desktop: Column(
                        children: [
                          // 3 Equal-Height Columns
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Left Panel: Pending Deploys List (flex 3)
                                Expanded(
                                  flex: 3,
                                  child: _buildPendingPoliciesSidebar(pendingPolicies),
                                ),
                                const SizedBox(width: 14),

                                // Middle Panel: Incident Analysis Diagnostic (flex 4)
                                Expanded(
                                  flex: 4,
                                  child: _selectedPolicy != null
                                      ? _buildIncidentAnalysisCard(_selectedPolicy!)
                                      : const SizedBox(),
                                ),
                                const SizedBox(width: 14),

                                // Right Panel: Rego Policy Builder Code Workstation (flex 5)
                                Expanded(
                                  flex: 5,
                                  child: _selectedPolicy != null
                                      ? _buildRegoEditorCard(_selectedPolicy!)
                                      : const SizedBox(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Unified Sticky Footer Action Bar Across Workstation
                          if (_selectedPolicy != null)
                            _buildUnifiedWorkstationFooter(_selectedPolicy!),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF5DD62C).withOpacity(0.40),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.pending_actions, size: 15, color: Color(0xFF5DD62C)),
                  const SizedBox(width: 6),
                  Text(
                    'PENDING APPROVALS',
                    style: CyberTextStyles.technical(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF5DD62C),
                    ).copyWith(letterSpacing: 1.1),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF5DD62C).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: const Color(0xFF5DD62C), width: 1.0),
                ),
                child: Text(
                  '${policies.length} READY',
                  style: CyberTextStyles.technical(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF5DD62C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: const Color(0xFF5DD62C).withOpacity(0.35), height: 1),
          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: policies.length,
              itemBuilder: (context, idx) {
                final policy = policies[idx];
                final bool isSelected = _selectedPolicy?.id == policy.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedPolicy = policy;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF142416) : const Color(0xFF141414),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF5DD62C) : Colors.white12,
                          width: isSelected ? 1.5 : 0.8,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  policy.deviceName.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.white : Colors.white70,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFA500).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: const Color(0xFFFFA500), width: 0.6),
                                ),
                                child: Text(
                                  'REVIEW',
                                  style: CyberTextStyles.technical(fontSize: 8.5, color: const Color(0xFFFFA500), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'TARGET ID: ${policy.deviceId}',
                            style: CyberTextStyles.technical(
                              fontSize: 10,
                              color: isSelected ? const Color(0xFF5DD62C) : Colors.white38,
                            ),
                          ),
                        ],
                      ),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFFA88AED).withOpacity(0.40),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.troubleshoot, size: 15, color: Color(0xFFA88AED)),
                  const SizedBox(width: 6),
                  Text(
                    'INCIDENT ANALYSIS DIAGNOSTIC',
                    style: CyberTextStyles.technical(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFA88AED),
                    ).copyWith(letterSpacing: 1.1),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFA88AED).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: const Color(0xFFA88AED), width: 1.0),
                ),
                child: Text(
                  'GNN TRIAGE',
                  style: CyberTextStyles.technical(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFA88AED),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: const Color(0xFFA88AED).withOpacity(0.35), height: 1),
          const SizedBox(height: 12),

          Text(
            policy.deviceName.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Color(0xFFA88AED),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'TARGET DEVICE ID: ${policy.deviceId}',
            style: CyberTextStyles.technical(
              fontSize: 10.5,
              color: const Color(0xFFFFE997),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDiagItem('CONFIDENCE LEVEL', '${(policy.confidence * 100).toStringAsFixed(1)}% (Transformer DNN & GraphSAGE)'),
                  _buildDiagItem('AI RATIONALE', policy.explanation),
                  _buildDiagItem('SEGMENTATION PROTOCOL', 'Zero-Trust OPA Microsegmentation Rule'),
                  _buildDiagItem('DEPLOYMENT SCOPE', 'Kubernetes Envoy Gateway Edge Sidecars (Port 8181)'),
                  _buildDiagItem('INGESTED TELEMETRY FLOW', 'Zeek Conformer Feature Vector #4892'),
                  _buildDiagItem('SYNTHESIS LATENCY', '1.4ms (TorchScript JIT Model)'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagItem(String header, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: CyberTextStyles.technical(
              fontSize: 10,
              color: const Color(0xFF5DD62C),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            val.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegoEditorCard(SecurityPolicy policy) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF5DD62C).withOpacity(0.40),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.code, color: Color(0xFF5DD62C), size: 15),
                  const SizedBox(width: 6),
                  Text(
                    'REGO POLICY BUILDER',
                    style: CyberTextStyles.technical(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF5DD62C),
                    ).copyWith(letterSpacing: 1.1),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF5DD62C).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: const Color(0xFF5DD62C), width: 1.0),
                ),
                child: Text(
                  'OPA v0.68',
                  style: CyberTextStyles.technical(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF5DD62C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: const Color(0xFF5DD62C).withOpacity(0.35), height: 1),
          const SizedBox(height: 10),

          // Code text editor panel with dark obsidian terminal styling
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF050608),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF5DD62C).withOpacity(0.30), width: 1.0),
              ),
              child: TextField(
                controller: _codeController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Color(0xFF5DD62C),
                  fontSize: 12.5,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
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
        ],
      ),
    );
  }

  Widget _buildUnifiedWorkstationFooter(SecurityPolicy policy) {
    final bool isDeploying = policy.status == PolicyStatus.approved;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF5DD62C).withOpacity(0.40),
          width: 1.0,
        ),
      ),
      child: isDeploying
          ? Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5DD62C)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'COMPILING REGO BYTECODE & DISPATCHING TO OPA SIDECARS AT PORT 8181...',
                    style: CyberTextStyles.technical(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5DD62C),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                // Reject Recommendation
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(securityProvider.notifier).rejectPolicy(policy.id);
                    setState(() {
                      _selectedPolicy = null;
                    });
                  },
                  icon: const Icon(Icons.close, size: 14, color: Color(0xFFDF2531)),
                  label: Text(
                    'REJECT RECOMMENDATION',
                    style: CyberTextStyles.technical(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFDF2531),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFDF2531), width: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const Spacer(),

                // Active Target Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF5DD62C).withOpacity(0.40)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.terminal, size: 15, color: Color(0xFF5DD62C)),
                      const SizedBox(width: 8),
                      Text(
                        'ENVOY SIDECAR : PORT 8181 · OPA REGO V0.68',
                        style: CyberTextStyles.technical(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Test in Simulation Button
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(navigationNotifierProvider.notifier).selectTab(7);
                  },
                  icon: const Icon(Icons.science_outlined, size: 14, color: Color(0xFFA88AED)),
                  label: Text(
                    'TEST IN SIMULATION',
                    style: CyberTextStyles.technical(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFA88AED),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFA88AED), width: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 10),

                // Approve & Deploy to OPA Button
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(securityProvider.notifier).deployPolicy(policy.id, _codeController.text);
                  },
                  icon: const Icon(Icons.rocket_launch, size: 14, color: Colors.black),
                  label: Text(
                    'APPROVE & DEPLOY TO OPA',
                    style: CyberTextStyles.technical(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5DD62C),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ],
            ),
    );
  }
}

