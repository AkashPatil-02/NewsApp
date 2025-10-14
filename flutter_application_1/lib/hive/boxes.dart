import 'package:hive_flutter/hive_flutter.dart';

late Box boxSavedNews;

Future<void> initHive() async {
  await Hive.initFlutter();
  boxSavedNews = await Hive.openBox('saved_news_box');
}
