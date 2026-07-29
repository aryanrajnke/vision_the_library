import 'package:cloud_firestore/cloud_firestore.dart';

class LibrarySettingsModel {
  final String libraryName;
  final String requiredWifi;
  final int maxSessionsPerDay;
  final Map<String, dynamic> shifts;

  LibrarySettingsModel({
    required this.libraryName,
    required this.requiredWifi,
    required this.maxSessionsPerDay,
    required this.shifts,
  });

  factory LibrarySettingsModel.fromMap(Map<String, dynamic> map) {
    return LibrarySettingsModel(
      libraryName: map['libraryName']?.toString() ?? 'Vision The Library',
      requiredWifi: map['requiredWifi']?.toString() ?? 'Vision',
      maxSessionsPerDay: (map['maxSessionsPerDay'] is int)
          ? map['maxSessionsPerDay']
          : int.tryParse(map['maxSessionsPerDay']?.toString() ?? '3') ?? 3,
      shifts: (map['shifts'] is Map)
          ? Map<String, dynamic>.from(map['shifts'])
          : {},
    );
  }
}

class LibrarySettingsService {
  static final LibrarySettingsService _instance =
      LibrarySettingsService._internal();
  factory LibrarySettingsService() => _instance;
  LibrarySettingsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  LibrarySettingsModel? _cachedSettings;

  Stream<LibrarySettingsModel> getSettingsStream() {
    return _firestore
        .collection('library_settings')
        .doc('config')
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            _cachedSettings = LibrarySettingsModel.fromMap(snapshot.data()!);
            return _cachedSettings!;
          }
          return LibrarySettingsModel(
            libraryName: 'Vision The Library',
            requiredWifi: 'Vision',
            maxSessionsPerDay: 3,
            shifts: {},
          );
        });
  }

  Future<LibrarySettingsModel> getSettings() async {
    if (_cachedSettings != null) return _cachedSettings!;

    try {
      final doc = await _firestore
          .collection('library_settings')
          .doc('config')
          .get();
      if (doc.exists && doc.data() != null) {
        _cachedSettings = LibrarySettingsModel.fromMap(doc.data()!);
        return _cachedSettings!;
      }
    } catch (_) {}

    return LibrarySettingsModel(
      libraryName: 'Vision The Library',
      requiredWifi: 'Vision',
      maxSessionsPerDay: 3,
      shifts: {},
    );
  }
}
