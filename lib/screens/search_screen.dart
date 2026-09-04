import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/youtube_provider.dart';
import '../widgets/video_card.dart';
import 'video_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<YouTubeProvider>().searchVideos(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search YouTube',
            border: InputBorder.none,
          ),
          autofocus: true,
          onSubmitted: (_) => _performSearch(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _performSearch,
          ),
        ],
      ),
      body: Consumer<YouTubeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }
          if (provider.searchResults.isEmpty) {
            return const Center(child: Text('Search for videos'));
          }

          return ListView.builder(
            itemCount: provider.searchResults.length,
            itemBuilder: (context, index) {
              final video = provider.searchResults[index];
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
          );
        },
      ),
    );
  }
}
