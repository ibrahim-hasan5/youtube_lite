import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../providers/youtube_provider.dart';

class VideoDetailsScreen extends StatefulWidget {
  final String videoId;

  const VideoDetailsScreen({Key? key, required this.videoId}) : super(key: key);

  @override
  State<VideoDetailsScreen> createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<YouTubeProvider>().fetchVideoDetails(widget.videoId);
    });
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Details'),
      ),
      body: Consumer<YouTubeProvider>(
        builder: (context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              YoutubePlayer(
                controller: _controller,
                aspectRatio: 16 / 9,
              ),
              Expanded(
                child: provider.isLoading || provider.currentVideoDetails == null
                  ? const Center(child: CircularProgressIndicator())
                  : _buildVideoInfo(provider.currentVideoDetails!),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVideoInfo(Map<String, dynamic> video) {
    final snippet = video['snippet'];
    final statistics = video['statistics'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            snippet['title'] ?? '',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatNumber(statistics['viewCount'])} views • ${_formatNumber(statistics['likeCount'])} likes',
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
          const Divider(height: 32),
          Row(
            children: [
              const CircleAvatar(
                child: Icon(Icons.person),
              ),
              const SizedBox(width: 12),
              Text(
                snippet['channelTitle'] ?? '',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            snippet['description'] ?? '',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _formatNumber(String? countStr) {
    if (countStr == null) return '0';
    final count = int.tryParse(countStr) ?? 0;
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }
}
