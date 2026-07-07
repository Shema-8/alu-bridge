enum ApplicationStatus { pending, reviewed, interview, accepted, rejected }

class ApplicationModel {
  final String applicationId;
  final String studentId;
  final String internshipId;
  final String coverLetter;
  final ApplicationStatus status;
  final DateTime submittedAt;

  ApplicationModel({
    required this.applicationId,
    required this.studentId,
    required this.internshipId,
    required this.coverLetter,
    this.status = ApplicationStatus.pending,
    required this.submittedAt,
  });

  factory ApplicationModel.fromMap(String id, Map<String, dynamic> map) {
    return ApplicationModel(
      applicationId: id,
      studentId: map['studentId'] ?? '',
      internshipId: map['internshipId'] ?? '',
      coverLetter: map['coverLetter'] ?? '',
      status: ApplicationStatus.values.firstWhere(
        (s) => s.name == (map['status'] ?? 'pending'),
        orElse: () => ApplicationStatus.pending,
      ),
      submittedAt:
          DateTime.tryParse(map['submittedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'studentId': studentId,
        'internshipId': internshipId,
        'coverLetter': coverLetter,
        'status': status.name,
        'submittedAt': submittedAt.toIso8601String(),
      };
}
