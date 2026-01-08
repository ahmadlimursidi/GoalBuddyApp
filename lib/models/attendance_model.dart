class StudentAttendance {
  final String id;
  final String name;
  final bool isPresent;
  final bool isNew;
  final String parentContact;
  final String medicalNotes;
  final String ageGroup;

  StudentAttendance({
    required this.id,
    required this.name,
    required this.isPresent,
    required this.isNew,
    required this.parentContact,
    required this.medicalNotes,
    required this.ageGroup,
  });

  // Factory constructor to create from Firestore map data
  factory StudentAttendance.fromMap(Map<String, dynamic> data, String id) {
    return StudentAttendance(
      id: id,
      name: data['name'] ?? '',
      isPresent: data['isPresent'] ?? false,
      isNew: data['isNew'] ?? false,
      parentContact: data['parentContact'] ?? '',
      medicalNotes: data['medicalNotes'] ?? '',
      ageGroup: data['ageGroup'] ?? '',
    );
  }

  // Convert to map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isPresent': isPresent,
      'isNew': isNew,
      'parentContact': parentContact,
      'medicalNotes': medicalNotes,
      'ageGroup': ageGroup,
    };
  }
}