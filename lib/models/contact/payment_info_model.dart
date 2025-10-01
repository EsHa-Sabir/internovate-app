class PaymentInfoModel {
  final String id;
  final String jazzCashNumber;
  final String jazzCashHolderName;
  final String easyPaisaNumber;
  final String bankName;
  final String accountTitle;
  final String accountNumber;
  final String amount;

  PaymentInfoModel({
    required this.id,
    required this.jazzCashNumber,
    required this.jazzCashHolderName,
    required this.easyPaisaNumber,
    required this.bankName,
    required this.accountTitle,
    required this.accountNumber,
    required this.amount,
  });

  factory PaymentInfoModel.fromJson(Map<String, dynamic> json) {
    return PaymentInfoModel(
      id: json["id"],
      jazzCashNumber: json['jazzCashNumber'] ?? '',
      jazzCashHolderName: json['jazzCashHolderName'] ?? '',
      easyPaisaNumber: json['easyPaisaNumber'] ?? '',
      bankName: json['bankName'] ?? '',
      accountTitle: json['accountTitle'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      amount: json['amount'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "jazzCashHolderName": jazzCashHolderName,
      "jazzCashNumber": jazzCashNumber,
      "easyPaisaNumber": easyPaisaNumber,
      "bankName": bankName,
      "accountTitle": accountTitle,
      "accountNumber": accountNumber,
      "amount": amount,
    };
  }
}
