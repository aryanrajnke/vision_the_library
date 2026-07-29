import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'change_admin_password_screen.dart';
import '../welcome_screen.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F172A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Admin Profile",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const CircleAvatar(
              radius: 55,
              backgroundColor: Colors.white24,
              child: Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 65,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              "ADMIN",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              "Vision The Library",
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 15),
            ),

            const SizedBox(height: 35),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),

              child: Column(
                children: [
                  _profileTile(Icons.lock_outline, "Change Password", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangeAdminPasswordScreen(),
                      ),
                    );
                  }),

                  const Divider(color: Colors.white24, height: 1),

                  _profileTile(Icons.logout, "Logout", () {
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
                            "Are you sure you want to logout from Admin Panel?",
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
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const WelcomeScreen(),
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
                  }),
                ],
              ),
            ),

            const SizedBox(height: 35),

            Text(
              "Admin Panel",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              "Version 1.0.0",
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileTile(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
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
