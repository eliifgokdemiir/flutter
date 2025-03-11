import 'package:flutter/material.dart';
import 'package:state_management/ui/view/dashboard.dart';
import 'package:state_management/ui/view/home.dart';
import 'package:state_management/ui/view/navbar_menu.dart';
import 'package:state_management/ui/view/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:state_management/ui/view/login.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _darkMode = false;
  bool _notifications = true;
  String _selectedLanguage = 'Türkçe';
  final List<String> _languages = ['Türkçe', 'English', 'Español', 'Deutsch'];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.blue),
                cursorColor: Colors.blue,
                decoration: InputDecoration(
                  hintText: 'Ara...',
                  hintStyle: TextStyle(color: Colors.blue.withOpacity(0.7)),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: Colors.blue),
                    onPressed: _toggleSearch,
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo/flexy-logo.png',
                      width: 100,
                      height: 50,
                    ),
                  ],
                ),
              ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search,
                  color: Color.fromARGB(255, 6, 83, 146)),
              onPressed: _toggleSearch,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profil',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue,
                        child: const Icon(Icons.person,
                            color: Colors.white, size: 30),
                      ),
                      title: const Text('Profil Bilgilerini Düzenle'),
                      subtitle: const Text(
                          'İsim, e-posta ve profil fotoğrafını değiştir'),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: Colors.blue),
                      onTap: () {
                        // Navigate to profile edit page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Profile()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Appearance Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Görünüm',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Karanlık Mod'),
                      subtitle:
                          const Text('Uygulamanın karanlık temasını kullan'),
                      value: _darkMode,
                      activeColor: Colors.blue,
                      onChanged: (bool value) {
                        setState(() {
                          _darkMode = value;
                        });
                        // Implement theme change logic here
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Dil'),
                      subtitle: Text(_selectedLanguage),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: Colors.blue),
                      onTap: () {
                        _showLanguageDialog();
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Notifications Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bildirimler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Bildirimleri Etkinleştir'),
                      subtitle:
                          const Text('Uygulama bildirimlerini aç veya kapat'),
                      value: _notifications,
                      activeColor: Colors.blue,
                      onChanged: (bool value) {
                        setState(() {
                          _notifications = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // About Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hakkında',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Uygulama Versiyonu'),
                      subtitle: const Text('1.0.0'),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Gizlilik Politikası'),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: Colors.blue),
                      onTap: () {
                        // Navigate to privacy policy
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Kullanım Koşulları'),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: Colors.blue),
                      onTap: () {
                        // Navigate to terms of service
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Firebase ile çıkış yap
                  FirebaseAuth.instance.signOut().then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Çıkış yapılıyor...')),
                    );

                    // Login sayfasına yönlendir
                    Future.delayed(const Duration(milliseconds: 500), () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                        (route) => false, // Tüm önceki rotaları temizle
                      );
                    });
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Çıkış yapılırken hata oluştu: $error')),
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Çıkış Yap', style: TextStyle(fontSize: 16)),
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
              icon: Icon(Icons.home, color: Colors.blue[800], size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.analytics_outlined,
                  color: Colors.blue[800], size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Dashboard()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.person, color: Colors.blue[800], size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Profile()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dil Seçin'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _languages.length,
              itemBuilder: (BuildContext context, int index) {
                return RadioListTile<String>(
                  title: Text(_languages[index]),
                  value: _languages[index],
                  groupValue: _selectedLanguage,
                  activeColor: Colors.blue,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedLanguage = value!;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('İptal', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
}
