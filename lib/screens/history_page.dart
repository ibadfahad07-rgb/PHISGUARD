import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: user == null
          ? const Center(
              child: Text('You need to be signed in to view history.'),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('scans')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Something went wrong loading your history.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No scans yet. Go scan a link to see it here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    final String url = data['url'] ?? 'Unknown URL';
                    final String result = data['result'] ?? 'Unknown';
                    final int riskScore = data['riskScore'] ?? 0;
                    final Timestamp? timestamp = data['timestamp'] as Timestamp?;

                    final bool isHighRisk = result == 'High Risk';
                    final bool isSuspicious = result == 'Suspicious';

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

                    final String formattedDate = timestamp != null
                        ? DateFormat('MMM d, y • h:mm a').format(timestamp.toDate())
                        : 'Just now';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: resultColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Icon(resultIcon, color: resultColor, size: 32),
                        title: Text(
                          url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(formattedDate),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              result,
                              style: TextStyle(
                                color: resultColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$riskScore/100',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}