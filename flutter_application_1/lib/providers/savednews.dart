import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/hive/boxes.dart';

final savedNewsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final box = boxSavedNews;
  final raw = box.get('saved_news', defaultValue: <dynamic>[]) as List<dynamic>;

  final List<Map<String, dynamic>> result = [];

  for (final item in raw) {
    try {
      if (item is String) {
        final decoded = jsonDecode(item);
        if (decoded is Map) {
          result.add(Map<String, dynamic>.from(decoded));
        }
      } else if (item is Map) {
        result.add(Map<String, dynamic>.from(item));
      }
    } catch (_) {}
  }

  return result;
});

final savedNewsController = Provider((ref) => SavedNewsController(ref));

class SavedNewsController {
  final Ref ref;
  SavedNewsController(this.ref);

  void saveNews(Map<String, dynamic> article) {
    final box = boxSavedNews;
    final raw =
        box.get('saved_news', defaultValue: <dynamic>[]) as List<dynamic>;

    final data = raw.map((item) {
      if (item is Map) return jsonEncode(item);
      if (item is String) return item;
      return jsonEncode({});
    }).toList();

    final encoded = jsonEncode(article);

    final alreadySaved = data.any((item) {
      try {
        final decoded = jsonDecode(item);
        return decoded is Map && decoded['url'] == article['url'];
      } catch (_) {
        return false;
      }
    });

    if (!alreadySaved) {
      data.add(encoded);
      box.put('saved_news', data);
      ref.invalidate(savedNewsProvider);
    }
  }

  void removeNews(String url) {
    final box = boxSavedNews;
    final raw =
        box.get('saved_news', defaultValue: <dynamic>[]) as List<dynamic>;

    final filtered = raw.where((item) {
      try {
        final decoded = jsonDecode(item is Map ? jsonEncode(item) : item);
        return decoded is! Map || decoded['url'] != url;
      } catch (_) {
        return true;
      }
    }).toList();

    box.put('saved_news', filtered);
    ref.invalidate(savedNewsProvider);
  }

  void clearAll() {
    boxSavedNews.put('saved_news', []);
    ref.invalidate(savedNewsProvider);
  }
}
