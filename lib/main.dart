import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypime/core/init/app_botstrap.dart';
import 'package:mypime/core/routes/app_router.dart';
import 'package:mypime/shared/providers/isar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isar = await AppBootstrap.initIsar();

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      routerConfig: router,
    );
  }
}
