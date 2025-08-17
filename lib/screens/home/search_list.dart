import 'package:flutter/material.dart';
import '../../core/medicine_service.dart';
import 'medicine_detail.dart';

class SearchListScreen extends StatefulWidget {
  final String? initialCategory;
  
  const SearchListScreen({super.key, this.initialCategory});

  @override
  State<SearchListScreen> createState() => _SearchListScreenState();
}

class _SearchListScreenState extends State<SearchListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _sortBy = 'Name';
  bool _showOnlyInStock = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _allMedicines = [];
  String? _errorMessage;
  
  final List<String> _categories = [
    'All', 'Pain Relief', 'Antibiotics', 'Cardiovascular', 'General'
  ];
  
  final List<String> _sortOptions = [
    'Name', 'Price: Low to High', 'Price: High to Low', 'Rating', 'Newest'
  ];

  @override
  void initState() {
    super.initState();
    // Set initial category if provided
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
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
          _allMedicines = transformedMedicines;
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

  // Enhanced search functionality
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // First try to search via API
      final searchResult = await MedicineService.searchMedicines(query);
      
      if (searchResult['success']) {
        final medicinesData = searchResult['data']['results'] as List;
        
        // Transform API search results
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
            'rating': 4.5,
            'reviews': 50,
            'inStock': medicine['is_in_stock'] ?? false,
          };
        }).toList();

        setState(() {
          _allMedicines = transformedMedicines;
          _isLoading = false;
        });
      } else {
        // If API search fails, fall back to local search
        _performLocalSearch(query);
      }
    } catch (e) {
      // Fall back to local search if API fails
      _performLocalSearch(query);
    }
  }

  void _performLocalSearch(String query) {
    final searchQuery = query.toLowerCase().trim();
    
    // Search in local medicines if available
    if (_allMedicines.isNotEmpty) {
      final filteredMedicines = _allMedicines.where((medicine) {
        return medicine['name'].toString().toLowerCase().contains(searchQuery) ||
               medicine['generic_name'].toString().toLowerCase().contains(searchQuery) ||
               medicine['description'].toString().toLowerCase().contains(searchQuery) ||
               medicine['manufacturer'].toString().toLowerCase().contains(searchQuery);
      }).toList();

      setState(() {
        _allMedicines = filteredMedicines;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredMedicines {
    List<Map<String, dynamic>> filtered = _allMedicines;
    
    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((medicine) => 
        medicine['category'] == _selectedCategory
      ).toList();
    }
    
    // Filter by stock
    if (_showOnlyInStock) {
      filtered = filtered.where((medicine) => 
        medicine['inStock'] == true
      ).toList();
    }
    
    // Sort
    switch (_sortBy) {
      case 'Name':
        filtered.sort((a, b) => a['name'].compareTo(b['name']));
        break;
      case 'Price: Low to High':
        filtered.sort((a, b) => a['price'].compareTo(b['price']));
        break;
      case 'Price: High to Low':
        filtered.sort((a, b) => b['price'].compareTo(a['price']));
        break;
      case 'Rating':
        filtered.sort((a, b) => b['rating'].compareTo(a['rating']));
        break;
      case 'Newest':
        filtered.sort((a, b) => b['id'].compareTo(a['id']));
        break;
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF799EFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Browse Medicines',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Removed the filter icon from actions
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          
          // Filters Row
          _buildFiltersRow(),
          
          // Results Count
          _buildResultsCount(),
          
          // Medicines Grid
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState()
                    : _buildMedicinesGrid(),
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
            size: 80,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(height: 16),
          const Text(
            'Error loading medicines',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
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

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          if (value.trim().isEmpty) {
            // If search is empty, reload all medicines
            _loadMedicines();
          } else {
            // Perform search with a small delay to avoid too many API calls
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_searchController.text == value) {
                _performSearch(value);
              }
            });
          }
        },
        decoration: InputDecoration(
          hintText: 'Search medicines...',
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 16,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF799EFF),
            size: 24,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF94A3B8)),
                  onPressed: () {
                    _searchController.clear();
                    _loadMedicines(); // Reload all medicines when clearing search
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF799EFF), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Category Filter
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(_selectedCategory),
              selected: _selectedCategory != 'All',
              onSelected: (selected) {
                _showCategoryDialog();
              },
              backgroundColor: _selectedCategory != 'All' 
                  ? const Color(0xFF799EFF) 
                  : Colors.white,
              labelStyle: TextStyle(
                color: _selectedCategory != 'All' 
                    ? Colors.white 
                    : const Color(0xFF64748B),
              ),
              selectedColor: const Color(0xFF799EFF),
            ),
          ),
          
          // Stock Filter
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: const Text('In Stock Only'),
              selected: _showOnlyInStock,
              onSelected: (selected) {
                setState(() {
                  _showOnlyInStock = selected;
                });
              },
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: _showOnlyInStock ? Colors.white : const Color(0xFF64748B),
              ),
              selectedColor: const Color(0xFF10B981),
            ),
          ),
          
          // Sort Filter
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text('Sort: $_sortBy'),
              selected: _sortBy != 'Name',
              onSelected: (selected) {
                _showSortDialog();
              },
              backgroundColor: _sortBy != 'Name' 
                  ? const Color(0xFF4A90E2) 
                  : Colors.white,
              labelStyle: TextStyle(
                color: _sortBy != 'Name' 
                    ? Colors.white 
                    : const Color(0xFF64748B),
              ),
              selectedColor: const Color(0xFF4A90E2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_filteredMedicines.length} medicines found',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                Text(
                  'Searching for: "${_searchController.text}"',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
            ],
          ),
          if (_filteredMedicines.isNotEmpty)
            TextButton(
              onPressed: () {
                // Clear all filters
                setState(() {
                  _selectedCategory = 'All';
                  _showOnlyInStock = false;
                  _sortBy = 'Name';
                  _searchController.clear();
                });
                _loadMedicines(); // Reload all medicines
              },
              child: const Text(
                'Clear All',
                style: TextStyle(
                  color: Color(0xFF799EFF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicinesGrid() {
    if (_filteredMedicines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 16),
            const Text(
              'No medicines found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.60,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredMedicines.length,
      itemBuilder: (context, index) {
        final medicine = _filteredMedicines[index];
        return _buildMedicineCard(medicine);
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
              height: 165, // Reduced height
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
                    
                    // const SizedBox(height: 6),
                    
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
                    
                    const SizedBox(height: 2),
                    
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
                    
                    const SizedBox(height: 2),
                    
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
                    
                    const SizedBox(height: 4),
                    
                    // Price and Stock
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${medicine['price'].toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF799EFF),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: medicine['inStock'] 
                                ? const Color(0xFF10B981).withOpacity(0.1)
                                : const Color(0xFFEF4444).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            medicine['inStock'] ? '✓' : '✗',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: medicine['inStock'] 
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildDefaultMedicineImage() {
    return Center(
      child: Image.asset(
        'assets/images/logo_small.png',
        height: 100,
        width: 100,
      ),
    );
  }

  Widget _buildMedicineImage(Map<String, dynamic> medicine) {
    final imagePath = MedicineService.getDefaultImage(medicine['generic_name'] ?? '');

    return Center(
      child: Image.asset(
        imagePath,
        height: 100,
        width: 100,
        errorBuilder: (context, error, stackTrace) {
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

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _categories.map((category) {
            return RadioListTile<String>(
              title: Text(category),
              value: category,
              groupValue: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF799EFF),
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _sortOptions.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF799EFF),
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Category Filter
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                children: _categories.map((category) {
                  return FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: const Color(0xFF799EFF),
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 20),
              
              // Stock Filter
              Row(
                children: [
                  Checkbox(
                    value: _showOnlyInStock,
                    onChanged: (value) {
                      setState(() {
                        _showOnlyInStock = value!;
                      });
                    },
                    activeColor: const Color(0xFF799EFF),
                  ),
                  const Text(
                    'Show only in-stock items',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Sort Options
              const Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                children: _sortOptions.map((option) {
                  return FilterChip(
                    label: Text(option),
                    selected: _sortBy == option,
                    onSelected: (selected) {
                      setState(() {
                        _sortBy = option;
                      });
                    },
                    selectedColor: const Color(0xFF799EFF),
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
              
              const Spacer(),
              
              // Apply Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF799EFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
