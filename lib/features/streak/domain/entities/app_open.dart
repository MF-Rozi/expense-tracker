import 'package:equatable/equatable.dart';

class AppOpen extends Equatable {
  const AppOpen({
    required this.uuid,
    required this.date,
  });

  final String uuid;
  final DateTime date;

  @override
  List<Object?> get props => [uuid, date];
}
