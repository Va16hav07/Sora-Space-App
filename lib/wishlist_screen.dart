import 'package:flutter/material.dart';
import 'property_detail_screen.dart';
import 'home_screen.dart'; // For PropertyListing model

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late List<PropertyListing> _wishlistProperties;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWishlistData();
  }

  void _loadWishlistData() async {
    // Simulate API loading delay
    await Future.delayed(const Duration(milliseconds: 1000));

    // Sample wishlist data - in a real app, this would come from a database
    final List<PropertyListing> wishlistItems = [
      PropertyListing(
        id: '5',
        title: 'Luxury Penthouse',
        address: '1 Skyview Tower, Downtown',
        price: 1250000,
        bedrooms: 4,
        bathrooms: 3,
        sqft: 3200,
        imageUrl:
            'https://images.unsplash.com/photo-1512917774080-9991f1c4c750',
        isFeatured: true,
        hasVirtualTour: true,
        type: 'Penthouse',
      ),
      PropertyListing(
        id: '3',
        title: 'Luxury Condo',
        address: '789 Skyline Blvd, Metro City',
        price: 620000,
        bedrooms: 3,
        bathrooms: 2,
        sqft: 1800,
        imageUrl:
            'https://images.unsplash.com/photo-1576941089067-2de3c901e126',
        isFeatured: false,
        hasVirtualTour: true,
        type: 'Condo',
      ),
    ];

    if (mounted) {
      setState(() {
        _wishlistProperties = wishlistItems;
        _isLoading = false;
      });
    }
  }

  void _removeFromWishlist(PropertyListing property) {
    setState(() {
      _wishlistProperties.remove(property);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${property.title} removed from wishlist'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              _wishlistProperties.add(property);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        backgroundColor: isDarkMode ? const Color(0xFF0A1128) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDarkMode
                    ? [const Color(0xFF0A1128), const Color(0xFF001F54)]
                    : [const Color(0xFFF8F5F2), const Color(0xFFFFFFFF)],
          ),
        ),
        child:
            _isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    color: isDarkMode ? Colors.white : Colors.indigo,
                  ),
                )
                : _wishlistProperties.isEmpty
                ? _buildEmptyState(isDarkMode)
                : _buildWishlistItems(isDarkMode),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: isDarkMode ? Colors.white30 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Your wishlist is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Properties you like will appear here',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.search),
            label: const Text('Explore Properties'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.blueAccent : Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItems(bool isDarkMode) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _wishlistProperties.length,
      itemBuilder: (context, index) {
        final property = _wishlistProperties[index];
        return Dismissible(
          key: Key(property.id),
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerRight,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            _removeFromWishlist(property);
          },
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => PropertyDetailScreen(property: property),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color:
                    isDarkMode ? Colors.black.withOpacity(0.2) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (!isDarkMode)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Row(
                children: [
                  // Property image
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(16),
                    ),
                    child: Image.network(
                      property.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Property info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            property.address,
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${_formatPrice(property.price)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode
                                      ? Colors.blueAccent
                                      : Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Remove button
                  IconButton(
                    onPressed: () => _removeFromWishlist(property),
                    icon: Icon(Icons.favorite, color: Colors.red[400]),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatPrice(int price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(price % 1000000 == 0 ? 0 : 1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}K';
    }
    return price.toString();
  }
}
