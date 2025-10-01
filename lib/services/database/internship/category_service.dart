import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/internship/internship_category_model.dart';

class InternshipCategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all internship categories from Firestore and convert to model list
  Future<List<InternshipCategoryModel>> fetchAllInternshipCategory() async {
    final snapshot = await _firestore
        .collection("internship_categories")
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return InternshipCategoryModel.fromJson(doc.data());
    }).toList();
  }

}
