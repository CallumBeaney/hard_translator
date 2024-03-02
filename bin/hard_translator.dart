import 'dart:io';

import 'package:elegant/src/result.dart';
import 'package:azure_translation/azure_translation.dart';
import 'package:hard_translator/defines.dart';
import 'package:hard_translator/helpers.dart';
import 'package:hard_translator/jieba/lib/analysis/jieba_segmenter.dart';

void main() async {
  final (String key, String region) = loadEnv();
  JiebaSegmenter seg = await JiebaSegmenter.init().then((_) => JiebaSegmenter());
  Map<String, ProcessedTranslation> finalSentences = {};

  clearTerminal();

  final String inputSentence = getInput();
  final String inputLanguage = await detect([inputSentence], key: key, region: region)
      .then((value) => value.object!.first.language);

  // get a translation of the input string, treated as a [list] containing a single String element.
  final Result<List<TranslationResult>, AzureTranslationError> res = await translate(
    [inputSentence],
    languages: targetLanguages,
    key: key,
    region: region,
    baseLanguage: inputLanguage,
  );
  if (errorPresent(res)) exit(1);

  final List<Translation> translations = res.object!.first.translations;

  // take each translated sentence, split each into individual words, and translate them back word by word
  for (final Translation t in translations) {
    String thisLanguage = t.to, thisSentence = t.text;
    if (isInputLanguage(thisLanguage, inputLanguage)) continue;

    List<String> segmented = segmentText(thisSentence, thisLanguage, seg);

    // baseLanguage: you must define because you are translating word-by-word e.g. `comment` means `how` in French, is also a valid word in English
    var ret = await translate(segmented,
        key: key, region: region, languages: [inputLanguage], baseLanguage: thisLanguage);
    if (errorPresent(ret)) exit(1);

    String reversed = ret.object!.map((tr) => tr.translations.map((e) => e.text)).join('');
    finalSentences[t.to] = ProcessedTranslation(thisSentence, reversed);
  }

  finalSentences.forEach((k, v) => stdout.write('\n${v.translation}\n${v.reversedTranslation}\n'));
  exit(0);
}
