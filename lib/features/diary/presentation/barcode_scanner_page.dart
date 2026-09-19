import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/data/barcode_lookup_service.dart';
import '../../../core/models/app_models.dart';
import '../../../core/theme/app_colors.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage>
    with SingleTickerProviderStateMixin {
  final _scannerController = MobileScannerController();
  late final AnimationController _scanLineController;
  bool _loading = false;
  bool _manualEntryOpen = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_loading || _manualEntryOpen) return;
    final code = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');
    if (code.isEmpty) return;
    await _lookupBarcode(code);
  }

  Future<void> _lookupBarcode(String code) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _message = 'Produkt wird gesucht ...';
    });
    try {
      final food = await BarcodeLookupService().lookup(code);
      if (!mounted) return;
      Navigator.of(context).pop<FoodItem>(food);
    } on BarcodeLookupException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = switch (error.kind) {
          BarcodeErrorKind.notFound =>
            'Dieses Produkt ist noch nicht in der Datenquelle. Du kannst es selbst eintragen.',
          BarcodeErrorKind.rateLimited =>
            'Bitte kurz warten, bevor du den nächsten Barcode suchst.',
          _ => error.message,
        };
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = 'Barcode konnte gerade nicht verarbeitet werden.';
      });
    }
  }

  Future<void> _openManualEntry() async {
    if (_loading || _manualEntryOpen) return;
    setState(() => _manualEntryOpen = true);
    if (!mounted) return;
    final textController = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Barcode eingeben'),
        content: TextField(
          controller: textController,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'z. B. 3017620422003',
            labelText: 'EAN / Barcode',
          ),
          onSubmitted: (value) => Navigator.pop(dialogContext, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, textController.text),
            child: const Text('Suchen'),
          ),
        ],
      ),
    );
    textController.dispose();
    if (!mounted) return;
    setState(() => _manualEntryOpen = false);
    if (code?.trim().isNotEmpty == true) {
      await _lookupBarcode(code!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barcode scannen')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleBarcode,
          ),
          Center(
            child: SizedBox(
              width: 280,
              height: 150,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, width: 3),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.18),
                            blurRadius: 28,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _scanLineController,
                    builder: (context, _) {
                      final reduceMotion =
                          MediaQuery.maybeOf(context)?.disableAnimations ??
                          false;
                      final progress = reduceMotion
                          ? 0.5
                          : _scanLineController.value;
                      return Positioned(
                        left: 16,
                        right: 16,
                        top: 18 + (112 * progress),
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.primary,
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.65,
                                ),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 30,
            child: Card(
              color: Colors.black.withValues(alpha: 0.78),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (_loading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          const Icon(Icons.qr_code_scanner_rounded),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _message ??
                                'Kamera aktiv – Barcode in den Rahmen halten',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _loading ? null : _openManualEntry,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                      icon: const Icon(Icons.keyboard_rounded, size: 18),
                      label: const Text('Barcode manuell eingeben'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
