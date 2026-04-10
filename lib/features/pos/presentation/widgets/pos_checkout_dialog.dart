import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypime/core/theme/app_theme.dart';
import 'package:mypime/features/pos/presentation/providers/cart_provider.dart';
import 'package:mypime/features/products/presentation/providers/product_providers.dart';
import 'package:mypime/features/sales/domain/entities/sale_entity.dart';
import 'package:mypime/features/sales/presentation/providers/sales_providers.dart';

DateTime _todayKey() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

/// Devuelve `true` si la venta se registró correctamente.
Future<bool> showPosCheckoutDialog({
  required BuildContext context,
  required WidgetRef ref,
  required List<CartLine> cart,
  required double total,
}) async {
  if (cart.isEmpty) return false;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _CheckoutDialog(
      cart: cart,
      total: total,
      onConfirm: (paymentMethod, cashReceived) async {
        final lines = cart
            .map(
              (l) => SaleLineEntity(
                productId: l.productId,
                productName: l.name,
                quantity: l.quantity,
                unitPrice: l.unitPrice,
              ),
            )
            .toList();

        final create = ref.read(createSaleUseCaseProvider);
        await create(
          lines: lines,
          paymentMethod: paymentMethod,
          cashReceived: cashReceived,
        );

        ref.read(cartProvider.notifier).clear();
        ref.invalidate(fullProductCatalogProvider);
        await ref.read(productsNotifierProvider.notifier).refresh();
        ref.invalidate(salesByDayProvider(_todayKey()));
      },
    ),
  );
  return result ?? false;
}

class _CheckoutDialog extends StatefulWidget {
  const _CheckoutDialog({
    required this.cart,
    required this.total,
    required this.onConfirm,
  });

  final List<CartLine> cart;
  final double total;
  final Future<void> Function(String paymentMethod, double? cashReceived) onConfirm;

  @override
  State<_CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<_CheckoutDialog> {
  String _payment = 'cash';
  final _cashController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    double? cashIn;
    if (_payment == 'cash') {
      final parsed = double.tryParse(_cashController.text.replaceAll(',', '.'));
      if (parsed == null || parsed < widget.total) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Indica un monto recibido mayor o igual al total')),
        );
        return;
      }
      cashIn = parsed;
    }

    setState(() => _busy = true);
    try {
      await widget.onConfirm(_payment, cashIn);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cobrar'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Total: \$${widget.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryTeal,
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'cash', label: Text('Efectivo'), icon: Icon(Icons.money)),
                ButtonSegment(value: 'card', label: Text('Tarjeta'), icon: Icon(Icons.credit_card)),
              ],
              selected: {_payment},
              onSelectionChanged: (s) {
                setState(() => _payment = s.first);
              },
            ),
            if (_payment == 'cash') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _cashController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Recibido',
                  prefixText: r'$ ',
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Confirmar venta'),
        ),
      ],
    );
  }
}
