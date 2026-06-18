import 'dart:async';

import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
	final RxBool isLogoVisible = false.obs;
	final RxBool isBrandVisible = false.obs;
	final RxBool isContentVisible = false.obs;
	final RxDouble loadingProgress = 0.0.obs;

	@override
	void onReady() {
		super.onReady();
		_startSequence();
	}

	Future<void> _startSequence() async {
		await Future<void>.delayed(const Duration(milliseconds: 150));
		if (isClosed) return;
		isLogoVisible.value = true;

		await Future<void>.delayed(const Duration(milliseconds: 250));
		if (isClosed) return;
		isBrandVisible.value = true;

		await Future<void>.delayed(const Duration(milliseconds: 250));
		if (isClosed) return;
		isContentVisible.value = true;

		const totalDuration = Duration(seconds: 5);
		final ticks = 50;
		for (var index = 1; index <= ticks; index++) {
			await Future<void>.delayed(Duration(milliseconds: totalDuration.inMilliseconds ~/ ticks));
			if (isClosed) return;
			loadingProgress.value = index / ticks;
		}

		if (isClosed) return;
		await _navigateFromSplash();
	}

	Future<void> _navigateFromSplash() async {
		final uc = UserController.instance;
		final sessionToken = await uc.getSessionToken();

		if (sessionToken.isEmpty) {
			Get.offNamed(AppRoutes.onboarding);
			return;
		}

		if (!uc.profileComplete.value) {
			Get.offAllNamed(AppRoutes.roles, arguments: {'skipAuth': true});
			return;
		}

		final isDriver = uc.role.value == 'driver' || uc.role.value == 'conducteur';
		Get.offAllNamed(
			isDriver ? AppRoutes.dashboardDriver : AppRoutes.dashboardPassenger,
		);
	}
}
