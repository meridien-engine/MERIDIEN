import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Bottom sheet that handles barcode input via:
/// - Camera (mobile: Android / iOS)
/// - Hardware barcode reader or manual typing (web / desktop)
class BarcodeScannerSheet extends StatefulWidget {
  /// Called once with the raw barcode/SKU string when a scan is confirmed.
  final void Function(String value) onScanned;

  const BarcodeScannerSheet({super.key, required this.onScanned});

  @override
  State<BarcodeScannerSheet> createState() => _BarcodeScannerSheetState();
}

class _BarcodeScannerSheetState extends State<BarcodeScannerSheet> {
  static bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  MobileScannerController? _cameraController;
  final _textController = TextEditingController();
  bool _consumed = false; // prevent firing onScanned twice

  @override
  void initState() {
    super.initState();
    if (_isMobile) {
      _cameraController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _emit(String value) {
    if (_consumed || value.trim().isEmpty) return;
    _consumed = true;
    widget.onScanned(value.trim());
    Navigator.of(context).pop();
  }

  void _onDetect(BarcodeCapture capture) {
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw != null && raw.isNotEmpty) _emit(raw);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: _isMobile ? 0.75 : 0.38,
      minChildSize: 0.3,
      maxChildSize: _isMobile ? 0.92 : 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // ── Drag handle ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Title ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.qr_code_scanner_rounded,
                      color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    'Scan Product',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // ── Camera view (mobile only) ──────────────────────────────
            if (_isMobile) ...[
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        MobileScanner(
                          controller: _cameraController!,
                          onDetect: _onDetect,
                        ),
                        // Aiming overlay
                        Center(
                          child: Container(
                            width: 260,
                            height: 90,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorScheme.primary,
                                width: 2.5,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        // Corner hint text
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Point camera at barcode',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or enter manually',
                          style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
              ),
            ] else ...[
              // ── Web / Desktop hint ────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.keyboard_rounded,
                        size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Scan with a barcode reader or type the barcode / SKU below',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Manual text entry (all platforms) ─────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: TextField(
                controller: _textController,
                autofocus: !_isMobile,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: 'Barcode / SKU',
                  hintText: 'e.g. 6291041500213',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.qr_code_rounded),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search_rounded),
                    tooltip: 'Look up',
                    onPressed: () => _emit(_textController.text),
                  ),
                ),
                onSubmitted: _emit,
              ),
            ),
          ],
        );
      },
    );
  }
}
