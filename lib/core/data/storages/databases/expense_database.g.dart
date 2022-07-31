// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Log extends DataClass implements Insertable<Log> {
  final String id;
  final String action;
  final String path;
  final String params;
  final int status;
  final int? responseCode;
  final String? responseMessage;
  final String? responseData;
  final String? errorCode;
  final String? errorData;
  final String? nextExecutionId;
  final int retry;
  Log(
      {required this.id,
      required this.action,
      required this.path,
      required this.params,
      required this.status,
      this.responseCode,
      this.responseMessage,
      this.responseData,
      this.errorCode,
      this.errorData,
      this.nextExecutionId,
      required this.retry});
  factory Log.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return Log(
      id: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      action: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}action'])!,
      path: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}path'])!,
      params: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}params'])!,
      status: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}status'])!,
      responseCode: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}response_code']),
      responseMessage: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}response_message']),
      responseData: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}response_data']),
      errorCode: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}error_code']),
      errorData: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}error_data']),
      nextExecutionId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}next_execution_id']),
      retry: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}retry'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['action'] = Variable<String>(action);
    map['path'] = Variable<String>(path);
    map['params'] = Variable<String>(params);
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || responseCode != null) {
      map['response_code'] = Variable<int?>(responseCode);
    }
    if (!nullToAbsent || responseMessage != null) {
      map['response_message'] = Variable<String?>(responseMessage);
    }
    if (!nullToAbsent || responseData != null) {
      map['response_data'] = Variable<String?>(responseData);
    }
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<String?>(errorCode);
    }
    if (!nullToAbsent || errorData != null) {
      map['error_data'] = Variable<String?>(errorData);
    }
    if (!nullToAbsent || nextExecutionId != null) {
      map['next_execution_id'] = Variable<String?>(nextExecutionId);
    }
    map['retry'] = Variable<int>(retry);
    return map;
  }

  LogsCompanion toCompanion(bool nullToAbsent) {
    return LogsCompanion(
      id: Value(id),
      action: Value(action),
      path: Value(path),
      params: Value(params),
      status: Value(status),
      responseCode: responseCode == null && nullToAbsent
          ? const Value.absent()
          : Value(responseCode),
      responseMessage: responseMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(responseMessage),
      responseData: responseData == null && nullToAbsent
          ? const Value.absent()
          : Value(responseData),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
      errorData: errorData == null && nullToAbsent
          ? const Value.absent()
          : Value(errorData),
      nextExecutionId: nextExecutionId == null && nullToAbsent
          ? const Value.absent()
          : Value(nextExecutionId),
      retry: Value(retry),
    );
  }

  factory Log.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Log(
      id: serializer.fromJson<String>(json['id']),
      action: serializer.fromJson<String>(json['action']),
      path: serializer.fromJson<String>(json['path']),
      params: serializer.fromJson<String>(json['params']),
      status: serializer.fromJson<int>(json['status']),
      responseCode: serializer.fromJson<int?>(json['responseCode']),
      responseMessage: serializer.fromJson<String?>(json['responseMessage']),
      responseData: serializer.fromJson<String?>(json['responseData']),
      errorCode: serializer.fromJson<String?>(json['errorCode']),
      errorData: serializer.fromJson<String?>(json['errorData']),
      nextExecutionId: serializer.fromJson<String?>(json['nextExecutionId']),
      retry: serializer.fromJson<int>(json['retry']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'action': serializer.toJson<String>(action),
      'path': serializer.toJson<String>(path),
      'params': serializer.toJson<String>(params),
      'status': serializer.toJson<int>(status),
      'responseCode': serializer.toJson<int?>(responseCode),
      'responseMessage': serializer.toJson<String?>(responseMessage),
      'responseData': serializer.toJson<String?>(responseData),
      'errorCode': serializer.toJson<String?>(errorCode),
      'errorData': serializer.toJson<String?>(errorData),
      'nextExecutionId': serializer.toJson<String?>(nextExecutionId),
      'retry': serializer.toJson<int>(retry),
    };
  }

  Log copyWith(
          {String? id,
          String? action,
          String? path,
          String? params,
          int? status,
          int? responseCode,
          String? responseMessage,
          String? responseData,
          String? errorCode,
          String? errorData,
          String? nextExecutionId,
          int? retry}) =>
      Log(
        id: id ?? this.id,
        action: action ?? this.action,
        path: path ?? this.path,
        params: params ?? this.params,
        status: status ?? this.status,
        responseCode: responseCode ?? this.responseCode,
        responseMessage: responseMessage ?? this.responseMessage,
        responseData: responseData ?? this.responseData,
        errorCode: errorCode ?? this.errorCode,
        errorData: errorData ?? this.errorData,
        nextExecutionId: nextExecutionId ?? this.nextExecutionId,
        retry: retry ?? this.retry,
      );
  @override
  String toString() {
    return (StringBuffer('Log(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('path: $path, ')
          ..write('params: $params, ')
          ..write('status: $status, ')
          ..write('responseCode: $responseCode, ')
          ..write('responseMessage: $responseMessage, ')
          ..write('responseData: $responseData, ')
          ..write('errorCode: $errorCode, ')
          ..write('errorData: $errorData, ')
          ..write('nextExecutionId: $nextExecutionId, ')
          ..write('retry: $retry')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      action,
      path,
      params,
      status,
      responseCode,
      responseMessage,
      responseData,
      errorCode,
      errorData,
      nextExecutionId,
      retry);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Log &&
          other.id == this.id &&
          other.action == this.action &&
          other.path == this.path &&
          other.params == this.params &&
          other.status == this.status &&
          other.responseCode == this.responseCode &&
          other.responseMessage == this.responseMessage &&
          other.responseData == this.responseData &&
          other.errorCode == this.errorCode &&
          other.errorData == this.errorData &&
          other.nextExecutionId == this.nextExecutionId &&
          other.retry == this.retry);
}

