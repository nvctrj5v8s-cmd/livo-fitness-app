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

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final _scannerController = MobileScannerController();
  bool _loading = false;
  String? _message;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_loading) return;
    final code = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');
    if (code.isEmpty) return;
    setState(() {
      _loading = true;
      _message = 'Produkt wird gesucht ...';
    });
    await _scannerController.stop();
    try {
      final food = await BarcodeLookupService().lookup(code);
      if (!mounted) return;
      Navigator.of(context).pop<FoodItem>(food);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = 'Nicht gefunden. Bitte Barcode nochmals scannen.';
      });
      await _scannerController.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barcode scannen')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _scannerController, onDetect: _handleBarcode),
          Center(
            child: Container(
              width: 280,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 3),
                borderRadius: BorderRadius.circular(18),
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
                child: Row(
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
                        _message ?? 'Barcode in den Rahmen halten',
                        style: const TextStyle(color: Colors.white),
                      ),
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
