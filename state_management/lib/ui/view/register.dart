import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:state_management/ui/view/login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print("Kayıt işlemi başlatılıyor: ${_emailController.text}");

      try {
        // Firebase Authentication durumunu kontrol et
        final currentUser = FirebaseAuth.instance.currentUser;
        print("Mevcut kullanıcı: ${currentUser?.email ?? 'Yok'}");

        // Eğer mevcut bir kullanıcı oturumu varsa, önce çıkış yap
        if (currentUser != null) {
          print("Mevcut kullanıcı oturumu kapatılıyor...");
          FirebaseAuth.instance.signOut().then((_) {
            print("Kullanıcı oturumu kapatıldı");
            _createNewUser(); // Yeni kullanıcı oluştur
          }).catchError((error) {
            print("Oturum kapatma hatası: $error");
            _createNewUser(); // Yine de yeni kullanıcı oluşturmayı dene
          });
        } else {
          _createNewUser(); // Doğrudan yeni kullanıcı oluştur
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

  // Yeni kullanıcı oluşturma işlemi
  void _createNewUser() {
    print("Yeni kullanıcı oluşturuluyor: ${_emailController.text.trim()}");

    // Timeout kontrolü için
    Timer? timeoutTimer;

    try {
      // 30 saniye timeout
      timeoutTimer = Timer(const Duration(seconds: 30), () {
        print("Kayıt işlemi zaman aşımına uğradı");
        if (_isLoading) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                "Kayıt işlemi zaman aşımına uğradı. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.";
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Kayıt işlemi zaman aşımına uğradı")),
          );
        }
      });

      FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      )
          .then((userCredential) {
        // Timeout timer'ı iptal et
        timeoutTimer?.cancel();

        // Kayıt başarılı
        print("Kayıt başarılı: ${userCredential.user?.email}");
        print("Kullanıcı UID: ${userCredential.user?.uid}");

        setState(() {
          _isLoading = false;
        });

        // Başarı mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Kayıt başarılı! Giriş yapabilirsiniz.")),
        );

        // Giriş sayfasına yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }).catchError((error) {
        // Timeout timer'ı iptal et
        timeoutTimer?.cancel();

        // Kayıt başarısız
        print("Kayıt hatası: $error");
        print("Hata türü: ${error.runtimeType}");

        setState(() {
          _isLoading = false;
        });

        // Hata mesajını göster
        String errorMessage = "Kayıt başarısız";
        if (error is FirebaseAuthException) {
          print("Firebase Auth Hata Kodu: ${error.code}");
          print("Firebase Auth Hata Mesajı: ${error.message}");

          switch (error.code) {
            case 'email-already-in-use':
              errorMessage = "Bu email adresi zaten kullanımda";
              break;
            case 'invalid-email':
              errorMessage = "Geçersiz email formatı";
              break;
            case 'weak-password':
              errorMessage = "Şifre çok zayıf";
              break;
            case 'operation-not-allowed':
              errorMessage = "Email/şifre girişi etkin değil";
              break;
            case 'network-request-failed':
              errorMessage = "Ağ bağlantısı hatası";
              break;
            case 'invalid-credential':
              errorMessage = "Geçersiz kimlik bilgileri";
              break;
            default:
              errorMessage = "Kayıt başarısız: ${error.message}";
          }
        } else {
          errorMessage = "Kayıt başarısız: $error";
        }

        setState(() {
          _errorMessage = errorMessage;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      });
    } catch (e) {
      // Timeout timer'ı iptal et
      timeoutTimer?.cancel();

      print("Beklenmeyen kayıt hatası: $e");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
      ),
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
                    'Hesap Oluştur',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Lütfen bilgilerinizi girin',
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
                  const SizedBox(height: 20),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Şifreyi Onayla',
                      hintText: 'Şifrenizi tekrar girin',
                      prefixIcon:
                          const Icon(Icons.lock_outline, color: Colors.blue),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
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
                        return 'Lütfen şifrenizi tekrar girin';
                      }
                      if (value != _passwordController.text) {
                        return 'Şifreler eşleşmiyor';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Register Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
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
                            'Kayıt Ol',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Login Option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Zaten hesabınız var mı?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Login()),
                          );
                        },
                        child: const Text(
                          'Giriş Yap',
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
