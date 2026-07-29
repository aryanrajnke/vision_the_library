import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dashboard_screen.dart';
import 'admin/admin_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController libraryIdController = TextEditingController();

  final TextEditingController pinController = TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    libraryIdController.dispose();
    pinController.dispose();
    super.dispose();
  }

  Future<void> _loginStudent() async {
    final String libraryId = libraryIdController.text.trim().toUpperCase();

    final String pin = pinController.text.trim();

    if (libraryId.isEmpty || pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid Library ID and 4-digit PIN"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final studentDocument = await FirebaseFirestore.instance
          .collection('students')
          .doc(libraryId)
          .get();

      if (!mounted) return;

      if (!studentDocument.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid Library ID or PIN"),
            backgroundColor: Colors.red,
          ),
        );

        setState(() {
          isLoading = false;
        });

        return;
      }

      final studentData = studentDocument.data()!;

      final String savedPin = studentData['pin']?.toString() ?? "";

      if (savedPin != pin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid Library ID or PIN"),
            backgroundColor: Colors.red,
          ),
        );

        setState(() {
          isLoading = false;
        });

        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(libraryId: libraryId),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login failed: $e"),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff0F172A), Color(0xff1E3A8A), Color(0xff2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Align(
                  alignment: Alignment.topRight,

                  child: TextButton.icon(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminLoginScreen(),
                              ),
                            );
                          },

                    icon: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                    ),

                    label: Text(
                      "Admin",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Icon(Icons.local_library, color: Colors.white, size: 90),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    "Vision The Library",
                    textAlign: TextAlign.center,

                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Student Login",

                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 17,
                  ),
                ),

                const SizedBox(height: 90),

                TextField(
                  controller: libraryIdController,

                  textCapitalization: TextCapitalization.characters,

                  inputFormatters: [UpperCaseTextFormatter()],

                  decoration: InputDecoration(
                    hintText: "Library ID",

                    prefixIcon: const Icon(Icons.badge),

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),

                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: pinController,

                  obscureText: hidePassword,

                  keyboardType: TextInputType.number,

                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,

                    LengthLimitingTextInputFormatter(4),
                  ],

                  decoration: InputDecoration(
                    hintText: "4-Digit PIN",

                    prefixIcon: const Icon(Icons.pin),

                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
                      ),

                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),

                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: isLoading ? null : _loginStudent,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,

                      foregroundColor: Colors.blue,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),

                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,

                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : Text(
                            "LOGIN",

                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 25),

                const Divider(color: Colors.white38, thickness: 1),

                const SizedBox(height: 20),

                Text(
                  "© Vision The Library",

                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Knowledge Beyond Limits",

                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
