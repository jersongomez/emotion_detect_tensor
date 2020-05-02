import 'package:emotion_detect_tensor/repo/repository.dart';
import 'package:emotion_detect_tensor/ui/detect_screen.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  
  final Repository repository = Repository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Investigación Entrevista'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buttonDevelop('Prueba 1 \n Entrevistador: Ramiro Lopez',
                Icons.filter_1, context, 'assets/11.mp4'),
            buttonDevelop('Prueba 2 \n Entrevistador: Pedro Perez',
                Icons.filter_2, context, 'assets/21.mp4'),
            buttonDevelop('Prueba 3 \n Entrevistador: Patricia García',
                Icons.filter_3, context, 'assets/31.mp4'),
            buttonDevelop('Prueba 4 \n Entrevistador: Lucia Flores',
                Icons.filter_4, context, 'assets/41.mp4'),
          ],
        )),
      ),
    );
  }

  Widget buttonDevelop(String text, IconData icon, BuildContext context, String videoURL) {
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: height * 0.12,
        child: RaisedButton(
          color: Colors.lightBlue,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(
                icon,
                color: Colors.white,
                size: 40,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                text,
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.right,
              )
            ],
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (context) {
                return DetectScreen(
                  title: text.substring(text.indexOf("\n") +2), 
                  videoAssets: videoURL,
                  repository: repository,
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
