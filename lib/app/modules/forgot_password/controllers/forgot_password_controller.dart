import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController emailC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  void sendEmail() async {
    if (emailC.text.isNotEmpty) {
      try {
        isLoading.value = true;
        await auth.sendPasswordResetEmail(email: emailC.text);
        Get.snackbar("Berhasil",
            "Kami telah mengirimkan email reset password. Periksa email kamu");
        Get.back();
      } catch (e) {
        Get.snackbar(
            "Terjadi Kesalahan", "Tidak dapat mengirim email reset password");
      } finally {
        isLoading.value = false;
      }
    }
  }
}
