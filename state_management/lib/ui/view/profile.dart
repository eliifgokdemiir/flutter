import 'package:flutter/material.dart';
import 'package:state_management/ui/view/dashboard.dart';
import 'package:state_management/ui/view/home.dart';
import 'package:state_management/ui/view/navbar_menu.dart';
import 'package:state_management/ui/view/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _surnameController;

  String _userName = '';
  String _userEmail = '';
  String _joinDate = '';
  String _lastLogin = '';
  bool _isLoading = true;
  String _userSurname = '';

  // Firebase kullanıcısı
  User? _currentUser;

  // Firestore referansı
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    // Controller'ları önce boş değerlerle başlat
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    // Verileri yükle
    _loadUserData();
  }

  // Kullanıcı verilerini yükle
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mevcut kullanıcıyı al
      _currentUser = FirebaseAuth.instance.currentUser;
      print("Mevcut kullanıcı: ${_currentUser?.uid}");

      if (_currentUser != null) {
        // Email bilgisini doğrudan Firebase Auth'dan al
        _userEmail = _currentUser!.email ?? '';
        print("Kullanıcı email: $_userEmail");

        try {
          // Doğrudan kullanıcının UID'si ile belgeyi çekmeyi dene
          print(
              "Kullanıcı belgesini UID ile çekme deneniyor: ${_currentUser!.uid}");
          DocumentSnapshot userDoc =
              await _firestore.collection('users').doc(_currentUser!.uid).get();
          print("Kullanıcı belgesi var mı: ${userDoc.exists}");

          if (userDoc.exists) {
            // Kullanıcı belgesi bulundu
            print("Kullanıcı belgesi bulundu");
            Map<String, dynamic> userData =
                userDoc.data() as Map<String, dynamic>;
            print("Firestore verisi: $userData");

            setState(() {
              _userName = userData['name'] ?? 'İsimsiz';
              _userSurname = userData['surname'] ?? 'Kullanıcı';
              _joinDate = userData['joinDate'] ?? 'Bilinmiyor';

              // lastLogin işleme
              if (userData['lastLogin'] != null) {
                if (userData['lastLogin'] is Timestamp) {
                  Timestamp lastLoginTimestamp =
                      userData['lastLogin'] as Timestamp;
                  DateTime lastLoginDateTime = lastLoginTimestamp.toDate();
                  _lastLogin =
                      "${lastLoginDateTime.day}.${lastLoginDateTime.month}.${lastLoginDateTime.year} ${lastLoginDateTime.hour}:${lastLoginDateTime.minute}";
                } else {
                  _lastLogin = userData['lastLogin'].toString();
                }
              } else {
                _lastLogin = 'Bilinmiyor';
              }
            });

            // Controller'ları güncelle
            _nameController.text = _userName;
            _surnameController.text = _userSurname;
            _emailController.text = _userEmail;
          } else {
            // Kullanıcı belgesi bulunamadı, yeni oluştur
            print("Kullanıcı belgesi bulunamadı, yeni oluşturuluyor");
            await _createUserInFirestore();

            // Kullanıcı oluşturulduktan sonra verileri tekrar yükle
            DocumentSnapshot newUserDoc = await _firestore
                .collection('users')
                .doc(_currentUser!.uid)
                .get();

            if (newUserDoc.exists) {
              print("Yeni oluşturulan kullanıcı belgesi bulundu");
              Map<String, dynamic> userData =
                  newUserDoc.data() as Map<String, dynamic>;

              setState(() {
                _userName = userData['name'] ?? 'İsimsiz';
                _userSurname = userData['surname'] ?? 'Kullanıcı';
                _joinDate = userData['joinDate'] ?? 'Bilinmiyor';

                if (userData['lastLogin'] != null) {
                  if (userData['lastLogin'] is Timestamp) {
                    Timestamp lastLoginTimestamp =
                        userData['lastLogin'] as Timestamp;
                    DateTime lastLoginDateTime = lastLoginTimestamp.toDate();
                    _lastLogin =
                        "${lastLoginDateTime.day}.${lastLoginDateTime.month}.${lastLoginDateTime.year} ${lastLoginDateTime.hour}:${lastLoginDateTime.minute}";
                  } else {
                    _lastLogin = userData['lastLogin'].toString();
                  }
                } else {
                  _lastLogin = 'Bilinmiyor';
                }
              });

              // Controller'ları güncelle
              _nameController.text = _userName;
              _surnameController.text = _userSurname;
              _emailController.text = _userEmail;
            } else {
              print("Yeni kullanıcı belgesi oluşturulamadı");
              // Varsayılan değerleri kullan
              setState(() {
                _userName = 'İsimsiz';
                _userSurname = 'Kullanıcı';
                _joinDate = 'Bilinmiyor';
                _lastLogin = 'Bilinmiyor';
              });

              // Controller'ları güncelle
              _nameController.text = _userName;
              _surnameController.text = _userSurname;
              _emailController.text = _userEmail;
            }
          }
        } catch (e) {
          print("Firestore veri çekme hatası: $e");
          // Hata durumunda varsayılan değerleri kullan
          setState(() {
            _userName = 'İsimsiz';
            _userSurname = 'Kullanıcı';
            _joinDate = 'Bilinmiyor';
            _lastLogin = 'Bilinmiyor';
          });

          // Controller'ları güncelle
          _nameController.text = _userName;
          _surnameController.text = _userSurname;
          _emailController.text = _userEmail;
        }
      } else {
        // Kullanıcı oturum açmamışsa, giriş sayfasına yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    } catch (e) {
      print("Kullanıcı verisi yükleme hatası: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Kullanıcıyı Firestore'a ekle
  Future<void> _createUserInFirestore() async {
    if (_currentUser != null) {
      try {
        print("Yeni kullanıcı oluşturuluyor: ${_currentUser!.uid}");

        // Email'den isim ve soyisim çıkarma (örnek bir yaklaşım)
        String emailName = _currentUser!.email!.split('@')[0];
        String name = emailName;
        String surname = '';

        // Eğer email adında nokta varsa, noktadan öncesini isim, sonrasını soyisim olarak kullan
        if (emailName.contains('.')) {
          List<String> nameParts = emailName.split('.');
          name = nameParts[0];
          if (nameParts.length > 1) {
            surname = nameParts[1];
          }
        }

        // Değişkenleri güncelle
        _userName = name;
        _userSurname = surname;

        // Şu anki tarihi al
        String currentDate =
            "${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}";

        // Firestore'a kullanıcı bilgilerini kaydet
        Map<String, dynamic> userData = {
          'name': name,
          'surname': surname,
          'email': _userEmail,
          'joinDate': currentDate,
          'lastLogin': DateTime.now(),
          'createdAt': DateTime.now(),
        };

        print("Kaydedilecek kullanıcı verisi: $userData");

        await _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .set(userData);
        print("Kullanıcı Firestore'a eklendi");

        // Controller'ları güncelle
        _nameController.text = _userName;
        _surnameController.text = _userSurname;
        _emailController.text = _userEmail;
      } catch (e) {
        print("Firestore'a kullanıcı ekleme hatası: $e");
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateProfile() async {
    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 127, 168, 214),
        title: const Text(
          'Profili Düzenle',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ad',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _surnameController,
                decoration: const InputDecoration(
                  labelText: 'Soyad',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                enabled: false, // Email değiştirilemez
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Yeni Şifre (Boş bırakırsanız değişmez)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'name': _nameController.text,
                'surname': _surnameController.text,
                'email': _emailController.text,
                'password': _passwordController.text,
              });
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _userName = result['name'];
        _userSurname = result['surname'];
        _userEmail = result['email'];
      });

      // Firestore'daki kullanıcı bilgilerini güncelle
      if (_currentUser != null) {
        try {
          print("Profil güncelleniyor: ${_currentUser!.uid}");
          print("Yeni değerler - Ad: $_userName, Soyad: $_userSurname");

          Map<String, dynamic> updateData = {
            'name': _userName,
            'surname': _userSurname,
            'updatedAt': DateTime.now(),
          };

          await _firestore
              .collection('users')
              .doc(_currentUser!.uid)
              .update(updateData);
          print("Profil Firestore'da güncellendi");

          // Şifre değişikliği varsa
          if (result['password'] != null && result['password'].isNotEmpty) {
            await _currentUser!.updatePassword(result['password']);
            print("Şifre güncellendi");
          }

          // Başarı mesajı göster
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil başarıyla güncellendi')),
          );
        } catch (e) {
          print("Profil güncelleme hatası: $e");

          // Hata mesajı göster
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profil güncellenirken hata oluştu: $e')),
          );
        }
      }
    }
  }

  // Çıkış yap
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } catch (e) {
      print("Çıkış yapma hatası: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Çıkış yapılırken hata oluştu: $e')),
      );
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const NavbarMenu(),
      appBar: AppBar(
        backgroundColor: Colors.white12,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo/flexy-logo.png',
              width: 100,
              height: 50,
            ),
          ],
        ),
        centerTitle: true, //appbarın başlığı ortalaması için
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
            tooltip: 'Yenile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 25),
                          _buildInfoRow('Ad', _userName),
                          const Divider(height: 30),
                          _buildInfoRow('Soyad', _userSurname),
                          const Divider(height: 30),
                          _buildInfoRow('E-posta', _userEmail),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.edit,
                                  size: 20, color: Colors.white),
                              label: const Text('Profili Düzenle',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[800],
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _updateProfile,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailItem('Üyelik Tarihi', _joinDate),
                          const SizedBox(height: 15),
                          _buildDetailItem('Son Giriş', _lastLogin),
                          const SizedBox(height: 15),
                          _buildDetailItem(
                              'Kullanıcı ID', _currentUser?.uid ?? ''),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Home()));
              },
              icon: Icon(Icons.home, color: Colors.blue[800], size: 28),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Dashboard()));
              },
              icon: Icon(Icons.analytics_outlined,
                  color: Colors.blue[800], size: 28),
            ),
            IconButton(
              onPressed: () {
                // Zaten profil sayfasındayız
              },
              icon: Icon(Icons.person, color: Colors.blue[800], size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.blue[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.blue[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
