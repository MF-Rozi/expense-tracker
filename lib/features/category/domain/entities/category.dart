import 'package:equatable/equatable.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';

class Category extends Equatable {
  const Category({
    required this.uuid,
    required this.name,
    required this.isSynced,
    required this.updatedAt,
    this.parentUuid,
  });

  final UniqueId uuid;
  final StringSingleLine name;
  final UniqueId? parentUuid;
  final bool isSynced;
  final DateTime updatedAt;

  bool get isRoot => parentUuid == null;

  @override
  List<Object?> get props => [
        uuid,
        name,
        parentUuid,
        isSynced,
        updatedAt,
      ];
}
