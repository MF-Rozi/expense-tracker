import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/core/utils/extensions/context_extensions.dart';
import 'package:expense_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';

mixin ErrorMessageHandler {
  void handleError(BuildContext context, Failure failure) {
    final l10n = context.l10n;
    failure.when(
      //Change this in the future
      connectivityFailure: () => context.displayFlash(l10n.counterAppBarTitle),
    );
  }
}
