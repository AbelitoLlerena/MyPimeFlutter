import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mypime/core/theme/app_theme.dart';
import 'package:mypime/features/sales/domain/entities/sale_entity.dart';
import 'package:mypime/features/sales/presentation/providers/sales_providers.dart';

class SalesHistoryPage extends ConsumerStatefulWidget {
  const SalesHistoryPage({super.key});

  @override
  ConsumerState<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends ConsumerState<SalesHistoryPage> {
  DateTime _day = DateTime.now();

  DateTime get _normalized => DateTime(_day.year, _day.month, _day.day);

  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(salesByDayProvider(_normalized));
    final timeFmt = DateFormat('HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Historial de Ventas',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    salesAsync.when(
                      loading: () => const Text('Cargando…'),
                      error: (e, _) => Text('Error: $e'),
                      data: (sales) => Text(
                        '${sales.length} ventas encontradas',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _day,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _day = picked);
                },
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(
                  '${_day.day.toString().padLeft(2, '0')}/${_day.month.toString().padLeft(2, '0')}/${_day.year}',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: salesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (sales) {
              final dayTotal = sales.fold<double>(0, (a, s) => a + s.total);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.payments_outlined, color: AppColors.primaryGreen),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total del día', style: TextStyle(fontSize: 13)),
                                Text(
                                  '\$${dayTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: sales.isEmpty
                          ? Card(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.receipt_long, size: 56, color: Colors.grey.shade300),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Sin ventas este día',
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: sales.length,
                              itemBuilder: (context, i) {
                                final s = sales[i];
                                return _SaleTile(sale: s, timeFmt: timeFmt);
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SaleTile extends StatelessWidget {
  const _SaleTile({required this.sale, required this.timeFmt});

  final SaleEntity sale;
  final DateFormat timeFmt;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: const Icon(Icons.receipt_long, color: AppColors.primaryTeal),
        title: Text(
          '\$${sale.total.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${timeFmt.format(sale.createdAt)} · ${_pay(sale.paymentMethod)} · ${sale.lines.length} líneas'
          '${sale.isLocalOnly ? ' · local' : ''}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                for (final line in sale.lines)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(line.productName),
                    trailing: Text(
                      '${line.quantity} × \$${line.unitPrice.toStringAsFixed(2)} = \$${line.lineTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                if (sale.cashReceived != null)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Recibido'),
                    trailing: Text('\$${sale.cashReceived!.toStringAsFixed(2)}'),
                  ),
                if (sale.changeAmount != null)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Cambio'),
                    trailing: Text(
                      '\$${sale.changeAmount!.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _pay(String? m) {
    switch (m) {
      case 'card':
        return 'Tarjeta';
      case 'cash':
        return 'Efectivo';
      default:
        return m ?? '—';
    }
  }
}
