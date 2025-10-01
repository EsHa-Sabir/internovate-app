import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/contact/payment_info_model.dart';

class PaymentInfoService {
  Future<PaymentInfoModel?> getPaymentInfo() async {
    final doc = await FirebaseFirestore.instance
        .collection("paymentInfo")
        .doc("mainPayment")
        .get();

    if (doc.exists) {
      return PaymentInfoModel.fromJson(doc.data()!);
    } else {
      return null;
    }
  }
}
