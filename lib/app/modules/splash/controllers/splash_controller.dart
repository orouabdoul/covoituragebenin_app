import 'dart:async';

import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
		final prefs = await SharedPreferences.getInstance();
		final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

		if (!hasSeenOnboarding) {
			// Marquer comme vu ICI pendant le splash (prefs déjà chargé, aucun blocage).
			// Ne jamais écrire dans SharedPreferences depuis un tap — cela bloque le
			// thread UI natif sur MIUI/Xiaomi (~26 s) même avec .then().
			prefs.setBool('has_seen_onboarding', true);
			Get.offAllNamed(AppRoutes.onboarding);
			return;
		}

		final uc = UserController.instance;
		final sessionToken = await uc.getSessionToken();

		if (sessionToken.isEmpty || !uc.profileComplete.value) {
			Get.offAllNamed(AppRoutes.register);
			return;
		}

		final isDriver = uc.role.value == 'driver' || uc.role.value == 'conducteur';
		Get.offAllNamed(
			isDriver ? AppRoutes.dashboardDriver : AppRoutes.dashboardPassenger,
		);
	}
}
