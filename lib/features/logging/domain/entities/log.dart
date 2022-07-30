import 'package:expense_tracker/shared/categories/domain/entities/value_objects.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'log.freezed.dart';

@freezed
class Log with _$Log {
  const factory Log({
    required UniqueId id,
    required String action,
    required String path,
    required Map<String, dynamic> params,
    required LogStatus status,
    int? responseCode,
    String? responseMessage,
    Map<String, dynamic>? responseData,
    String? errorCode,
    String? errorMessage,
    UniqueId? nextExecutionId,
    @Default(0) int retry,
  }) = _Log;
}

enum LogStatus {
  initiated,
  executed,
  succeed,
  failed,
  skipped,
}
