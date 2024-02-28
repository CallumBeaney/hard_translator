import 'package:azure_translation/azure_translation.dart';

/*
  1. check whether source language is supported 
  2. translate sentence to target language
  3. For word in sentence, translate (2) back to src language.

*/

// https://pub.dev/documentation/azure_translation/latest/
// https://github.com/alexobviously/azure_translation

Future<void> detectLang(List<String> queries, List<String> langs, String key, String region) async {
  final res = await detect(
    queries,
    key: key,
    region: region,
  );

  if (!res.ok) {
    print('Error: ${res.error}');
    return;
  }

  final detections = res.object!;
  for (final d in detections) {
    print('${d.text}: ${d.language} (${d.score})');
  }
}

Future<List<String>?> translateText(
    List<String> queries, List<String> langs, String key, String region) async {
  final res = await translate(
    queries,
    // baseLanguage: // auto-detected
    languages: langs,
    key: key,
    region: region,
  );

  if (!res.ok) {
    print('Error: ${res.error}');
    return null;
  }

  final translations = res.object!;
  for (final t in translations) {
    print('${t.text}: ${t.translations}');
  }
}
