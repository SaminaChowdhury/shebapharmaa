import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/cart_provider.dart';
import '../../core/models.dart';
import '../../core/medicine_service.dart';
import '../cart/cart_screen.dart';

class MedicineDetailScreen extends StatefulWidget {
  final Map<String, dynamic> medicine;

  const MedicineDetailScreen({super.key, required this.medicine});

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  int _selectedQuantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: const Color(0xFF799EFF),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Background Image
                  Container(
                    width: double.infinity,
                    height: 500,
                    decoration: BoxDecoration(
                      color: const Color(0xFF799EFF).withOpacity(0.1),
                    ),
                    child: _shouldShowNetworkImage(widget.medicine['image'])
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(0),
                              topRight: Radius.circular(0),
                            ),
                            child: Image.network(
                              widget.medicine['image'],
                              height: 300,
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
                                    strokeWidth: 3,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return _buildMedicineImage();
                              },
                            ),
                          )
                        : _buildMedicineImage(),
                  ),
                  
                  // Gradient Overlay
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF799EFF).withOpacity(0.3),
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            // Removed the favorite icon from actions
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medicine Header
                  _buildMedicineHeader(),
                  
                  const SizedBox(height: 16),
                  
                  // Price and Rating
                  _buildPriceAndRating(),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  _buildDescription(),
                  
                  const SizedBox(height: 16),
                  
                  // Specifications
                  _buildSpecifications(),
                  
                  const SizedBox(height: 16),
                  
                  // Removed customer reviews section
                  
                  const SizedBox(height: 80), // Reduced space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom Purchase Section
      bottomSheet: _buildBottomPurchaseSection(),
    );
  }

  Widget _buildMedicineHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF799EFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.medicine['category'] ?? 'General',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF799EFF),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Medicine Name
        Text(
          widget.medicine['name'],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        
        const SizedBox(height: 6),
        
        // Generic Name
        Text(
          widget.medicine['generic_name'] ?? '',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF64748B),
            fontStyle: FontStyle.italic,
          ),
        ),
        
        const SizedBox(height: 6),
        
        // Stock Status
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: widget.medicine['inStock'] 
                    ? const Color(0xFF10B981).withOpacity(0.1)
                    : const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.medicine['inStock'] ? Icons.check_circle : Icons.cancel,
                    color: widget.medicine['inStock'] 
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.medicine['inStock'] ? 'In Stock' : 'Out of Stock',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.medicine['inStock'] 
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceAndRating() {
    return Row(
      children: [
        // Price
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Price',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${(widget.medicine['price'] ?? 0.0).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF799EFF),
                ),
              ),
            ],
          ),
        ),
        
        // Rating
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Rating',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color: Color(0xFFFFD700),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.medicine['rating'] ?? 4.5}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              Text(
                '${widget.medicine['reviews'] ?? 50} reviews',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.medicine['description'] ?? 'No description available',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Specifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        
        _buildSpecItem('Generic Name', widget.medicine['generic_name'] ?? 'N/A'),
        _buildSpecItem('Brand Name', widget.medicine['name'] ?? 'N/A'),
        _buildSpecItem('Manufacturer', widget.medicine['manufacturer'] ?? 'N/A'),
        _buildSpecItem('Category', widget.medicine['category'] ?? 'General'),
        _buildSpecItem('Price', '\$${(widget.medicine['price'] ?? 0.0).toStringAsFixed(2)}'),
        _buildSpecItem('Stock Status', widget.medicine['inStock'] ? 'In Stock' : 'Out of Stock'),
      ],
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPurchaseSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: SafeArea(
        child: Row(
          children: [
            // Quantity Selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Color(0xFF799EFF)),
                    onPressed: () {
                      if (_selectedQuantity > 1) {
                        setState(() {
                          _selectedQuantity--;
                        });
                      }
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      '$_selectedQuantity',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Color(0xFF799EFF)),
                    onPressed: () {
                      setState(() {
                        _selectedQuantity++;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Add to Cart Button
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: widget.medicine['inStock'] 
                      ? const LinearGradient(
                          colors: [Color(0xFF799EFF), Color(0xFF4A90E2)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                  color: widget.medicine['inStock'] 
                      ? null 
                      : const Color(0xFFEF4444).withOpacity(0.1),
                  boxShadow: widget.medicine['inStock'] 
                      ? [
                          BoxShadow(
                            color: const Color(0xFF799EFF).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ]
                      : null,
                ),
                child: ElevatedButton(
                  onPressed: widget.medicine['inStock'] ? () => _addToCart() : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    widget.medicine['inStock'] ? 'Add to Cart' : 'Out of Stock',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: widget.medicine['inStock'] 
                          ? Colors.white 
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineImage() {
    // Get the appropriate image from assets based on medicine name
    final imagePath = MedicineService.getDefaultImage(widget.medicine['generic_name'] ?? '');
    
    return Center(
      child: Image.asset(
        imagePath,
        height: 140,
        width: 140,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/logo_small.png',
            height: 140,
            width: 140,
          );
        },
      ),
    );
  }

  bool _shouldShowNetworkImage(String? imageUrl) {
    return imageUrl != null && imageUrl.isNotEmpty && imageUrl.startsWith('http');
  }

  void _addToCart() {
    final cart = context.read<CartProvider>();
    
    final cartItem = CartItem(
      medicineId: widget.medicine['id'],
      medicineName: widget.medicine['name'],
      genericName: widget.medicine['generic_name'],
      price: widget.medicine['price'],
      quantity: _selectedQuantity,
      imageUrl: widget.medicine['image'],
      description: widget.medicine['description'],
    );
    
    cart.addItem(cartItem);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.medicine['name']} added to cart!'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pop(context);
            // Navigate to cart screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          },
        ),
      ),
    );
  }
}
