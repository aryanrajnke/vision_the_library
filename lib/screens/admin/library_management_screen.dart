import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LibraryManagementScreen extends StatefulWidget {
  const LibraryManagementScreen({super.key});

  @override
  State<LibraryManagementScreen> createState() =>
      _LibraryManagementScreenState();
}

class _LibraryManagementScreenState extends State<LibraryManagementScreen> {
  bool showSearchBar = false;
  bool showBoysSeats = true;
  bool showGirlsSeats = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F172A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: Text(
          "Library Management",
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
                      "Search Seat",
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
                      "Filter Seats",
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
            if (showSearchBar) ...[
              TextField(
                controller: searchController,
                autofocus: true,
                style: GoogleFonts.poppins(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    // Firebase ke baad actual seat search hogi
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search seat number",
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
              "Seat & Shift Bookings",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              "View booking details for every seat and shift",
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12),
            ),

            const SizedBox(height: 20),
            _seatCard(
              seatNumber: "B-01",
              shifts: const {
                "Morning": ["Aryan Raj", "VTL1001"],
                "Day": null,
                "Evening": ["Aryan Raj", "VTL1001"],
                "Night": null,
              },
            ),

            const SizedBox(height: 15),

            _seatCard(
              seatNumber: "B-02",
              shifts: const {
                "Morning": null,
                "Day": ["Rahul Kumar", "VTL1002"],
                "Evening": null,
                "Night": ["Rahul Kumar", "VTL1002"],
              },
            ),

            const SizedBox(height: 15),

            _seatCard(
              seatNumber: "G-01",
              shifts: const {
                "Morning": ["Ananya Kumari", "VTL1003"],
                "Day": null,
                "Evening": null,
                "Night": null,
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _seatCard({
    required String seatNumber,
    required Map<String, List<String>?> shifts,
  }) {
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
              Container(
                height: 48,
                width: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.event_seat_outlined,
                  color: Colors.blueAccent,
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  seatNumber,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),

          const SizedBox(height: 15),

          for (final entry in shifts.entries) ...[
            _shiftBookingRow(shiftName: entry.key, studentData: entry.value),

            if (entry.key != shifts.keys.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _shiftBookingRow({
    required String shiftName,
    required List<String>? studentData,
  }) {
    final bool isBooked = studentData != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              shiftName,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: isBooked
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentData[0],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        studentData[1],
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  )
                : Text(
                    "Available",
                    style: GoogleFonts.poppins(
                      color: Colors.greenAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),

          Icon(
            isBooked ? Icons.lock_outline : Icons.check_circle_outline,
            color: isBooked ? Colors.orangeAccent : Colors.greenAccent,
            size: 20,
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
                "Filter Seats",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    value: showBoysSeats,
                    title: const Text(
                      "Boys Seats (B-)",
                      style: TextStyle(color: Colors.white),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        showBoysSeats = value ?? true;
                      });
                    },
                  ),

                  CheckboxListTile(
                    value: showGirlsSeats,
                    title: const Text(
                      "Girls Seats (G-)",
                      style: TextStyle(color: Colors.white),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        showGirlsSeats = value ?? true;
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
