import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LibraryReportScreen extends StatefulWidget {
  const LibraryReportScreen({super.key});

  @override
  State<LibraryReportScreen> createState() => _LibraryReportScreenState();
}

class _LibraryReportScreenState extends State<LibraryReportScreen> {
  DateTime selectedDate = DateTime.now();
  String selectedPeriod = "Today";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F172A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Library Report",
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Period
            DropdownButtonFormField<String>(
              initialValue: selectedPeriod,
              dropdownColor: const Color(0xff1E293B),
              iconEnabledColor: Colors.white,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Report Period",
                labelStyle: GoogleFonts.poppins(color: Colors.white70),
                prefixIcon: const Icon(
                  Icons.date_range_outlined,
                  color: Colors.white70,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
              items: const [
                DropdownMenuItem(value: "Today", child: Text("Today")),
                DropdownMenuItem(
                  value: "This Month",
                  child: Text("This Month"),
                ),
                DropdownMenuItem(
                  value: "Last 6 Months",
                  child: Text("Last 6 Months"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedPeriod = value ?? "Today";
                });
              },
            ),

            const SizedBox(height: 25),

            Text(
              "Overview",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _reportCard(
                    title: "Total Students",
                    value: "80",
                    icon: Icons.people_outline,
                    valueColor: Colors.blueAccent,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _reportCard(
                    title: "Present",
                    value: "62",
                    icon: Icons.check_circle_outline,
                    valueColor: Colors.greenAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _reportCard(
                    title: "Absent",
                    value: "18",
                    icon: Icons.cancel_outlined,
                    valueColor: Colors.redAccent,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _reportCard(
                    title: "Attendance",
                    value: "77.5%",
                    icon: Icons.insights_outlined,
                    valueColor: Colors.orangeAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            Text(
              "Attendance History",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _historyCard(
              date: "18 July 2026",
              present: 62,
              absent: 18,
              percentage: "77.5%",
            ),

            const SizedBox(height: 12),

            _historyCard(
              date: "17 July 2026",
              present: 68,
              absent: 12,
              percentage: "85%",
            ),

            const SizedBox(height: 12),

            _historyCard(
              date: "16 July 2026",
              present: 65,
              absent: 15,
              percentage: "81.25%",
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _reportCard({
    required String title,
    required String value,
    required IconData icon,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: valueColor, size: 27),

          const SizedBox(height: 12),

          Text(
            value,
            style: GoogleFonts.poppins(
              color: valueColor,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _historyCard({
    required String date,
    required int present,
    required int absent,
    required String percentage,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
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

              Text(
                percentage,
                style: GoogleFonts.poppins(
                  color: Colors.blueAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _historyValue(
                  "Present",
                  present.toString(),
                  Colors.greenAccent,
                ),
              ),

              Container(width: 1, height: 35, color: Colors.white24),

              Expanded(
                child: _historyValue(
                  "Absent",
                  absent.toString(),
                  Colors.redAccent,
                ),
              ),

              Container(width: 1, height: 35, color: Colors.white24),

              Expanded(
                child: _historyValue(
                  "Total",
                  (present + absent).toString(),
                  Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _historyValue(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          title,
          style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }
}
