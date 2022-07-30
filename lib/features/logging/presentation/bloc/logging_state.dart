part of 'logging_bloc.dart';

abstract class LoggingState extends Equatable {
  const LoggingState();  

  @override
  List<Object> get props => [];
}
class LoggingInitial extends LoggingState {}
