import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangeAdminPasswordScreen extends StatefulWidget {
  const ChangeAdminPasswordScreen({super.key});

  @override
  State<ChangeAdminPasswordScreen> createState() =>
      _ChangeAdminPasswordScreenState();
}

class _ChangeAdminPasswordScreenState extends State<ChangeAdminPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool hideNewPassword = true;
  bool hideConfirmPassword = true;

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F172A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

        title: Text(
          "Change Password",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white24,
              child: Icon(
                Icons.lock_reset_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Update Admin Password",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Choose a new password.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
            ),

            const SizedBox(height: 35),

            _passwordField(
              controller: newPasswordController,
              hint: "New Password",
              hidden: hideNewPassword,
              onVisibilityPressed: () {
                setState(() {
                  hideNewPassword = !hideNewPassword;
                });
              },
            ),

            const SizedBox(height: 18),

            _passwordField(
              controller: confirmPasswordController,
              hint: "Confirm New Password",
              hidden: hideConfirmPassword,
              onVisibilityPressed: () {
                setState(() {
                  hideConfirmPassword = !hideConfirmPassword;
                });
              },
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  final newPassword = newPasswordController.text.trim();

                  final confirmPassword = confirmPasswordController.text.trim();

                  if (newPassword.isEmpty || confirmPassword.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please fill all fields"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (newPassword != confirmPassword) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("New passwords do not match"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Actual password change Firebase ke baad add hoga.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Password changed successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );

                  Navigator.pop(context);
                },
                icon: const Icon(Icons.lock_reset),
                label: Text(
                  "CHANGE PASSWORD",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool hidden,
    required VoidCallback onVisibilityPressed,
  }) {
    return TextField(
      controller: controller,
      obscureText: hidden,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          onPressed: onVisibilityPressed,
          icon: Icon(hidden ? Icons.visibility_off : Icons.visibility),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
