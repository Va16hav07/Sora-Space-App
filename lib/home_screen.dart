import 'dart:math';
import 'package:flutter/material.dart';
import 'property_detail_screen.dart';
import 'profile_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HomeScreen extends StatefulWidget {
  final String useCurrency;
  final String country;
  
  const HomeScreen({
    this.useCurrency = 'USD',
    this.country = 'United States',
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final List<PropertyListing> _nearbyProperties = [];
  final List<PropertyListing> _featuredProperties = [];
  List<PropertyListing> _filteredNearbyProperties = [];
  List<PropertyListing> _filteredFeaturedProperties = [];
  bool _isLoading = true;
  String? _locationError;
  String _userLocation = "Location access pending";
  bool _isLocationLoading = false;

  // For background particles
  final List<Particle> _particles = [];
  final Random _random = Random();
  late AnimationController _particleController;
  bool _particlesInitialized = false;

  // Filter state
  RangeValues _priceRange = const RangeValues(100000, 2000000);
  RangeValues _sizeRange = const RangeValues(500, 10000);
  int _minBedrooms = 0;
  int _minBathrooms = 0;
  List<String> _selectedTypes = [];
  
  // Currency symbol based on selection
  late String _currencySymbol;

  @override
  void initState() {
    super.initState();
    
    // Set currency symbol
    _setCurrencySymbol();

    // Initialize particles animation controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Get location with proper permissions
    _getCurrentLocation();

    // Load data with a slight delay to show loading state
    _loadData();

    // Don't initialize particles here - moved to didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize particles after the first build when MediaQuery is available
    if (!_particlesInitialized) {
      _initializeParticles();
      _particlesInitialized = true;
    }
  }

  void _initializeParticles() {
    final size = MediaQuery.of(context).size;

    for (int i = 0; i < 20; i++) {
      _particles.add(
        Particle(
          position: Offset(
            _random.nextDouble() * size.width,
            _random.nextDouble() * size.height,
          ),
          size: _random.nextDouble() * 4 + 1,
          speed: _random.nextDouble() * 0.5 + 0.1,
          angle: _random.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  void _setCurrencySymbol() {
    // Set the appropriate currency symbol
    switch (widget.useCurrency) {
      case 'INR':
        _currencySymbol = '₹';
        break;
      case 'EUR':
        _currencySymbol = '€';
        break;
      case 'GBP':
        _currencySymbol = '£';
        break;
      default:
        _currencySymbol = '\$';
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocationLoading = true;
    });

    try {
      // First check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Location services are disabled.';
          _isLocationLoading = false;
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      
      // If denied, request permission
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Location permissions are denied.';
            _isLocationLoading = false;
          });
          return;
        }
      }
      
      // If permanently denied, show error
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Location permissions are permanently denied. Please enable in settings.';
          _isLocationLoading = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition();
      
      // Get place details from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String city = place.locality ?? "";
        String state = place.administrativeArea ?? "";
        String country = place.country ?? "India"; // Default to India
        
        setState(() {
          _userLocation = "$city, $state, $country";
          _isLocationLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _locationError = 'Error retrieving location: $e';
        _isLocationLoading = false;
      });
    }
  }

  void _loadData() async {
    // Simulate API loading delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Sample properties data - updated for Indian market
    final List<PropertyListing> nearby = [
      PropertyListing(
        id: '1',
        title: 'Modern Apartment',
        address: '123 Urban St, ${widget.country == 'India' ? 'Mumbai' : 'Downtown'}',
        price: widget.useCurrency == 'INR' ? 3500000 : 350000,
        bedrooms: 2,
        bathrooms: 2,
        sqft: 1200,
        imageUrl:
            'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
        isFeatured: false,
        hasVirtualTour: true,
      ),
      PropertyListing(
        id: '2',
        title: 'Family Home',
        address: '456 Maple Ave, ${widget.country == 'India' ? 'Gurugram' : 'Suburbia'}',
        price: widget.useCurrency == 'INR' ? 5250000 : 525000,
        bedrooms: 4,
        bathrooms: 3,
        sqft: 2400,
        imageUrl:
            'https://images.unsplash.com/photo-1598228723793-52759bba239c',
        isFeatured: false,
        hasVirtualTour: false,
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
      ),
      PropertyListing(
        id: '4',
        title: 'Riverside Cottage',
        address: '101 River Road, Lakeside',
        price: 275000,
        bedrooms: 2,
        bathrooms: 1,
        sqft: 950,
        imageUrl:
            'https://images.unsplash.com/photo-1575517111839-3a3843ee7f5d',
        isFeatured: false,
        hasVirtualTour: false,
      ),
    ];

    final List<PropertyListing> featured = [
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
      ),
      PropertyListing(
        id: '6',
        title: 'Beach Villa',
        address: '25 Oceanfront Drive, Beachside',
        price: 1750000,
        bedrooms: 5,
        bathrooms: 4,
        sqft: 4500,
        imageUrl:
            'https://images.unsplash.com/photo-1613490493576-7fde63acd811',
        isFeatured: true,
        hasVirtualTour: true,
      ),
      PropertyListing(
        id: '7',
        title: 'Urban Loft',
        address: '42 Artist Way, Arts District',
        price: 875000,
        bedrooms: 2,
        bathrooms: 2,
        sqft: 1800,
        imageUrl:
            'https://images.unsplash.com/photo-1507089947368-19c1da9775ae',
        isFeatured: true,
        hasVirtualTour: true,
      ),
      PropertyListing(
        id: '8',
        title: 'Mountain Retreat',
        address: '88 Alpine Road, Mountainview',
        price: 980000,
        bedrooms: 3,
        bathrooms: 2,
        sqft: 2200,
        imageUrl:
            'https://images.unsplash.com/photo-1593955808003-93f6151e0f45',
        isFeatured: true,
        hasVirtualTour: false,
      ),
    ];

    if (mounted) {
      setState(() {
        _nearbyProperties.addAll(nearby);
        _featuredProperties.addAll(featured);
        _filteredNearbyProperties = List.from(_nearbyProperties);
        _filteredFeaturedProperties = List.from(_featuredProperties);
        _isLoading = false;
      });
    }
  }

  void _applyFilters({
    required RangeValues priceRange,
    required RangeValues sizeRange,
    required int bedrooms,
    required int bathrooms,
    required List<String> propertyTypes,
  }) {
    setState(() {
      _priceRange = priceRange;
      _sizeRange = sizeRange;
      _minBedrooms = bedrooms;
      _minBathrooms = bathrooms;
      _selectedTypes = propertyTypes;

      // Filter nearby properties
      _filteredNearbyProperties = _nearbyProperties.where((property) {
        bool matchesPrice =
            property.price >= priceRange.start &&
            property.price <= priceRange.end;
        bool matchesSize =
            property.sqft >= sizeRange.start &&
            property.sqft <= sizeRange.end;
        bool matchesBedrooms = property.bedrooms >= bedrooms;
        bool matchesBathrooms = property.bathrooms >= bathrooms;
        bool matchesType =
            propertyTypes.isEmpty || propertyTypes.contains(property.type);

        return matchesPrice &&
            matchesSize &&
            matchesBedrooms &&
            matchesBathrooms &&
            matchesType;
      }).toList();

      // Filter featured properties
      _filteredFeaturedProperties = _featuredProperties.where((property) {
        bool matchesPrice =
            property.price >= priceRange.start &&
            property.price <= priceRange.end;
        bool matchesSize =
            property.sqft >= sizeRange.start &&
            property.sqft <= sizeRange.end;
        bool matchesBedrooms = property.bedrooms >= bedrooms;
        bool matchesBathrooms = property.bathrooms >= bathrooms;
        bool matchesType =
            propertyTypes.isEmpty || propertyTypes.contains(property.type);

        return matchesPrice &&
            matchesSize &&
            matchesBedrooms &&
            matchesBathrooms &&
            matchesType;
      }).toList();
    });

    // Show feedback to the user
    if (_filteredNearbyProperties.isEmpty &&
        _filteredFeaturedProperties.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No properties match your filters'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Showing ${_filteredNearbyProperties.length + _filteredFeaturedProperties.length} properties',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _resetFilters() {
    setState(() {
      _priceRange = const RangeValues(100000, 2000000);
      _sizeRange = const RangeValues(500, 10000);
      _minBedrooms = 0;
      _minBathrooms = 0;
      _selectedTypes = [];
      _filteredNearbyProperties = List.from(_nearbyProperties);
      _filteredFeaturedProperties = List.from(_featuredProperties);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filters reset'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background with particles
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDarkMode
                    ? [const Color(0xFF0A1128), const Color(0xFF001F54)]
                    : [const Color(0xFFF8F5F2), const Color(0xFFFFFFFF)],
              ),
            ),
          ),

          // Animated particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              // Update particle positions
              for (var particle in _particles) {
                particle.position = Offset(
                  (particle.position.dx +
                          cos(particle.angle) * particle.speed) %
                      size.width,
                  (particle.position.dy +
                          sin(particle.angle) * particle.speed) %
                      size.height,
                );
              }

              return CustomPaint(
                painter: ParticlePainter(
                  particles: _particles,
                  isDarkMode: isDarkMode,
                ),
                size: Size(size.width, size.height),
              );
            },
          ),

          // Show appropriate screen based on selected tab
          SafeArea(child: _buildCurrentScreen(isDarkMode, size)),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(isDarkMode),
    );
  }

  Widget _buildCurrentScreen(bool isDarkMode, Size size) {
    switch (_currentIndex) {
      case 0:
        // Home tab - main content
        return _isLoading
            ? _buildLoadingView(isDarkMode)
            : _buildMainContent(isDarkMode, size);
      case 1:
        // Wishlist tab
        return const Center(
          child: Text(
            'Wishlist Screen Coming Soon',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
      case 2:
        // Schedule tab
        return const Center(
          child: Text(
            'Schedule Screen Coming Soon',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
      case 3:
        // Profile tab
        return const ProfileScreen();
      default:
        return _isLoading
            ? _buildLoadingView(isDarkMode)
            : _buildMainContent(isDarkMode, size);
    }
  }

  Widget _buildLoadingView(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDarkMode ? Colors.white : Colors.indigo,
          ),
          const SizedBox(height: 20),
          Text(
            'Discovering beautiful spaces...',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isDarkMode, Size size) {
    // Show empty state if no properties match the filters
    if (_filteredNearbyProperties.isEmpty &&
        _filteredFeaturedProperties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: isDarkMode ? Colors.white54 : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No properties match your filters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search criteria',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _resetFilters,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.blueAccent : Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // App Bar with Search and Location
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location display
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 18,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _isLocationLoading
                        ? Row(
                            children: [
                              SizedBox(
                                width: 16, 
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: isDarkMode ? Colors.white70 : Colors.indigo,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Getting location...",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            _locationError ?? _userLocation,
                            style: TextStyle(
                              fontSize: 14,
                              color: _locationError != null
                                ? Colors.amber
                                : (isDarkMode ? Colors.white70 : Colors.black54),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                    ),
                    if (_locationError != null)
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 18),
                        onPressed: _getCurrentLocation,
                        color: isDarkMode ? Colors.white70 : Colors.indigo,
                      ),
                  ],
                ),
                
                const SizedBox(height: 10),

                // Welcome text
                Text(
                  'Find your dream home',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Explore properties in your area',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),

                // Search bar
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color:
                        isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : Colors.white,
                    boxShadow: [
                      if (!isDarkMode)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search for homes near you',
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.white60 : Colors.black45,
                      ),
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        color: isDarkMode ? Colors.white70 : Colors.indigo,
                      ),
                      suffixIcon: InkWell(
                        onTap: () => _showFilterBottomSheet(size),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(15),
                            ),
                            color:
                                isDarkMode
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.indigo.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.filter_list,
                            color: isDarkMode ? Colors.white70 : Colors.indigo,
                          ),
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _handleSearch(value);
                      }
                    },
                  ),
                ),

                // Active filter indicators
                if (_selectedTypes.isNotEmpty || 
                    _minBedrooms > 0 || 
                    _minBathrooms > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        if (_minBedrooms > 0)
                          _buildFilterChip('$_minBedrooms+ beds', isDarkMode),
                        if (_minBathrooms > 0)
                          _buildFilterChip('$_minBathrooms+ baths', isDarkMode),
                        ..._selectedTypes.map(
                          (type) => _buildFilterChip(type, isDarkMode),
                        ),
                        GestureDetector(
                          onTap: _resetFilters,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            margin: const EdgeInsets.only(right: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  isDarkMode
                                      ? Colors.blueAccent.withOpacity(0.2)
                                      : Colors.indigo.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.close,
                                  size: 16,
                                  color:
                                      isDarkMode
                                          ? Colors.white70
                                          : Colors.indigo,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Clear All',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.indigo,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Nearby Properties Section
        if (_filteredNearbyProperties.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.only(left: 16, top: 20, bottom: 10),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Nearby Properties',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final property = _filteredNearbyProperties[index];
              return PropertyCard(
                property: property,
                isDarkMode: isDarkMode,
                onTap: () => _viewPropertyDetails(property),
                currencySymbol: _currencySymbol,
              );
            }, childCount: _filteredNearbyProperties.length),
          ),
        ],

        // Featured Properties Section
        if (_filteredFeaturedProperties.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.only(left: 16, top: 30, bottom: 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Featured Listings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 320,
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _filteredFeaturedProperties.length,
                itemBuilder: (context, index) {
                  final property = _filteredFeaturedProperties[index];
                  return FeaturedPropertyCard(
                    property: property,
                    isDarkMode: isDarkMode,
                    onTap: () => _viewPropertyDetails(property),
                    currencySymbol: _currencySymbol,
                  );
                },
              ),
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.blueAccent.withOpacity(0.2)
                : Colors.indigo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isDarkMode ? Colors.white : Colors.indigo,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0A1128) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home', isDarkMode),
              _buildNavItem(1, Icons.favorite_border, 'Wishlist', isDarkMode),
              _buildNavItem(2, Icons.calendar_month, 'Schedule', isDarkMode),
              _buildNavItem(3, Icons.person_outline, 'Profile', isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    bool isDarkMode,
  ) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode
                  ? Colors.blueAccent.withOpacity(0.2)
                  : Colors.indigo.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? (isDarkMode ? Colors.white : Colors.indigo)
                      : (isDarkMode ? Colors.white60 : Colors.black54),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected
                        ? (isDarkMode ? Colors.white : Colors.indigo)
                        : (isDarkMode ? Colors.white60 : Colors.black54),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewPropertyDetails(PropertyListing property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailScreen(property: property),
      ),
    );
  }

  void _handleSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredNearbyProperties = List.from(_nearbyProperties);
        _filteredFeaturedProperties = List.from(_featuredProperties);
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredNearbyProperties = _nearbyProperties.where((property) {
        return property.title.toLowerCase().contains(lowerQuery) ||
            property.address.toLowerCase().contains(lowerQuery) ||
            property.type.toLowerCase().contains(lowerQuery);
      }).toList();

      _filteredFeaturedProperties = _featuredProperties.where((property) {
        return property.title.toLowerCase().contains(lowerQuery) ||
            property.address.toLowerCase().contains(lowerQuery) ||
            property.type.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  void _showFilterBottomSheet(Size screenSize) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialPriceRange: _priceRange,
        initialSizeRange: _sizeRange,
        initialBedrooms: _minBedrooms,
        initialBathrooms: _minBathrooms,
        initialSelectedTypes: _selectedTypes,
        onApplyFilters: _applyFilters,
        screenHeight: screenSize.height,
      ),
    );
  }
}

