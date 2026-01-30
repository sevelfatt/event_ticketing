import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:skl_1_event_ticketing/services/api_service.dart';
import 'package:flutter/services.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  final ApiService _api = ApiService();
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[900],
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (_isScanned) return;
              for (final barcode in capture.barcodes) {
                _handleQRCode(barcode.rawValue);
              }
            },
          ),

          // Overlay scanner frame
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Instruction text
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Text(
              'Arahkan QR code ke frame',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleQRCode(String? code) async {
    if (code == null) return;
    setState(() => _isScanned = true);

    Response response;
    try {
      response = await _api.scanTicket(code);
    } catch (e) {
      response = Response(
        requestOptions: RequestOptions(path: ''),
        data: {'message': 'Failed', 'ticket': {'name': '', 'status': ''}},
      );
    }

    // Haptic & sound feedback
    HapticFeedback.mediumImpact();

    // Show bottom sheet instead of dialog
    await showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        bool success = response.data['message'] == "Success";
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? Colors.green : Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                success ? "Berhasil" : "Gagal",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Nama: ${response.data['ticket']['name'] ?? '-'}"),
              Text("Status: ${response.data['ticket']['status'] ?? '-'}"),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _isScanned = false); // reset scanner
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                ),
                child: const Text('Scan Lagi'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
