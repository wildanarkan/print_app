import 'dart:convert';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:image/image.dart' as img;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

void main() {
  runApp(const PrintApp());
}

class PrintApp extends StatefulWidget {
  const PrintApp({super.key});

  @override
  State<PrintApp> createState() => _PrintAppState();
}

class _PrintAppState extends State<PrintApp> {
  final GlobalKey _globalKey = GlobalKey();

  final String _selectSize = "2";
  String _message = "";
  String _bluetooth = "";
  String _connection = "";
  bool loading = false;
  final _txtText = TextEditingController(text: "");
  bool connected = false;
  bool _visible = true;
  WidgetsToImageController controller = WidgetsToImageController();

  List<BluetoothInfo> devices = [];
  String? selectedDevice;

  @override
  void initState() {
    super.initState();
    checkBluetooth();
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange[200],
          title: const Text('Print Thermal APP'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => checkBluetooth(),
                        child: const Text('Check Bluetooth'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => checkConnection(),
                        child: const Text('Check Connection'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => checkBattery(),
                        child: const Text('Check Battery'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => disconnectDevice(),
                        child: const Text('Disconnect Device'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => searchDevices(),
                        child: const Text('Search Devices'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => connectDevice(),
                        child: const Text('Connect Device'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (devices.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedDevice,
                  hint: const Text('Select Device'),
                  items: devices.map((device) {
                    return DropdownMenuItem(
                      value: device.macAdress,
                      child: Text('${device.name} (${device.macAdress})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDevice = value;
                    });
                  },
                ),
              ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bluetooth Enable = $_bluetooth'),
                  Text('Connection Status = $_connection'),
                  Text('Output = $_message'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _txtText,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter text to print',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 100,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => printText(),
                    child: const Text('Print'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => printStatus(),
              child: const Text('PRINT STATUS'),
            ),
            ElevatedButton(
              onPressed: () => printImage(),
              child: const Text('PRINT IMAGE'),
            ),
            ElevatedButton(
              onPressed: () => printQrCode(),
              child: const Text('PRINT QR CODE'),
            ),
            ElevatedButton(
              onPressed: () => printWidget(),
              child: const Text('PRINT WIDGET NOTE'),
            ),
            ElevatedButton(
              onPressed: () => printNote(),
              child: const Text('PRINT EXAMPLE'),
            ),
            ElevatedButton(
              onPressed: () => printTest(),
              child: const Text('PRINT TEST'),
            ),
            ElevatedButton(
              onPressed: () => printTestBytes(),
              child: const Text('PRINT TEST BYTES'),
            ),
            ElevatedButton(
              onPressed: () => printImageResize(),
              child: const Text('PRINT IMAGE RESIZE'),
            ),
            ElevatedButton(
              onPressed: () async {
                await renderingWidget();
              },
              child: const Text('Capture Image'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('PRINT WIDGET NOT SHOWING'),
            ),
            WidgetsToImage(
              controller: controller,
              child: myNote(),
            ),
            Offstage(
              offstage: _visible,
              child: widgetBoundary(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> renderingWidget() async {
    setState(() {
      _visible = false;
    });
    await _captureImage();
  }

  Widget widgetBoundary() {
    return Transform.translate(
      offset: const Offset(0, -9999),
      child: RepaintBoundary(
        key: _globalKey,
        child: Container(
          width: 384,
          color: Colors.white,
          // padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Nota
              const Center(
                child: Column(
                  children: [
                    Text(
                      'TOKO MAINAN CERIA',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Jl. Mainstreet No. 123',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Telp: (021) 123-456',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),

              // Informasi Transaksi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('No. Nota: INV-001'),
                  Text(
                      'Tanggal: ${DateTime.now().toString().substring(0, 10)}'),
                ],
              ),
              const SizedBox(height: 20),

              // Header Tabel
              const Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Item',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Qty',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Harga',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const Divider(
                thickness: 2,
                color: Colors.black,
              ),
              _buildItemRow('Mobil Remote', 1, 150000),
              _buildItemRow('Boneka Beruang', 2, 75000),
              _buildItemRow('Puzzle 100pc', 1, 45000),
              const Divider(
                thickness: 2,
                color: Colors.black,
              ),

              // Total
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rp 345.000',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              // Footer
              const SizedBox(height: 30),
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Terima kasih atas kunjungan Anda!',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    Text(
                      'Barang yang sudah dibeli tidak dapat ditukar',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Widget helper untuk membuat baris item
  Widget _buildItemRow(String item, int qty, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item,
              style: const TextStyle(fontWeight: ui.FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              qty.toString(),
              style: const TextStyle(fontWeight: ui.FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Rp ${price.toStringAsFixed(0)}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: ui.FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Rp ${(price * qty).toStringAsFixed(0)}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: ui.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _captureImage() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        RenderRepaintBoundary boundary = _globalKey.currentContext
            ?.findRenderObject() as RenderRepaintBoundary;

        // Menunggu sampai rendering selesai (tunggu frame pertama)
        if (boundary.debugNeedsPaint) {
          print('Widget belum selesai dirender, menunggu...');
          return; // Jangan lanjutkan jika belum siap
        }

        ui.Image boundaryImage = await boundary.toImage(pixelRatio: 3.0);

        // Convert the captured image to bytes (PNG format)
        ByteData? byteData =
            await boundaryImage.toByteData(format: ui.ImageByteFormat.png);
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        // Optionally, save the image or display it
        // For example, you can use the `image` bytes in a File or display it in an Image widget.
        print('Captured image bytes: $pngBytes');

        img.Image? image = img.decodeImage(pngBytes);

        // RESIZE IMAGE
        final resizedImage = img.copyResize(image!, width: 384);

        List<int> printBytes = [];
        final profile = await CapabilityProfile.load();
        final generator = Generator(PaperSize.mm58, profile);
        printBytes += generator.reset();
        printBytes += generator.image(resizedImage);
        printBytes += generator.feed(2);

        final result = await PrintBluetoothThermal.writeBytes(printBytes);

        setState(() {
          _message =
              result ? "Widget printed successfully" : "Failed to print widget";
          loading = false;
          _visible = true;
        });
      } catch (e) {
        print('Error capturing image: $e');
      }
    });
  }

  Future<void> printImageResize() async {
    bool isConnect = await PrintBluetoothThermal.connectionStatus;
    if (!isConnect) {
      log(isConnect.toString());
      setState(() {
        _message = 'PrintBluetoothThermal: $isConnect';
      });
    }

    int battery = await PrintBluetoothThermal.batteryLevel;
    log('Battery: $battery');

    bool bluetooth = await PrintBluetoothThermal.bluetoothEnabled;
    log('Bluetooth: $bluetooth');

    bool connection = await PrintBluetoothThermal.connectionStatus;
    log('Connection: $connection');
    final ByteData data = await rootBundle.load('assets/dudul1.jpeg');
    final Uint8List bytesImg = data.buffer.asUint8List();
    img.Image? image = img.decodeImage(bytesImg);

    // RESIZE IMAGE
    final resizedImage = img.copyResize(image!, width: 384);

    List<int> printBytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    printBytes += generator.reset();
    printBytes += generator.image(resizedImage);
    printBytes += generator.feed(2);

    final result = await PrintBluetoothThermal.writeBytes(printBytes);

    setState(() {
      _message =
          result ? "Widget printed successfully" : "Failed to print widget";
      loading = false;
    });
  }

  Future<void> disconnectDevice() async {
    bool isConnect = await PrintBluetoothThermal.connectionStatus;
    if (!isConnect) {
      log('kamu tidak terkonek apapun saat ini');
      return;
    }

    try {
      bool isDisconnect = await PrintBluetoothThermal.disconnect;
      log('disconnect');
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> checkBattery() async {
    int battery = await PrintBluetoothThermal.batteryLevel;
    setState(() {
      _message = "Your battery now: $battery";
    });
  }

  Future<void> printTest() async {
    bool isConnect = await PrintBluetoothThermal.connectionStatus;
    if (!isConnect) {
      log(isConnect.toString());
      setState(() {
        _message = 'PrintBluetoothThermal: $isConnect';
      });
    }
    int battery = await PrintBluetoothThermal.batteryLevel;
    log('Battery: $battery');

    bool bluetooth = await PrintBluetoothThermal.bluetoothEnabled;
    log('Bluetooth: $bluetooth');

    bool connection = await PrintBluetoothThermal.connectionStatus;
    log('Connection: $connection');

    await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 1, text: 'Satu\n'));
    await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 2, text: 'Dua\n'));
    await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 3, text: 'Tiga\n'));
    await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 4, text: 'Empat\n'));
    await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 5, text: 'Lima\n'));

    setState(() {
      _message = 'PrintBluetoothThermal: $isConnect';
    });
  }

  Future<void> printTestBytes() async {
    bool isConnect = await PrintBluetoothThermal.connectionStatus;
    if (!isConnect) {
      log(isConnect.toString());
      setState(() {
        _message = 'PrintBluetoothThermal: $isConnect';
      });
    }
    List<int> bytes = [];

    int battery = await PrintBluetoothThermal.batteryLevel;
    log('Battery: $battery');

    bool bluetooth = await PrintBluetoothThermal.bluetoothEnabled;
    log('Bluetooth: $bluetooth');

    bool connection = await PrintBluetoothThermal.connectionStatus;
    log('Connection: $connection');

    // Buat byte array (contoh teks ESC/POS)
    bytes += utf8.encode("Satu\n"); // Teks sederhana
    bytes += [0x1B, 0x45, 0x01]; // ESC/POS Bold ON
    bytes += utf8.encode("Satu\n"); // Teks sederhana
    bytes += [0x1B, 0x45, 0x00]; // ESC/POS Bold OFF
    bytes += utf8.encode("Satu\n"); // Teks sederhana

    // Kirim byte array ke printer
    await PrintBluetoothThermal.writeBytes(bytes);

    setState(() {
      _message = 'PrintBluetoothThermal: $isConnect';
    });
  }

  Future<void> printNote() async {
    bool isConnect = await PrintBluetoothThermal.connectionStatus;
    if (isConnect) {
      // Header
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 2, text: "NAMA TOKO\n"),
      );
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
            size: 1, text: "Jl. Contoh No. 123\nTelp: 081234567890\n"),
      );

      // Separator
      await PrintBluetoothThermal.writeString(
        printText:
            PrintTextSize(size: 1, text: "================================\n"),
      );

      // Transaction Info
      String dateTime = DateTime.now().toString().substring(0, 19);
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 1, text: "Tanggal: $dateTime\n"),
      );
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 1, text: "No. Nota: INV-001\n"),
      );
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 1, text: "Kasir: Admin\n"),
      );

