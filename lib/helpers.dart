import 'dart:io';
import 'package:azure_translation/azure_translation.dart';
import 'package:dotenv/dotenv.dart';
import 'package:elegant/elegant.dart';
import 'package:hard_translator/jieba/lib/analysis/jieba_segmenter.dart';

(String, String) loadEnv() {
  final DotEnv env = DotEnv()..load();
  final String key = env['AZURE_KEY'] ?? 'YOUR_KEY';
  final String region = env['AZURE_REGION'] ?? 'YOUR_REGION';
  return (key, region);
}

bool errorPresent(Result<List<TranslationResult>, AzureTranslationError> result) {
  if (!result.ok) {
    stdout.write('Error: ${result.error}');
    return true;
  } else if (result.object!.isEmpty || result.object == null) {
    stdout.write('Error: empty response');
    return true;
  }
  return false;
}

void listLanguageCodes() async {
  final Result<LanguageList, AzureTranslationError> langListResult = await languages();
  stdout.write(langListResult.object?.transliteration?.join('\n'));
}

String getInput() {
  String? query;
  while (query == null) {
    stdout.write('input your text: ');
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

bool isInputLanguage(String thisLanguage, String inputLanguage) {
  if (thisLanguage == 'zh-Hans' && inputLanguage == 'zh-Hant' ||
      thisLanguage == 'zh-Hant' && inputLanguage == 'zh-Hans') {
    return true; // fix for simp/trad chinese
  } else if (thisLanguage == inputLanguage) {
    return true;
  } else {
    return false;
  }
}

/// TODO: implement Japanese checker as well as any other non-space-delimited languages.
List<String> segmentText(String inputText, String languageCode, JiebaSegmenter segmenter) {
  List<String> segmented;
  if (languageCode == 'zh-Hans' || languageCode == 'zh-Hant') {
    segmented = List.from(segmenter.process(inputText, SegMode.SEARCH).map((e) => e.word));
  } else {
    segmented = inputText.split(' ');
  }
  return segmented;
}
