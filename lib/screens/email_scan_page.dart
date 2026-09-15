import 'package:flutter/material.dart';

class EmailScanPage extends StatefulWidget {
  final String? initialText;

  const EmailScanPage({super.key, this.initialText});

  @override
  State<EmailScanPage> createState() => _EmailScanPageState();
}

class _EmailScanPageState extends State<EmailScanPage> {
  late final TextEditingController _textController;

  bool _isScanning = false;

  String? _result;
  String? _description;
  List<String> _reasons = [];
  int _riskScore = 0;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText ?? '');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _scanEmail() {
    final input = _textController.text.trim();

    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter or paste some email text first.'),
        ),
      );
      return;
    }

    setState(() {
      _isScanning = true;
      _result = null;
      _description = null;
      _reasons = [];
      _riskScore = 0;
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      final analysis = _analyzeEmail(input);

      setState(() {
        _isScanning = false;
        _result = analysis['result'] as String;
        _description = analysis['description'] as String;
        _reasons = List<String>.from(analysis['reasons'] as List);
        _riskScore = analysis['score'] as int;
      });
    });
  }

  Map<String, dynamic> _analyzeEmail(String input) {
    final reasons = <String>[];
    int riskScore = 0;

    final lowerText = input.toLowerCase();

    // Urgency / pressure language.
    final urgencyPhrases = [
      'act now',
      'act immediately',
      'verify immediately',
      'immediate action',
      'account will be suspended',
      'account has been suspended',
      'account will be closed',
      'account will be locked',
      'urgent action required',
      'expires today',
      'expires in 24 hours',
      'limited time',
      'failure to comply',
      'legal action',
      'final notice',
    ];

    final foundUrgency = urgencyPhrases
        .where((phrase) => lowerText.contains(phrase))
        .toList();

    if (foundUrgency.isNotEmpty) {
      riskScore += 25;
      reasons.add(
        'The message uses urgent or pressuring language, a common '
        'phishing tactic to rush you into acting without thinking.',
      );
    }

    // Requests for sensitive information.
    final sensitiveInfoWords = [
      'password',
      'social security',
      'ssn',
      'credit card number',
      'card number',
      'cvv',
      'pin number',
      'one-time password',
      'otp',
      'security code',
      'bank account number',
    ];

    final foundSensitive = sensitiveInfoWords
        .where((word) => lowerText.contains(word))
        .toList();

    if (foundSensitive.isNotEmpty) {
      riskScore += 30;
      reasons.add(
        'The message asks for sensitive personal or financial '
        'information. Legitimate organizations rarely ask for this '
        'over email.',
      );
    }

    // Generic greetings.
    final genericGreetings = [
      'dear customer',
      'dear user',
      'dear valued customer',
      'dear account holder',
      'dear member',
      'dear sir/madam',
    ];

    final foundGreeting = genericGreetings
        .where((greeting) => lowerText.contains(greeting))
        .toList();

    if (foundGreeting.isNotEmpty) {
      riskScore += 10;
      reasons.add(
        'The message uses a generic greeting instead of your name, '
        'which is common in mass phishing emails.',
      );
    }

    // Threats of consequence.
    final threatPhrases = [
      'unauthorized access',
      'unusual activity',
      'suspicious activity',
      'your account has been compromised',
      'we detected',
    ];

    final foundThreats = threatPhrases
        .where((phrase) => lowerText.contains(phrase))
        .toList();

    if (foundThreats.isNotEmpty) {
      riskScore += 15;
      reasons.add(
        'The message claims suspicious account activity, a tactic '
        'often used to provoke fear and prompt quick action.',
      );
    }

    // Find and evaluate any URLs embedded in the text.
    final urlPattern = RegExp(
      r'(https?:\/\/[^\s]+)',
      caseSensitive: false,
    );

    final matches = urlPattern.allMatches(input);
    int suspiciousLinkCount = 0;

    for (final match in matches) {
      final foundUrl = match.group(0)!;

      Uri? uri;
      try {
        uri = Uri.parse(foundUrl);
      } catch (_) {
        continue;
      }

      final host = uri.host.toLowerCase();
      if (host.isEmpty) continue;

      bool thisLinkSuspicious = false;

      if (uri.scheme != 'https') {
        thisLinkSuspicious = true;
      }

      final linkSuspiciousWords = [
        'verify',
        'login',
        'secure',
        'account',
        'confirm',
      ];

      if (linkSuspiciousWords.any((word) => foundUrl.toLowerCase().contains(word))) {
        thisLinkSuspicious = true;
      }

      final ipPattern = RegExp(r'^(?:\d{1,3}\.){3}\d{1,3}$');
      if (ipPattern.hasMatch(host)) {
        thisLinkSuspicious = true;
      }

      if (thisLinkSuspicious) {
        suspiciousLinkCount++;
      }
    }

    if (suspiciousLinkCount > 0) {
      riskScore += 20;
      reasons.add(
        'The message contains $suspiciousLinkCount link(s) with '
        'characteristics commonly seen in phishing attempts.',
      );
    }

    // Keep score between 0 and 100.
    if (riskScore > 100) {
      riskScore = 100;
    }

    String result;
    String description;

    if (riskScore >= 50) {
      result = 'High Risk';
      description = 'This message has several characteristics of a phishing attempt.';
    } else if (riskScore >= 25) {
      result = 'Suspicious';
      description = 'This message contains characteristics that deserve caution.';
    } else {
      result = 'Low Risk';
      description = 'No major suspicious characteristics were detected.';
    }

    if (reasons.isEmpty) {
      reasons.add('No suspicious characteristics were detected.');
    }

    return {
      'result': result,
      'description': description,
      'reasons': reasons,
      'score': riskScore,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan an Email',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            const Text(
              'Check a suspicious email',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Paste the email text below, or share it directly to '
              'PhishGuard from your email app.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: _textController,
              maxLines: 10,
              minLines: 5,
              decoration: InputDecoration(
                labelText: 'Email content',
                hintText: 'Paste the email text here...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isScanning ? null : _scanEmail,
                icon: _isScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.security),
                label: Text(
                  _isScanning ? 'Analyzing...' : 'Scan Email',
                  style: const TextStyle(fontSize: 17),
                ),
              ),
            ),

            const SizedBox(height: 30),

            if (_result != null) _buildResultCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final isHighRisk = _result == 'High Risk';
    final isSuspicious = _result == 'Suspicious';

    Color resultColor;
    IconData resultIcon;

    if (isHighRisk) {
      resultColor = Colors.red;
      resultIcon = Icons.warning;
    } else if (isSuspicious) {
      resultColor = Colors.orange;
      resultIcon = Icons.error_outline;
    } else {
      resultColor = Colors.green;
      resultIcon = Icons.check_circle;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: resultColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(resultIcon, color: resultColor, size: 35),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _result!,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: resultColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Center(
            child: Column(
              children: [
                Text(
                  '$_riskScore',
                  style: TextStyle(
                    fontSize: 54,
                    fontWeight: FontWeight.bold,
                    color: resultColor,
                  ),
                ),
                const Text(
                  'Risk Score / 100',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(_description!, style: const TextStyle(fontSize: 15)),

          const SizedBox(height: 20),

          const Text(
            'Why?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          ..._reasons.map(
            (reason) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: resultColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(reason)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Note: This is an initial text analysis and does not '
            'guarantee that a message is safe or malicious.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}