      // Separator
      await PrintBluetoothThermal.writeString(
        printText:
            PrintTextSize(size: 1, text: "================================\n"),
      );

      // Items
      List<Map<String, dynamic>> items = [
        {"name": "Produk A", "qty": 2, "price": 50000},
        {"name": "Produk B", "qty": 1, "price": 75000},
      ];

      for (var item in items) {
        String itemName = item["name"];
        int qty = item["qty"];
        int price = item["price"];
        int total = qty * price;

        await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(size: 1, text: "$itemName\n"),
        );
        await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(
              size: 1,
              text:
                  "$qty x ${formatCurrency(price)} = ${formatCurrency(total)}\n"),
        );
      }

      // Separator
      await PrintBluetoothThermal.writeString(
        printText:
            PrintTextSize(size: 1, text: "--------------------------------\n"),
      );

      // Total
      int subtotal = items.fold<int>(0,
          (sum, item) => sum + ((item["qty"] as int) * (item["price"] as int)));
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
            size: 1, text: "Subtotal: ${formatCurrency(subtotal)}\n"),
      );

      int tax = (subtotal * 0.10).round(); // 10% tax
      await PrintBluetoothThermal.writeString(
        printText:
            PrintTextSize(size: 1, text: "PPN (10%): ${formatCurrency(tax)}\n"),
      );

      int grandTotal = subtotal + tax;
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
            size: 2, text: "TOTAL: ${formatCurrency(grandTotal)}\n"),
      );

      // Footer
      await PrintBluetoothThermal.writeString(
        printText:
            PrintTextSize(size: 1, text: "================================\n"),
      );
      await PrintBluetoothThermal.writeString(
        printText:
            PrintTextSize(size: 1, text: "Terima kasih atas kunjungan Anda\n"),
      );
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
            size: 1,
            text:
                "Barang yang sudah dibeli\ntidak dapat ditukar/dikembalikan\n"),
      );

      // Print extra lines to ensure paper can be torn
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 1, text: "\n\n\n"),
      );
    } else {
      print("Printer tidak terhubung. Status: $isConnect");
    }
  }

  String formatCurrency(int number) {
    return "Rp ${number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
  }

  Widget myNote() {
    // Sample data - in real app you would pass this as parameters
    final items = [
      {'name': 'Mie Goreng', 'qty': 2, 'price': 15000},
      {'name': 'Es Teh Manis', 'qty': 2, 'price': 5000},
      {'name': 'Nasi Putih', 'qty': 2, 'price': 5000},
    ];

    final total = items.fold<int>(
        0, (sum, item) => sum + (item['qty'] as int) * (item['price'] as int));

    return Container(
      width: 380, // Standard width for 58mm printer
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Header
          const Text(
            'WARUNG MAKAN BAROKAH',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Jl. Contoh No. 123, Kota',
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const Text(
            'Telp: 081234567890',
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),

          // Divider
          const Divider(thickness: 1, color: Colors.black),

          // Receipt Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'No: WMB-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                DateTime.now().toString().substring(0, 19),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Items Header
          const Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Item',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Qty',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Harga',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const Divider(thickness: 1, color: Colors.black),

          // Items
          ...items.map((item) => Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      item['name'] as String,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${item['qty']}',
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      formatPrice(item['price'] as int),
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      formatPrice(
                          (item['qty'] as int) * (item['price'] as int)),
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              )),

          // Total
          const Divider(thickness: 1, color: Colors.black),
          Row(
            children: [
              const Expanded(
                flex: 6,
                child: Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  formatPrice(total),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Footer
          const Text(
            'Terima Kasih',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Silahkan datang kembali',
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String formatPrice(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  Future<void> printQrCode() async {
    bool isConnect = await PrintBluetoothThermal.connectionStatus;
    if (isConnect) {
      List<int> bytes = [];
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      bytes +=
          generator.qrcode('https://linktr.ee/wildanarkan', size: QRSize.size1);
      bytes +=
          generator.qrcode('https://linktr.ee/wildanarkan', size: QRSize.size2);
      bytes +=
          generator.qrcode('https://linktr.ee/wildanarkan', size: QRSize.size3);
      bytes +=
          generator.qrcode('https://linktr.ee/wildanarkan', size: QRSize.size4);
      bytes +=
          generator.qrcode('https://linktr.ee/wildanarkan', size: QRSize.size5);
      bytes +=
          generator.qrcode('https://linktr.ee/wildanarkan', size: QRSize.size6);
      bytes +=
          generator.qrcode('https://linktr.ee/wildanarkan', size: QRSize.size7);
      bytes +=
          generator.qrcode('https://linktr.ee/wildanarkan', size: QRSize.size8);
      loading = await PrintBluetoothThermal.writeBytes(bytes);
    } else {
      print("Connection Bluetooth: $isConnect");
    }
  }

  Future<void> printStatus() async {
    bool isConnect = await PrintBluetoothThermal.connectionStatus;
    if (isConnect) {
      String enter = '\n';
      await PrintBluetoothThermal.writeBytes(enter.codeUnits);
      //size of 1-5
      String text = "Hello";
      await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(size: 1, text: text));
      await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(size: 2, text: "$text size 2"));
      await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(size: 3, text: "$text size 3"));
    } else {
      print("Connection Bluetooth: $isConnect");
    }
  }

  Future<void> printWidget() async {
    try {
      // Check connection first
      bool isConnect = await PrintBluetoothThermal.connectionStatus;
      if (!isConnect) {
        setState(() {
          _message = "No printer connected";
        });
        return;
      }

      setState(() {
        _message = "Processing widget...";
        loading = true;
      });

      // Capture widget to bytes
      final bytes = await controller.capture(pixelRatio: 6.0); // Tingkatkan DPI
      if (bytes == null) {
        setState(() {
          _message = "Failed to capture widget";
          loading = false;
        });
        return;
      }

      final image = img.decodeImage(bytes);
      if (image == null) {
        setState(() {
          _message = "Failed to decode image";
          loading = false;
        });
        return;
      }

      final resizedImage = img.copyResize(image, width: 384);

      List<int> printBytes = [];
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      printBytes += generator.reset();
      printBytes += generator.image(resizedImage);
      // printBytes += generator.qrcode('https://linktr.ee/wildanarkan', size: QRSize.size2);
      // printBytes += generator.text('Terima Kasih');
      // printBytes += generator.text('Silahkan datang kembali');
      printBytes += generator.feed(2);

      final result = await PrintBluetoothThermal.writeBytes(printBytes);

      setState(() {
        _message =
            result ? "Widget printed successfully" : "Failed to print widget";
        loading = false;
      });
    } catch (e) {
      setState(() {
        _message = "Error printing widget: $e";
        loading = false;
      });
    }
  }

  Future<void> printImage() async {
    List<int> bytes = [];
    // Using default profile
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    //bytes += generator.setGlobalFont(PosFontType.fontA);
    bytes += generator.reset();

    final ByteData data = await rootBundle.load('assets/keluarga.jpg');
    final Uint8List bytesImg = data.buffer.asUint8List();
    img.Image? image = img.decodeImage(bytesImg);
    bytes += generator.image(image!);
    try {
      PrintBluetoothThermal.writeBytes(bytes).toString();
      setState(() {
        _message = "success";
      });
    } catch (e) {
      setState(() {
        _message = "$e";
      });
    }
  }

  Future<void> checkBluetooth() async {
    try {
      bool state = await PrintBluetoothThermal.bluetoothEnabled;
      log('Bluetooth Enabled: $state');
      setState(() {
        _message = "Bluetooth enabled: $state";
        _bluetooth = "$state";
      });
    } catch (e) {
      setState(() {
        _message = "Error checking Bluetooth: $e";
        _bluetooth = "Error";
      });
    }
  }

  Future<String> checkConnection() async {
    try {
      final bool result = await PrintBluetoothThermal.connectionStatus;
      connected = result;
      setState(() {
        _message = "Connection status: $result";
        _connection = "$result";
      });
      return _message;
    } catch (e) {
      setState(() {
        _message = "Error checking connection: $e";
        _connection = "Error";
      });
      return _message;
    }
  }

  Future<void> searchDevices() async {
    setState(() {
      _message = "Searching devices...";
    });

    try {
      final List<BluetoothInfo> peripherals =
          await PrintBluetoothThermal.pairedBluetooths;

      setState(() {
        devices = peripherals;
        _message = "Found ${peripherals.length} devices";
      });
    } catch (e) {
      setState(() {
        _message = "Error searching devices: $e";
      });
    }
  }

  Future<void> connectDevice() async {
    if (selectedDevice == null) {
      setState(() {
        _message = "Please select a device first";
      });
      return;
    }

    if (connected == true) {
      log('Sudah konek');
      return;
    }

    setState(() {
      _message = "Connecting...";
    });

    try {
      final bool result = await PrintBluetoothThermal.connect(
        macPrinterAddress: selectedDevice!,
      );

      setState(() {
        connected = result;
        _message = result ? "Connected successfully" : "Connection failed";
        _connection = "$result";
      });
    } catch (e) {
      setState(() {
        _message = "Error connecting: $e";
        _connection = "Error";
      });
    }
  }

  Future<void> printText() async {
    if (!connected) {
      setState(() {
        _message = "No connected device";
      });
      return;
    }

    if (_txtText.text.isEmpty) {
      setState(() {
        _message = "Please enter text to print";
      });
      return;
    }

    try {
      String text = "${_txtText.text}\n";
      bool result = await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: int.parse(_selectSize), text: text),
      );

      setState(() {
        _message = "Printed status: $result";
      });
    } catch (e) {
      setState(() {
        _message = "Error printing: $e";
      });
    }
  }
}
