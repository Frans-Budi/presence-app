import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPegawaiController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLoadingAddPegawai = false.obs;
  TextEditingController nameC = TextEditingController();
  TextEditingController nipC = TextEditingController();
  TextEditingController emailC = TextEditingController();
  TextEditingController jobC = TextEditingController();
  TextEditingController passAdminC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> prosesAddPegawai() async {
    if (passAdminC.text.isNotEmpty) {
      try {
        String emailAdmin = auth.currentUser!.email!;

        UserCredential credentialAdmin = await auth.signInWithEmailAndPassword(
          email: emailAdmin,
          password: passAdminC.text,
        );

        // Mendaftarkan Email Dan Password Baru
        UserCredential credentialPegawai =
            await auth.createUserWithEmailAndPassword(
          email: emailC.text,
          password: "password",
        );

        if (credentialPegawai.user != null) {
          String? uid = credentialPegawai.user?.uid;

          // Menambahkan pegawai ke collection
          firestore.collection("pegawai").doc(uid).set({
            "nip": nipC.text,
            "name": nameC.text,
            "email": emailC.text,
            "job": jobC.text,
            "uid": uid,
            "role": "pegawai",
            "createdAt": DateTime.now().toIso8601String(),
          });

          // Kirim Email Verifikasi
          await credentialPegawai.user!.sendEmailVerification();
          // Sign Out
          await auth.signOut();
          // Relogin
          UserCredential credentialAdmin =
              await auth.signInWithEmailAndPassword(
            email: emailAdmin,
            password: passAdminC.text,
          );

          Get.back(); // Tutup Dialog
          Get.back(); // Back to Home
          Get.snackbar("Berhasil", "Berhasil menambahkan pegawai");
        }

        print(credentialPegawai);
      } on FirebaseAuthException catch (e) {
        isLoadingAddPegawai.value = false;
        if (e.code == 'weak-password') {
          Get.snackbar(
              "Terjadi Kesalahan", "Password yang digunakan terlalu singkat");
        } else if (e.code == 'email-already-in-use') {
          Get.snackbar("Terjadi Kesalahan",
              "Pegawai sudah ada. Kamu tidak dapat menambahkan pegawai dengan email ini!");
        } else if (e.code == 'wrong-password') {
          Get.snackbar(
              "Terjadi kesalahan", "Admin tidak dapat login. Password Salah!");
        } else {
          Get.snackbar("Terjadi Kesalahan", "${e.code}");
        }
      } catch (e) {
        isLoadingAddPegawai.value = false;
        Get.snackbar("Terjadi Kesalahan", "Tidak dapat menbambahkan pegawai");
      }
    } else {
      isLoading.value = false;
      Get.snackbar(
          "Terjadi Kesalahn", "Password wajib diisi untuk keperluan validasi");
    }
  }

  Future<void> addPegawai() async {
    if (nameC.text.isNotEmpty &&
        nipC.text.isNotEmpty &&
        emailC.text.isNotEmpty &&
        jobC.text.isNotEmpty) {
      isLoading.value = true;

      Get.defaultDialog(
        title: "Validasi Admin",
        content: Column(
          children: [
            const Text("Masukkan Password untuk validasi Admin"),
            const SizedBox(height: 10),
            TextField(
              controller: passAdminC,
              autocorrect: false,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Password",
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              isLoading.value = false;
              Get.back();
            },
            child: const Text("CANCEL"),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: () async {
                if (isLoadingAddPegawai.isFalse) {
                  isLoadingAddPegawai.value = true;
                  await prosesAddPegawai();
                }
                isLoadingAddPegawai.value = false;
              },
              child: Text(
                  isLoadingAddPegawai.isFalse ? "ADD PEGAWAI" : "LOADING..."),
            ),
          ),
        ],
      );
    } else {
      Get.snackbar(
          "Terjadi Kesalahan", "NIP, Nama, Job, dan Email Harus diIsi.");
    }
  }
}
