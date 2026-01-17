import 'dart:convert';

UserKycInfo userKycInfoFromJson(String str) => UserKycInfo.fromJson(json.decode(str) as Map<String, dynamic>);

String userKycInfoToJson(UserKycInfo userKycInfo) => json.encode(userKycInfo.toJson());

class UserKycInfo {

    UserKycInfo({
        this.id,
        this.subjectType,
        this.subjectId,
        this.documentType,
        this.documentNumber,
        this.documentImageUrl,
        this.selfieImageUrl,
        this.fullName,
        this.dateOfBirth,
        this.expiryDate,
        this.issueDate,
        this.nationality,
        this.state,
        this.address,
        this.companyName,
        this.registrationNumber,
        this.status,
        this.verificationNotes,
        this.rejectionReason,
        this.verifiedBy,
        this.verifiedAt,
        this.expiresAt,
        this.submittedAt,
        this.updatedAt,
    });

    factory UserKycInfo.fromJson(Map<String, dynamic> json) => UserKycInfo(
        id: json['id'] as int,
        subjectType: json['subjectType'] as String,
        subjectId: json['subjectId'] as int,
        documentType: json['documentType'] as String,
        documentNumber: json['documentNumber'] as String,
        documentImageUrl: json['documentImageUrl'] as String,
        selfieImageUrl: json['selfieImageUrl'] as String,
        fullName: json['fullName'] as String,
        dateOfBirth: json['dateOfBirth'] == null ? null : DateTime.parse(json['dateOfBirth']as String),
        expiryDate: json['expiryDate'] == null ? null : DateTime.parse(json['expiryDate'] as String),
        issueDate: json['issueDate'] == null ? null : DateTime.parse(json['issueDate'] as String),
        nationality: json['nationality'] as String,
        state: json['state'] as String,
        address: json['address'] as String,
        companyName: json['companyName'] as String,
        registrationNumber: json['registrationNumber'] as String,
        status: json['status'] as String,
        verificationNotes: json['verificationNotes'] as String,
        rejectionReason: json['rejectionReason'] as String,
        verifiedBy: json['verifiedBy'] as int,
        verifiedAt: json['verifiedAt'] == null ? null : DateTime.parse(json['verifiedAt']as String),
        expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt']as String),
        submittedAt: json['submittedAt'] == null ? null : DateTime.parse(json['submittedAt']as String),
        updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String),
    );
    final int? id;
    final String? subjectType;
    final int? subjectId;
    final String? documentType;
    final String? documentNumber;
    final String? documentImageUrl;
    final String? selfieImageUrl;
    final String? fullName;
    final DateTime? dateOfBirth;
    final DateTime? expiryDate;
    final DateTime? issueDate;
    final String? nationality;
    final String? state;
    final String? address;
    final String? companyName;
    final String? registrationNumber;
    final String? status;
    final String? verificationNotes;
    final String? rejectionReason;
    final int? verifiedBy;
    final DateTime? verifiedAt;
    final DateTime? expiresAt;
    final DateTime? submittedAt;
    final DateTime? updatedAt;

    Map<String, dynamic> toJson() => {
        'id': id,
        'subjectType': subjectType,
        'subjectId': subjectId,
        'documentType': documentType,
        'documentNumber': documentNumber,
        'documentImageUrl': documentImageUrl,
        'selfieImageUrl': selfieImageUrl,
        'fullName': fullName,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'expiryDate': expiryDate?.toIso8601String(),
        'issueDate': issueDate?.toIso8601String(),
        'nationality': nationality,
        'state': state,
        'address': address,
        'companyName': companyName,
        'registrationNumber': registrationNumber,
        'status': status,
        'verificationNotes': verificationNotes,
        'rejectionReason': rejectionReason,
        'verifiedBy': verifiedBy,
        'verifiedAt': verifiedAt?.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'submittedAt': submittedAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
    };
}
