import 'package:flutter/material.dart';
import 'package:state_management/ui/view/home.dart';

class NavbarMenu extends StatelessWidget {
  const NavbarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 236, 239, 243),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Image.asset(
                    'assets/logo/flexy-logo.png',
                    width: 100,
                    height: 60,
                  ),
                  const SizedBox(width: 15),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 20),
              children: [
                _buildMenuItem(Icons.home, 'Anasayfa', context),
                _buildMenuItem(Icons.analytics, 'Raporlar', context),
                _buildMenuItem(Icons.business, 'Şubeler', context),
                _buildMenuItem(Icons.person, 'Profil', context),
                _buildMenuItem(Icons.settings, 'Ayarlar', context),
                _buildMenuItem(Icons.exit_to_app, 'Çıkış Yap', context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[800]),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      },
    );
  }
}
