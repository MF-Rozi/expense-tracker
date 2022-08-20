import 'package:expense_tracker/shared/categories/domain/entities/category.dart';
import 'package:expense_tracker/shared/enitites/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Category Entity', () {
    test(
      'should instantiate category object',
      () async {
        // arrange
        final id = UniqueId.generate();
        // act
        final category = Category(
          id: id,
          name: StringSingleLine('Kategori'),
          icon: 'test.svg',
        );
        // assert
        expect(category, isA<Category>());
      },
    );
    test(
      'parent should contain category',
      () async {
        // arrange
        final parent = Category(
          id: UniqueId.generate(),
          name: StringSingleLine('Parent'),
          icon: 'test.svg',
        );
        // act
        final child = Category(
          id: UniqueId.generate(),
          name: StringSingleLine('child'),
          parent: parent,
          icon: 'test.svg',
        );
        // assert
        expect(child.parent, isA<Category>());
        expect(child.parent, equals(parent));
      },
    );
  });
}
