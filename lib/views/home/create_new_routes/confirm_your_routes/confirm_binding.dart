import 'package:get/get.dart';
import 'confirm_controller.dart';

class EditConfirmRouteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConfirmRouteController>(
          () => ConfirmRouteController(),
      fenix: true,
    );
  }
}