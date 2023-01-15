import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:presence2/app/routes/app_pages.dart';

class NewPasswordController extends GetxController {
  TextEditingController newPassC = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;

  void newPassword() async {
    // Jika Inputan tidak Kosong
    if (newPassC.text.isNotEmpty) {
      // Jika Inputan tidak berisi 'password'
      if (newPassC.text != "password") {
        try {
          String email = auth.currentUser!.email!;

          // Upadate Password akun ini
          await auth.currentUser!.updatePassword(newPassC.text);
          // Sign Out
          await auth.signOut();

          // Sign In
          await auth.signInWithEmailAndPassword(
            email: email,
            password: newPassC.text,
          );

          Get.offAllNamed(Routes.HOME);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
            Get.snackbar("Terjadi Kesalahan",
                "Password terlalu lemah, setidaknya 6 karakter");
          }
        } catch (e) {
          Get.snackbar("Terjadi Kesalahan",
              "Tidak dapat membuat password baru. Hubungi admin / customer service");
        }
      } else {
        Get.snackbar("Terjadi Kesalahan",
            "Password baru harus diubah, Jangan 'password' kembali");
      }
    } else {
      Get.snackbar("Terjadi Kesalahan", "Password baru wajib diisi");
    }
  }
}
