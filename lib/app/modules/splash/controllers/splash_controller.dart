import 'dart:async';

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

		if (!isClosed) {
			Get.offNamed(AppRoutes.onboarding);
		}
	}
}
