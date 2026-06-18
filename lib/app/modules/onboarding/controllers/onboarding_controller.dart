import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/auth_mode.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class OnboardingController extends GetxController {
	final PageController pageController = PageController();
	final RxInt currentPage = 0.obs;

	static const int pagesCount = 4;

	bool get isFirstPage => currentPage.value == 0;

	bool get isLastPage => currentPage.value == pagesCount - 1;

	void onPageChanged(int index) {
		currentPage.value = index;
		update();
	}

	Future<void> nextPage() async {
		if (isLastPage) return;
		await pageController.animateToPage(
			currentPage.value + 1,
			duration: const Duration(milliseconds: 350),
			curve: Curves.easeOutCubic,
		);
	}

	Future<void> previousPage() async {
		if (isFirstPage) return;
		await pageController.animateToPage(
			currentPage.value - 1,
			duration: const Duration(milliseconds: 350),
			curve: Curves.easeOutCubic,
		);
	}

	Future<void> skip() async {
		if (isLastPage) return;
		currentPage.value = pagesCount - 1;
		update();
		pageController.jumpToPage(pagesCount - 1);
	}

	void start() {
		Get.toNamed(
			AppRoutes.register,
			arguments: {'mode': AuthMode.login},
		);
	}

	@override
	void onClose() {
		pageController.dispose();
		super.onClose();
	}
}
