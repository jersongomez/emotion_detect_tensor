import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:emotion_detect_tensor/repo/repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'info_event.dart';
part 'info_state.dart';

class InfoBloc extends Bloc<InfoEvent, InfoState> {
  final Repository _repository;

  InfoBloc({@required Repository repository})
    : assert(repository != null),
    _repository = repository;

  @override
  InfoState get initialState => InfoLoading();

  @override
  Stream<InfoState> mapEventToState(
    InfoEvent event,
  ) async* {
    if (event is SaveInfo) {
      yield* mapSaveInfoToState(event.faceList, event.sentiWord);
    }
  }

  Stream<InfoState> mapSaveInfoToState(String faceList, String sentiWord) 
    async* {
      yield InfoLoading();
      try {
        await _repository.addNewInfo(faceList, sentiWord);
      } catch (_) {
        yield InfoNotLoaded();
      }
  }
}
