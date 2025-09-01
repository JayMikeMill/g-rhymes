import 'dart:typed_data';

import 'package:g_rhymes/helpers/log.dart';

class IPA {
  // ===== MASTER MAP =====
  // Only includes IPA symbols and clusters used in the top 15 languages
  // (English, Spanish, French, Portuguese, German, Russian, Arabic, Hindi/Urdu,
  // Japanese, Italian, Korean, Turkish, Polish, Mandarin, Bengali).
  static final Map<String, int> clusterMap = {
    // --- Vowel monophthongs + rhotic ---
    'i':0,'ɪ':1,'e':2,'ɛ':3,'æ':4,'a':5,'ɑ':6,'ɒ':7,
    'o':8,'ɔ':9,'u':10,'ʊ':11,'ə':12,'ʌ':13,'ɝ':14,'ɚ':15,
    'y':16,'ø':17,'œ':18,'ɜ':19,'ɨ':20,'ɐ':21,'ʉ':22,
    'ɵ':23,'ɘ':24,'ã':25,'õ':26,

    // --- Diphthongs ---
    'eɪ':27,'aɪ':28,'ɔɪ':29,'oʊ':30,'əʊ':31,'aʊ':32,
    'ɪə':33,'eə':34,'ʊə':35,'ai':36,'ei':37,'oi':38,'au':39,
    'eu':40,'ou':41,'ie':42,'uo':43,'ui':44,'iu':45,'oa':46,
    'ja':47,'ju':48,'wa':49,'wo':50,'ɔu':51,'ɑɪ':52,

    // --- Triphthongs ---
    'eɪə':53,'aɪə':54,'ɔɪə':55,'iau':56,'uai':57,'iao':58,'iou':59,
    'aʊə':60,'oʊə':61,

    // --- Pulmonic consonants ---
    'p':62,'b':63,'t':64,'d':65,'ʈ':66,'ɖ':67,
    'k':68,'ɡ':69,'q':70,'ʔ':71,
    'm':72,'n':73,'ɲ':74,'ŋ':75,
    'f':76,'v':77,'θ':78,'ð':79,'s':80,'z':81,
    'ʃ':82,'ʒ':83,'x':84,'ɣ':85,'h':86,'ɦ':87,
    'j':88,'w':89,'ɹ':90,'ɻ':91,
    'l':92,'ʎ':93,'r':94,'ɫ':95,'ɾ':96,'ʍ':97,'χ':98,

    // --- Onset consonant clusters ---
    'pr':99,'pl':100,'br':101,'bl':102,'tr':103,'dr':104,
    'kr':105,'kl':106,'gr':107,'gl':108,'fr':109,'fl':110,
    'sp':111,'st':112,'sk':113,'sm':114,'sn':115,'sw':116,
    'spl':117,'spr':118,'str':119,'skr':120,
    'θr':121,'ʃr':122,'tw':123,'dw':124,
    'ʈr':125,'ɖr':126,'ʃt':127,'ʒr':128,'ʃk':129,'ʃp':130,
    'ʧr':131,'dʒr':132,'ts':133,'dz':134,'tɕ':135,'dʑ':136,
    'tɬ':137,'dɮ':138,

    // --- Coda consonant clusters ---
    'nd':139,'nds':140,'nt':141,'nts':142,'ns':143,'nz':144,
    'ld':145,'lds':146,'lk':147,'lks':148,'lp':149,'lps':150,
    'lf':151,'lfs':152,'lm':153,'lms':154,
    'rd':155,'rds':156,'rk':157,'rks':158,'rt':159,'rts':160,
    'rn':161,'rm':162,
    'mp':163,'mps':164,'mb':165,'mbs':166,'ŋk':167,'ŋks':168,
    'ŋg':169,'ŋgs':170,'st̚':171,'sts':172,'sp̚':173,'sps':174,
    'sk̚':175,'sks':176,'ks':177,'gz':178,'dʒ':179,'tʃ':180,
    'θs':181,'ɲs':182,'ŋs':183,

    // --- Suprasegmentals / modifiers (all 255) ---
    'ː': 255, 'ˈ': 255, 'ˌ': 255, '.': 255, '͡': 255, '(': 255, ')': 255,
    '̯': 255, '̩': 255, 'ʴ': 255, '̠': 255, '̃': 255, '˨': 255, '˩': 255, '̚': 255,
    ' ': 255, '/': 255, '[': 255, 'ʰ': 255, '̥': 255, '˭': 255, '̪': 255,
    '˧': 255, '̈': 255, 'ᵊ': 255, '-': 255, '˦': 255, 'c': 255,
    'ǁ': 255, '‿': 255, 'ʱ': 255, 'ʙ': 255, 'ʁ': 255, 'ç': 255, '͜': 255,
    '˞': 255, 'ˑ': 255, '|': 255, '̆': 255, 'ɶ': 255, 'ɳ': 255, 'ʷ': 255,
    'ɭ': 255, '̰': 255, 'ǀ': 255, 'ʲ': 255, '~': 255, 'ˤ': 255, '̙': 255,
    '̝': 255, 'ɬ': 255, '˥': 255, 'ä': 255, 'ɸ': 255, 'ā': 255, 'ɽ': 255,
    'ĭ': 255, 'ĩ': 255, 'ʼ': 255, 'ă': 255, 'ŏ': 255, 'ɱ': 255, 'ǐ': 255,
    'ʋ': 255, '̞': 255, 'ɟ': 255, 'ʏ': 255, '⁻': 255, '³': 255, '͆': 255,
    'ɤ': 255, '̂': 255, '̊': 255, 'β': 255, 'ˀ': 255, '¹': 255, '²': 255,
    '⁴': 255, 'ˠ': 255, 'ü': 255, 'ɯ': 255, 'ɕ': 255, 'ʳ': 255,
  };

// ===== CLASSIFICATION =====
  static final Set<int> vowelClusters = {
    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,25,26,
    27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,
    46,47,48,49,50,51,52, 53,54,55,56,57,58,59,60,61
  };

