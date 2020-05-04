import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Bye extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Gracias por su ayuda'),
              RaisedButton(
                onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Cerrar App'),
                    Icon(Icons.exit_to_app)
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}