// Custom Widgets
class PropertyCard extends StatelessWidget {
  final PropertyListing property;
  final bool isDarkMode;
  final VoidCallback onTap;
  final String currencySymbol;

  const PropertyCard({
    required this.property,
    required this.isDarkMode,
    required this.onTap,
    this.currencySymbol = '₹',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.white,
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
              // Property Image
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    children: [
                      Image.network(
                        property.imageUrl,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress
                                            .cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: isDarkMode ? Colors.white60 : Colors.indigo,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[200],
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: isDarkMode ? Colors.white60 : Colors.grey,
                            ),
                          );
                        },
                      ),
                      if (property.hasVirtualTour)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.indigo.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.view_in_ar,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'VR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Property Info
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        property.address,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildFeatureChip(
                            '${property.bedrooms} bed',
                            Icons.bed,
                            isDarkMode,
                          ),
                          _buildFeatureChip(
                            '${property.bathrooms} bath',
                            Icons.bathtub_outlined,
                            isDarkMode,
                          ),
                          _buildFeatureChip(
                            '${property.sqft} sqft',
                            Icons.square_foot,
                            isDarkMode,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${_formatPrice(property.price)}',  // Changed $ to ₹
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode
                                      ? Colors.blueAccent
                                      : Colors.indigo,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isDarkMode
                                      ? Colors.blueAccent.withOpacity(0.2)
                                      : Colors.indigo.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'View',
                              style: TextStyle(
                                color:
                                    isDarkMode ? Colors.blueAccent : Colors.indigo,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
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
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    // Format only for Indian Rupees
    if (price >= 10000000) {
      return '${(price / 10000000).toStringAsFixed(price % 10000000 == 0 ? 0 : 2)} Cr';
    } else if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(price % 100000 == 0 ? 0 : 2)} L';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}K';
    }
    return price.toString();
  }
}

