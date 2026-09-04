import 'package:flutter/material.dart';
import '../services/youtube_api_service.dart';

class YouTubeProvider with ChangeNotifier {
  final YouTubeApiService _apiService = YouTubeApiService();

  List<dynamic> _trendingVideos = [];
  List<dynamic> get trendingVideos => _trendingVideos;

  List<dynamic> _searchResults = [];
  List<dynamic> get searchResults => _searchResults;

  Map<String, dynamic>? _currentVideoDetails;
  Map<String, dynamic>? get currentVideoDetails => _currentVideoDetails;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchTrendingVideos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _trendingVideos = await _apiService.getTrendingVideos();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchVideos(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchVideos(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchVideoDetails(String videoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentVideoDetails = await _apiService.getVideoDetails(videoId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }
}