class LogsCompanion extends UpdateCompanion<Log> {
  final Value<String> id;
  final Value<String> action;
  final Value<String> path;
  final Value<String> params;
  final Value<int> status;
  final Value<int?> responseCode;
  final Value<String?> responseMessage;
  final Value<String?> responseData;
  final Value<String?> errorCode;
  final Value<String?> errorData;
  final Value<String?> nextExecutionId;
  final Value<int> retry;
  const LogsCompanion({
    this.id = const Value.absent(),
    this.action = const Value.absent(),
    this.path = const Value.absent(),
    this.params = const Value.absent(),
    this.status = const Value.absent(),
    this.responseCode = const Value.absent(),
    this.responseMessage = const Value.absent(),
    this.responseData = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.errorData = const Value.absent(),
    this.nextExecutionId = const Value.absent(),
    this.retry = const Value.absent(),
  });
  LogsCompanion.insert({
    required String id,
    required String action,
    required String path,
    required String params,
    required int status,
    this.responseCode = const Value.absent(),
    this.responseMessage = const Value.absent(),
    this.responseData = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.errorData = const Value.absent(),
    this.nextExecutionId = const Value.absent(),
    this.retry = const Value.absent(),
  })  : id = Value(id),
        action = Value(action),
        path = Value(path),
        params = Value(params),
        status = Value(status);
  static Insertable<Log> custom({
    Expression<String>? id,
    Expression<String>? action,
    Expression<String>? path,
    Expression<String>? params,
    Expression<int>? status,
    Expression<int?>? responseCode,
    Expression<String?>? responseMessage,
    Expression<String?>? responseData,
    Expression<String?>? errorCode,
    Expression<String?>? errorData,
    Expression<String?>? nextExecutionId,
    Expression<int>? retry,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (action != null) 'action': action,
      if (path != null) 'path': path,
      if (params != null) 'params': params,
      if (status != null) 'status': status,
      if (responseCode != null) 'response_code': responseCode,
      if (responseMessage != null) 'response_message': responseMessage,
      if (responseData != null) 'response_data': responseData,
      if (errorCode != null) 'error_code': errorCode,
      if (errorData != null) 'error_data': errorData,
      if (nextExecutionId != null) 'next_execution_id': nextExecutionId,
      if (retry != null) 'retry': retry,
    });
  }

  LogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? action,
      Value<String>? path,
      Value<String>? params,
      Value<int>? status,
      Value<int?>? responseCode,
      Value<String?>? responseMessage,
      Value<String?>? responseData,
      Value<String?>? errorCode,
      Value<String?>? errorData,
      Value<String?>? nextExecutionId,
      Value<int>? retry}) {
    return LogsCompanion(
      id: id ?? this.id,
      action: action ?? this.action,
      path: path ?? this.path,
      params: params ?? this.params,
      status: status ?? this.status,
      responseCode: responseCode ?? this.responseCode,
      responseMessage: responseMessage ?? this.responseMessage,
      responseData: responseData ?? this.responseData,
      errorCode: errorCode ?? this.errorCode,
      errorData: errorData ?? this.errorData,
      nextExecutionId: nextExecutionId ?? this.nextExecutionId,
      retry: retry ?? this.retry,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (params.present) {
      map['params'] = Variable<String>(params.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (responseCode.present) {
      map['response_code'] = Variable<int?>(responseCode.value);
    }
    if (responseMessage.present) {
      map['response_message'] = Variable<String?>(responseMessage.value);
    }
    if (responseData.present) {
      map['response_data'] = Variable<String?>(responseData.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String?>(errorCode.value);
    }
    if (errorData.present) {
      map['error_data'] = Variable<String?>(errorData.value);
    }
    if (nextExecutionId.present) {
      map['next_execution_id'] = Variable<String?>(nextExecutionId.value);
    }
    if (retry.present) {
      map['retry'] = Variable<int>(retry.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogsCompanion(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('path: $path, ')
          ..write('params: $params, ')
          ..write('status: $status, ')
          ..write('responseCode: $responseCode, ')
          ..write('responseMessage: $responseMessage, ')
          ..write('responseData: $responseData, ')
          ..write('errorCode: $errorCode, ')
          ..write('errorData: $errorData, ')
          ..write('nextExecutionId: $nextExecutionId, ')
          ..write('retry: $retry')
          ..write(')'))
        .toString();
  }
}

class $LogsTable extends Logs with TableInfo<$LogsTable, Log> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LogsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String?> id = GeneratedColumn<String?>(
      'id', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String?> action = GeneratedColumn<String?>(
      'action', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String?> path = GeneratedColumn<String?>(
      'path', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _paramsMeta = const VerificationMeta('params');
  @override
  late final GeneratedColumn<String?> params = GeneratedColumn<String?>(
      'params', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int?> status = GeneratedColumn<int?>(
      'status', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _responseCodeMeta =
      const VerificationMeta('responseCode');
  @override
  late final GeneratedColumn<int?> responseCode = GeneratedColumn<int?>(
      'response_code', aliasedName, true,
      type: const IntType(), requiredDuringInsert: false);
  final VerificationMeta _responseMessageMeta =
      const VerificationMeta('responseMessage');
  @override
  late final GeneratedColumn<String?> responseMessage =
      GeneratedColumn<String?>('response_message', aliasedName, true,
          type: const StringType(), requiredDuringInsert: false);
  final VerificationMeta _responseDataMeta =
      const VerificationMeta('responseData');
  @override
  late final GeneratedColumn<String?> responseData = GeneratedColumn<String?>(
      'response_data', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  final VerificationMeta _errorCodeMeta = const VerificationMeta('errorCode');
  @override
  late final GeneratedColumn<String?> errorCode = GeneratedColumn<String?>(
      'error_code', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  final VerificationMeta _errorDataMeta = const VerificationMeta('errorData');
  @override
  late final GeneratedColumn<String?> errorData = GeneratedColumn<String?>(
      'error_data', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  final VerificationMeta _nextExecutionIdMeta =
      const VerificationMeta('nextExecutionId');
  @override
  late final GeneratedColumn<String?> nextExecutionId =
      GeneratedColumn<String?>('next_execution_id', aliasedName, true,
          type: const StringType(), requiredDuringInsert: false);
  final VerificationMeta _retryMeta = const VerificationMeta('retry');
  @override
  late final GeneratedColumn<int?> retry = GeneratedColumn<int?>(
      'retry', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        action,
        path,
        params,
        status,
        responseCode,
        responseMessage,
        responseData,
        errorCode,
        errorData,
        nextExecutionId,
        retry
      ];
  @override
  String get aliasedName => _alias ?? 'logs';
  @override
  String get actualTableName => 'logs';
  @override
  VerificationContext validateIntegrity(Insertable<Log> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('params')) {
      context.handle(_paramsMeta,
          params.isAcceptableOrUnknown(data['params']!, _paramsMeta));
    } else if (isInserting) {
      context.missing(_paramsMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('response_code')) {
      context.handle(
          _responseCodeMeta,
          responseCode.isAcceptableOrUnknown(
              data['response_code']!, _responseCodeMeta));
    }
    if (data.containsKey('response_message')) {
      context.handle(
          _responseMessageMeta,
          responseMessage.isAcceptableOrUnknown(
              data['response_message']!, _responseMessageMeta));
    }
    if (data.containsKey('response_data')) {
      context.handle(
          _responseDataMeta,
          responseData.isAcceptableOrUnknown(
              data['response_data']!, _responseDataMeta));
    }
    if (data.containsKey('error_code')) {
      context.handle(_errorCodeMeta,
          errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta));
    }
    if (data.containsKey('error_data')) {
      context.handle(_errorDataMeta,
          errorData.isAcceptableOrUnknown(data['error_data']!, _errorDataMeta));
    }
    if (data.containsKey('next_execution_id')) {
      context.handle(
          _nextExecutionIdMeta,
          nextExecutionId.isAcceptableOrUnknown(
              data['next_execution_id']!, _nextExecutionIdMeta));
    }
    if (data.containsKey('retry')) {
      context.handle(
          _retryMeta, retry.isAcceptableOrUnknown(data['retry']!, _retryMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Log map(Map<String, dynamic> data, {String? tablePrefix}) {
    return Log.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $LogsTable createAlias(String alias) {
    return $LogsTable(attachedDatabase, alias);
  }
}

abstract class _$ExpenseDatabase extends GeneratedDatabase {
  _$ExpenseDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $LogsTable logs = $LogsTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [logs];
}