class FeaturedPropertyCard extends StatelessWidget {
  final PropertyListing property;
  final bool isDarkMode;
  final VoidCallback onTap;
  final String currencySymbol;

  const FeaturedPropertyCard({
    required this.property,
    required this.isDarkMode,
    required this.onTap,
    this.currencySymbol = '₹',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.white,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  property.imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 150,
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: isDarkMode ? Colors.white60 : Colors.indigo,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: isDarkMode ? Colors.white60 : Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              // Featured badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Featured',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // VR badge
              if (property.hasVirtualTour)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Opening VR tour for ${property.title}',
                          ),
                          duration: const Duration(milliseconds: 800),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.view_in_ar, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'View in VR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Info section
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  property.address,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${_formatPrice(property.price)}',  // Changed $ to ₹
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.blueAccent : Colors.indigo,
                      ),
                    ),
                    Text(
                      '${property.sqft} sqft',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Action buttons
                InkWell(
                  onTap: onTap,
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [Colors.blueAccent, Colors.indigo]
                            : [Colors.indigo, Colors.indigo.shade700],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    // Format only for Indian Rupees
    if (price >= 10000000) {
      return '${(price / 10000000).toStringAsFixed(price % 10000000 == 0 ? 0 : 2)} Cr';
    } else if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(price % 100000 == 0 ? 0 : 2)} L';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}K';
    }
    return price.toString();
  }
}

