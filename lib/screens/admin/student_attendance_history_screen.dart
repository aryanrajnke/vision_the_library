import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentAttendanceHistoryScreen extends StatelessWidget {
  const StudentAttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F172A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Attendance History",
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
            const CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white, size: 55),
            ),

            const SizedBox(height: 14),

            Text(
              "Aryan Raj",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              "VTL1001",
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13),
            ),

            const SizedBox(height: 25),

            // Attendance Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),

              child: Row(
                children: [
                  Expanded(
                    child: _summaryItem("Present", "24", Colors.greenAccent),
                  ),

                  Container(height: 45, width: 1, color: Colors.white24),

                  Expanded(
                    child: _summaryItem("Absent", "6", Colors.redAccent),
                  ),

                  Container(height: 45, width: 1, color: Colors.white24),

                  Expanded(
                    child: _summaryItem("Attendance", "80%", Colors.blueAccent),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Attendance Records",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            _attendanceDayCard(
              date: "18 July 2026",
              status: "Present",
              sessions: const [
                ["08:05 AM", "11:30 AM"],
                ["02:10 PM", "05:00 PM"],
              ],
            ),

            const SizedBox(height: 15),

            _attendanceDayCard(
              date: "17 July 2026",
              status: "Absent",
              sessions: const [],
            ),

            const SizedBox(height: 15),

            _attendanceDayCard(
              date: "16 July 2026",
              status: "Present",
              sessions: const [
                ["08:15 AM", "12:00 PM"],
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String title, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            color: valueColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }

  Widget _attendanceDayCard({
    required String date,
    required String status,
    required List<List<String>> sessions,
  }) {
    final bool isPresent = status == "Present";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: Colors.white70,
                size: 21,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  date,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isPresent
                      ? Colors.green.withValues(alpha: 0.20)
                      : Colors.red.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    color: isPresent ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          if (isPresent && sessions.isNotEmpty) ...[
            const SizedBox(height: 15),

            Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),

            const SizedBox(height: 12),

            Text(
              "Sessions: ${sessions.length} / 3",
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12),
            ),

            const SizedBox(height: 10),

            for (int i = 0; i < sessions.length; i++) ...[
              _sessionRow(
                sessionNumber: i + 1,
                inTime: sessions[i][0],
                outTime: sessions[i][1],
              ),

              if (i != sessions.length - 1) const SizedBox(height: 8),
            ],
          ],

          if (!isPresent) ...[
            const SizedBox(height: 10),

            Text(
              "No attendance recorded.",
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sessionRow({
    required int sessionNumber,
    required String inTime,
    required String outTime,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "$sessionNumber",
              style: GoogleFonts.poppins(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "IN",
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
                Text(
                  inTime,
                  style: GoogleFonts.poppins(
                    color: Colors.greenAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.arrow_forward, color: Colors.white38, size: 18),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "OUT",
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
                Text(
                  outTime,
                  style: GoogleFonts.poppins(
                    color: Colors.orangeAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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
