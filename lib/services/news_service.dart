import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/news_model.dart';
import 'package:flutter/foundation.dart';

class NewsService {
  // final String _apiKey = dotenv.env['NEWS_API_KEY'] ?? "";
  String get _apiKey => dotenv.env['NEWS_API_KEY'] ?? "";
  final String _baseUrl = "https://newsapi.org/v2/everything";

  Future<List<SkinNews>> fetchSkinNews() async {
    if (_apiKey.isEmpty) {
      debugPrint("❌ Error: NEWS_API_KEY not found in .env file");
      return [];
    }

    final response = await http.get(
      Uri.parse(
        "$_baseUrl?q=skin+health+dermatology&sortBy=publishedAt&apiKey=$_apiKey",
      ),
    );
    debugPrint(response.body);

    if (response.statusCode == 200) {
      // final data = json.decode(response.body);
      // List<dynamic> articles = data['articles'];
      final data = json.decode(response.body);

      if (data['articles'] == null) {
        debugPrint("No articles found: ${response.body}");
        return [];
      }

      List<dynamic> articles = data['articles'];

      return articles
          .where((article) => article['title'] != "[Removed]")
          .map((article) => SkinNews.fromJson(article))
          .toList();
    } else {
      debugPrint("API Error: ${response.statusCode} - ${response.body}");
      throw Exception("Failed to load news");
    }
  }
}




