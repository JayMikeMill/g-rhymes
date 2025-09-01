import 'package:g_rhymes/data/g_dict.dart';

/// --- Properties ---
class RhymeSearchProps {
  RhymeType rhymeType   = RhymeType.perfect;
  SpeechType speechType = SpeechType.common;
  WordType wordType     = WordType.common;
  int syllables         = 0; // 0 = All
}

/// --- Enhanced enums with display names ---
enum RhymeType {
  all('All'),
  perfect('Perfect'),
  near('Near'),
  vowel('Vowel'),
  conso('Consonant');

  final String displayName;
  const RhymeType(this.displayName);
}


const Set<PartOfSpeech> commonSpeechTypes = {
  PartOfSpeech.noun, PartOfSpeech.verb, PartOfSpeech.adjective,
  PartOfSpeech.adverb, PartOfSpeech.pronoun
};

enum SpeechType {
  all('All', commonSpeechTypes),
  common('Common', commonSpeechTypes),
  noun('Nouns', {PartOfSpeech.noun}),
  verb('Verbs', {PartOfSpeech.verb}),
  adjective('Adjectives', {PartOfSpeech.adjective}),
  phrase('Phrases', {PartOfSpeech.phrase}),
  name('Names', {PartOfSpeech.name}),
  other('Other', {PartOfSpeech.other});

  final String displayName;
  final Set<PartOfSpeech> wordPoS;
  const SpeechType(this.displayName, this.wordPoS);
}

enum WordType {
  all('All'),
  common('Common'),
  uncommon('Uncommon'),
  slang('Slang'),
  vulgar('Vulgar');

  final String displayName;
  const WordType(this.displayName);
}

