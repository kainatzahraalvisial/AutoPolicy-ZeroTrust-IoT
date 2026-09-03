import 'dart:math';

class OpaLogEntry {
  final DateTime timestamp;
  final String level; // INFO, WARNING, ERROR
  final String message;

  const OpaLogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
  });
}

class OpaService {
  final Random _random = Random();

  // Simulates OPA deployment and generates detailed execution logs
  Future<List<OpaLogEntry>> deployPolicyToOpa(String policyId, String rawJsonPolicy) async {
    await Future.delayed(const Duration(milliseconds: 1400)); // Simulate bundle upload & compilation latency

    final List<OpaLogEntry> logs = [
      OpaLogEntry(
        timestamp: DateTime.now().subtract(const Duration(milliseconds: 1200)),
        level: 'INFO',
        message: 'OPA Agent: Initiating policy bundle import for policy ID: $policyId',
      ),
      OpaLogEntry(
        timestamp: DateTime.now().subtract(const Duration(milliseconds: 1000)),
        level: 'INFO',
        message: 'Rego Compiler: Parsing AST structure...',
      ),
    ];

    if (_random.nextDouble() > 0.05) {
      logs.addAll([
        OpaLogEntry(
          timestamp: DateTime.now().subtract(const Duration(milliseconds: 700)),
          level: 'INFO',
          message: 'Rego Compiler: AST parsed successfully. 0 errors, 0 warnings.',
        ),
        OpaLogEntry(
          timestamp: DateTime.now().subtract(const Duration(milliseconds: 500)),
          level: 'INFO',
          message: 'OPA Storage: Policy rules updated. Syncing rules bundle with OPA sidecar agents...',
        ),
        OpaLogEntry(
          timestamp: DateTime.now().subtract(const Duration(milliseconds: 200)),
          level: 'INFO',
          message: 'OPA Engine: Rules bundle synced. Deployed successfully on 12 gateway edge clusters.',
        ),
      ]);
    } else {
      // Simulate rare compile failure for added high-fidelity SOC realism
      logs.addAll([
        OpaLogEntry(
          timestamp: DateTime.now().subtract(const Duration(milliseconds: 800)),
          level: 'ERROR',
          message: 'Rego Compiler: Syntax error at line 14: unexpected Token near `allow`',
        ),
        OpaLogEntry(
          timestamp: DateTime.now().subtract(const Duration(milliseconds: 400)),
          level: 'ERROR',
          message: 'OPA Engine: Bundle compilation failed. Rolling back edge nodes to baseline policy v1.2.4',
        ),
      ]);
      throw Exception('Rego Compilation Failure: unexpected Token near `allow`');
    }

    return logs;
  }
}
