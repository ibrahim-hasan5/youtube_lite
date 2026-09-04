import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/youtube_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/video_card.dart';
import 'search_screen.dart';
import 'video_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['All', 'Music', 'Mixes', 'Gaming', 'Live', 'News', 'Podcasts'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<YouTubeProvider>().fetchTrendingVideos();
    });
  }

  Future<void> _refresh() async {
    await context.read<YouTubeProvider>().fetchTrendingVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildCategoriesBar(),
          Expanded(
            child: Consumer<YouTubeProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.trendingVideos.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                if (provider.error != null && provider.trendingVideos.isEmpty) {
                  return _buildErrorState(provider);
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  color: Colors.white,
                  backgroundColor: Colors.black,
                  child: ListView.builder(
                    itemCount: provider.trendingVideos.length,
                    itemBuilder: (context, index) {
                      final video = provider.trendingVideos[index];
                      return VideoCard(
                        video: video,
                        onTap: () {
                          final videoId = video['id'] is String ? video['id'] : video['id']['videoId'];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VideoDetailsScreen(videoId: videoId),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0F0F0F),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleSpacing: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.play_circle_fill, color: Colors.red, size: 28),
          const SizedBox(width: 4),
          const Text(
            'YouTube',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -1.0,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 2),
          const Text(
            'BD',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          onPressed: () {},
        ),
        // Profile avatar / Sign-In button
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isSignedIn) {
              // Signed in: show profile photo with popup menu
              return _buildProfileMenu(authProvider);
            } else {
              // Not signed in: show sign-in button
              return GestureDetector(
                onTap: () => _showSignInDialog(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFF3EA6FF),
                    child: Icon(Icons.person, size: 18, color: Colors.white),
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildProfileMenu(AuthProvider authProvider) {
    final user = authProvider.user!;
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      color: const Color(0xFF282828),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'sign_out') {
          authProvider.signOut();
        }
      },
      itemBuilder: (context) => [
        // User info header
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    backgroundColor: Colors.grey,
                    child: user.photoURL == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email ?? '',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.grey, thickness: 0.3),
            ],
          ),
        ),
        // Menu items
        _buildPopupMenuItem('your_channel', Icons.portrait_outlined, 'Your channel'),
        _buildPopupMenuItem('your_videos', Icons.video_library_outlined, 'Your videos'),
        _buildPopupMenuItem('purchases', Icons.shopping_bag_outlined, 'Purchases and memberships'),
        _buildPopupMenuItem('time_watched', Icons.access_time, 'Time watched'),
        const PopupMenuDivider(),
        _buildPopupMenuItem('youtube_studio', Icons.bar_chart_outlined, 'YouTube Studio'),
        _buildPopupMenuItem('switch_account', Icons.switch_account_outlined, 'Switch account'),
        _buildPopupMenuItem('incognito', Icons.security_outlined, 'Turn on Incognito'),
        const PopupMenuDivider(),
        _buildPopupMenuItem('appearance', Icons.dark_mode_outlined, 'Appearance: Device theme'),
        _buildPopupMenuItem('language', Icons.language, 'Language: English'),
        _buildPopupMenuItem('location', Icons.location_on_outlined, 'Location: Bangladesh'),
        _buildPopupMenuItem('restricted', Icons.shield_outlined, 'Restricted Mode: Off'),
        const PopupMenuDivider(),
        _buildPopupMenuItem('settings', Icons.settings_outlined, 'Settings'),
        _buildPopupMenuItem('help', Icons.help_outline, 'Help & feedback'),
        const PopupMenuDivider(),
        _buildPopupMenuItem('sign_out', Icons.logout, 'Sign out'),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: CircleAvatar(
          radius: 14,
          backgroundImage: user.photoURL != null
              ? NetworkImage(user.photoURL!)
              : null,
          backgroundColor: Colors.grey,
          child: user.photoURL == null
              ? Text(
                  (user.displayName ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                )
              : null,
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, IconData icon, String title) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  void _showSignInDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Sign in to YouTube Lite',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Sign in with your Google account to access personalized features.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  if (authProvider.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        authProvider.error!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              await authProvider.signInWithGoogle();
                              if (authProvider.isSignedIn && context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                      icon: authProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.g_mobiledata, size: 28),
                      label: Text(
                        authProvider.isLoading ? 'Signing in...' : 'Sign in with Google',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3EA6FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0F0F0F),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // Drawer Header with user info
              if (authProvider.isSignedIn)
                _buildSignedInDrawerHeader(authProvider)
              else
                _buildSignedOutDrawerHeader(),
              _buildDrawerItem(Icons.home_filled, 'Home', isSelected: true),
              _buildDrawerItem(Icons.play_circle_outline, 'Shorts'),
              const Divider(color: Colors.grey, thickness: 0.2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: const [
                    Text('Subscriptions', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                    Icon(Icons.chevron_right, color: Colors.white, size: 20),
                  ],
                ),
              ),
              _buildSubscriptionItem('Coke Studio Bangla'),
              _buildSubscriptionItem('Next Gear'),
              _buildSubscriptionItem('Fully Faltoo'),
              _buildSubscriptionItem('T-Series'),
              _buildSubscriptionItem('Club 11 Entertai...'),
              _buildSubscriptionItem('Saregama Music'),
              _buildSubscriptionItem('SOMOY TV'),
              _buildDrawerItem(Icons.keyboard_arrow_down, 'Show more'),
              const Divider(color: Colors.grey, thickness: 0.2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: const [
                    Text('You', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                    Icon(Icons.chevron_right, color: Colors.white, size: 20),
                  ],
                ),
              ),
              _buildDrawerItem(Icons.portrait, 'Your channel'),
              _buildDrawerItem(Icons.history, 'History'),
              _buildDrawerItem(Icons.playlist_play, 'Playlists'),
              _buildDrawerItem(Icons.watch_later_outlined, 'Watch later'),
              _buildDrawerItem(Icons.thumb_up_alt_outlined, 'Liked videos'),
              _buildDrawerItem(Icons.video_library_outlined, 'Your videos'),
              _buildDrawerItem(Icons.download_outlined, 'Downloads'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSignedInDrawerHeader(AuthProvider authProvider) {
    final user = authProvider.user!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: user.photoURL != null
                ? NetworkImage(user.photoURL!)
                : null,
            backgroundColor: Colors.grey,
            child: user.photoURL == null
                ? Text(
                    (user.displayName ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            user.displayName ?? 'User',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            user.email ?? '',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSignedOutDrawerHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Color(0xFF3EA6FF),
            child: Icon(Icons.person, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text(
            'Sign in',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // Close drawer
              _showSignInDialog();
            },
            child: const Text(
              'Tap to sign in with Google',
              style: TextStyle(color: Color(0xFF3EA6FF), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey[800] : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
        dense: true,
        horizontalTitleGap: 0,
        onTap: () {},
      ),
    );
  }

  Widget _buildSubscriptionItem(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: const CircleAvatar(
          radius: 12,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, size: 16, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
        trailing: const Icon(Icons.circle, color: Colors.blue, size: 8),
        dense: true,
        horizontalTitleGap: 0,
        onTap: () {},
      ),
    );
  }

  Widget _buildCategoriesBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategoryIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
              // Functionality to filter can be added here
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFF272727),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                _categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(YouTubeProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text('Error: ${provider.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refresh,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
