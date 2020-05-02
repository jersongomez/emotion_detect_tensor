import 'package:emotion_detect_tensor/repo/lex_es.dart';
import 'package:emotion_detect_tensor/repo/stop_words.dart';

class SentimentAnalisys {
  const SentimentAnalisys(this.respuesta);

  final String respuesta;

  String sentimentAnalisys() {
    // Text-mining Pre-processing steps and NLP Emotion Algorithnm
    return filteringEmotion(caseFolding(respuesta));
  }

  ///Text Mining - Preprocesing steps
  /// * Case Folding: Convierte el texto en lowercase (minúsculas) y elimina caracteres extraños
  /// * Filtering: Elimina palabras innecesarias (stop words), reemplazar palabras por su sinonimo
  /// * Tokenizing: Produce palabras solas

  String caseFolding(String text) {
    return removeAccent(text)
        .replaceAll(RegExp('[^a-zA-ZñÑ\\s]*'), '') // regex no words, ñ or space
        .replaceAll(RegExp('\\s+'), ' ') // regex space
        .toLowerCase();
  }

  // Do filtering and tokenizing

  /// NLP Emotion Algorithm
  ///  1) Check if the word in the final word list is also present in lex_es
  ///   - open the lex_es file
  ///   - Loop through each line and clear it
  ///   - Extract the word and emotion using split
  /// 
  ///  2) If word is present -> Add the emotion to emotion_list
  ///  3) Finally count each emotion in the emotion list
  String filteringEmotion(String text) {
    var emotionList = <String>[];
    int pos = 0, neg = 0;

    for (var word in text.split(' ')) {
      if (!STOP_WORDS.contains(word)) {
        if (mapSenti.containsKey(word)) {
          emotionList.add(mapSenti[word]);
        }
      }
    }

    emotionList.forEach((String em) => (em == "pos") ? pos += 1 : neg += 1);

    if (pos == neg) return "Neutro";
    else return (pos > neg) ? "Positivo" :"Negativo";
  }

  /// Functions
  String removeAccent(String text) {
    return text
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
  }
}
