import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/banner/banner_model.dart';

class BannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Fetch all banners
  Future<List<BannerModel>> fetchBanners() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection("banners")
          .orderBy("createdAt", descending: true) // latest first
          .get();
     // return list of banner
      return snapshot.docs
          .map((doc) => BannerModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("❌ Error fetching banners: $e");
      rethrow;
    }
  }


}
