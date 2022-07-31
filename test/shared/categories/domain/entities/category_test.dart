import 'package:expense_tracker/shared/categories/domain/entities/category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Category Entity', () {
    test(
      'should instantiate category object',
      () async {
        // arrange

        // act
        const category = Category();
        // assert
        expect(category, isA<Category>());
      },
    );
  });
}
