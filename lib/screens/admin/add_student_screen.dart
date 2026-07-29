import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController libraryIdController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController seatController = TextEditingController();
  String selectedSeatPrefix = "B-";
  String? selectedGender;
  bool morningShift = false;
  bool dayShift = false;
  bool eveningShift = false;
  bool nightShift = false;
  String selectedMembership = "Active";

  DateTime? dateOfBirth;
  DateTime? joiningDate;
  DateTime? validTill;

  @override
  void dispose() {
    nameController.dispose();
    libraryIdController.dispose();
    pinController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    seatController.dispose();
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
          "Add Student",
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
            _sectionTitle("Personal Information"),

            const SizedBox(height: 15),

            _textField(
              controller: nameController,
              label: "Full Name",
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 15),

            _textField(
              controller: phoneController,
              label: "Mobile Number",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 15),

            _textField(
              controller: emailController,
              label: "Email Address",
              icon: Icons.email_outlined,
            ),

            const SizedBox(height: 15),

            _textField(
              controller: addressController,
              label: "Address",
              icon: Icons.home_outlined,
            ),

            const SizedBox(height: 15),

            _dropdownField(
              value: selectedGender,
              label: "Gender",
              icon: Icons.people_outline,
              items: const ["Boy", "Girl"],
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                });
              },
            ),

            const SizedBox(height: 15),

            _dateField(
              title: "Date of Birth",
              date: dateOfBirth,
              icon: Icons.cake_outlined,
              onTap: () async {
                final selectedDate = await _selectDate(context);

                if (selectedDate != null) {
                  setState(() {
                    dateOfBirth = selectedDate;
                  });
                }
              },
            ),

            const SizedBox(height: 30),

            _sectionTitle("Library Information"),

            const SizedBox(height: 15),
            _textField(
              controller: libraryIdController,
              label: "Library ID",
              icon: Icons.badge_outlined,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                UpperCaseTextFormatter(),
              ],
            ),

            const SizedBox(height: 15),

            _textField(
              controller: pinController,
              label: "4-Digit PIN",
              icon: Icons.pin_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedSeatPrefix,
                    dropdownColor: const Color(0xff1E293B),
                    style: GoogleFonts.poppins(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: "B-", child: Text("B-")),
                      DropdownMenuItem(value: "G-", child: Text("G-")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedSeatPrefix = value ?? "B-";
                      });
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: TextField(
                    controller: seatController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: GoogleFonts.poppins(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Seat Number",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_outlined,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Select Shift",
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  CheckboxListTile(
                    value: morningShift,
                    title: const Text(
                      "Morning",
                      style: TextStyle(color: Colors.white),
                    ),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        morningShift = value ?? false;
                      });
                    },
                  ),

                  CheckboxListTile(
                    value: dayShift,
                    title: const Text(
                      "Day",
                      style: TextStyle(color: Colors.white),
                    ),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        dayShift = value ?? false;
                      });
                    },
                  ),

                  CheckboxListTile(
                    value: eveningShift,
                    title: const Text(
                      "Evening",
                      style: TextStyle(color: Colors.white),
                    ),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        eveningShift = value ?? false;
                      });
                    },
                  ),

                  CheckboxListTile(
                    value: nightShift,
                    title: const Text(
                      "Night",
                      style: TextStyle(color: Colors.white),
                    ),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        nightShift = value ?? false;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            _dateField(
              title: "Joining Date",
              date: joiningDate,
              icon: Icons.calendar_today_outlined,
              onTap: () async {
                final selectedDate = await _selectDate(context);

                if (selectedDate != null) {
                  setState(() {
                    joiningDate = selectedDate;
                  });
                }
              },
            ),

            const SizedBox(height: 15),

            _dropdownField(
              value: selectedMembership,
              label: "Membership Status",
              icon: Icons.verified_user_outlined,
              items: const ["Active", "Inactive"],
              onChanged: (value) {
                setState(() {
                  selectedMembership = value ?? "Active";
                });
              },
            ),

            const SizedBox(height: 15),

            _dateField(
              title: "Valid Till",
              date: validTill,
              icon: Icons.event_available_outlined,
              onTap: () async {
                final selectedDate = await _selectDate(context);

                if (selectedDate != null) {
                  setState(() {
                    validTill = selectedDate;
                  });
                }
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final String libraryId = libraryIdController.text
                      .trim()
                      .toUpperCase();

                  if (nameController.text.trim().isEmpty ||
                      libraryId.isEmpty ||
                      pinController.text.trim().length != 4 ||
                      selectedGender == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please fill all required fields correctly",
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    final studentRef = FirebaseFirestore.instance
                        .collection('students')
                        .doc(libraryId);

                    final existingStudent = await studentRef.get();

                    if (existingStudent.exists) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("This Library ID already exists"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    await studentRef.set({
                      'name': nameController.text.trim(),
                      'libraryId': libraryId,
                      'pin': pinController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'email': emailController.text.trim(),
                      'address': addressController.text.trim(),
                      'gender': selectedGender,
                      'dateOfBirth': dateOfBirth != null
                          ? Timestamp.fromDate(dateOfBirth!)
                          : null,
                      'seatPrefix': selectedSeatPrefix,
                      'seatNumber': seatController.text.trim(),
                      'seat':
                          '$selectedSeatPrefix${seatController.text.trim()}',
                      'shifts': {
                        'morning': morningShift,
                        'day': dayShift,
                        'evening': eveningShift,
                        'night': nightShift,
                      },
                      'joiningDate': joiningDate != null
                          ? Timestamp.fromDate(joiningDate!)
                          : null,
                      'membershipStatus': selectedMembership,
                      'validTill': validTill != null
                          ? Timestamp.fromDate(validTill!)
                          : null,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Student Added Successfully"),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.pop(context);
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to add student: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.person_add_alt_1),
                label: Text(
                  "ADD STUDENT",
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
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
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

  Widget _dropdownField({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: const Color(0xff1E293B),
      style: GoogleFonts.poppins(color: Colors.white),
      iconEnabledColor: Colors.white70,
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
      items: items.map((item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _dateField({
    required String title,
    required DateTime? date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                date == null
                    ? title
                    : "${date.day.toString().padLeft(2, '0')}/"
                          "${date.month.toString().padLeft(2, '0')}/"
                          "${date.year}",
                style: GoogleFonts.poppins(
                  color: date == null ? Colors.white70 : Colors.white,
                  fontSize: 15,
                ),
              ),
            ),

            const Icon(Icons.calendar_month, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
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
