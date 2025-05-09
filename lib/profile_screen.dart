import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Edit profile feature coming soon'),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.edit,
                          size: 16,
                          color: isDarkMode ? Colors.white : Colors.indigo,
                        ),
                        label: Text(
                          'Edit',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.indigo,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      // Profile image
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isDarkMode
                                  ? Colors.white10
                                  : Colors.grey.shade200,
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=300',
                            ),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  isDarkMode
                                      ? Colors.black.withOpacity(0.3)
                                      : Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(
                            color:
                                isDarkMode
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.white,
                            width: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // User name
                      Text(
                        'Alex Johnson',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // User email
                      Text(
                        'alex.johnson@example.com',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // User stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatItem(
                            isDarkMode,
                            '5',
                            'Wishlist',
                            Icons.favorite,
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: isDarkMode ? Colors.white24 : Colors.black12,
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                          _buildStatItem(
                            isDarkMode,
                            '3',
                            'Visits',
                            Icons.calendar_month,
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: isDarkMode ? Colors.white24 : Colors.black12,
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                          _buildStatItem(
                            isDarkMode,
                            '1',
                            'Offers',
                            Icons.business,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Profile sections
                _buildSection(context, isDarkMode, 'Account Settings', [
                  _buildMenuItem(
                    isDarkMode,
                    'Personal Information',
                    Icons.person_outline,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    isDarkMode,
                    'Notifications',
                    Icons.notifications_none,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    isDarkMode,
                    'Privacy & Security',
                    Icons.lock_outline,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    isDarkMode,
                    'Payment Methods',
                    Icons.credit_card,
                    onTap: () {},
                  ),
                ]),

                _buildSection(context, isDarkMode, 'Preferences', [
                  _buildMenuItem(
                    isDarkMode,
                    'Dark Mode',
                    Icons.dark_mode,
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged: (value) {
                        // Theme switching would be handled here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Theme switching coming soon'),
                          ),
                        );
                      },
                      activeColor: Colors.blueAccent,
                    ),
                    onTap: null,
                  ),
                  _buildMenuItem(
                    isDarkMode,
                    'Push Notifications',
                    Icons.notifications_active_outlined,
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {},
                      activeColor:
                          isDarkMode ? Colors.blueAccent : Colors.indigo,
                    ),
                    onTap: null,
                  ),
                  _buildMenuItem(
                    isDarkMode,
                    'Location Services',
                    Icons.location_on_outlined,
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {},
                      activeColor:
                          isDarkMode ? Colors.blueAccent : Colors.indigo,
                    ),
                    onTap: null,
                  ),
                ]),

                _buildSection(context, isDarkMode, 'Support & About', [
                  _buildMenuItem(
                    isDarkMode,
                    'Help Center',
                    Icons.help_outline,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    isDarkMode,
                    'Terms & Policies',
                    Icons.description_outlined,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    isDarkMode,
                    'About Sora Space',
                    Icons.info_outline,
                    onTap: () {},
                  ),
                ]),

                // Sign out button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sign out feature coming soon'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDarkMode ? Colors.white10 : Colors.grey.shade100,
                      foregroundColor:
                          isDarkMode ? Colors.white : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    bool isDarkMode,
    String count,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isDarkMode ? Colors.white70 : Colors.indigo,
            ),
            const SizedBox(width: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    bool isDarkMode,
    String title,
    List<Widget> items,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const Divider(),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    bool isDarkMode,
    String title,
    IconData icon, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDarkMode ? Colors.white70 : Colors.indigo),
      title: Text(
        title,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right,
            color: isDarkMode ? Colors.white30 : Colors.black26,
          ),
      onTap: onTap,
    );
  }
}
