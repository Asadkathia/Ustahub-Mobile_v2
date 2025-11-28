class DocumentResponse {
  final List<DocumentModel> documents;

  DocumentResponse({required this.documents});

  factory DocumentResponse.fromJson(Map<String, dynamic> json) {
    return DocumentResponse(
      documents:
          (json['documents'] as List<dynamic>?)
              ?.map(
                (item) => DocumentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'documents': documents.map((doc) => doc.toJson()).toList()};
  }
}

class DocumentModel {
  final String id;
  final String providerId;
  final String documentType;
  final String documentImage;
  final int isVerified;
  final String? verifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  DocumentModel({
    required this.id,
    required this.providerId,
    required this.documentType,
    required this.documentImage,
    required this.isVerified,
    this.verifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return DocumentModel(
      id: json['id']?.toString() ?? '',
      providerId: json['provider_id']?.toString() ?? '',
      documentType: json['document_type']?.toString() ?? '',
      documentImage: json['document_image']?.toString() ?? '',
      isVerified: int.tryParse(json['is_verified']?.toString() ?? '0') ?? 0,
      verifiedAt: json['verified_at']?.toString(),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'document_type': documentType,
      'document_image': documentImage,
      'is_verified': isVerified,
      'verified_at': verifiedAt,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  bool get isDocumentVerified => isVerified == 1;

  String get formattedDocumentType {
    switch (documentType.toUpperCase()) {
      case 'NIC':
        return 'National ID';
      case 'PASSPORT':
        return 'Passport';
      case 'TRADE_LICENSE':
        return 'Trade License';
      case 'BUSINESS_PROOF':
        return 'Business Proof';
      default:
        return documentType;
    }
  }

  String get statusText => isDocumentVerified ? 'Verified' : 'Pending';

  // Copy with method for immutable updates
  DocumentModel copyWith({
    String? id,
    String? providerId,
    String? documentType,
    String? documentImage,
    int? isVerified,
    String? verifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      documentType: documentType ?? this.documentType,
      documentImage: documentImage ?? this.documentImage,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
