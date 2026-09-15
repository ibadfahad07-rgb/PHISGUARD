import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final TextEditingController _urlController = TextEditingController();

  bool _isScanning = false;

  String? _result;
  String? _description;
  List<String> _reasons = [];
  int _riskScore = 0;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _scanLink() {
    final input = _urlController.text.trim();

    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a link first.'),
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

      final analysis = _analyzeUrl(input);

      setState(() {
        _isScanning = false;
        _result = analysis['result'] as String;
        _description = analysis['description'] as String;
        _reasons = List<String>.from(analysis['reasons'] as List);
        _riskScore = analysis['score'] as int;
      });

      // Save this scan to Firestore, tied to the logged-in user.
      _saveScanToFirestore(
        url: input,
        result: _result!,
        riskScore: _riskScore,
        reasons: _reasons,
      );
    });
  }

  Future<void> _saveScanToFirestore({
    required String url,
    required String result,
    required int riskScore,
    required List<String> reasons,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    // If there's no signed-in user for some reason, don't try to save.
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('scans').add({
        'userId': user.uid,
        'url': url,
        'result': result,
        'riskScore': riskScore,
        'reasons': reasons,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // We don't want a Firestore failure to break the scan UI itself,
      // so just log it for now. We'll add user-facing error handling later.
      debugPrint('Failed to save scan to Firestore: $e');
    }
  }

  Map<String, dynamic> _analyzeUrl(String input) {
    String url = input;

    if (!url.contains('://')) {
      url = 'https://$url';
    }

    Uri? uri;

    try {
      uri = Uri.parse(url);
    } catch (_) {
      return {
        'result': 'Invalid URL',
        'description': 'This does not appear to be a valid website address.',
        'reasons': [
          'The URL could not be parsed correctly.',
        ],
        'score': 100,
      };
    }

    final host = uri.host.toLowerCase();

    if (host.isEmpty) {
      return {
        'result': 'Invalid URL',
        'description': 'No valid website domain was found.',
        'reasons': [
          'The URL does not contain a valid hostname.',
        ],
        'score': 100,
      };
    }

    final reasons = <String>[];
    int riskScore = 0;

    // HTTPS check
    if (uri.scheme != 'https') {
      riskScore += 15;
      reasons.add('The website does not use HTTPS.');
    }

    // IP address check
    final ipPattern = RegExp(
      r'^(?:\d{1,3}\.){3}\d{1,3}$',
    );

    if (ipPattern.hasMatch(host)) {
      riskScore += 30;
      reasons.add(
        'The link uses an IP address instead of a domain name.',
      );
    }

    // Long hostname
    if (host.length > 50) {
      riskScore += 15;
      reasons.add(
        'The domain name is unusually long.',
      );
    }

    // Suspicious words
    final suspiciousWords = [
      'verify',
      'verification',
      'login',
      'signin',
      'secure',
      'account',
      'password',
      'update',
      'confirm',
      'wallet',
    ];

    final lowerUrl = url.toLowerCase();

    final foundWords = suspiciousWords
        .where((word) => lowerUrl.contains(word))
        .toList();

    if (foundWords.isNotEmpty) {
      riskScore += 15;
      reasons.add(
        'The URL contains words commonly associated with '
        'account or verification pages.',
      );
    }

    // Excessive subdomains
    final subdomainCount = host.split('.').length - 2;

    if (subdomainCount >= 3) {
      riskScore += 20;
      reasons.add(
        'The domain contains an unusually large number of subdomains.',
      );
    }

    // @ symbol
    if (url.contains('@')) {
      riskScore += 30;
      reasons.add(
        'The URL contains an @ symbol, which can be used '
        'to disguise the actual destination.',
      );
    }

    // Long URL
    if (url.length > 150) {
      riskScore += 10;
      reasons.add(
        'The URL is unusually long.',
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
      description =
          'This URL has several suspicious characteristics.';
    } else if (riskScore >= 25) {
      result = 'Suspicious';
      description =
          'This URL contains characteristics that deserve caution.';
    } else {
      result = 'Low Risk';
      description =
          'No major suspicious characteristics were detected.';
    }

    if (reasons.isEmpty) {
      reasons.add(
        'No suspicious characteristics were detected.',
      );
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
          'Scan a Link',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            const Text(
              'Check a suspicious link',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Enter a URL and PhishGuard will analyze it '
              'for suspicious characteristics.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: 'Website URL',
                hintText: 'https://example.com',
                prefixIcon: const Icon(Icons.link),
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
                onPressed: _isScanning ? null : _scanLink,
                icon: _isScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.security),
                label: Text(
                  _isScanning ? 'Analyzing...' : 'Scan Link',
                  style: const TextStyle(
                    fontSize: 17,
                  ),
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

    if (isHighRisk) {
      resultColor = Colors.red;
    } else if (isSuspicious) {
      resultColor = Colors.orange;
    } else {
      resultColor = Colors.green;
    }

    IconData resultIcon;

    if (isHighRisk) {
      resultIcon = Icons.warning;
    } else if (isSuspicious) {
      resultIcon = Icons.error_outline;
    } else {
      resultIcon = Icons.check_circle;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: resultColor.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                resultIcon,
                color: resultColor,
                size: 35,
              ),
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
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            _description!,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Why?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
                  Expanded(
                    child: Text(reason),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Note: This is an initial URL analysis and does not '
            'guarantee that a website is safe or malicious.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}