import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get apiKey => dotenv.env["NEWS_API_KEY"] ?? "4de8183f19db45d58764f190e3d2c0b6";
  static const String baseUrl = 'https://newsapi.org/v2';
  static const String everything = '/everything';
  static const String topHeadlines = '/top-headlines';
  
  // Categories
  static const List<String> categories = [
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology',
  ];
  
  // Category display names
  static const Map<String, String> categoryNames = {
    'general': 'General',
    'business': 'Business',
    'entertainment': 'Entertainment',
    'health': 'Health',
    'science': 'Science',
    'sports': 'Sports',
    'technology': 'Technology',
  };
}
