import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypime/features/auth/domain/entities/auth_entity.dart';
import 'package:mypime/features/auth/presentation/providers/auth_state.dart';

class GoRouterNotifier extends ChangeNotifier {
  GoRouterNotifier(this.ref) {
    ref.listen<AsyncValue<AuthEntity?>>(
      authStateNotifierProvider,
      (_, _) => notifyListeners(),
    );
  }

  final WidgetRef ref;
}
