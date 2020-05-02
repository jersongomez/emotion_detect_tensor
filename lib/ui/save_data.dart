import 'package:emotion_detect_tensor/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:emotion_detect_tensor/bloc/info_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SaveData extends StatelessWidget {

  SaveData({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InfoBloc, InfoState>(
      builder: (context, state) {
        if (state is InfoLoaded) {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(
              builder: (_) => App()
            ));
        }
        if (state is InfoLoading) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Registrado datos...'),
                    CircularProgressIndicator()
                  ],
                )
              )
            );
        }
        if (state is InfoNotLoaded) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Fallo al registrar datos'), Icon(Icons.error)],
                ),
                backgroundColor: Colors.red,
              ),
            );
        }
        return Container();
      },
    );
  }
}