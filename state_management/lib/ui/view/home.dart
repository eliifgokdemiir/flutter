import 'package:flutter/material.dart';
import 'package:state_management/data/entity/category.dart';
import 'package:state_management/data/entity/branch.dart';
import 'package:state_management/ui/view/dashboard.dart';
import 'package:state_management/ui/view/navbar_menu.dart';
import 'package:state_management/ui/view/branches.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final List<Category> categories = [
    Category(id: 1, name: 'Bugün', color: Colors.blue),
    Category(id: 2, name: 'Dün', color: Colors.green),
    Category(id: 3, name: 'Geçen hafta', color: Colors.orange),
    Category(id: 4, name: 'Geçen Ay', color: Colors.red),
    Category(id: 5, name: 'Bu yıl', color: Colors.purple),
  ];
  final List<Branch> branchList = [
    Branch(id: 1, name: 'Şube 1', turnover: 125000.0),
    Branch(id: 2, name: 'Şube 2', turnover: 184500.0),
    Branch(id: 3, name: 'Şube 3', turnover: 234200.0),
    Branch(id: 4, name: 'Şube 4', turnover: 98700.0),
    Branch(id: 5, name: 'Şube 5', turnover: 123400.0),
    Branch(id: 6, name: 'Şube 6', turnover: 123400.0),
    Branch(id: 7, name: 'Şube 7', turnover: 123400.0),
    Branch(id: 8, name: 'Şube 8', turnover: 123400.0),
    Branch(id: 9, name: 'Şube 9', turnover: 123400.0),
    Branch(id: 10, name: 'Şube 10', turnover: 123400.0),
  ];

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
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(15),
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
                  _buildAmountInfo('Açık Masa Tutarı', 875.50),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.blue.withOpacity(0.3),
                  ),
                  _buildAmountInfo('Açık Paket Tutarı', 154.75),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: category.color.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide(color: category.color),
                      ),
                      onPressed: () {},
                      child: Text(
                        category.name,
                        style: TextStyle(
                          color: category.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Şubeler',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: branchList.length,
                    itemBuilder: (context, index) {
                      final branch = branchList[index];
                      return _buildBranchCard(branch);
                    },
                  ),
                ],
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
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInfo(String title, double amount) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.blue[800],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '₺${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: Colors.blue[800],
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBranchCard(Branch branch) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Branches(branch: branch),
          ),
        );
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.storefront, size: 50, color: Colors.blue),
                  const SizedBox(height: 8),
                  Text(
                    branch.name,
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Aylık Ciro',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₺${branch.turnover.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
