// Copyright (c) 2022, Adryan Eka Vandra & M. Fakhrul Rozi
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:expense_tracker/app/app.dart';
import 'package:expense_tracker/bootstrap.dart';
import 'package:expense_tracker/core/utils/constants.dart';

void main() {
  bootstrap(() => const App(), environment: Environment.production);
}
