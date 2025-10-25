# G-Rhymes - Advanced Rhyming Dictionary Flutter App

A sophisticated Flutter application that provides advanced rhyming capabilities with comprehensive dictionary support and phonetic analysis. Built with performance optimization and linguistic accuracy in mind.

---

## 🚀 Project Overview

G-Rhymes is a **comprehensive rhyming dictionary application** that leverages International Phonetic Alphabet (IPA) processing for accurate rhyme detection. Key features include:

- **Advanced rhyme searching** with perfect, near, vowel, and consonant rhyme types
- **Intelligent phonetic analysis** using IPA notation for precise rhyme matching
- **Multi-source dictionary compilation** from Wiktionary, CMU Dictionary, and common word lists
- **Flexible filtering options** by syllable count, part of speech, and word rarity
- **Phrase rhyme support** for multi-word expressions
- **Optimized performance** with precomputed rhyme indices and efficient data structures
- **Cross-platform support** for Windows, macOS, Linux, iOS, and Android

This application demonstrates advanced linguistic processing, efficient data management, and sophisticated Flutter development techniques.

---

## 🏗️ Tech Stack

**Flutter Framework:**

- Flutter SDK 3.9.0+
- Dart programming language
- Material Design components
- Provider for state management
- Cross-platform window management

**Data Processing:**

- **Hive** for local NoSQL database storage
- **SQLite** for structured data management
- Custom IPA (International Phonetic Alphabet) processing engine
- Efficient binary data structures with Uint8List/Uint32List

**Dictionary Sources:**

- **Wiktionary** (wiktionary.jsonl) - Comprehensive word definitions
- **CMU Pronouncing Dictionary** (cmudict.txt) - Phonetic pronunciations
- **Google 10K Common Words** (google-10k-common.txt)
- **Wikipedia 100K Common Words** (wiki-100k-common.txt)
- **Song Lyrics Dataset** (song_lyrics.csv) - Creative vocabulary

**Development Tools:**

- Flutter Lints for code quality
- Hive Generator for data model code generation
- Build Runner for code generation automation
- Logger for debugging and monitoring

---

## 🔬 Advanced Features

**Phonetic Processing:**

- Custom IPA encoding/decoding system with 256-byte phoneme mapping
- Vowel and consonant cluster classification
- Syllable counting and stress pattern analysis
- Multi-language phonetic support (15+ languages)

**Rhyme Engine:**

- **Perfect rhymes** - Exact sound matching from last vowel
- **Near rhymes** - Similar sound patterns with variation
- **Vowel rhymes** - Matching vowel sounds only
- **Consonant rhymes** - Matching consonant patterns

**Smart Filtering:**

- Part of speech filtering (nouns, verbs, adjectives, etc.)
- Word rarity levels (common, uncommon, slang, vulgar)
- Syllable count specification
- Phrase vs. single word options

**Performance Optimizations:**

- Precomputed rhyme indices for instant lookup
- Efficient binary data structures
- Lazy loading of dictionary components
- Optimized memory usage with typed arrays

---

## 🗂️ Project Structure

The application follows a clean, modular architecture:

### Core Components

- **`/lib/data/`** - Dictionary data structures and storage management

  - `g_dict.dart` - Core dictionary classes and entry management
  - `rhyme_dict.dart` - Rhyme processing engine and search logic
  - `ipa.dart` - International Phonetic Alphabet processing utilities
  - `hive_storage.dart` - Local database persistence layer

- **`/lib/widgets/`** - UI components and user interface

  - `rhyme_search_widget.dart` - Advanced search interface
  - `rhyme_list_view.dart` - Results display and formatting
  - `my_app_bar.dart` - Application header and navigation

- **`/lib/providers/`** - State management

  - `rhyme_search_provider.dart` - Search state and parameters management

- **`/lib/dict_builder/`** - Dictionary compilation system
  - `dict_builder.dart` - Automated dictionary construction from sources
  - `dict_parser.dart` - Multi-format dictionary parsing utilities

### Data Sources

- **`/source_dicts/`** - Raw dictionary files and linguistic data
- **`/assets/`** - Compiled dictionary assets for app distribution

### Platform Support

- **`/android/`**, **`/ios/`**, **`/windows/`**, **`/linux/`**, **`/macos/`** - Platform-specific configurations
- **`/web/`** - Progressive web app support

---

## 🎯 How It Works

**For Users:**

1. Enter a word in the search field
2. Select rhyme type (perfect, near, vowel, consonant)
3. Apply filters for syllables, part of speech, and word type
4. Browse comprehensive rhyme results with definitions

**For Linguists:**

- Access to IPA transcriptions and phonetic analysis
- Detailed part-of-speech and etymological information
- Support for phrase-level rhyme analysis

**For Developers:**

- Modular architecture with clear separation of concerns
- Efficient data structures optimized for linguistic processing
- Extensible framework for additional language support

---

## 📄 License

Licensed under the **GWorks Non-Commercial License v1.0**:

- ✅ View, copy, and modify source code
- ✅ Redistribute source code under same terms
- ✅ Build and use for personal/educational purposes
- ❌ Commercial distribution of built binaries prohibited
