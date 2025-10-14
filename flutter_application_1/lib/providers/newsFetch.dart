import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final FetchNews = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await http.get(
    Uri.parse("${dotenv.env['ADDRESS']}/headlines"),
  );
  if (response.statusCode != 200) throw Exception("Error");
  final data = json.decode(response.body);

  final List<dynamic> articles = data['articles'] ?? [];
  return articles.map((e) => Map<String, dynamic>.from(e)).toList();
});
