import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/policy.dart';
import '../providers/security_provider.dart';
import '../theme/colors.dart';
import '../theme/responsive.dart';
import '../theme/text_styles.dart';
import '../widgets/glass_container.dart';
import '../widgets/neon_button.dart';

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

  // Synchronizes editor input when another rule index is selected
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

    // Default select first policy in list
    if (_selectedPolicy == null && pendingPolicies.isNotEmpty) {
      _selectedPolicy = pendingPolicies.first;
    }

    if (_selectedPolicy != null) {
      // Keep selectedPolicy state active during dynamic updates
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
            // Screen Title
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TRANSFORMER POLICY WORKSTATION', style: CyberTextStyles.heading2),
                const SizedBox(height: 4),
                Text('AI REGO JSON CODE COMPILER & INTER-AGENT DEPLOYER', style: CyberTextStyles.techMuted),
              ],
            ),
            const SizedBox(height: 16),

            // Workstation container split panel
            Expanded(
              child: pendingPolicies.isEmpty
                  ? GlassContainer(
                      borderColor: CyberColors.neonGreen,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.verified, color: CyberColors.neonGreen, size: 48),
                            const SizedBox(height: 16),
                            Text('ALL TELEMETRIES CLEAR. NO POLICIES PENDING DEPLOYMENT.', style: CyberTextStyles.technical(color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      ),
                    )
                  : ResponsiveLayout(
                      mobile: _buildMobileList(pendingPolicies),
                      desktop: Row(
                        children: [
                          // Left sidebar: list of pending policy rule blocks
                          Expanded(
                            flex: 2,
                            child: _buildPendingPoliciesSidebar(pendingPolicies),
                          ),
                          const SizedBox(width: 16),

                          // Middle: Incident Description Card
                          Expanded(
                            flex: 3,
                            child: _selectedPolicy != null
                                ? _buildIncidentAnalysisCard(_selectedPolicy!)
                                : const SizedBox(),
                          ),
                          const SizedBox(width: 16),

                          // Right: Rego Code Editor & Compile triggers
                          Expanded(
                            flex: 4,
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
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GlassContainer(
            showHUDCorners: false,
            padding: EdgeInsets.zero,
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: CyberColors.neonCyan,
                ),
              ),
              child: ExpansionTile(
                iconColor: CyberColors.neonCyan,
                collapsedIconColor: CyberColors.textMuted,
                title: Text(policy.deviceName.toUpperCase(), style: CyberTextStyles.technical()),
                subtitle: Text('ID: ${policy.id}', style: CyberTextStyles.techMuted),
                backgroundColor: Colors.transparent,
                collapsedBackgroundColor: Colors.transparent,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildIncidentAnalysisCard(policy),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildRegoEditorCard(policy),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPendingPoliciesSidebar(List<SecurityPolicy> policies) {
    return GlassContainer(
      borderColor: CyberColors.neonCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PENDING DEPLOYS', style: CyberTextStyles.technical(color: Colors.white, fontSize: 11)),
          const Divider(color: CyberColors.borderNeonCyan),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: policies.length,
              itemBuilder: (context, idx) {
                final policy = policies[idx];
                final bool isSelected = _selectedPolicy?.id == policy.id;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPolicy = policy;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: GlassContainer(
                      showHUDCorners: false,
                      padding: const EdgeInsets.all(10),
                      borderRadius: 4.0,
                      borderColor: isSelected ? CyberColors.neonCyan : CyberColors.textMuted,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            policy.deviceName.toUpperCase(),
                            style: CyberTextStyles.technical(
                              fontSize: 11,
                              color: isSelected ? Colors.white : CyberColors.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ID: ${policy.id}',
                            style: CyberTextStyles.techMuted.copyWith(fontSize: 9),
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
    final bool isDeploying = policy.status == PolicyStatus.approved;

    return GlassContainer(
      borderColor: CyberColors.neonCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('INCIDENT ANALYSIS DIAGNOSTIC', style: CyberTextStyles.technical(color: Colors.white, fontSize: 11)),
          const Divider(color: CyberColors.borderNeonCyan),
          const SizedBox(height: 12),

          Text(
            policy.deviceName.toUpperCase(),
            style: CyberTextStyles.displayTitle(fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(
            'TARGET DEVICE ID: ${policy.deviceId}',
            style: CyberTextStyles.techMuted.copyWith(fontSize: 10),
          ),
          const SizedBox(height: 16),

          _buildDiagItem('CONFIDENCE', '${(policy.confidence * 100).toStringAsFixed(1)}%'),
          _buildDiagItem('AI RATIONALE', policy.explanation),
          _buildDiagItem('SEGMENTATION PROTOCOL', 'Zero-Trust OPA Microsegmentation Rule'),
          _buildDiagItem('PIPELINE TARGET', 'Kubernetes Envoy Gateway Edge Sidecars'),
          
          const Spacer(),
          
          // Action triggers
          if (isDeploying)
            const Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(CyberColors.neonCyan)),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      ref.read(securityProvider.notifier).rejectPolicy(policy.id);
                      setState(() {
                        _selectedPolicy = null;
                      });
                    },
                    child: Text(
                      'REJECT SECURITY RECOMMENDATION',
                      style: CyberTextStyles.technical(color: CyberColors.alertRed, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
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
          Text(header, style: CyberTextStyles.techMuted.copyWith(fontSize: 9.0)),
          const SizedBox(height: 2),
          Text(
            val.toUpperCase(),
            style: CyberTextStyles.interface(fontSize: 11.5, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildRegoEditorCard(SecurityPolicy policy) {
    final bool isDeploying = policy.status == PolicyStatus.approved;

    return GlassContainer(
      borderColor: CyberColors.neonGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('REGO POLICY BUILDER', style: CyberTextStyles.technical(color: Colors.white, fontSize: 11)),
              const Icon(Icons.code, color: CyberColors.neonGreen, size: 14),
            ],
          ),
          const Divider(color: CyberColors.borderNeonGreen),
          const SizedBox(height: 12),

          // Code text editor panel
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white10),
              ),
              child: TextField(
                controller: _codeController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: CyberTextStyles.technical(color: CyberColors.neonGreen, fontSize: 12),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Compile compile action
          if (!isDeploying)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                NeonButton(
                  text: 'Approve & Compile OPA',
                  onPressed: () {
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
