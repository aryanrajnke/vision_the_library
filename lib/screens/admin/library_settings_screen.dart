import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LibrarySettingsScreen extends StatefulWidget {
  const LibrarySettingsScreen({super.key});

  @override
  State<LibrarySettingsScreen> createState() => _LibrarySettingsScreenState();
}

class _LibrarySettingsScreenState extends State<LibrarySettingsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController libraryNameController = TextEditingController();
  final TextEditingController wifiNameController = TextEditingController();
  final TextEditingController maxSessionsController = TextEditingController();

  TimeOfDay morningStart = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay morningEnd = const TimeOfDay(hour: 11, minute: 0);

  TimeOfDay dayStart = const TimeOfDay(hour: 11, minute: 0);
  TimeOfDay dayEnd = const TimeOfDay(hour: 17, minute: 0);

  TimeOfDay eveningStart = const TimeOfDay(hour: 17, minute: 0);
  TimeOfDay eveningEnd = const TimeOfDay(hour: 22, minute: 0);

  TimeOfDay nightStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay nightEnd = const TimeOfDay(hour: 6, minute: 0);

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettingsFromFirestore();
  }

  /// Firestore se current settings load karein
  Future<void> _loadSettingsFromFirestore() async {
    try {
      final doc = await _firestore
          .collection('library_settings')
          .doc('config')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        setState(() {
          libraryNameController.text =
              data['libraryName']?.toString() ?? "Vision The Library";
          wifiNameController.text =
              data['requiredWifi']?.toString() ?? "Vision";
          maxSessionsController.text =
              data['maxSessionsPerDay']?.toString() ?? "3";

          if (data['shifts'] != null && data['shifts'] is Map) {
            Map shifts = data['shifts'];
            if (shifts['morning'] != null) {
              morningStart = _parseTimeString(
                shifts['morning']['startTime'],
                morningStart,
              );
              morningEnd = _parseTimeString(
                shifts['morning']['endTime'],
                morningEnd,
              );
            }
            if (shifts['day'] != null) {
              dayStart = _parseTimeString(shifts['day']['startTime'], dayStart);
              dayEnd = _parseTimeString(shifts['day']['endTime'], dayEnd);
            }
            if (shifts['evening'] != null) {
              eveningStart = _parseTimeString(
                shifts['evening']['startTime'],
                eveningStart,
              );
              eveningEnd = _parseTimeString(
                shifts['evening']['endTime'],
                eveningEnd,
              );
            }
            if (shifts['night'] != null) {
              nightStart = _parseTimeString(
                shifts['night']['startTime'],
                nightStart,
              );
              nightEnd = _parseTimeString(shifts['night']['endTime'], nightEnd);
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error loading settings: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// TimeOfDay ko HH:mm string format me convert karne ke liye
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  /// String HH:mm ko TimeOfDay me convert karne ke liye
  TimeOfDay _parseTimeString(String? timeStr, TimeOfDay defaultTime) {
    if (timeStr == null || !timeStr.contains(":")) return defaultTime;
    final parts = timeStr.split(":");
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? defaultTime.hour,
      minute: int.tryParse(parts[1]) ?? defaultTime.minute,
    );
  }

  /// Firestore me changes Save karein
  Future<void> _saveSettingsToFirestore() async {
    setState(() {
      isSaving = true;
    });

    try {
      final int maxSessions =
          int.tryParse(maxSessionsController.text.trim()) ?? 3;

      Map<String, dynamic> settingsData = {
        'libraryName': libraryNameController.text.trim(),
        'requiredWifi': wifiNameController.text.trim(),
        'maxSessionsPerDay': maxSessions,
        'shifts': {
          'morning': {
            'startTime': _formatTimeOfDay(morningStart),
            'endTime': _formatTimeOfDay(morningEnd),
          },
          'day': {
            'startTime': _formatTimeOfDay(dayStart),
            'endTime': _formatTimeOfDay(dayEnd),
          },
          'evening': {
            'startTime': _formatTimeOfDay(eveningStart),
            'endTime': _formatTimeOfDay(eveningEnd),
          },
          'night': {
            'startTime': _formatTimeOfDay(nightStart),
            'endTime': _formatTimeOfDay(nightEnd),
          },
        },
      };

      await _firestore
          .collection('library_settings')
          .doc('config')
          .set(settingsData, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Library Settings Saved Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save settings: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    libraryNameController.dispose();
    wifiNameController.dispose();
    maxSessionsController.dispose();
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
          "Library Settings",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("General Settings"),
                  const SizedBox(height: 15),
                  _textField(
                    controller: libraryNameController,
                    label: "Library Name",
                    icon: Icons.local_library_outlined,
                  ),
                  const SizedBox(height: 15),
                  _textField(
                    controller: wifiNameController,
                    label: "Library Wi-Fi Name",
                    icon: Icons.wifi,
                  ),
                  const SizedBox(height: 15),
                  _textField(
                    controller: maxSessionsController,
                    label: "Maximum Sessions Per Day",
                    icon: Icons.repeat,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 30),
                  _sectionTitle("Shift Timings"),
                  const SizedBox(height: 15),
                  _shiftTimingCard(
                    title: "Morning",
                    startTime: morningStart,
                    endTime: morningEnd,
                    onStartTap: () async {
                      final time = await _selectTime(morningStart);
                      if (time != null) setState(() => morningStart = time);
                    },
                    onEndTap: () async {
                      final time = await _selectTime(morningEnd);
                      if (time != null) setState(() => morningEnd = time);
                    },
                  ),
                  const SizedBox(height: 12),
                  _shiftTimingCard(
                    title: "Day",
                    startTime: dayStart,
                    endTime: dayEnd,
                    onStartTap: () async {
                      final time = await _selectTime(dayStart);
                      if (time != null) setState(() => dayStart = time);
                    },
                    onEndTap: () async {
                      final time = await _selectTime(dayEnd);
                      if (time != null) setState(() => dayEnd = time);
                    },
                  ),
                  const SizedBox(height: 12),
                  _shiftTimingCard(
                    title: "Evening",
                    startTime: eveningStart,
                    endTime: eveningEnd,
                    onStartTap: () async {
                      final time = await _selectTime(eveningStart);
                      if (time != null) setState(() => eveningStart = time);
                    },
                    onEndTap: () async {
                      final time = await _selectTime(eveningEnd);
                      if (time != null) setState(() => eveningEnd = time);
                    },
                  ),
                  const SizedBox(height: 12),
                  _shiftTimingCard(
                    title: "Night",
                    startTime: nightStart,
                    endTime: nightEnd,
                    onStartTap: () async {
                      final time = await _selectTime(nightStart);
                      if (time != null) setState(() => nightStart = time);
                    },
                    onEndTap: () async {
                      final time = await _selectTime(nightEnd);
                      if (time != null) setState(() => nightEnd = time);
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: isSaving ? null : _saveSettingsToFirestore,
                      icon: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        isSaving ? "SAVING..." : "SAVE SETTINGS",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }

  Widget _shiftTimingCard({
    required String title,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required VoidCallback onStartTap,
    required VoidCallback onEndTap,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _timeBox(
                  title: "Start Time",
                  time: startTime,
                  onTap: onStartTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _timeBox(
                  title: "End Time",
                  time: endTime,
                  onTap: onEndTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeBox({
    required String title,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white70, size: 18),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    time.format(context),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<TimeOfDay?> _selectTime(TimeOfDay initialTime) async {
    return showTimePicker(context: context, initialTime: initialTime);
  }
}
