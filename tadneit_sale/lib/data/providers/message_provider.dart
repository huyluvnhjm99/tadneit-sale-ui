import 'package:flutter_riverpod/flutter_riverpod.dart';

final StateProvider<String?> messageProvider = StateProvider<String?>((Ref<String?> ref) => null);

final StateProvider<String?> errorMessageProvider = StateProvider<String?>((Ref<String?> ref) => null);