import 'package:hive/hive.dart';

part 'saved.g.dart';

@HiveType(typeId: 1)
class Saved {
  Saved({required this.saved_news});
  @HiveField(0)
  List<Map<String, dynamic>> saved_news;
}