class FilterBottomSheet extends StatefulWidget {
  final RangeValues initialPriceRange;
  final RangeValues initialSizeRange;
  final int initialBedrooms;
  final int initialBathrooms;
  final List<String> initialSelectedTypes;
  final Function({
    required RangeValues priceRange,
    required RangeValues sizeRange,
    required int bedrooms,
    required int bathrooms,
    required List<String> propertyTypes,
  })
  onApplyFilters;
  final double screenHeight;

  const FilterBottomSheet({
    required this.initialPriceRange,
    required this.initialSizeRange,
    required this.initialBedrooms,
    required this.initialBathrooms,
    required this.initialSelectedTypes,
    required this.onApplyFilters,
    required this.screenHeight,
    super.key,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late RangeValues _priceRange;
  late RangeValues _sizeRange;
  late int _bedrooms;
  late int _bathrooms;
  late List<String> _selectedTypes;

  final List<String> _propertyTypes = [
    'House',
    'Apartment',
    'Condo',
    'Townhouse',
    'Villa',
    'Cottage',
  ];

  @override
  void initState() {
    super.initState();
    _priceRange = widget.initialPriceRange;
    _sizeRange = widget.initialSizeRange;
    _bedrooms = widget.initialBedrooms;
    _bathrooms = widget.initialBathrooms;
    _selectedTypes = List.from(widget.initialSelectedTypes);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Use screenHeight to calculate the maximum height for the bottom sheet
    final maxHeight = widget.screenHeight * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0A1128) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle and title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white30 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Properties',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _priceRange = const RangeValues(100000, 2000000);
                      _sizeRange = const RangeValues(500, 10000);
                      _bedrooms = 0;
                      _bathrooms = 0;
                      _selectedTypes = [];
                    });
                  },
                  child: Text(
                    'Reset All',
                    style: TextStyle(
                      color: isDarkMode ? Colors.blueAccent : Colors.indigo,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Price Range
            _buildFilterSection(
              'Price Range',
              isDarkMode,
              child: Column(
                children: [
                  RangeSlider(
                    values: _priceRange,
                    min: 100000,
                    max: 2000000,
                    divisions: 19,
                    activeColor: isDarkMode ? Colors.blueAccent : Colors.indigo,
                    inactiveColor:
                        isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey.shade200,
                    labels: RangeLabels(
                      '₹${(_priceRange.start / 1000).round()}K',  // Changed $ to ₹
                      '₹${(_priceRange.end / 1000).round()}K',    // Changed $ to ₹
                    ),
                    onChanged: (values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${(_priceRange.start / 1000).round()}K',  // Changed $ to ₹
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        Text(
                          '₹${(_priceRange.end / 1000).round()}K',  // Changed $ to ₹
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Property Size
            _buildFilterSection(
              'Property Size (sqft)',
              isDarkMode,
              child: Column(
                children: [
                  RangeSlider(
                    values: _sizeRange,
                    min: 500,
                    max: 10000,
                    divisions: 19,
                    activeColor: isDarkMode ? Colors.blueAccent : Colors.indigo,
                    inactiveColor:
                        isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey.shade200,
                    labels: RangeLabels(
                      '${_sizeRange.start.round()}',
                      '${_sizeRange.end.round()}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _sizeRange = values;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_sizeRange.start.round()}',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        Text(
                          '${_sizeRange.end.round()}',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bedrooms and Bathrooms
            Row(
              children: [
                Expanded(
                  child: _buildFilterSection(
                    'Min. Bedrooms',
                    isDarkMode,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_bedrooms > 0) {
                              setState(() {
                                _bedrooms--;
                              });
                            }
                          },
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        Text(
                          '$_bedrooms+',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _bedrooms++;
                            });
                          },
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFilterSection(
                    'Min. Bathrooms',
                    isDarkMode,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_bathrooms > 0) {
                              setState(() {
                                _bathrooms--;
                              });
                            }
                          },
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        Text(
                          '$_bathrooms+',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _bathrooms++;
                            });
                          },
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Property Types
            _buildFilterSection(
              'Property Type',
              isDarkMode,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _propertyTypes.map((type) {
                  final isSelected = _selectedTypes.contains(type);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedTypes.remove(type);
                        } else {
                          _selectedTypes.add(type);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDarkMode
                                ? Colors.blueAccent.withOpacity(0.3)
                                : Colors.indigo.withOpacity(0.1))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? (isDarkMode
                                  ? Colors.blueAccent
                                  : Colors.indigo)
                              : (isDarkMode
                                  ? Colors.white30
                                  : Colors.grey.shade300),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          color: isSelected
                              ? (isDarkMode
                                  ? Colors.white
                                  : Colors.indigo)
                              : (isDarkMode
                                  ? Colors.white70
                                  : Colors.black54),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Apply button
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onApplyFilters(
                        priceRange: _priceRange,
                        sizeRange: _sizeRange,
                        bedrooms: _bedrooms,
                        bathrooms: _bathrooms,
                        propertyTypes: _selectedTypes,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDarkMode ? Colors.blueAccent : Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    bool isDarkMode, {
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class Particle {
  Offset position;
  final double size;
  final double speed;
  final double angle;

  Particle({
    required this.position,
    required this.size,
    required this.speed,
    required this.angle,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final bool isDarkMode;

  ParticlePainter({required this.particles, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = isDarkMode
            ? Colors.white.withOpacity(0.1 + (particle.size / 5) * 0.15)
            : Colors.indigo.withOpacity(
                0.04 + (particle.size / 5) * 0.06,
              );
      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PropertyListing {
  final String id;
  final String title;
  final String address;
  final int price;
  final int bedrooms;
  final int bathrooms;
  final int sqft;
  final String imageUrl;
  final bool isFeatured;
  final bool hasVirtualTour;
  final String type;
  final String description;
  final List<String> amenities;
  final List<String> additionalImages;

  PropertyListing({
    required this.id,
    required this.title,
    required this.address,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.sqft,
    required this.imageUrl,
    required this.isFeatured,
    required this.hasVirtualTour,
    this.type = 'House',
    this.description = 'Beautiful property with modern amenities and convenient location.',
    this.amenities = const ['Parking', 'Garden', 'Pool'],
    this.additionalImages = const [],
  });
}
