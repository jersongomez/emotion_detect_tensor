import 'package:emotion_detect_tensor/repo/repository.dart';
import 'package:emotion_detect_tensor/repo/sentiment_analisys.dart';
import 'package:emotion_detect_tensor/ui/bye.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Recording extends StatefulWidget {
  Recording({Key key, this.faceList}) 
    : super(key: key);

  final String faceList;

  @override
  _RecordingState createState() => _RecordingState();
}

class _RecordingState extends State<Recording> {
  bool _hasSpeech = false;
  bool _stressTest = false;
  double level = 0.0;
  int _stressLoops = 0;
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  String _currentLocaleId = "";
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();

  final Repository repository = Repository();
  SentimentAnalisys sentimentAnalisys;

  @override
  void initState() {
    super.initState();
  }

  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);
    if (hasSpeech) {
      _localeNames = await speech.locales();

      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale.localeId;
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: Column(children: [
              ListTile(
                leading: Icon(Icons.mic),
                title: Text('Registra tu respuesta aquí:'),
                subtitle: Text('Inicializa, selecciona tu idioma y asegúrate de tener conexión a internet'),
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        RaisedButton(
                          child: Text('Initialize'),
                          onPressed: _hasSpeech ? null : initSpeechState,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        DropdownButton(
                          onChanged: (selectedVal) => _switchLang(selectedVal),
                          value: _currentLocaleId,
                          items: _localeNames
                              .map(
                                (localeName) => DropdownMenuItem(
                                  value: localeName.localeId,
                                  child: Text(localeName.name),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        FlatButton(
                          child: Icon(Icons.play_arrow),
                          onPressed: !_hasSpeech || speech.isListening
                              ? null
                              : startListening,
                        ),
                        FloatingActionButton(
                          heroTag: "btnStop",
                          child: Icon(Icons.stop),
                          backgroundColor: Colors.red,
                          onPressed: speech.isListening ? stopListening : null,
                        ),
                      ],
                    ),
                    
                  ],
                ),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.mic),
                            Text('Tu respuesta:',),
                          ],
                        ),
                      ),
                      Container(
                        height: 100.0,
                        color: Theme.of(context).selectedRowColor,
                        child: Center(
                          child: Text(
                            lastWords,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: Theme.of(context).backgroundColor,
                child: Center(
                  child: speech.isListening
                      ? Text(
                          "Estoy escuchando...",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      : Text(
                          'No estoy escuchando',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ]),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(15.0),
          child: RaisedButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Enviar respuesta'),
                Icon(Icons.send),
              ],
            ),
            onPressed: lastWords.isEmpty ? null : (){
              sentimentAnalisys = SentimentAnalisys(lastWords.substring(0, lastWords.indexOf('-')-1));
              String sentimentDetected = sentimentAnalisys.sentimentAnalisys();
              repository.addNewInfo(widget.faceList, lastWords, sentimentDetected);
              Navigator.of(context).pop();
              Navigator.push(context, 
                MaterialPageRoute(
                  builder: (context) {
                    return Bye();
                  }
                ));
            }
          ),
        ),
        
      ],
    );
  }

  void changeStatusForStress(String status) {
    if (!_stressTest) {
      return;
    }
    if (speech.isListening) {
      stopListening();
    } else {
      if (_stressLoops >= 100) {
        _stressTest = false;
        print("Stress test complete.");
        return;
      }
      print("Stress loop: $_stressLoops");
      ++_stressLoops;
      startListening();
    }
  }

  void startListening() {
    lastWords = "";
    lastError = "";
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 10),
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        partialResults: true);
    setState(() {});
  }

  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = "${result.recognizedWords} - ${result.finalResult}";
    });
  }

  void soundLevelListener(double level) {
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void statusListener(String status) {
    changeStatusForStress(status);
    setState(() {
      lastStatus = "$status";
    });
  }

  _switchLang(selectedVal) {
    setState(() {
      _currentLocaleId = selectedVal;
    });
    print(selectedVal);
  }
}
