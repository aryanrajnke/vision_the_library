import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'student_attendance_history_screen.dart';

class AttendanceManagementScreen extends StatefulWidget {
  const AttendanceManagementScreen({super.key});

  @override
  State<AttendanceManagementScreen> createState() =>
      _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState
    extends State<AttendanceManagementScreen> {
  DateTime selectedDate = DateTime.now();

  bool showSearchBar = false;
  final TextEditingController searchController = TextEditingController();

  bool showPresent = true;
  bool showAbsent = true;
  bool showBoys = true;
  bool showGirls = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F172A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: Text(
          "Attendance Management",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          PopupMenuButton<String>(
            color: const Color(0xff1E293B),
            icon: const Icon(Icons.more_vert, color: Colors.white),

            onSelected: (value) {
              if (value == "search") {
                setState(() {
                  showSearchBar = !showSearchBar;

                  if (!showSearchBar) {
                    searchController.clear();
                  }
                });
              }

              if (value == "filter") {
                _showFilterDialog(context);
              }
            },

            itemBuilder: (context) => [
              PopupMenuItem(
                value: "search",
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.white),

                    const SizedBox(width: 12),

                    Text(
                      "Search Student",
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ],
                ),
              ),

              PopupMenuItem(
                value: "filter",
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, color: Colors.white),

                    const SizedBox(width: 12),

                    Text(
                      "Filter",
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Selector
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );

                if (date != null) {
                  setState(() {
                    selectedDate = date;
                  });
                }
              },

              borderRadius: BorderRadius.circular(18),

              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white24),
                ),

                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: Colors.white,
                      size: 28,
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Attendance Date",
                            style: GoogleFonts.poppins(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            "${selectedDate.day.toString().padLeft(2, '0')}/"
                            "${selectedDate.month.toString().padLeft(2, '0')}/"
                            "${selectedDate.year}",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.edit_calendar_outlined,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            if (showSearchBar) ...[
              TextField(
                controller: searchController,
                autofocus: true,
                style: GoogleFonts.poppins(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    // Firebase connect hone ke baad actual search hogi
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search by name or Library ID",
                  hintStyle: GoogleFonts.poppins(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        searchController.clear();
                        showSearchBar = false;
                      });
                    },
                    icon: const Icon(Icons.close, color: Colors.white70),
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
              ),

              const SizedBox(height: 25),
            ],

            Text(
              "Students Attendance",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),
            _attendanceCard(
              name: "Aryan Raj",
              libraryId: "VTL1001",
              status: "Present",
              sessions: const [
                ["08:05 AM", "11:30 AM"],
                ["02:10 PM", "05:00 PM"],
              ],
            ),

            const SizedBox(height: 15),

            _attendanceCard(
              name: "Rahul Kumar",
              libraryId: "VTL1002",
              status: "Absent",
              sessions: const [],
            ),

            const SizedBox(height: 15),

            _attendanceCard(
              name: "Ananya Kumari",
              libraryId: "VTL1003",
              status: "Present",
              sessions: const [
                ["09:00 AM", "01:15 PM"],
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _attendanceCard({
    required String name,
    required String libraryId,
    required String status,
    required List<List<String>> sessions,
  }) {
    final bool isPresent = status == "Present";

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StudentAttendanceHistoryScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),

      child: Container(
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
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        libraryId,
                        style: GoogleFonts.poppins(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
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
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            if (isPresent) ...[
              const SizedBox(height: 18),

              Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),

              const SizedBox(height: 15),

              Text(
                "Sessions: ${sessions.length} / 3",
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              for (int i = 0; i < sessions.length; i++) ...[
                _sessionRow(
                  sessionNumber: i + 1,
                  inTime: sessions[i][0],
                  outTime: sessions[i][1],
                ),

                if (i != sessions.length - 1) const SizedBox(height: 10),
              ],
            ],

            if (!isPresent) ...[
              const SizedBox(height: 12),

              Text(
                "No attendance recorded for this date.",
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
              ),
            ],
          ],
        ),
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

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xff1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                "Filter Attendance",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    value: showPresent,
                    title: const Text(
                      "Present",
                      style: TextStyle(color: Colors.white),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        showPresent = value ?? true;
                      });
                    },
                  ),
                  CheckboxListTile(
                    value: showAbsent,
                    title: const Text(
                      "Absent",
                      style: TextStyle(color: Colors.white),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        showAbsent = value ?? true;
                      });
                    },
                  ),
                  CheckboxListTile(
                    value: showBoys,
                    title: const Text(
                      "Boys",
                      style: TextStyle(color: Colors.white),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        showBoys = value ?? true;
                      });
                    },
                  ),
                  CheckboxListTile(
                    value: showGirls,
                    title: const Text(
                      "Girls",
                      style: TextStyle(color: Colors.white),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        showGirls = value ?? true;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(dialogContext);
                  },
                  child: const Text("APPLY"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
