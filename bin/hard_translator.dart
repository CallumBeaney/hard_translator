import 'dart:io';
import 'package:elegant/src/result.dart';
import 'package:azure_translation/azure_translation.dart';
import 'package:dotenv/dotenv.dart';
import 'package:hard_translator/jieba/lib/analysis/jieba_segmenter.dart';

(String, String) loadEnv() {
  final DotEnv env = DotEnv()..load();
  final String key = env['AZURE_KEY'] ?? 'YOUR_KEY';
  final String region = env['AZURE_REGION'] ?? 'YOUR_REGION';
  return (key, region);
}

const List<String> _targetLanguages = [
  'zh',
  'en',
  'ja',
];

void main(List<String> arguments) async {
  final (String key, String region) = loadEnv();
  JiebaSegmenter seg = await JiebaSegmenter.init().then((_) => JiebaSegmenter());

  /*
    1. user inputs a sentence
    2. translate sentence to Chinese
    3. segment chinese and translate each word
    4. 
  */

  // final Result<LanguageList, AzureTranslationError> langListResult = await languages();
  // print(langListResult.object?.transliteration?.join('\n'));

  // clearTerminal();
  String inputSentence = getInput();

  // Extract from a list of DetectionResult classes the first language field
  final String inputLanguage = await detect([inputSentence], key: key, region: region)
      .then((value) => value.object!.first.language);
  final String targetLanguage = inputLanguage == 'zh-Hans' ? 'en' : 'zh-Hans';

  // get a translation of the input string, treated as a [list] containing a single String element.
  final Result<List<TranslationResult>, AzureTranslationError> res = await translate(
    [inputSentence],
    languages: _targetLanguages,
    key: key,
    region: region,
    baseLanguage: inputLanguage,
  );

  if (!res.ok) {
    print('Error: ${res.error}');
    return;
  }

  final String translatedInput =
      res.object!.first.translations.firstWhere((e) => e.to == targetLanguage).text;

  // now we need to split that input string up
  List<String> segmented = segmentText(translatedInput, targetLanguage, seg);

  var revTransRes =
      await translate(segmented, key: key, region: region, languages: _targetLanguages);

  if (!revTransRes.ok) {
    print('Error: ${revTransRes.error}');
    return;
  }

  List<String> reverseTranslation = [];
  for (final t in revTransRes.object!) {
    final String word = t.translations.firstWhere((e) => e.to == inputLanguage).text;
    reverseTranslation.add(word);
  }
  String finalText = reverseTranslation.join(' ');

  print(translatedInput);
  print(finalText);
}

//
//  helpers begin
//

String getInput() {
  String? query;
  while (query == null) {
    print('input your text: ');
    query = stdin.readLineSync();
  }
  return query;
}

void clearTerminal() {
  /// If using Terminal.app, running a 'clear' command just adds empty space equivalent to the
  /// number of \n that fit in the terminal. Scrolling up through the links into this empty space
  /// is irratating, so it will only perform a clear if I call this script from the VSc terminal.
  if (Platform.environment['TERM_PROGRAM'] != 'Apple_Terminal') {
    stdout.write(Process.runSync('clear', [], runInShell: true).stdout);
  }
}

/// TODO: implement Japanese checker as well as any other non-space-delimited languages.
List<String> segmentText(String inputText, String languageCode, JiebaSegmenter segmenter) {
  List<String> segmented;
  if (languageCode == 'zh-Hans') {
    segmented = List.from(segmenter.process(inputText, SegMode.SEARCH).map((e) => e.word));
  } else {
    segmented = inputText.split(' ');
  }
  return segmented;
}
