import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypime/core/di/injector.dart';
import 'package:mypime/domain/entities/auth_entity.dart';

class GoRouterNotifier extends ChangeNotifier {
  GoRouterNotifier(this.ref) {
    ref.listen<AsyncValue<AuthEntity?>>(
      authNotifierProvider,
      (_, _) => notifyListeners(),
    );
  }

  final WidgetRef ref;
}
