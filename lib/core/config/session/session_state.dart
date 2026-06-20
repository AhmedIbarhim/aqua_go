import 'package:flutter/foundation.dart';
import 'package:aqua_go/features/auth/data/models/user_model.dart';

/// Singleton reactive notifier for the authenticated user.
/// Widgets wrap guest-gated subtrees in a [ValueListenableBuilder] on
/// [currentUser] so auth transitions propagate without a restart.
final ValueNotifier<UserModel?> currentUser = ValueNotifier<UserModel?>(null);
