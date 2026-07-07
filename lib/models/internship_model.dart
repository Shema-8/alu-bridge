class InternshipModel {
  final String internshipId;
  final String startupId;
  final String title;
  final String description;
  final List<String> skillsRequired;
  final String location;
  final bool remote;
  final bool paid;
  final DateTime deadline;
  final int positions;
  final DateTime createdAt;

  InternshipModel({
    required this.internshipId,
    required this.startupId,
    required this.title,
    required this.description,
    required this.skillsRequired,
    required this.location,
    required this.remote,
    required this.paid,
    required this.deadline,
    required this.positions,
    required this.createdAt,
  });

  factory InternshipModel.fromMap(String id, Map<String, dynamic> map) {
    return InternshipModel(
      internshipId: id,
      startupId: map['startupId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      skillsRequired: List<String>.from(map['skillsRequired'] ?? []),
      location: map['location'] ?? '',
      remote: map['remote'] ?? false,
      paid: map['paid'] ?? false,
      deadline: DateTime.tryParse(map['deadline'] ?? '') ?? DateTime.now(),
      positions: map['positions'] ?? 1,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// Used to gate the Apply button and to badge a posting as
  /// "Closed" once its deadline has passed, without needing a
  /// separate Firestore field that could drift out of sync.
  bool get isOpen => deadline.isAfter(DateTime.now());

  Map<String, dynamic> toMap() => {
        'startupId': startupId,
        'title': title,
        'description': description,
        'skillsRequired': skillsRequired,
        'location': location,
        'remote': remote,
        'paid': paid,
        'deadline': deadline.toIso8601String(),
        'positions': positions,
        'createdAt': createdAt.toIso8601String(),
      };
}
