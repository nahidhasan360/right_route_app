import 'package:get/get.dart';
import 'package:right_routes/controllers/route_creation/confirm_controller.dart';

class EditConfirmRouteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConfirmRouteController>(
          () => ConfirmRouteController(),
      fenix: true,
    );
  }
}