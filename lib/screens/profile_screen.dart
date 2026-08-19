import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'personal_information_screen.dart';
import 'library_information_screen.dart';
import 'notice_board_screen.dart';
import 'admin/student_attendance_history_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String libraryId;

  const ProfileScreen({super.key, required this.libraryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F172A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Profile",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('students')
            .doc(libraryId)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Failed to load profile",
                style: GoogleFonts.poppins(color: Colors.redAccent),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                "Student not found",
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final String name = data['name']?.toString() ?? "Student";

          final String studentId = data['libraryId']?.toString() ?? libraryId;

          final String gender = data['gender']?.toString() ?? "";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white24,

                  child: Icon(
                    gender == "Girl" ? Icons.person_2 : Icons.person,
                    color: Colors.white,
                    size: 65,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  name.toUpperCase(),
                  textAlign: TextAlign.center,

                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "Student ID : $studentId",

                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 30),

                Container(
                  width: double.infinity,

                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),

                    borderRadius: BorderRadius.circular(20),

                    border: Border.all(color: Colors.white24),
                  ),

                  child: Column(
                    children: [
                      profileTile(
                        context,
                        Icons.person_2_outlined,
                        "Personal Information",
                        studentId,
                        name,
                      ),

                      const Divider(color: Colors.white24, height: 1),

                      profileTile(
                        context,
                        Icons.badge_outlined,
                        "Library Information",
                        studentId,
                        name,
                      ),

                      const Divider(color: Colors.white24, height: 1),

                      profileTile(
                        context,
                        Icons.campaign_outlined,
                        "Notice Board",
                        studentId,
                        name,
                      ),

                      const Divider(color: Colors.white24, height: 1),

                      profileTile(
                        context,
                        Icons.history,
                        "Attendance History",
                        studentId,
                        name,
                      ),

                      const Divider(color: Colors.white24, height: 1),

                      profileTile(
                        context,
                        Icons.logout,
                        "Logout",
                        studentId,
                        name,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  "Vision The Library",

                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "Version 1.0.0",

                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget profileTile(
    BuildContext context,
    IconData icon,
    String title,
    String studentId,
    String name,
  ) {
    return InkWell(
      onTap: () {
        if (title == "Attendance History") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentAttendanceHistoryScreen(
                name: name,
                libraryId: studentId,
              ),
            ),
          );

          return;
        }

        if (title == "Notice Board") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoticeBoardScreen()),
          );
        }

        if (title == "Library Information") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  LibraryInformationScreen(libraryId: studentId),
            ),
          );
        }

        if (title == "Personal Information") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PersonalInformationScreen(libraryId: studentId),
            ),
          );
        }

        if (title == "Logout") {
          showDialog(
            context: context,

            builder: (dialogContext) {
              return AlertDialog(
                backgroundColor: const Color(0xff1E293B),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),

                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white),
                ),

                content: const Text(
                  "Are you sure you want to logout?",
                  style: TextStyle(color: Colors.white70),
                ),

                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },

                    child: const Text("Cancel"),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,

                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),

                        (route) => false,
                      );
                    },

                    child: const Text("Logout"),
                  ),
                ],
              );
            },
          );
        }
      },

      borderRadius: BorderRadius.circular(20),

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),

        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,

                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
