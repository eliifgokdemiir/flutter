import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:state_management/ui/view/home.dart';
import 'package:state_management/ui/view/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print("Giriş işlemi başlatılıyor: ${_emailController.text}");

      try {
        // Firebase Authentication durumunu kontrol et
        final currentUser = FirebaseAuth.instance.currentUser;
        print("Mevcut kullanıcı: ${currentUser?.email ?? 'Yok'}");

        // Eğer mevcut bir kullanıcı oturumu varsa, önce çıkış yap
        if (currentUser != null) {
          print("Mevcut kullanıcı oturumu kapatılıyor...");
          FirebaseAuth.instance.signOut().then((_) {
            print("Kullanıcı oturumu kapatıldı");
            _performLogin(); // Yeni giriş yap
          }).catchError((error) {
            print("Oturum kapatma hatası: $error");
            _performLogin(); // Yine de giriş yapmayı dene
          });
        } else {
          _performLogin(); // Doğrudan giriş yap
        }
      } catch (e) {
        print("Beklenmeyen hata: $e");

        setState(() {
          _isLoading = false;
          _errorMessage = "Beklenmeyen bir hata oluştu: $e";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Beklenmeyen bir hata oluştu: $e")),
        );
      }
    }
  }

  // Giriş işlemi
  void _performLogin() {
    print("Giriş yapılıyor: ${_emailController.text.trim()}");

    // Timeout kontrolü için
    Timer? timeoutTimer;

    try {
      // 30 saniye timeout
      timeoutTimer = Timer(const Duration(seconds: 30), () {
        print("Giriş işlemi zaman aşımına uğradı");
        if (_isLoading) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                "Giriş işlemi zaman aşımına uğradı. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.";
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Giriş işlemi zaman aşımına uğradı")),
          );
        }
      });

      // Firebase Authentication ile giriş yap
      FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      )
          .then((userCredential) {
        // Timeout timer'ı iptal et
        timeoutTimer?.cancel();

        // Giriş başarılı
        print("Giriş başarılı: ${userCredential.user?.email}");
        print("Kullanıcı UID: ${userCredential.user?.uid}");

        // Son giriş tarihini güncelle
        _updateLastLogin(userCredential.user!);

        setState(() {
          _isLoading = false;
        });

        // Başarı mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Giriş başarılı!")),
        );

        // Ana sayfaya yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }).catchError((error) {
        // Timeout timer'ı iptal et
        timeoutTimer?.cancel();

        // Giriş başarısız
        print("Giriş hatası: $error");
        print("Hata türü: ${error.runtimeType}");

        setState(() {
          _isLoading = false;
        });

        // Hata mesajını göster
        String errorMessage = "Giriş başarısız";
        if (error is FirebaseAuthException) {
          print("Firebase Auth Hata Kodu: ${error.code}");
          print("Firebase Auth Hata Mesajı: ${error.message}");

          switch (error.code) {
            case 'user-not-found':
              errorMessage = "Kullanıcı bulunamadı";
              break;
            case 'wrong-password':
              errorMessage = "Yanlış şifre";
              break;
            case 'invalid-email':
              errorMessage = "Geçersiz email formatı";
              break;
            case 'user-disabled':
              errorMessage = "Bu kullanıcı hesabı devre dışı bırakılmış";
              break;
            case 'too-many-requests':
              errorMessage =
                  "Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin";
              break;
            case 'network-request-failed':
              errorMessage = "Ağ bağlantısı hatası";
              break;
            case 'invalid-credential':
              errorMessage = "Geçersiz kimlik bilgileri";
              break;
            default:
              errorMessage = "Giriş başarısız: ${error.message}";
          }
        } else {
          errorMessage = "Giriş başarısız: $error";
        }

        setState(() {
          _errorMessage = errorMessage;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }, test: (error) => true); // Tüm hataları yakala

      // Alternatif yaklaşım: Auth state değişikliklerini dinle
      // Bu, Firebase Authentication işlemi başarılı olduğunda tetiklenecek
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user != null && _isLoading) {
          print(
              "Auth state değişikliği: Kullanıcı oturum açtı: ${user.email} (${user.uid})");

          // Timeout timer'ı iptal et
          timeoutTimer?.cancel();

          // Son giriş tarihini güncelle
          _updateLastLogin(user);

          setState(() {
            _isLoading = false;
          });

          // Başarı mesajı göster
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Giriş başarılı!")),
          );

          // Ana sayfaya yönlendir
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        }
      });
    } catch (e) {
      // Timeout timer'ı iptal et
      timeoutTimer?.cancel();

      print("Beklenmeyen giriş hatası: $e");
      print("Hata türü: ${e.runtimeType}");

      setState(() {
        _isLoading = false;
        _errorMessage = "Beklenmeyen bir hata oluştu: $e";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Beklenmeyen bir hata oluştu: $e")),
      );
    }
  }

  // Son giriş tarihini güncelle
  Future<void> _updateLastLogin(User user) async {
    try {
      // Firestore'da kullanıcı belgesini kontrol et
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // Kullanıcı belgesi varsa, son giriş tarihini güncelle
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'lastLogin': DateTime.now().toString(),
        });
      } else {
        // Kullanıcı belgesi yoksa, yeni bir belge oluştur
        String name = user.displayName ?? user.email!.split('@')[0];

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name,
          'email': user.email,
          'joinDate': DateTime.now().toString(),
          'lastLogin': DateTime.now().toString(),
          'createdAt': DateTime.now(),
        });
      }

      print("Son giriş tarihi güncellendi");
    } catch (e) {
      print("Son giriş tarihini güncelleme hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/logo/flexy-logo.png',
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Welcome Text
                  const Text(
                    'Hoş Geldiniz',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Lütfen hesabınıza giriş yapın',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Error Message (if any)
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Email adresinizi girin',
                      prefixIcon: const Icon(Icons.email, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen email adresinizi girin';
                      }
                      // Email formatı kontrolü
                      final emailRegex =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Geçerli bir email adresi girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      hintText: 'Şifrenizi girin',
                      prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen şifrenizi girin';
                      }
                      if (value.length < 6) {
                        return 'Şifre en az 6 karakter olmalıdır';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Remember Me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: Colors.blue,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value!;
                              });
                            },
                          ),
                          const Text('Beni Hatırla'),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          // Forgot password logic
                        },
                        child: const Text(
                          'Şifremi Unuttum',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.blue.withOpacity(0.6),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            'Giriş Yap',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Register Option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Hesabınız yok mu?'),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Register()),
                          );
                        },
                        child: const Text(
                          'Kayıt Ol',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
