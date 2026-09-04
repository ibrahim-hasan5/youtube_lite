import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class YouTubeApiService {
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';
  String get _apiKey => dotenv.env['YOUTUBE_API_KEY'] ?? '';

  Future<List<dynamic>> getTrendingVideos() async {
    if (_apiKey.isEmpty) throw Exception('API Key is missing');
    final url = Uri.parse(
        '$_baseUrl/videos?part=snippet,contentDetails,statistics&chart=mostPopular&regionCode=US&maxResults=20&key=$_apiKey');
    
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['items'];
    } else {
      throw Exception('Failed to load trending videos: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> searchVideos(String query) async {
    if (_apiKey.isEmpty) throw Exception('API Key is missing');
    final url = Uri.parse(
        '$_baseUrl/search?part=snippet&q=$query&maxResults=20&type=video&key=$_apiKey');
    
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['items'];
    } else {
      throw Exception('Failed to search videos: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getVideoDetails(String videoId) async {
    if (_apiKey.isEmpty) throw Exception('API Key is missing');
    final url = Uri.parse(
        '$_baseUrl/videos?part=snippet,contentDetails,statistics&id=$videoId&key=$_apiKey');
    
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['items'] != null && data['items'].isNotEmpty) {
        return data['items'][0];
      } else {
        throw Exception('Video not found');
      }
    } else {
      throw Exception('Failed to load video details: ${response.statusCode}');
    }
  }
}
