import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intern_management_app/models/contact/our_info_model.dart';

class OurInfoService{

  Future<OurInfoModel?> getOurInfo() async {
    final doc = await FirebaseFirestore.instance
        .collection("ourInformation")
        .doc("mainInfo") // yeh tumhara fixed document ID hoga
        .get();

    if (doc.exists) {
      return OurInfoModel.fromJson(doc.data()!);
    } else {
      return null;
    }
  }


}