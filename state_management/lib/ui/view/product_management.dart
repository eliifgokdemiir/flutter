import 'package:flutter/material.dart';
import 'package:state_management/data/entity/branch.dart';
import 'package:state_management/data/entity/category.dart';
import 'package:state_management/data/entity/product.dart';
import 'package:state_management/ui/view/home.dart';
import 'package:state_management/ui/view/dashboard.dart';
import 'package:state_management/ui/view/navbar_menu.dart';
import 'package:state_management/ui/view/profile.dart';

class ProductManagement extends StatefulWidget {
  const ProductManagement({super.key});

  @override
  State<ProductManagement> createState() => _ProductManagementState();
}

class _ProductManagementState extends State<ProductManagement> {
  Branch? _selectedBranch;
  Category? _selectedCategory;
  final List<Branch> _branches = [
    Branch(id: 1, name: 'Şube 1', turnover: 0),
    Branch(id: 2, name: 'Şube 2', turnover: 0),
  ];

  final List<Category> _categories = [
    Category(id: 1, name: 'Yiyecek', color: Colors.blue),
    Category(id: 2, name: 'İçecek', color: Colors.green),
    Category(id: 3, name: 'Tatlı', color: Colors.red),
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Product> _products = [];
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _stockController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const NavbarMenu(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Padding(
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
          IconButton(
            icon: const Icon(Icons.search,
                color: Color.fromARGB(255, 6, 83, 146)),
            onPressed: () {}, // Arama fonksiyonunu ekleyin
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBranchSelector(),
            const SizedBox(height: 20),
            _buildCategorySelector(),
            const SizedBox(height: 20),
            _buildProductForm(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text('Ürünü Kaydet',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saveProduct,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildProductList(),
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.analytics_outlined,
                  color: Colors.blue[800], size: 28),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Dashboard()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.person, color: Colors.blue[800], size: 28),
              onPressed: () {
                Navigator.pushReplacement(
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

  Widget _buildBranchSelector() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Şube Seçiniz:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<Branch>(
              value: _selectedBranch,
              hint: const Text('Şube seçin...'),
              items: _branches
                  .map((branch) => DropdownMenuItem(
                        value: branch,
                        child: Text(branch.name),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBranch = value;
                  _selectedCategory = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kategori Seçiniz:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: _categories.map((category) {
                final isSelected = _selectedCategory?.id == category.id;
                return ChoiceChip(
                  label: Text(category.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : null;
                    });
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: category.color.withOpacity(0.3),
                  labelStyle: TextStyle(
                    color: isSelected ? category.color : Colors.black,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductForm() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(
                  labelText: 'Ürün Adı',
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen ürün adı giriniz';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stok Miktarı',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen stok miktarı giriniz';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Fiyat (₺)',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen fiyat giriniz';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return Card(
      elevation: 4,
      child: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ListTile(
            leading: const Icon(Icons.inventory),
            title: Text(product.name),
            subtitle: Text('Stok: ${product.stock} • Fiyat: ₺${product.price}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteProduct(index),
            ),
          );
        },
      ),
    );
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate() &&
        _selectedBranch != null &&
        _selectedCategory != null) {
      setState(() {
        _products.add(Product(
          name: _productNameController.text,
          stock: int.parse(_stockController.text),
          price: double.parse(_priceController.text),
          branchId: _selectedBranch!.id,
          categoryId: _selectedCategory!.id,
        ));
        _clearForm();
      });
    }
  }

  void _deleteProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  void _clearForm() {
    _productNameController.clear();
    _stockController.clear();
    _priceController.clear();
  }
}
