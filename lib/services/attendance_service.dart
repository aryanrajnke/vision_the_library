import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:vision_the_library/services/library_settings_service.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LibrarySettingsService _settingsService = LibrarySettingsService();

  /// Today's Date String (Format: YYYY-MM-DD)
  String get _todayDateStr => DateFormat('yyyy-MM-dd').format(DateTime.now());

  /// Specific Date String (Format: YYYY-MM-DD)
  String _getDateStr(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  /// Reference for Student Attendance Base Doc (VLT0000)
  DocumentReference _getStudentBaseDocRef(String studentLibraryId) {
    return _firestore.collection('attendance').doc(studentLibraryId);
  }

  /// Reference for Student Daily Attendance Document (VLT0000 -> days -> YYYY-MM-DD)
  DocumentReference _getDailyDocRef(String studentLibraryId, String dateStr) {
    return _getStudentBaseDocRef(
      studentLibraryId,
    ).collection('days').doc(dateStr);
  }

  /// Ensure Parent Student Doc Exists (AUTOMATIC PARENT CREATION)
  Future<void> _ensureStudentDocExists(String studentLibraryId) async {
    final baseDocRef = _getStudentBaseDocRef(studentLibraryId);
    // Automatic field creation so document is never phantom/virtual
    await baseDocRef.set({
      'libraryId': studentLibraryId,
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Get Today's Main Document Stream
  Stream<DocumentSnapshot> getTodayAttendanceStream(String studentLibraryId) {
    return _getDailyDocRef(studentLibraryId, _todayDateStr).snapshots();
  }

  /// Get Today's Active Sub-collection Sessions Stream
  Stream<QuerySnapshot> getTodaySessionsStream(String studentLibraryId) {
    return _getDailyDocRef(studentLibraryId, _todayDateStr)
        .collection('sessions')
        .orderBy('sessionNumber', descending: false)
        .snapshots();
  }

  /// Check Previous Day Auto-Exit Logic
  Future<void> checkAndProcessAutoExit(String studentLibraryId) async {
    try {
      final now = DateTime.now();
      final yesterdayStr = _getDateStr(now.subtract(const Duration(days: 1)));

      final yesterdayDocRef = _getDailyDocRef(studentLibraryId, yesterdayStr);
      final activeSessions = await yesterdayDocRef
          .collection('sessions')
          .where('exitAt', isNull: true)
          .get();

      for (var doc in activeSessions.docs) {
        final attendanceDate = DateTime.parse(yesterdayStr);
        final autoExitTime = DateTime(
          attendanceDate.year,
          attendanceDate.month,
          attendanceDate.day,
          23,
          59,
          59,
        );

        await doc.reference.update({
          'exitAt': Timestamp.fromDate(autoExitTime),
          'autoExit': true,
        });
      }

      if (activeSessions.docs.isNotEmpty) {
        await yesterdayDocRef.set({
          'dayStatus': 'Completed',
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print("Error in checkAndProcessAutoExit: $e");
    }
  }

  /// MARK ATTENDANCE (New Session Entry)
  Future<Map<String, dynamic>> markEntry(String studentLibraryId) async {
    try {
      // 1. Base Document Auto-Create karein (No more phantom docs!)
      await _ensureStudentDocExists(studentLibraryId);

      // 2. Pichle din ka auto-exit handle karein
      await checkAndProcessAutoExit(studentLibraryId);

      // 3. Settings fetch karein
      final settings = await _settingsService.getSettings();
      final dailyDocRef = _getDailyDocRef(studentLibraryId, _todayDateStr);

      final dailyDoc = await dailyDocRef.get();
      int totalCompleted = 0;

      if (dailyDoc.exists && dailyDoc.data() != null) {
        final data = dailyDoc.data() as Map<String, dynamic>;
        totalCompleted = data['totalSessionsCompleted'] ?? 0;
      }

      // 4. Check active session
      final openSessions = await dailyDocRef
          .collection('sessions')
          .where('exitAt', isNull: true)
          .get();

      if (openSessions.docs.isNotEmpty) {
        return {
          'success': false,
          'message':
              'Aapka ek active session pehle se chal raha hai. Pehle EXIT mark karein!',
        };
      }

      // 5. Check daily max session limit
      if (totalCompleted >= settings.maxSessionsPerDay) {
        return {
          'success': false,
          'message':
              'Aaj ki maximum session limit (${settings.maxSessionsPerDay}) poori ho chuki hai.',
        };
      }

      int nextSessionNum = totalCompleted + 1;
      String sessionId = "session_$nextSessionNum";

      // 6. Daily Parent Document create/update karein
      await dailyDocRef.set({
        'date': _todayDateStr,
        'studentLibraryId': studentLibraryId,
        'totalSessionsCompleted': totalCompleted,
        'dayStatus': 'In Progress',
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 7. Session Sub-collection create karein
      await dailyDocRef.collection('sessions').doc(sessionId).set({
        'sessionNumber': nextSessionNum,
        'entryAt': FieldValue.serverTimestamp(),
        'exitAt': null,
        'autoEntry': false,
        'autoExit': false,
      });

      return {
        'success': true,
        'message': 'Attendance Marked! (Session $nextSessionNum Started)',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error marking attendance: $e'};
    }
  }

  /// MARK EXIT (Current Active Session Closing)
  Future<Map<String, dynamic>> markExit(String studentLibraryId) async {
    try {
      final settings = await _settingsService.getSettings();
      final dailyDocRef = _getDailyDocRef(studentLibraryId, _todayDateStr);

      final openSessions = await dailyDocRef
          .collection('sessions')
          .where('exitAt', isNull: true)
          .get();

      if (openSessions.docs.isEmpty) {
        return {
          'success': false,
          'message':
              'Koi active session nahi mila jiska Exit mark kiya ja sake.',
        };
      }

      final activeDoc = openSessions.docs.first;
      int sessionNum = activeDoc.data()['sessionNumber'] ?? 1;

      // Exit timestamp set karein
      await activeDoc.reference.update({
        'exitAt': FieldValue.serverTimestamp(),
        'autoExit': false,
      });

      // Total completed sessions count update karein
      bool isLastSession = sessionNum >= settings.maxSessionsPerDay;
      await dailyDocRef.set({
        'totalSessionsCompleted': sessionNum,
        'dayStatus': isLastSession ? 'Completed' : 'In Progress',
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return {
        'success': true,
        'message': 'Exit Marked! (Session $sessionNum Completed)',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error marking exit: $e'};
    }
  }
}
