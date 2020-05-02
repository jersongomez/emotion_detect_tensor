part of 'info_bloc.dart';

abstract class InfoEvent extends Equatable {
  const InfoEvent();

  @override
  List<Object> get props => [];
}

class SaveInfo extends InfoEvent {
  final String faceList, sentiWord;

  SaveInfo(this.faceList, this.sentiWord);

  @override
  List<Object> get props => [faceList, sentiWord];
}
