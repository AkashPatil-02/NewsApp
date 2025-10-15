import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/savednews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IconButton(
          onPressed: () {
            showSearch(context: context, delegate: CustomDelegate());
          },
          icon: Icon(Icons.search),
          iconSize: 60,
        ),
      ),
    );
  }
}

class CustomDelegate extends SearchDelegate {
  List<dynamic> searchResults = [];

  Future<List<dynamic>> fetchSearchResults(String query) async {
    try {
      final response = await http.get(
        Uri.parse("${dotenv.env['ADDRESS']}/search?q=$query"),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['articles'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching search results: $e");
      return [];
    }
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchSearchResults(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No results for "$query"'));
        }

        final results = snapshot.data!;
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final article = results[index];
            final title = article['title'] ?? 'No title';
            final description = article['description'] ?? '';
            final imageUrl = article['urlToImage'];

            return Card(
              margin: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl != null)
                    Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(description, style: const TextStyle(fontSize: 14)),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.bookmark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(child: Text('Type something to search news...'));
  }
}
