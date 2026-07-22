import '../model/composition_response.dart';
import '../model/composition_state.dart';

/// A contract search Service handling composition run requests and responses.
abstract class CompositionSearchService {
  /// Send a composition run request [state] and asynchronously get a
  /// [CompositionResponse].
  Future<CompositionResponse> search(CompositionState state);
}
