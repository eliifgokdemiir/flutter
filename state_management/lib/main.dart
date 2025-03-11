import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:state_management/firebase_options.dart';
import 'package:state_management/ui/view/login.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  // Flutter engine'i başlat
  WidgetsFlutterBinding.ensureInitialized();
  print("Flutter engine başlatıldı");

  // Image Picker ayarları
  try {
    ImagePickerPlatform imagePickerImplementation = ImagePickerAndroid();
    ImagePickerPlatform.instance = imagePickerImplementation;
    print("Image Picker başlatıldı");
  } catch (e) {
    print("Image Picker başlatma hatası: $e");
  }

  // Firebase'i başlat
  try {
    print("Firebase başlatılıyor...");
    final options = DefaultFirebaseOptions.currentPlatform;
    print("Firebase options: $options");

    // Firebase başlatma işlemi için timeout
    bool firebaseInitialized = false;
    Timer? timeoutTimer;

    timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (!firebaseInitialized) {
        print("Firebase başlatma işlemi zaman aşımına uğradı");
        runApp(const MyApp()); // Firebase olmadan uygulamayı başlat
      }
    });

    await Firebase.initializeApp(
      options: options,
    );

    firebaseInitialized = true;
    timeoutTimer.cancel();

    print("Firebase başarıyla başlatıldı");

    // Firebase Auth durumunu kontrol et
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('Kullanıcı oturumu kapalı');
      } else {
        print('Kullanıcı oturum açtı: ${user.email} (${user.uid})');
      }
    });

    // Mevcut kullanıcıyı kontrol et
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      print(
          "Mevcut oturum açmış kullanıcı: ${currentUser.email} (${currentUser.uid})");

      // Uygulama başlangıcında oturumu kapat (temiz başlangıç için)
      try {
        await FirebaseAuth.instance.signOut();
        print("Uygulama başlangıcında kullanıcı oturumu kapatıldı");
      } catch (signOutError) {
        print("Oturum kapatma hatası: $signOutError");
      }
    } else {
      print("Oturum açmış kullanıcı yok");
    }

    // Firebase Auth yapılandırmasını kontrol et
    print("Firebase Auth yapılandırması kontrol ediliyor...");
    try {
      await FirebaseAuth.instance
          .fetchSignInMethodsForEmail("test@example.com");
      print("Firebase Auth yapılandırması doğru çalışıyor");
    } catch (authError) {
      print("Firebase Auth yapılandırması hatası: $authError");
      if (authError is FirebaseAuthException) {
        print("Firebase Auth hata kodu: ${authError.code}");
        print("Firebase Auth hata mesajı: ${authError.message}");
      }
    }
  } catch (e) {
    print("Firebase başlatma hatası: $e");
    if (e is FirebaseException) {
      print("Firebase hata kodu: ${e.code}");
      print("Firebase hata mesajı: ${e.message}");
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Login(),
    );
  }
}
