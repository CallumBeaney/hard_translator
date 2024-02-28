import 'dart:io';
import 'package:elegant/src/result.dart';
import 'package:hard_translator/hard_translator.dart' as hc;
import 'package:azure_translation/azure_translation.dart';
import 'package:dotenv/dotenv.dart';

(String, String) loadEnv() {
  final DotEnv env = DotEnv()..load();
  final String key = env['AZURE_KEY'] ?? 'YOUR_KEY';
  final String region = env['AZURE_REGION'] ?? 'YOUR_REGION';
  return (key, region);
}

final List<String> _targetLanguages = [
  // 'ja',
  'zh',
  'en',
];

const String targetLang = 'zh-Hans';

void main(List<String> arguments) async {
  final (String key, String region) = loadEnv();

  // final Result<LanguageList, AzureTranslationError> langListResult = await languages();
  // print(langListResult.object?.transliteration?.join('\n'));

  // clearTerminal();
  String inputText = getInput();
  List<String> parsedInput = inputText.split(' ');

  final Result<List<TranslationResult>, AzureTranslationError> res = await translate(
    [inputText], // get a "proper" translation from the input string, whatever the length.
    languages: _targetLanguages,
    key: key,
    region: region,
    // baseLanguage: // auto-detected
  );

  if (!res.ok) {
    print('Error: ${res.error}');
    return;
  }

  final TranslationResult sentenceTranslation = res.object!.first;
  final String splitSentence = sentenceTranslation.translations.first.text;
  // print(sentenceTranslation);
  print(splitSentence);
}

// helpers begin

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
