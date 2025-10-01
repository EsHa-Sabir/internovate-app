import 'package:get/get.dart';
import '../../models/banner/banner_model.dart';
import '../../services/database/banner/banner_service.dart';

class BannerController extends GetxController {
  final BannerService _bannerService = BannerService();

  var banners = <BannerModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  Future<void> fetchBanners() async {
    try {
      isLoading.value = true;
      banners.value = await _bannerService.fetchBanners();
    } catch (e) {
      print("❌ Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
