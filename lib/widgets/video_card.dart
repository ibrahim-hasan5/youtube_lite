import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VideoCard extends StatelessWidget {
  final dynamic video;
  final VoidCallback onTap;

  const VideoCard({Key? key, required this.video, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final snippet = video['snippet'];
    final statistics = video['statistics'];
    
    // Some search results don't return statistics, so we handle nulls.
    final views = statistics != null ? _formatViews(statistics['viewCount']) : '';
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: snippet['thumbnails']['high']['url'],
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snippet['title'] ?? 'No Title',
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          views.isNotEmpty 
                            ? '${snippet['channelTitle']} • $views views'
                            : snippet['channelTitle'] ?? 'Unknown Channel',
                          style: TextStyle(color: Colors.grey[400], fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_vert, color: Colors.white, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatViews(String? viewCountStr) {
    if (viewCountStr == null) return '';
    final count = int.tryParse(viewCountStr) ?? 0;
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }
}
