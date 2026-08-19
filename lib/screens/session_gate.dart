import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/session_service.dart';
import 'dashboard_screen.dart';
import 'welcome_screen.dart';
import 'admin/admin_dashboard_screen.dart';

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  @override
  void initState() {
    super.initState();

    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      // ==========================================================
      // 1. CHECK FIREBASE SERVER CONNECTION
      // ==========================================================

      await FirebaseFirestore.instance
          .collection('settings')
          .doc('admin')
          .get(const GetOptions(source: Source.server));

      if (!mounted) return;

      // ==========================================================
      // 2. CHECK SAVED SESSION
      // ==========================================================

      final loggedIn = await SessionService.isLoggedIn();

      if (!mounted) return;

      if (!loggedIn) {
        _openWelcome();

        return;
      }

      // ==========================================================
      // 3. GET USER TYPE
      // ==========================================================

      final userType = await SessionService.getUserType();

      if (!mounted) return;

      // ==========================================================
      // 4. ADMIN SESSION
      // ==========================================================

      if (userType == 'admin') {
        _openAdminDashboard();

        return;
      }

      // ==========================================================
      // 5. STUDENT SESSION
      // ==========================================================

      if (userType == 'student') {
        final libraryId = await SessionService.getLibraryId();

        if (!mounted) return;

        if (libraryId == null || libraryId.isEmpty) {
          await SessionService.logout();

          if (!mounted) return;

          _openWelcome();

          return;
        }

        // --------------------------------------------------------
        // Verify that student still exists in Firebase.
        // --------------------------------------------------------

        final studentDocument = await FirebaseFirestore.instance
            .collection('students')
            .doc(libraryId)
            .get(const GetOptions(source: Source.server));

        if (!mounted) return;

        if (!studentDocument.exists) {
          await SessionService.logout();

          if (!mounted) return;

          _openWelcome();

          return;
        }

        _openStudentDashboard(libraryId);

        return;
      }

      // ==========================================================
      // 6. UNKNOWN SESSION
      // ==========================================================

      await SessionService.logout();

      if (!mounted) return;

      _openWelcome();
    } on FirebaseException catch (e) {
      if (!mounted) return;

      String message;

      if (e.code == 'unavailable') {
        message = 'Please connect to the internet.';
      } else if (e.code == 'permission-denied') {
        message = 'Firebase permission denied.';
      } else {
        message = 'Unable to connect to Firebase.';
      }

      _showConnectionError(message);
    } catch (e) {
      if (!mounted) return;

      _showConnectionError('Please connect to the internet.');
    }
  }

  // ============================================================
  // WELCOME
  // ============================================================

  void _openWelcome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  // ============================================================
  // STUDENT DASHBOARD
  // ============================================================

  void _openStudentDashboard(String libraryId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(libraryId: libraryId),
      ),
    );
  }

  // ============================================================
  // ADMIN DASHBOARD
  // ============================================================

  void _openAdminDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
    );
  }

  // ============================================================
  // CONNECTION ERROR
  // ============================================================

  void _showConnectionError(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Connection Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                _checkSession();
              },
              child: const Text('RETRY'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // LOADING UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xff0F172A),
      body: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
