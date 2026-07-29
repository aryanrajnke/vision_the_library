import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/glass_card.dart';
import '../../widgets/gradient_background.dart';

class NoticeBoardScreen extends StatelessWidget {
  const NoticeBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),

                    Expanded(
                      child: Text(
                        "Notice Board",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 25),

                noticeCard(
                  Colors.red,
                  "Library will remain closed on Sunday",
                  "12 Jul 2026",
                ),

                const SizedBox(height: 15),

                noticeCard(Colors.green, "New Books Added", "11 Jul 2026"),

                const SizedBox(height: 15),

                noticeCard(
                  Colors.orange,
                  "Fee Submission Last Date",
                  "15 Jul 2026",
                ),

                const SizedBox(height: 15),

                noticeCard(Colors.blue, "Shift Timing Updated", "10 Jul 2026"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget noticeCard(Color color, String title, String date) {
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  date,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
