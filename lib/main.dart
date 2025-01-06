import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_page.dart';
import 'profile_page.dart';

// Model untuk item keranjang
class CartItem {
  final String image;
  final String name;
  final String price;
  int quantity;

  CartItem({
    required this.image,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  int get total => (double.parse(price.replaceAll('Rp.', '').replaceAll('.', '')) * quantity).toInt();
}

// Model untuk menu item
class MenuItem {
  final String image;
  final String name;
  final String description;
  final String price;
  final String category;

  MenuItem({
    required this.image,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
  });
}

// Tambahkan class AppPadding setelah class CartItem
class AppPadding {
  static const double xs = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xl = 32.0;

  static EdgeInsets get screenPadding => const EdgeInsets.symmetric(
    horizontal: medium,
    vertical: small,
  );

  static EdgeInsets get cardPadding => const EdgeInsets.all(medium);
  
  static EdgeInsets get listItemPadding => const EdgeInsets.symmetric(
    vertical: small,
    horizontal: medium,
  );

  static double getResponsivePadding(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return small;
    } else if (screenWidth < 400) {
      return medium;
    } else {
      return large;
    }
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Error handling untuk aplikasi
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi kesalahan',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set orientasi aplikasi ke portrait saja
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'Happy\'s Food',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
      // Tambahkan error handling untuk route
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const LoginPage(),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1; // Default ke HOME
  String _selectedCategory = 'all';
  final TextEditingController _searchController = TextEditingController();
  final List<CartItem> _cartItems = [];
  final List<MenuItem> _favoriteItems = []; // Untuk menyimpan menu favorit
  String _searchQuery = ''; // Tambahkan variabel untuk query pencarian

  // Daftar menu
  final List<MenuItem> _menuItems = [
    // Kategori EAT
    MenuItem(
      image: 'nasi_goreng',
      name: 'NASI GORENG',
      description: 'Nasi goreng spesial dengan telur dan ayam',
      price: 'Rp.15.000',
      category: 'eat',
    ),
    MenuItem(
      image: 'mie_ayam',
      name: 'MIE AYAM',
      description: 'Mie ayam yang lezat dan bergizi',
      price: 'Rp.10.000',
      category: 'eat',
    ),
    MenuItem(
      image: 'ayam_goreng',
      name: 'AYAM GORENG',
      description: 'Ayam goreng renyah dengan bumbu special',
      price: 'Rp.12.000',
      category: 'eat',
    ),
    MenuItem(
      image: 'soto_ayam',
      name: 'SOTO AYAM',
      description: 'Soto ayam dengan kuah bening segar',
      price: 'Rp.12.000',
      category: 'eat',
    ),
    // Kategori DRINK
    MenuItem(
      image: 'es_teh',
      name: 'ES TEH',
      description: 'Es teh manis segar',
      price: 'Rp.3.000',
      category: 'drink',
    ),
    MenuItem(
      image: 'kopi',
      name: 'KOPI',
      description: 'Kopi hitam nikmat',
      price: 'Rp.5.000',
      category: 'drink',
    ),
    // Kategori SNACK
    MenuItem(
      image: 'kentang_goreng',
      name: 'KENTANG GORENG',
      description: 'Kentang goreng renyah',
      price: 'Rp.8.000',
      category: 'snack',
    ),
    MenuItem(
      image: 'salad_buah',
      name: 'SALAD BUAH',
      description: 'Salad buah segar dengan mayonaise',
      price: 'Rp.10.000',
      category: 'snack',
    ),
    // Kategori PAKET SUPER
    MenuItem(
      image: 'nasi_goreng',
      name: 'PAKET NASI GORENG KOMPLIT',
      description: 'Nasi goreng + Telur + Ayam + Es Teh',
      price: 'Rp.20.000',
      category: 'super',
    ),
    MenuItem(
      image: 'mie_ayam',
      name: 'PAKET MIE AYAM KOMPLIT',
      description: 'Mie Ayam + Pangsit + Es Teh',
      price: 'Rp.15.000',
      category: 'super',
    ),
  ];

  // Filter menu berdasarkan kategori dan pencarian
  List<MenuItem> get filteredMenu {
    return _menuItems.where((item) {
      bool matchesCategory = _selectedCategory == 'all' || item.category == _selectedCategory;
      bool matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildCategoryItem(String icon, String label) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSelected = _selectedCategory == icon || 
                      (icon == 'star' && _selectedCategory == 'super');
    return Container(
      width: screenWidth * 0.22,
      margin: EdgeInsets.all(AppPadding.xs),
      child: Material(
        color: isSelected ? Colors.green : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _selectCategory(icon == 'star' ? 'super' : icon),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(AppPadding.small),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon == 'eat' ? Icons.restaurant : 
                  icon == 'drink' ? Icons.local_drink :
                  icon == 'snack' ? Icons.lunch_dining :
                  Icons.star,
                  size: screenWidth * 0.06,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                SizedBox(height: AppPadding.xs),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: screenWidth * 0.028,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBestSellerItem(String image, String name) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.28,
      height: screenWidth * 0.35,
      margin: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/$image.jpg',
              height: screenWidth * 0.2,
              width: screenWidth * 0.25,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.image_not_supported,
                  size: screenWidth * 0.1,
                  color: Colors.grey[400],
                );
              },
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
            child: Text(
              name,
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk mengecek apakah menu adalah favorit
  bool _isFavorite(String name) {
    return _favoriteItems.any((item) => item.name == name);
  }

  // Fungsi untuk menambah/menghapus menu favorit
  void _toggleFavorite(MenuItem item) {
    if (!_isContextValid) return;

    try {
      setState(() {
        if (_isFavorite(item.name)) {
          _favoriteItems.removeWhere((favItem) => favItem.name == item.name);
          _showSnackBar('${item.name} dihapus dari favorit');
        } else {
          _favoriteItems.add(item);
          _showSnackBar('${item.name} ditambahkan ke favorit');
        }
      });
    } catch (e) {
      print('Error toggling favorite: $e');
      _showSnackBar('Gagal mengubah status favorit');
    }
  }

  Widget _buildMenuItem(String image, String name, String description, String price) {
    final screenWidth = MediaQuery.of(context).size.width;
    final menuItem = _menuItems.firstWhere((item) => item.name == name);
    final isFavorite = _isFavorite(name);

    return Card(
      margin: EdgeInsets.symmetric(
        vertical: AppPadding.small,
        horizontal: AppPadding.medium,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: AppPadding.cardPadding,
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.2,
              height: screenWidth * 0.2,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/$image.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image_not_supported,
                      size: screenWidth * 0.08,
                      color: Colors.grey[400],
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: AppPadding.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: screenWidth * 0.05,
                        ),
                        onPressed: () => _toggleFavorite(menuItem),
                        padding: EdgeInsets.all(AppPadding.xs),
                        constraints: BoxConstraints(
                          minWidth: screenWidth * 0.08,
                          minHeight: screenWidth * 0.08,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppPadding.xs),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: screenWidth * 0.028,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppPadding.small),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppPadding.small),
            ElevatedButton(
              onPressed: () => _addToCart(image, name, price),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(AppPadding.small),
                minimumSize: Size(screenWidth * 0.1, screenWidth * 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Icon(
                Icons.shopping_cart,
                size: screenWidth * 0.045,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(String image, String name, String price) {
    if (!_isContextValid) return;

    try {
      setState(() {
        final existingItem = _cartItems.firstWhere(
          (item) => item.name == name,
          orElse: () => CartItem(image: '', name: '', price: ''),
        );

        if (existingItem.name.isNotEmpty) {
          existingItem.quantity++;
        } else {
          _cartItems.add(CartItem(
            image: image,
            name: name,
            price: price,
          ));
        }
      });
      _showSnackBar('$name ditambahkan ke keranjang');
    } catch (e) {
      print('Error adding to cart: $e');
      _showSnackBar('Gagal menambahkan ke keranjang');
    }
  }

  void _removeFromCart(int index) {
    if (index >= 0 && index < _cartItems.length) {
      setState(() {
        _cartItems.removeAt(index);
      });
    }
  }

  void _updateQuantity(int index, bool increment) {
    if (index >= 0 && index < _cartItems.length) {
      setState(() {
        if (increment) {
          _cartItems[index].quantity++;
        } else if (_cartItems[index].quantity > 1) {
          _cartItems[index].quantity--;
        } else {
          // Jika quantity 1 dan dikurangi, hapus item
          _cartItems.removeAt(index);
        }
      });
    }
  }

  void _showCart() {
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Keranjang Belanja',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: _cartItems.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Keranjang kosong',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        if (index >= _cartItems.length) return null;
                        final item = _cartItems[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/${item.image}.jpg',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.price,
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () => _updateQuantity(index, false),
                                      color: Colors.green,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () => _updateQuantity(index, true),
                                      color: Colors.green,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _removeFromCart(index),
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (_cartItems.isNotEmpty) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Rp.${_cartItems.fold(0, (sum, item) => sum + item.total).toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Implementasi checkout
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pesanan berhasil!')),
                    );
                    setState(() {
                      _cartItems.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('CHECKOUT'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPromoPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer,
            size: MediaQuery.of(context).size.width * 0.2,
            color: Colors.green,
          ),
          const SizedBox(height: 20),
          const Text(
            'Promo Hari Ini',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'DISKON 20%',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const Text(
                    'Untuk semua menu makanan\nMinimal pembelian Rp.50.000',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('MENU > Home',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        // Kategori
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCategoryItem('eat', 'Eat'),
            _buildCategoryItem('drink', 'Drink'),
            _buildCategoryItem('snack', 'Snack'),
            _buildCategoryItem('star', 'Paket Super'),
          ],
        ),
        if (_selectedCategory == 'all') ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('BEST SELLER',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // Best Seller Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            children: [
              _buildBestSellerItem('ayam_goreng', 'AYAM GORENG'),
              _buildBestSellerItem('kentang_goreng', 'KENTANG GORENG'),
              _buildBestSellerItem('es_teh', 'ES TEH'),
              _buildBestSellerItem('soto_ayam', 'SOTO AYAM'),
              _buildBestSellerItem('salad_buah', 'SALAD BUAH'),
              _buildBestSellerItem('kopi', 'KOPI'),
            ],
          ),
        ],
        // Menu Items berdasarkan kategori
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _selectedCategory == 'all' ? 'SEMUA MENU' :
            _selectedCategory == 'eat' ? 'MENU MAKANAN' :
            _selectedCategory == 'drink' ? 'MENU MINUMAN' :
            _selectedCategory == 'snack' ? 'MENU SNACK' : 'PAKET SUPER',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...filteredMenu.map((item) => _buildMenuItem(
          item.image,
          item.name,
          item.description,
          item.price,
        )).toList(),
      ],
    );
  }

  Widget _buildFavoritePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Menu Favorit',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        _favoriteItems.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'Belum ada menu favorit',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            : Column(
                children: _favoriteItems
                    .map((item) => _buildMenuItem(
                          item.image,
                          item.name,
                          item.description,
                          item.price,
                        ))
                    .toList(),
              ),
      ],
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(username: widget.username),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari Menu',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppPadding.medium,
              vertical: AppPadding.small,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        backgroundColor: Colors.green,
        elevation: 2,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: screenWidth * 0.06,
                ),
                padding: EdgeInsets.all(AppPadding.small),
                onPressed: _showCart,
              ),
              if (_cartItems.isNotEmpty)
                Positioned(
                  right: AppPadding.xs,
                  top: AppPadding.xs,
                  child: Container(
                    padding: EdgeInsets.all(AppPadding.xs),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_cartItems.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.025,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.white,
              size: screenWidth * 0.06,
            ),
            padding: EdgeInsets.all(AppPadding.small),
            onPressed: _openProfile,
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            SingleChildScrollView(
              padding: AppPadding.screenPadding,
              child: _buildPromoPage()
            ),
            SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + AppPadding.medium,
              ),
              child: _buildHomePage()
            ),
            SingleChildScrollView(
              padding: AppPadding.screenPadding,
              child: _buildFavoritePage()
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
          left: AppPadding.medium,
          right: AppPadding.medium,
        ),
        decoration: BoxDecoration(
          color: Colors.green,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.percent, 'PROMO', 0),
            _buildBottomNavItem(Icons.home, 'HOME', 1),
            _buildBottomNavItem(Icons.favorite, 'FAVORIT', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, 
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
            ),
            Text(label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Tambahkan listener untuk pencarian
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    try {
      _loadInitialData();
    } catch (e) {
      print('Error loading initial data: $e');
    }
  }

  void _loadInitialData() {
    setState(() {
      _selectedIndex = 1;
      _selectedCategory = 'all';
    });
  }

  @override
  void dispose() {
    try {
      _searchController.dispose();
    } catch (e) {
      print('Error disposing controllers: $e');
    }
    super.dispose();
  }

  // Fungsi helper untuk memastikan context masih valid
  bool get _isContextValid {
    return mounted && context != null;
  }

  void _showSnackBar(String message) {
    if (_isContextValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}