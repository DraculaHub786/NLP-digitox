
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides set of keys which have been animated once successfully.
final animatedFlagsProvider = StateProvider<Set<String>>((ref) => {});
