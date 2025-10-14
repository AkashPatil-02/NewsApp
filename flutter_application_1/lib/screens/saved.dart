import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/providers/savednews.dart';
import 'package:url_launcher/url_launcher.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedNewsAsync = ref.watch(savedNewsProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          savedNewsAsync.when(
            data: (savedNews) {
              if (savedNews.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_forever),
                  tooltip: "Clear All",
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Clear All Saved News"),
                        content: const Text(
                          "Are you sure you want to delete all saved news?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      ref.read(savedNewsController).clearAll();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("All saved news cleared")),
                      );
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: savedNewsAsync.when(
        data: (savedNews) {
          if (savedNews.isEmpty) {
            return const Center(child: Text("No saved news yet."));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(savedNewsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: savedNews.length,
              itemBuilder: (context, index) {
                final article = savedNews[index];
                final title = article['title'] ?? '';
                final description = article['description'] ?? '';
                final url = article['url'] ?? '';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        ref.read(savedNewsController).removeNews(url);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Removed: $title")),
                        );
                      },
                    ),
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
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }
}
