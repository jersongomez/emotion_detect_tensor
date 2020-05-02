part of 'info_bloc.dart';

abstract class InfoState extends Equatable {
  const InfoState();

  @override
  List<Object> get props => [];
}

class InfoLoading extends InfoState {}
class InfoLoaded extends InfoState {}
class InfoNotLoaded extends InfoState {}
