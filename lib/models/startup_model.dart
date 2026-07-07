enum VerificationStatus { pending, verified, rejected }

class StartupModel {
  final String startupId; // same as founder's uid
  final String name;
  final String description;
  final String industry;
  final String? logoUrl;
  final String founderName;
  final String contactEmail;
  final VerificationStatus status;
  final DateTime createdAt;

  StartupModel({
    required this.startupId,
    required this.name,
    required this.description,
    required this.industry,
    this.logoUrl,
    required this.founderName,
    required this.contactEmail,
    this.status = VerificationStatus.pending,
    required this.createdAt,
  });

  factory StartupModel.fromMap(String id, Map<String, dynamic> map) {
    return StartupModel(
      startupId: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      industry: map['industry'] ?? '',
      logoUrl: map['logoUrl'],
      founderName: map['founderName'] ?? '',
      contactEmail: map['contactEmail'] ?? '',
      status: VerificationStatus.values.firstWhere(
        (s) => s.name == (map['status'] ?? 'pending'),
        orElse: () => VerificationStatus.pending,
      ),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'industry': industry,
        'logoUrl': logoUrl,
        'founderName': founderName,
        'contactEmail': contactEmail,
        'status': status.name,
      };
}