  static final Set<int> consonantClusters = {
    62,63,64,65,66,67,68,69,70,71,72,73,74,75,
    76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,
    99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,
    117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,
    135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,
    153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,
    171,172,173,174,175,176,177,178,179,180,181,182,183
  };





  static const maxClusterLength = 3;

  // Convert an IPA string into a byte string (1 byte per cluster)
  static Uint8List toKey(String ipa) {
    final key = <int>[];
    int index = 0;

    while (index < ipa.length) {
      bool matched = false;

      // Try the longest possible cluster first
      for (int len = maxClusterLength; len > 0; len--) {
        if (index + len > ipa.length) continue;
        final substr = ipa.substring(index, index + len);

        final code = clusterMap[substr];
        if (code != null) {
          key.add(code & 0xFF); // ensure 1-byte
          index += len;
          matched = true;
          break;
        }
      }

      if (!matched) {
        Log.w('Unknown IPA cluster at position $index: ${ipa[index]}');
        index++; // skip unknown
      }
    }

    return Uint8List.fromList(key);
  }

  // Convert a byte string back into IPA
  // Precompute reverse map for efficiency
  static final Map<int, String> reverseMap = clusterMap.map((k, v) => MapEntry(v, k));
  static String fromKey(Uint8List key) {
    final buffer = StringBuffer();
    for (var code in key) {
      final cluster = reverseMap[code];
      if (cluster == null) continue;
      buffer.write(cluster);
    }
    return buffer.toString();
  }

  static Uint8List keyVocals(Uint8List key) =>
    Uint8List.fromList(key.where((byte) => vowelClusters.contains(byte)).toList());

  static Uint8List keyConsonants(Uint8List key) =>
    Uint8List.fromList(key.where((byte) => consonantClusters.contains(byte)).toList());

  static List<Uint8List> subKeys(Uint8List input) =>
      List.generate(input.length, (i) => input.sublist(i));

  static bool isKeyConsonant(int key) => consonantClusters.contains(key);
}
