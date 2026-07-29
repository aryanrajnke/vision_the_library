import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final String studentLibraryId;

  const AttendanceHistoryScreen({Key? key, required this.studentLibraryId})
    : super(key: key);

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "--:--";
    return DateFormat('hh:mm a').format(timestamp.toDate());
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('EEE, dd MMM yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance History (${widget.studentLibraryId})'),
        elevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          // Fetch past days ordered by date descending
          stream: _firestore
              .collection('attendance')
              .doc(widget.studentLibraryId)
              .collection('days')
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_toggle_off,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No attendance records found.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            final daysDocs = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: daysDocs.length,
              itemBuilder: (context, index) {
                final dayDoc = daysDocs[index];
                final dayData = dayDoc.data() as Map<String, dynamic>;

                final dateStr = dayData['date'] ?? dayDoc.id;
                final totalSessions = dayData['totalSessionsCompleted'] ?? 0;
                final dayStatus = dayData['dayStatus'] ?? 'In Progress';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    shape: const Border(),
                    leading: CircleAvatar(
                      backgroundColor: dayStatus == 'Completed'
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      child: Icon(
                        dayStatus == 'Completed'
                            ? Icons.check_circle_outline
                            : Icons.access_time,
                        color: dayStatus == 'Completed'
                            ? Colors.green.shade800
                            : Colors.orange.shade800,
                      ),
                    ),
                    title: Text(
                      _formatDate(dateStr),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Status: $dayStatus • Sessions: $totalSessions",
                      style: TextStyle(
                        fontSize: 13,
                        color: dayStatus == 'Completed'
                            ? Colors.green.shade700
                            : Colors.orange.shade800,
                      ),
                    ),
                    children: [
                      // Fetch sub-collection 'sessions' for this day
                      StreamBuilder<QuerySnapshot>(
                        stream: dayDoc.reference
                            .collection('sessions')
                            .orderBy('sessionNumber')
                            .snapshots(),
                        builder: (context, sessionSnapshot) {
                          if (!sessionSnapshot.hasData ||
                              sessionSnapshot.data!.docs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("No session details available."),
                            );
                          }

                          final sessions = sessionSnapshot.data!.docs;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Column(
                              children: sessions.map((sessDoc) {
                                final sessData =
                                    sessDoc.data() as Map<String, dynamic>;
                                final sessNum = sessData['sessionNumber'] ?? 1;
                                final entryAt =
                                    sessData['entryAt'] as Timestamp?;
                                final exitAt = sessData['exitAt'] as Timestamp?;
                                final autoExit = sessData['autoExit'] ?? false;

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Session #$sessNum",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "In: ${_formatTimestamp(entryAt)}  |  Out: ${_formatTimestamp(exitAt)}",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade800,
                                            ),
                                          ),
                                          if (autoExit) ...[
                                            const SizedBox(width: 6),
                                            Text(
                                              "(Auto)",
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.red.shade700,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
