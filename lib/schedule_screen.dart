import 'package:flutter/material.dart';
import 'home_screen.dart'; // For PropertyListing model
import 'property_detail_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<ScheduledVisit> _upcomingVisits = [];
  List<ScheduledVisit> _pastVisits = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadScheduleData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadScheduleData() async {
    // Simulate API loading delay
    await Future.delayed(const Duration(milliseconds: 1200));

    // Sample scheduled visits data - in a real app this would come from a database
    final upcomingVisits = [
      ScheduledVisit(
        id: '1',
        property: PropertyListing(
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
        date: DateTime.now().add(const Duration(days: 2)),
        time: '10:30 AM',
        agentName: 'Sarah Johnson',
      ),
      ScheduledVisit(
        id: '2',
        property: PropertyListing(
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
          type: 'Villa',
        ),
        date: DateTime.now().add(const Duration(days: 5)),
        time: '2:00 PM',
        agentName: 'Michael Rodriguez',
      ),
    ];

    final pastVisits = [
      ScheduledVisit(
        id: '3',
        property: PropertyListing(
          id: '2',
          title: 'Family Home',
          address: '456 Maple Ave, Suburbia',
          price: 525000,
          bedrooms: 4,
          bathrooms: 3,
          sqft: 2400,
          imageUrl:
              'https://images.unsplash.com/photo-1598228723793-52759bba239c',
          isFeatured: false,
          hasVirtualTour: false,
          type: 'House',
        ),
        date: DateTime.now().subtract(const Duration(days: 10)),
        time: '11:00 AM',
        agentName: 'Emily Chen',
        feedback: 'Great property but looking for more outdoor space.',
      ),
    ];

    if (mounted) {
      setState(() {
        _upcomingVisits = upcomingVisits;
        _pastVisits = pastVisits;
        _isLoading = false;
      });
    }
  }

  void _cancelVisit(ScheduledVisit visit) {
    setState(() {
      _upcomingVisits.remove(visit);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Visit to ${visit.property.title} canceled'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              _upcomingVisits.add(visit);
              // Re-sort by date
              _upcomingVisits.sort((a, b) => a.date.compareTo(b.date));
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
        title: const Text('My Schedule'),
        backgroundColor: isDarkMode ? const Color(0xFF0A1128) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isDarkMode ? Colors.blueAccent : Colors.indigo,
          labelColor: isDarkMode ? Colors.white : Colors.indigo,
          unselectedLabelColor: isDarkMode ? Colors.white60 : Colors.black54,
          tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past')],
        ),
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
                : TabBarView(
                  controller: _tabController,
                  children: [
                    // Upcoming visits tab
                    _upcomingVisits.isEmpty
                        ? _buildEmptyState(
                          isDarkMode,
                          'No upcoming visits',
                          'Schedule a property visit to see it here',
                          Icons.calendar_today,
                        )
                        : _buildUpcomingVisits(isDarkMode),

                    // Past visits tab
                    _pastVisits.isEmpty
                        ? _buildEmptyState(
                          isDarkMode,
                          'No past visits',
                          'Your visit history will appear here',
                          Icons.history,
                        )
                        : _buildPastVisits(isDarkMode),
                  ],
                ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: isDarkMode ? Colors.blueAccent : Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.pop(
            context,
          ); // Navigate back to home to schedule a new visit
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(
    bool isDarkMode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: isDarkMode ? Colors.white30 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
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
            label: const Text('Find Properties'),
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

  Widget _buildUpcomingVisits(bool isDarkMode) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _upcomingVisits.length,
      itemBuilder: (context, index) {
        final visit = _upcomingVisits[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => PropertyDetailScreen(property: visit.property),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
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
              children: [
                // Property image and details
                Row(
                  children: [
                    // Property image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                      ),
                      child: Image.network(
                        visit.property.imageUrl,
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
                              visit.property.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              visit.property.address,
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    isDarkMode
                                        ? Colors.white70
                                        : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  size: 14,
                                  color:
                                      isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(visit.date),
                                  style: TextStyle(
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color:
                                      isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  visit.time,
                                  style: TextStyle(
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                    fontWeight: FontWeight.w500,
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

                // Agent info and action buttons
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode
                            ? Colors.black.withOpacity(0.1)
                            : Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 18,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        visit.agentName,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          // Show reschedule dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reschedule feature coming soon'),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: isDarkMode ? Colors.white70 : Colors.indigo,
                        ),
                        label: Text(
                          'Reschedule',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.indigo,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 30),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _cancelVisit(visit),
                        icon: Icon(
                          Icons.cancel_outlined,
                          size: 16,
                          color: isDarkMode ? Colors.redAccent : Colors.red,
                        ),
                        label: Text(
                          'Cancel',
                          style: TextStyle(
                            color: isDarkMode ? Colors.redAccent : Colors.red,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 30),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPastVisits(bool isDarkMode) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pastVisits.length,
      itemBuilder: (context, index) {
        final visit = _pastVisits[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => PropertyDetailScreen(property: visit.property),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
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
              children: [
                // Property image and details
                Row(
                  children: [
                    // Property image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                      ),
                      child: Image.network(
                        visit.property.imageUrl,
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
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    visit.property.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isDarkMode
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isDarkMode
                                            ? Colors.white.withOpacity(0.1)
                                            : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Completed',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          isDarkMode
                                              ? Colors.white70
                                              : Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              visit.property.address,
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    isDarkMode
                                        ? Colors.white70
                                        : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  size: 14,
                                  color:
                                      isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(visit.date),
                                  style: TextStyle(
                                    color:
                                        isDarkMode
                                            ? Colors.white70
                                            : Colors.black54,
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

                // Feedback section
                if (visit.feedback != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Colors.black.withOpacity(0.1)
                              : Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Feedback:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          visit.feedback!,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class ScheduledVisit {
  final String id;
  final PropertyListing property;
  final DateTime date;
  final String time;
  final String agentName;
  final String? feedback;

  ScheduledVisit({
    required this.id,
    required this.property,
    required this.date,
    required this.time,
    required this.agentName,
    this.feedback,
  });
}
