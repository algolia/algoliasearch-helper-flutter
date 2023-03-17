// Mocks generated by Mockito 5.3.0 from annotations
// in algolia_helper/test/insights_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:algolia_insights/src/event.dart' as _i3;
import 'package:algolia_insights/src/event_service.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [EventService].
///
/// See the documentation for Mockito's code generation for more information.
class MockEventService extends _i1.Mock implements _i2.EventService {
  MockEventService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void send(List<_i3.Event>? events) =>
      super.noSuchMethod(Invocation.method(#send, [events]),
          returnValueForMissingStub: null);
}
