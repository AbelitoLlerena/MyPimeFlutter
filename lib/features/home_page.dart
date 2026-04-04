import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypime/features/auth/presentation/providers/auth_state.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateNotifierProvider);
    final user = authState.value?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateNotifierProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Center(
        child: user == null
            ? const Text('No user loaded')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '👤 Bienvenido',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text('ID: ${user.id}'),
                  Text('Nombre: ${user.name}'),
                  Text('Role: ${user.role}'),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(authStateNotifierProvider.notifier).logout();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                  ),
                ],
              ),
      ),
    );
  }
}
