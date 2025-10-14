import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/providers/newsFetch.dart';
import 'package:flutter_application_1/providers/savednews.dart';
import 'package:url_launcher/url_launcher.dart';

class DashScreen extends ConsumerWidget {
  const DashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fetch = ref.watch(FetchNews);
    final savedNewsAsync = ref.watch(savedNewsProvider);

    return Scaffold(
      body: fetch.when(
        data: (headlines) {
          return savedNewsAsync.when(
            data: (savedNews) => RefreshIndicator(
              onRefresh: () async {
                ref.refresh(FetchNews);
                ref.invalidate(savedNewsProvider);
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: headlines.length,
                itemBuilder: (context, index) {
                  final article = headlines[index];
                  final title = article['title'] ?? 'No title';
                  final description = article['description'] ?? '';
                  final imageUrl = article['urlToImage'];
                  final url = article['url'] ?? '';

                  final isSaved = savedNews.any((n) => n['url'] == url);

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () async {
                        if (url.isNotEmpty) {
                          final uri = Uri.parse(url);
                          if (!await launchUrl(uri)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Cannot open URL")),
                            );
                          }
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imageUrl != null)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                imageUrl,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.grey[300],
                                      height: 180,
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 50,
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(12),
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
                                const SizedBox(height: 8),
                                Text(
                                  description,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 120,
                                  child: ElevatedButton.icon(
                                    icon: isSaved
                                        ? const Icon(Icons.check)
                                        : const Icon(Icons.bookmark),
                                    label: Text(isSaved ? "Saved" : "Save"),
                                    onPressed: isSaved
                                        ? null
                                        : () {
                                            ref
                                                .read(savedNewsController)
                                                .saveNews({
                                                  'title': title,
                                                  'description': description,
                                                  'imageUrl': imageUrl,
                                                  'url': url,
                                                });
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text("Saved: $title"),
                                              ),
                                            );
                                          },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text("Error: $err")),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }
}
