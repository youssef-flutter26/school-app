import 'package:flutter/foundation.dart';

@immutable
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.schoolId,
    this.phone,
    this.schoolName,
    this.kycVerified = false,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final int? schoolId;
  final String? phone;
  final String? schoolName;
  final bool kycVerified;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    // دالة مساعدة لاستخراج النص بأمان سواء كان String أو Map
    String parseString(dynamic value, String defaultValue) {
      if (value == null) return defaultValue;
      if (value is String) return value;
      if (value is Map) {
        return value['name']?.toString() ??
            value['title']?.toString() ??
            value.toString();
      }
      return value.toString();
    }

    // استخراج الـ ID بأمان
    int parseId(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    // استخراج حالة الـ KYC بأمان بأكثر من صيغة ممكنة من الباك إند
    bool parseKycVerified(dynamic jsonMap) {
      if (jsonMap == null || jsonMap is! Map) return false;

      final kycData =
          jsonMap['kyc'] ?? jsonMap['kycStatus'] ?? jsonMap['kycVerified'];

      if (kycData is bool) return kycData;
      if (jsonMap['isKycVerified'] is bool)
        return jsonMap['isKycVerified'] as bool;
      if (jsonMap['isVerified'] is bool) return jsonMap['isVerified'] as bool;

      if (kycData is Map) {
        final status = kycData['status']?.toString().toLowerCase();
        return status == 'verified' || kycData['isVerified'] == true;
      }

      if (kycData is String) {
        final status = kycData.toLowerCase();
        return status == 'verified' || status == 'true';
      }

      return false;
    }

    // التعامل مع حقل الـ school لو راجع كـ Map أو ID
    final schoolData = json['school'];
    int? sId = json['schoolId'] != null ? parseId(json['schoolId']) : null;
    String? sName;

    if (schoolData is Map) {
      sId ??= parseId(schoolData['id']);
      sName = schoolData['name']?.toString();
    } else if (schoolData != null) {
      sName = schoolData.toString();
    }

    return AppUser(
      id: parseId(json['id']),
      // الباك إند يرسل fullName أو name
      name: parseString(json['fullName'] ?? json['name'], 'SchoolRide User'),
      email: parseString(json['email'], ''),
      role: parseString(json['role'], 'parent'),
      schoolId: sId,
      phone: json['phone']?.toString(),
      schoolName: sName,
      kycVerified: parseKycVerified(json),
    );
  }
}
