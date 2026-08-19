import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  String searchText = "";

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
                    searchText = "";
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

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Text(
                  "Failed to load library data",

                  textAlign: TextAlign.center,

                  style: GoogleFonts.poppins(color: Colors.redAccent),
                ),
              ),
            );
          }

          final documents = snapshot.data?.docs ?? [];

          final currentSearchText = searchText.trim().toLowerCase();

          final Map<String, Map<String, List<Map<String, String>>>>
          seatBookings = {};

          for (final document in documents) {
            final data = document.data() as Map<String, dynamic>;

            final String name = data['name']?.toString() ?? "-";

            final String libraryId =
                data['libraryId']?.toString() ?? document.id;

            final String seat = data['seat']?.toString().trim() ?? "";

            final String gender = data['gender']?.toString().trim() ?? "";

            if (seat.isEmpty) {
              continue;
            }

            final bool isBoy =
                gender.toLowerCase() == "boy" || gender.toLowerCase() == "male";

            final bool isGirl =
                gender.toLowerCase() == "girl" ||
                gender.toLowerCase() == "female";

            if (isBoy && !showBoysSeats) {
              continue;
            }

            if (isGirl && !showGirlsSeats) {
              continue;
            }

            if (!isBoy && !isGirl) {
              continue;
            }

            if (currentSearchText.isNotEmpty &&
                !seat.toLowerCase().contains(currentSearchText)) {
              continue;
            }

            final dynamic shiftData = data['shifts'];

            if (shiftData is! Map) {
              continue;
            }

            final Map<String, dynamic> shifts = Map<String, dynamic>.from(
              shiftData,
            );

            final seatKey = seat.toUpperCase();

            seatBookings.putIfAbsent(
              seatKey,
              () => {"Morning": [], "Day": [], "Evening": [], "Night": []},
            );

            if (shifts['morning'] == true) {
              seatBookings[seatKey]!["Morning"]!.add({
                "name": name,
                "libraryId": libraryId,
              });
            }

            if (shifts['day'] == true) {
              seatBookings[seatKey]!["Day"]!.add({
                "name": name,
                "libraryId": libraryId,
              });
            }

            if (shifts['evening'] == true) {
              seatBookings[seatKey]!["Evening"]!.add({
                "name": name,
                "libraryId": libraryId,
              });
            }

            if (shifts['night'] == true) {
              seatBookings[seatKey]!["Night"]!.add({
                "name": name,
                "libraryId": libraryId,
              });
            }
          }

          final seatNumbers = seatBookings.keys.toList();

          seatNumbers.sort(_compareSeatNumbers);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),

            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                if (showSearchBar) ...[
                  _buildSearchField(),

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
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 20),

                if (seatNumbers.isEmpty) _emptyState(),

                for (int i = 0; i < seatNumbers.length; i++) ...[
                  _seatCard(
                    seatNumber: seatNumbers[i],
                    shifts: seatBookings[seatNumbers[i]]!,
                  ),

                  if (i != seatNumbers.length - 1) const SizedBox(height: 15),
                ],

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // SEARCH FIELD
  // ============================================================

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,

      autofocus: true,

      style: GoogleFonts.poppins(color: Colors.white),

      onChanged: (value) {
        setState(() {
          searchText = value;
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
              searchText = "";
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
    );
  }

  // ============================================================
  // SEAT SORT
  // ============================================================

  int _compareSeatNumbers(String a, String b) {
    final aParts = a.split("-");
    final bParts = b.split("-");

    if (aParts.length != 2 || bParts.length != 2) {
      return a.compareTo(b);
    }

    final genderCompare = aParts[0].compareTo(bParts[0]);

    if (genderCompare != 0) {
      return genderCompare;
    }

    final aNumber = int.tryParse(aParts[1]) ?? 0;

    final bNumber = int.tryParse(bParts[1]) ?? 0;

    return aNumber.compareTo(bNumber);
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: Colors.white24),
      ),

      child: Column(
        children: [
          const Icon(
            Icons.event_seat_outlined,
            color: Colors.white54,
            size: 48,
          ),

          const SizedBox(height: 12),

          Text(
            "No seat booking found",
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEAT CARD
  // ============================================================

  Widget _seatCard({
    required String seatNumber,
    required Map<String, List<Map<String, String>>> shifts,
  }) {
    const shiftNames = ["Morning", "Day", "Evening", "Night"];

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

          for (int i = 0; i < shiftNames.length; i++) ...[
            _shiftBookingRow(
              shiftName: shiftNames[i],
              students: shifts[shiftNames[i]] ?? [],
            ),

            if (i != shiftNames.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // SHIFT BOOKING ROW
  // ============================================================

  Widget _shiftBookingRow({
    required String shiftName,
    required List<Map<String, String>> students,
  }) {
    final bool isBooked = students.isNotEmpty;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),

        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

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
                      for (int i = 0; i < students.length; i++) ...[
                        Text(
                          students[i]["name"] ?? "-",

                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        Text(
                          students[i]["libraryId"] ?? "-",

                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),

                        if (i != students.length - 1) const SizedBox(height: 6),
                      ],
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

          const SizedBox(width: 8),

          Icon(
            isBooked ? Icons.lock_outline : Icons.check_circle_outline,

            color: isBooked ? Colors.orangeAccent : Colors.greenAccent,

            size: 20,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER DIALOG
  // ============================================================

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
