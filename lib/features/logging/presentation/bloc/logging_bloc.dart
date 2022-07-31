import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'logging_event.dart';
part 'logging_state.dart';

class LoggingBloc extends Bloc<LoggingEvent, LoggingState> {
  LoggingBloc() : super(LoggingInitial()) {
    on<LoggingEvent>((event, emit) {});
  }
}
