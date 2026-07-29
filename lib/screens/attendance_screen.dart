import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/attendance_service.dart';
import '../services/library_settings_service.dart';

class AttendanceScreen extends StatefulWidget {
  final String studentLibraryId;

  const AttendanceScreen({Key? key, required this.studentLibraryId})
    : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  final LibrarySettingsService _settingsService = LibrarySettingsService();

  bool _isLoading = false;

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleEntry() async {
    setState(() => _isLoading = true);
    final result = await _attendanceService.markEntry(widget.studentLibraryId);
    setState(() => _isLoading = false);

    _showMessage(result['message'], isError: !result['success']);
  }

  Future<void> _handleExit() async {
    setState(() => _isLoading = true);
    final result = await _attendanceService.markExit(widget.studentLibraryId);
    setState(() => _isLoading = false);

    _showMessage(result['message'], isError: !result['success']);
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "--:--";
    final dt = timestamp.toDate();
    return DateFormat('hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Attendance'), elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Library Settings Card (Max Sessions Limit)
              StreamBuilder<LibrarySettingsModel>(
                stream: _settingsService.getSettingsStream(),
                builder: (context, settingsSnapshot) {
                  final maxSessions =
                      settingsSnapshot.data?.maxSessionsPerDay ?? 3;

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Student ID: ${widget.studentLibraryId}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Allowed Sessions/Day: $maxSessions",
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.badge_outlined,
                            size: 32,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // 2. Entry & Exit Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleEntry,
                      icon: const Icon(Icons.login),
                      label: const Text('MARK ENTRY'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleExit,
                      icon: const Icon(Icons.logout),
                      label: const Text('MARK EXIT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Text(
                "Today's Sessions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // 3. Sessions History List (Realtime Sub-collection Stream)
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _attendanceService.getTodaySessionsStream(
                    widget.studentLibraryId,
                  ),
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
                              Icons.history,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "No sessions recorded today.",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      );
                    }

                    final sessions = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final sessionData =
                            sessions[index].data() as Map<String, dynamic>;
                        final sessionNum =
                            sessionData['sessionNumber'] ?? (index + 1);
                        final entryAt = sessionData['entryAt'] as Timestamp?;
                        final exitAt = sessionData['exitAt'] as Timestamp?;
                        final isAutoExit = sessionData['autoExit'] ?? false;

                        final bool isActive = (exitAt == null);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isActive
                                  ? Colors.green
                                  : Colors.grey.shade300,
                              width: isActive ? 1.5 : 1,
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isActive
                                  ? Colors.green.shade100
                                  : Colors.blue.shade50,
                              child: Text(
                                "#$sessionNum",
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.green.shade800
                                      : Colors.blue.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  isActive ? "Active Session" : "Completed",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isActive
                                        ? Colors.green.shade700
                                        : Colors.black87,
                                  ),
                                ),
                                if (isAutoExit) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "Auto Exit",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.red.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 14,
                                    color: Colors.green.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text("In: ${_formatTimestamp(entryAt)}"),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.arrow_back,
                                    size: 14,
                                    color: Colors.red.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text("Out: ${_formatTimestamp(exitAt)}"),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
