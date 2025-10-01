// File: lib/services/hackathons/hackathons_services.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/hackathons/hackathon_model.dart';

class HackathonService {
  final CollectionReference _hackathonsCollection = FirebaseFirestore.instance.collection('hackathons');

  Future<List<Hackathon>> fetchHackathons() async {
    try {
      QuerySnapshot querySnapshot = await _hackathonsCollection.get();
      return querySnapshot.docs.map((doc) => Hackathon.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching hackathons: $e');
      return [];
    }
  }
}