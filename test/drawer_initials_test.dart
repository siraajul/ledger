import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/widgets/brutal_drawer.dart';

void main() {
  test('drawer initials survive stray whitespace', () {
    expect(drawerInitials('Sirajul '), 'S'); // used to throw RangeError
    expect(drawerInitials('  sirajul   islam '), 'SI');
    expect(drawerInitials('a b c'), 'AB');
    expect(drawerInitials('   '), '?');
    expect(drawerInitials(''), '?');
  });
}
