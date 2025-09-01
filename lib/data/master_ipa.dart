/*
 * Copyright (c) 2025 GWorks
 *
 * Licensed under the GWorks Non-Commercial License.
 * You may view, copy, and modify the source code.
 * You may redistribute the source code under the same terms.
 * You may build and use the code for personal or educational purposes.
 * You may NOT sell or redistribute the built binaries.
 *
 * For the full license text, see LICENSE file in this repository.
 *
 * File: master_ipa.dart
 * Description: Defines the full IPA set, including vowels, diphthongs,
 *              triphthongs, pulmonic and non-pulmonic consonants, affricates,
 *              clusters, and common onset/coda combinations across multiple
 *              languages.
 */


// -----------------------------------------------------------------------------
// Class: MasterIPA
// Description: Full IPA set.
// -----------------------------------------------------------------------------
class MasterIPA {
  // ===== MASTER MAP =====
  static final Map<String, int> clusterMap = {
    // --- Vowel monophthongs (full IPA chart + rho-tics) ---
    'i': 0, 'y': 1, 'ɨ': 2, 'ʉ': 3, 'ɯ': 4, 'u': 5,
    'ɪ': 6, 'ʏ': 7, 'ʊ': 8,
    'e': 9, 'ø': 10, 'ɘ': 11, 'ɵ': 12, 'ɤ': 13, 'o': 14,
    'ə': 15,
    'ɛ': 16, 'œ': 17, 'ɜ': 18, 'ɞ': 19, 'ʌ': 20, 'ɔ': 21,
    'æ': 22, 'ɐ': 23,
    'a': 24, 'ɶ': 25, 'ɑ': 26, 'ɒ': 27,
    'ɚ': 28, 'ɝ': 29,

    // --- Common diphthongs (broad, cross-lingual set) ---
    // English core
    'eɪ': 100, 'aɪ': 101, 'ɔɪ': 102, 'əʊ': 103, 'oʊ': 104, 'aʊ': 105,
    'ɪə': 106, 'eə': 107, 'ʊə': 108,
    // Germanic & Romance frequent
    'ai': 109, 'ei': 110, 'oi': 111, 'au': 112, 'eu': 113, 'ou': 114,
    'ie': 115, 'uo': 116, 'ui': 117, 'iu': 118, 'oa': 119,
    // With semivowel glides (broadly attested)
    'ja': 120, 'je': 121, 'jo': 122, 'ju': 123, 'jə': 124,
    'wa': 125, 'we': 126, 'wi': 127, 'wo': 128, 'wə': 129,
    'ɥi': 130, 'ɥe': 131, 'ɥɛ': 132, 'ɥo': 133, 'ɥə': 134,
    // Add more neutral combos often used
    'eo': 135, 'iu̯': 136, 'ui̯': 137,

    // --- Triphthongs (attested sets; English + common rising/falling) ---
    'eɪə': 200, 'aɪə': 201, 'ɔɪə': 202, 'əʊə': 203, 'aʊə': 204,
    'iau': 205, 'uai': 206, 'uei': 207, 'iao': 208, 'iou': 209,
    'jai': 210, 'jau': 211, 'wai': 212, 'wau': 213,

    // --- Pulmonic consonants (full IPA) ---
    // Plosives
    'p': 300, 'b': 301, 't': 302, 'd': 303, 'ʈ': 304, 'ɖ': 305,
    'c': 306, 'ɟ': 307, 'k': 308, 'ɡ': 309, 'q': 310, 'ɢ': 311, 'ʔ': 312,
    // Nasals
    'm': 313, 'ɱ': 314, 'n': 315, 'ɳ': 316, 'ɲ': 317, 'ŋ': 318, 'ɴ': 319,
    // Trills
    'ʙ': 320, 'r': 321, 'ʀ': 322,
    // Taps/Flaps
    'ⱱ': 323, 'ɾ': 324, 'ɽ': 325,
    // Fricatives
    'ɸ': 326, 'β': 327, 'f': 328, 'v': 329, 'θ': 330, 'ð': 331,
    's': 332, 'z': 333, 'ʃ': 334, 'ʒ': 335, 'ʂ': 336, 'ʐ': 337,
    'ç': 338, 'ʝ': 339, 'x': 340, 'ɣ': 341, 'χ': 342, 'ʁ': 343,
    'ħ': 344, 'ʕ': 345, 'h': 346, 'ɦ': 347,
    // Lateral fricatives
    'ɬ': 348, 'ɮ': 349,
    // Approximants
    'ʋ': 350, 'ɹ': 351, 'ɻ': 352, 'j': 353, 'ɰ': 354,
    // Lateral approximants
    'l': 355, 'ɭ': 356, 'ʎ': 357, 'ʟ': 358,

    // --- Non-pulmonic consonants ---
    // Clicks
    'ʘ': 400, 'ǀ': 401, 'ǃ': 402, 'ǂ': 403, 'ǁ': 404,
    // Implosives
    'ɓ': 405, 'ɗ': 406, 'ʄ': 407, 'ɠ': 408, 'ʛ': 409,
    // Ejectives (apostrophe)
    "pʼ": 410, "tʼ": 411, "kʼ": 412, "sʼ": 413, "qʼ": 414,
    "t͡sʼ": 415, "t͡ʃʼ": 416, "t͡ɕʼ": 417, "t͡ʂʼ": 418,

    // --- Co-articulated / labial-velar stops, etc. ---
    'k͡p': 450, 'ɡ͡b': 451, 'kp': 452, 'gb': 453,
    'ʍ': 454, 'w': 455, 'ɥ': 456, 'ʜ': 457, 'ʢ': 458, 'ʡ': 459,

    // --- Affricates (with/without tie bar) ---
    't͡s': 500, 'd͡z': 501, 't͡ʃ': 502, 'd͡ʒ': 503,
    't͡ɕ': 504, 'd͡ʑ': 505, 't͡ʂ': 506, 'd͡ʐ': 507,
    'k͡x': 508, 'ɡ͡ɣ': 509, 'p͡f': 510, 'b͡v': 511,
    'ts': 512, 'dz': 513, 'tʃ': 514, 'dʒ': 515,
    'tɕ': 516, 'dʑ': 517, 'tʂ': 518, 'dʐ': 519, 'pf': 520, 'bv': 521, 'kx': 522, 'gɣ': 523,

    // --- Common cross-lingual consonant clusters (non-exhaustive but broad) ---
    // Onset clusters (2-consonant)
    'pr': 600, 'pl': 601, 'br': 602, 'bl': 603, 'tr': 604, 'dr': 605,
    'kr': 606, 'gr': 607, 'kl': 608, 'gl': 609, 'fj': 610, 'vj': 611,
    'sp': 612, 'st': 613, 'sk': 614, 'sm': 615, 'sn': 616, 'sl': 617,
    'sw': 618, 'ʃr': 619, 'ʃl': 620, 'fjɰ': 621,
    // Onset clusters (3-consonant)
    'spr': 630, 'spl': 631, 'str': 632, 'skl': 633, 'skr': 634, 'skw': 635,
    // Codas (common finals)
    'nd': 640, 'nt': 641, 'ŋk': 642, 'ŋɡ': 643, 'mp': 644, 'mb': 645,
    'ft': 646, 'sp̚': 647, 'st̚': 648, 'sk̚': 649,
    'l̩': 650, 'n̩': 651, 'm̩': 652, 'r̩': 653,

    // You can append more language-specific clusters here as needed.
  };
}