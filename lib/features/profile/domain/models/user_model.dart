import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:more_experts/core/constants/service_package.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String password; // Adding password for login verification
  final ServicePackage package;
  final String status;
  final String? profilePic;
  final UserDocuments documents;
  final DateTime createdAt;
  final String address;
  final String dob;
  final String gender;
  final String? linkedin;
  final String mobile;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.package,
    required this.status,
    this.profilePic,
    required this.documents,
    required this.createdAt,
    required this.address,
    required this.dob,
    required this.gender,
    this.linkedin,
    required this.mobile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return UserModel(
      id: id ?? (json['id'] ?? json['_id'] ?? ''),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      package: _parsePackage(json['package']),
      status: json['status'] ?? 'active',
      profilePic: json['profilePic'] ?? json['profile_pic'],
      documents: UserDocuments.fromJson(json['documents'] ?? {}),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.parse(json['createdAt'].toString()))
          : DateTime.now(),
      address: json['address'] ?? '',
      dob: json['dob'] ?? '',
      gender: json['gender'] ?? '',
      linkedin: json['linkedin'],
      mobile: json['mobile'] ?? '',
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromJson(data, id: doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'package': package.toString().split('.').last,
      'status': status,
      'profilePic': profilePic,
      'documents': documents.toJson(),
      'createdAt': Timestamp.fromDate(createdAt), // Use Timestamp for Firestore
      'address': address,
      'dob': dob,
      'gender': gender,
      'linkedin': linkedin,
      'mobile': mobile,
    };
  }

  static ServicePackage _parsePackage(String? packageStr) {
    switch (packageStr?.toLowerCase()) {
      case 'silver':
        return ServicePackage.silver;
      case 'silver2':
        return ServicePackage.silver2;
      case 'golden':
        return ServicePackage.golden;
      case 'golden2':
        return ServicePackage.golden2;
      case 'premium':
        return ServicePackage.premium;
      case 'premium2':
        return ServicePackage.premium2;
      default:
        return ServicePackage.silver;
    }
  }

  double get updateProgress {
    if (package == ServicePackage.premium2) return 1.0;

    final expiry = _expiryDate;
    if (expiry == null) return 0.0;

    final now = DateTime.now();
    if (now.isAfter(expiry)) return 0.0;

    final totalDuration = expiry.difference(createdAt).inSeconds;
    final remainingDuration = expiry.difference(now).inSeconds;

    if (totalDuration <= 0) return 0.0;
    return (remainingDuration / totalDuration).clamp(0.0, 1.0);
  }

  String get updateStatusText {
    if (package == ServicePackage.premium2) return 'LIFE TIME VALID';

    final expiry = _expiryDate;
    if (expiry == null) return 'EXPIRED';

    final now = DateTime.now();
    if (now.isAfter(expiry)) return 'Updation Expired';

    final remainingDays = expiry.difference(now).inDays;
    return 'Expires in $remainingDays days';
  }

  DateTime? get _expiryDate {
    switch (package) {
      case ServicePackage.silver:
      case ServicePackage.silver2:
        return createdAt; // No updates included
      case ServicePackage.golden:
        return DateTime(createdAt.year, createdAt.month + 3, createdAt.day);
      case ServicePackage.golden2:
        return DateTime(createdAt.year, createdAt.month + 6, createdAt.day);
      case ServicePackage.premium:
        return DateTime(createdAt.year + 1, createdAt.month, createdAt.day);
      case ServicePackage.premium2:
        return null; // Lifetime
    }
  }
}

class UserDocuments {
  final String? serviceGuide;
  final String? serviceGuide2;
  final String? serviceGuide3;
  final String? idProof;
  final String? contract;
  final String? coverLetter;

  UserDocuments({
    this.serviceGuide,
    this.serviceGuide2,
    this.serviceGuide3,
    this.idProof,
    this.contract,
    this.coverLetter,
  });

  factory UserDocuments.fromJson(Map<String, dynamic> json) {
    return UserDocuments(
      serviceGuide: json['serviceGuide'],
      serviceGuide2: json['serviceGuide2'] ?? json['serviceGuideBW'],
      serviceGuide3: json['serviceGuide3'] ?? json['serviceGuideHorizontal'],
      idProof: json['idProof'],
      contract: json['contract'],
      coverLetter: json['coverLetter'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceGuide': serviceGuide,
      'serviceGuide2': serviceGuide2,
      'serviceGuide3': serviceGuide3,
      'idProof': idProof,
      'contract': contract,
      'coverLetter': coverLetter,
    };
  }
}
