import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/medicine_service.dart';
import '../../core/cart_provider.dart';
import '../../core/models.dart';
import 'profile_screen.dart';
import 'search_list.dart';
import 'medicine_detail.dart';
import '../cart/cart_screen.dart';
import '../orders/orders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _medicines = [];
  String? _errorMessage;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.medication, 'color': Color(0xFF799EFF)},
    {'name': 'Pain Relief', 'icon': Icons.healing, 'color': Color(0xFFFF6B6B)},
    {'name': 'Antibiotics', 'icon': Icons.medical_services, 'color': Color(0xFF4ECDC4)},
    {'name': 'Cardiovascular', 'icon': Icons.favorite, 'color': Color(0xFFFFE66D)},
    {'name': 'General', 'icon': Icons.medication_outlined, 'color': Color(0xFFFF8A80)},
  ];

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await MedicineService.getMedicines();
      
      if (result['success']) {
        final medicinesData = result['data']['results'] as List;
        
        // Transform API data to match our app structure
        final transformedMedicines = medicinesData.map<Map<String, dynamic>>((medicine) {
          return {
            'id': medicine['id'],
            'name': medicine['name'],
            'generic_name': medicine['generic_name'],
            'manufacturer': medicine['manufacturer'],
            'price': double.tryParse(medicine['price'].toString()) ?? 0.0,
            'image': medicine['image'] ?? MedicineService.getDefaultImage(medicine['generic_name']),
            'category': MedicineService.getCategoryFromGenericName(medicine['generic_name']),
            'description': MedicineService.getMedicineDescription(medicine['generic_name']),
            'rating': 4.5, // Default rating since API doesn't provide it
            'reviews': 50, // Default reviews count
            'inStock': medicine['is_in_stock'] ?? false,
          };
        }).toList();

        setState(() {
          _medicines = transformedMedicines;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading medicines: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _featuredMedicines {
    // Show first 4 medicines as featured
    return _medicines.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(),
            
            // Search Bar
            _buildSearchBar(),
            
            // Categories
            _buildCategories(),
            
            // Featured Medicines
            _buildFeaturedMedicines(),
            
            // Expanded to fill remaining space
            Expanded(child: Container()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Welcome Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'ShebaPharma',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          
          // Profile Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF799EFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_outline,
                color: Color(0xFF799EFF),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchListScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                color: Color(0xFF94A3B8),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Search medicines, pharmacies...',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 120,
      margin: const EdgeInsets.only(top: 24),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return GestureDetector(
            onTap: () {
              // Navigate to search list with category filter
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchListScreen(
                    initialCategory: category['name'],
                  ),
                ),
              );
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: category['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      category['icon'],
                      color: category['color'],
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category['name'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedMedicines() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Featured Medicines',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SearchListScreen()),
                    );
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Color(0xFF799EFF),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Medicines Grid
          Container(
            height: 360,
            margin: const EdgeInsets.only(top: 16),
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState()
                    : _medicines.isEmpty
                        ? _buildEmptyState()
                        : _buildMedicinesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF799EFF),
          ),
          SizedBox(height: 16),
          Text(
            'Loading medicines...',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading medicines',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadMedicines,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF799EFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_outlined,
            size: 60,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 16),
          const Text(
            'No medicines available',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later for new medicines',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMedicinesList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _featuredMedicines.length,
      itemBuilder: (context, index) {
        final medicine = _featuredMedicines[index];
        return Container(
          width: 200,
          margin: const EdgeInsets.only(right: 16),
          child: _buildMedicineCard(medicine),
        );
      },
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedicineDetailScreen(medicine: medicine),
          ),
        );
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medicine Image
            Container(
              height: 160, // Reduced height
              decoration: BoxDecoration(
                color: const Color(0xFF799EFF).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: _shouldShowNetworkImage(medicine['image'])
                    ? Image.network(
                        medicine['image'],
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: const Color(0xFF799EFF),
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _buildMedicineImage(medicine);
                        },
                      )
                    : _buildMedicineImage(medicine),
              ),
            ),
            
            // Medicine Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF799EFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        medicine['category'],
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF799EFF),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Medicine Name
                    Text(
                      medicine['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 3),
                    
                    // Generic Name
                    Text(
                      medicine['generic_name'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 3),
                    
                    // Description
                    Expanded(
                      child: Text(
                        medicine['description'],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Rating and Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFFFD700),
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${medicine['rating']}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        
                        // Price
                        Text(
                          '\$${medicine['price'].toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF799EFF),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Stock Status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: medicine['inStock'] 
                            ? const Color(0xFF10B981).withOpacity(0.1)
                            : const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        medicine['inStock'] ? 'In Stock' : 'Out of Stock',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: medicine['inStock'] 
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Add to Cart Button
                    if (medicine['inStock'])
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _addToCart(medicine),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF799EFF),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Out of Stock',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEF4444),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Consumer<CartProvider>(
        builder: (context, cart, child) {
          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
              
              // Handle navigation based on selected index
              switch (index) {
                case 0: // Home - already here
                  break;
                case 1: // Medicines
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchListScreen()),
                  );
                  break;
                case 2: // Cart
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                  break;
                                 case 3: // Orders
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => const OrdersScreen()),
                   );
                   break;
              }
              
              // Reset to home tab after navigation
              setState(() {
                _selectedIndex = 0;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF799EFF),
            unselectedItemColor: const Color(0xFF94A3B8),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.medication_outlined),
                activeIcon: Icon(Icons.medication),
                label: 'Medicines',
              ),
              BottomNavigationBarItem(
                icon: _buildCartIconWithBadge(
                  Icons.shopping_cart_outlined,
                  cart.itemCount,
                ),
                activeIcon: _buildCartIconWithBadge(
                  Icons.shopping_cart,
                  cart.itemCount,
                ),
                label: 'Cart',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Orders',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDefaultMedicineImage() {
    return Center(
      child: Image.asset(
        'assets/images/logo_small.png',
        height: 80,
        width: 80,
      ),
    );
  }

  Widget _buildMedicineImage(Map<String, dynamic> medicine) {
    // Try to get the appropriate image from assets based on medicine name
    final imagePath = MedicineService.getDefaultImage(medicine['generic_name'] ?? '');
    
    return Center(
      child: Image.asset(
        imagePath,
        height: 100,
        width: 100,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to logo if image not found
          return Image.asset(
            'assets/images/logo_small.png',
            height: 100,
            width: 100,
          );
        },
      ),
    );
  }

  bool _shouldShowNetworkImage(String? imageUrl) {
    return imageUrl != null && imageUrl.isNotEmpty && imageUrl.startsWith('http');
  }

  void _addToCart(Map<String, dynamic> medicine) {
    final cart = context.read<CartProvider>();
    
    final cartItem = CartItem(
      medicineId: medicine['id'],
      medicineName: medicine['name'],
      genericName: medicine['generic_name'],
      price: medicine['price'],
      quantity: 1,
      imageUrl: medicine['image'],
      description: medicine['description'],
    );
    
    cart.addItem(cartItem);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${medicine['name']} added to cart'),
        backgroundColor: const Color(0xFF799EFF),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCartIconWithBadge(IconData icon, int itemCount) {
    return Stack(
      children: [
        Icon(icon),
        if (itemCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '${itemCount > 99 ? '99+' : itemCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
