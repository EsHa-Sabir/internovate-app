import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intern_management_app/models/internship/internship_model.dart';

class InternshipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch internships based on categoryId
  Future<List<InternshipModel>> fetchInternshipsByCategory(String categoryId) async {
    final snapshot = await _firestore
        .collection("internships")
        .where("categoryId", isEqualTo: categoryId)
        .orderBy("createdAt", descending: true)
        .get();


    return snapshot.docs
        .map((doc) => InternshipModel.fromJson(doc.data()))
        .toList();
  }
}
