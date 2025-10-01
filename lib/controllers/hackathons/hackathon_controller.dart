// File: lib/controllers/hackathons/hackathon_controller.dart

import 'package:get/get.dart';
import '../../models/hackathons/hackathon_model.dart';
import '../../services/hackathons/hackathons_services.dart';

class HackathonController extends GetxController {
  final HackathonService _service = HackathonService();
  var hackathons = <Hackathon>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchHackathons();
    super.onInit();
  }

  void fetchHackathons() async {
    try {
      isLoading.value = true;
      var fetchedList = await _service.fetchHackathons();

      // ✅ Sorting logic add kiya gaya hai
      fetchedList.sort((a, b) {
        // Live ko sabse upar rakho
        if (a.status == 'Live' && b.status != 'Live') {
          return -1;
        }
        if (a.status != 'Live' && b.status == 'Live') {
          return 1;
        }

        // Finished ko sabse neeche rakho
        if (a.status == 'Finished' && b.status != 'Finished') {
          return 1;
        }
        if (a.status != 'Finished' && b.status == 'Finished') {
          return -1;
        }

        // Baki hackathons ko start date ke hisab se sort karo (naya pehle)
        return b.startDate.compareTo(a.startDate);
      });

      hackathons.value = fetchedList;
    } finally {
      isLoading.value = false;
    }
  }
}