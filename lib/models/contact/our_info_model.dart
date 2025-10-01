class OurInfoModel {
  final String infoId;
  final String email;
  final String phone;
  final String whatsapp;

  OurInfoModel({
    required this.infoId,
    required this.email,
    required this.phone,
    required this.whatsapp,
  });

  /// Convert object -> JSON (Firestore/REST API me save karne ke liye)
  Map<String, dynamic> toJson() {
    return {
      'infoId': infoId,
      'email': email,
      'phone': phone,
      'whatsapp': whatsapp,
    };
  }

  /// Convert JSON -> object (Firestore/REST API se fetch karne ke liye)
  factory OurInfoModel.fromJson(Map<String, dynamic> json) {
    return OurInfoModel(
      infoId: json['infoId'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
    );
  }
}
