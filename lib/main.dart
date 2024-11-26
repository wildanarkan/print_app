import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:print_app/controller/print_controller.dart';
import 'package:print_app/models/product_model.dart';
import 'package:print_app/pages/screenshot_page.dart';
import 'package:print_app/widgets/box_icon.dart';
import 'package:print_app/widgets/status_item.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PrintController printController = Get.put(PrintController());
  List<BluetoothInfo> devices = [];
  String? selectedDevice;

  final TextEditingController _txtPrintController = TextEditingController();

  // Print Note
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _cashierController = TextEditingController();

  // Print Screenshot
  final TextEditingController _nomorController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // Data produk
  List<Product> products = [
    Product(
      image: 'assets/dudul1.jpeg',
      name: 'Produk 1',
      price: 15000,
    ),
    Product(
      image: 'assets/dudul1.jpeg',
      name: 'Produk 2',
      price: 30000,
    ),
    Product(
      image: 'assets/dudul1.jpeg',
      name: 'Produk 3',
      price: 20000,
    ),
  ];

  bool isFound = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Print Thermal App",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.indigo,
        ),
        body: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            // if (devices.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedDevice,
                hint: Text(
                  isFound
                      ? 'Select device to connect...'
                      : 'Search for find devices...',
                ),
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
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                BoxIcon(
                  onTap: () => dialogStatus(),
                  icon: Icons.info_rounded,
                  title: 'STATUS',
                ),
                const SizedBox(width: 10),
                BoxIcon(
                  onTap: () => searchDevices(),
                  icon: Icons.search,
                  title: 'SEARCH',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                BoxIcon(
                  onTap: () => disconnectDevice(),
                  icon: Icons.cancel_outlined,
                  title: 'DISCONNECT',
                ),
                const SizedBox(width: 10),
                BoxIcon(
                  onTap: () => connectDevice(),
                  icon: Icons.all_inclusive_sharp,
                  title: 'CONNECT',
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                color: Colors.black38,
                thickness: 2,
              ),
            ),
            Row(
              children: [
                BoxIcon(
                  onTap: () => dialogTextField(false),
                  icon: Icons.text_fields_outlined,
                  title: 'TEXT',
                  height: 80,
                  titleSize: 10,
                  iconSize: 25,
                ),
                const SizedBox(width: 10),
                BoxIcon(
                  onTap: () => dialogTextField(true),
                  icon: Icons.qr_code_2,
                  title: 'QR CODE',
                  height: 80,
                  titleSize: 10,
                  iconSize: 25,
                ),
                const SizedBox(width: 10),
                BoxIcon(
                  onTap: () => dialogImage(),
                  icon: Icons.image,
                  title: 'IMAGE',
                  height: 80,
                  titleSize: 10,
                  iconSize: 25,
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                BoxIcon(
                  onTap: () => dialogNote(),
                  icon: Icons.sticky_note_2,
                  title: 'NOTE',
                  height: 80,
                  titleSize: 10,
                  iconSize: 25,
                ),
                const SizedBox(width: 10),
                BoxIcon(
                  onTap: () => dialogScreenshot(),
                  icon: Icons.camera,
                  title: 'SCREENSHOT',
                  height: 80,
                  titleSize: 10,
                  iconSize: 25,
                ),
                const SizedBox(width: 10),
                BoxIcon(
                  onTap: () => dialogShopping(),
                  icon: Icons.shopping_cart,
                  title: 'SHOPPING',
                  height: 80,
                  titleSize: 10,
                  iconSize: 25,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> searchDevices() async {
    try {
      final status = await printController.checkStatus();

      if (status['bluetooth'] == false) {
        Get.snackbar('Failed', 'Pastikan bluetooth anda aktif');
        return;
      }

      final List<BluetoothInfo> peripherals =
          await PrintBluetoothThermal.pairedBluetooths;

      // log(peripherals.length.toString());
      if (peripherals.isNotEmpty) {
        isFound = true;
      }

      setState(() {
        devices = peripherals;
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> connectDevice() async {
    var status = await printController.checkStatus();
    if (selectedDevice == null) {
      Get.snackbar(
        'Failed',
        'Mohon pilih device terlebih dahulu',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (status['connection'] == true) {
      Get.snackbar(
        'Failed',
        'Pastikan anda tidak terhubung dengan perangkat apapun',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    try {
      final bool result = await PrintBluetoothThermal.connect(
        macPrinterAddress: selectedDevice!,
      );

      if (!result) {
        Get.snackbar(
          'Failed',
          'Pastikan bluetooth printer anda aktif ',
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      log(selectedDevice!);

      Get.snackbar(
        'Success',
        'Connected ke perangkat berhasil',
        backgroundColor: Colors.green[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      log(e.toString());
      Get.snackbar(
        'Error',
        'Terjadi kesalahan pada aplikasi',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> disconnectDevice() async {
    var status = await printController.checkStatus();
    if (!status['connection']) {
      log('kamu tidak terkonek apapun saat ini');
      Get.snackbar(
        'Failed',
        'Anda tidak terkoneksi oleh perangkat apapun',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    try {
      bool isDisconnect = await PrintBluetoothThermal.disconnect;
      if (!isDisconnect) {
        Get.snackbar(
          'Failed',
          'Terjadi kesalahan pada aplikasi',
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      Get.snackbar(
        'Success',
        'Disconnected pada perangkat telah berhasil',
        backgroundColor: Colors.green[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      log('disconnect');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to connect: $e',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> printText() async {
    var status = await printController.checkStatus();
    if (!status['connection']) {
      log('kamu tidak terkonek apapun saat ini');
      Get.snackbar(
        'Failed',
        'Anda tidak terkoneksi oleh perangkat apapun',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (_txtPrintController.text.isEmpty) {
      Get.snackbar(
        'Failed',
        'Pastikan data tidak kosong',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    try {
      String text = "${_txtPrintController.text}\n";
      bool result = await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          // size: int.parse(_selectSize),
          text: text,
        ),
      );

      if (!result) {
        Get.snackbar(
          'Failed',
          'Terjadi kesalahan saat printing',
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }

      Get.snackbar(
        'Success',
        'Berhasil mencetak: ${_txtPrintController.text}',
        backgroundColor: Colors.green[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan pada aplikasi',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      _txtPrintController.text = '';
    }
  }

  Future<void> printQrCode(String link) async {
    if (_txtPrintController.text.isEmpty) {
      Get.snackbar(
        'Failed',
        'Mohon isi data agar tidak kosong',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    try {
      List<int> bytes = [];
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      bytes += generator.qrcode(link, size: QRSize.size4);

      bool success = await PrintBluetoothThermal.writeBytes(bytes);
      if (!success) {
        Get.snackbar(
          'Failed',
          'Terjadi kesalahan saat printing',
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }
      Get.snackbar(
        'Success',
        'Berhasil print QR Code',
        backgroundColor: Colors.green[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan pada aplikasi',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      _txtPrintController.text = '';
    }
  }

  Future<void> printImageResize(File imageFile) async {
    try {
      // Load dan decode gambar dari file
      final Uint8List bytesImg = await imageFile.readAsBytes();
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

      if (result) {
        Get.snackbar(
          'Sukses',
          'Gambar berhasil dicetak!',
          backgroundColor: Colors.green[400],
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Gagal',
          'Gambar gagal dicetak.',
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat mencetak gambar: $e',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String formatCurrency(int number) {
    return "Rp ${number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
  }

  Future<void> printNote({
    required String brand,
    required String address,
    required String phoneNumber,
    required String cashier,
  }) async {
    if (brand.isEmpty &&
        address.isEmpty &&
        phoneNumber.isEmpty &&
        cashier.isEmpty) {
      log('Data tidak boleh kosong');
      return;
    }
    log('Brand : $brand');
    log('Address : $address');
    log('Phone Number : $phoneNumber');
    log('Cashier : $cashier');
    // bool isConnect = await PrintBluetoothThermal.connectionStatus;
    // if (isConnect) {
    //   await PrintBluetoothThermal.writeString(
    //     printText: PrintTextSize(size: 2, text: "$brand \n"),
    //   );
    //   await PrintBluetoothThermal.writeString(
    //     printText:
    //         PrintTextSize(size: 1, text: "$address \nTelp: $phoneNumber \n"),
    //   );
    //   await PrintBluetoothThermal.writeString(
    //     printText:
    //         PrintTextSize(size: 1, text: "================================\n"),
    //   );

    //   // Transaction Info
    //   String dateTime = DateTime.now().toString().substring(0, 19);
    //   await PrintBluetoothThermal.writeString(
    //     printText: PrintTextSize(size: 1, text: "Tanggal: $dateTime\n"),
    //   );
    //   await PrintBluetoothThermal.writeString(
    //     printText: PrintTextSize(size: 1, text: "No. Nota: INV-001\n"),
    //   );
    //   await PrintBluetoothThermal.writeString(
    //     printText: PrintTextSize(size: 1, text: "Kasir: $cashier \n"),
    //   );

    //   // Separator
    //   await PrintBluetoothThermal.writeString(
    //     printText:
    //         PrintTextSize(size: 1, text: "================================\n"),
    //   );

    //   // Items
    //   List<Map<String, dynamic>> items = [
    //     {"name": "Ayam Geprek", "qty": 2, "price": 26000},
    //     {"name": "Nasi Rawon", "qty": 1, "price": 11000},
    //     {"name": "Pentol Goreng", "qty": 3, "price": 15000},
    //     {"name": "Permen", "qty": 5, "price": 2500},
    //     {"name": "Batagor", "qty": 2, "price": 5000},
    //   ];

    //   for (var item in items) {
    //     String itemName = item["name"];
    //     int qty = item["qty"];
    //     int price = item["price"];
    //     int total = qty * price;

    //     await PrintBluetoothThermal.writeString(
    //       printText: PrintTextSize(size: 1, text: "$itemName\n"),
    //     );
    //     await PrintBluetoothThermal.writeString(
    //       printText: PrintTextSize(
    //           size: 1,
    //           text:
    //               "$qty x ${formatCurrency(price)} = ${formatCurrency(total)}\n"),
    //     );
    //   }

    //   await PrintBluetoothThermal.writeString(
    //     printText:
    //         PrintTextSize(size: 1, text: "--------------------------------\n"),
    //   );

    //   int subtotal = items.fold<int>(0,
    //       (sum, item) => sum + ((item["qty"] as int) * (item["price"] as int)));
    //   await PrintBluetoothThermal.writeString(
    //     printText: PrintTextSize(
    //         size: 1, text: "Subtotal: ${formatCurrency(subtotal)}\n"),
    //   );

    //   int tax = (subtotal * 0.10).round();
    //   await PrintBluetoothThermal.writeString(
    //     printText:
    //         PrintTextSize(size: 1, text: "PPN (10%): ${formatCurrency(tax)}\n"),
    //   );

    //   int grandTotal = subtotal + tax;
    //   await PrintBluetoothThermal.writeString(
    //     printText: PrintTextSize(
    //         size: 2, text: "TOTAL: ${formatCurrency(grandTotal)}\n"),
    //   );

    //   // Footer
    //   await PrintBluetoothThermal.writeString(
    //     printText:
    //         PrintTextSize(size: 1, text: "================================\n"),
    //   );
    //   await PrintBluetoothThermal.writeString(
    //     printText:
    //         PrintTextSize(size: 1, text: "Terima kasih atas kunjungan Anda\n"),
    //   );
    //   await PrintBluetoothThermal.writeString(
    //     printText: PrintTextSize(
    //         size: 1,
    //         text:
    //             "Barang yang sudah dibeli\ntidak dapat ditukar/dikembalikan\n"),
    //   );

    //   await PrintBluetoothThermal.writeString(
    //     printText: PrintTextSize(size: 1, text: "\n\n\n"),
    //   );
    // } else {
    //   print("Printer tidak terhubung. Status: $isConnect");
    // }
  }

  void dialogTextField(bool isLink) async {
    try {
      final status = await printController.checkStatus();

      if (!status['connection']) {
        Get.snackbar(
          'Failed',
          'Pastikan anda sudah terhubung dengan printer',
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLink ? 'Print QR Code' : 'Print Text',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _txtPrintController,
                  maxLength: 30,
                  decoration: InputDecoration(
                      hintText:
                          isLink ? 'Masukkan link...' : 'Ketik sesuatu...',
                      border: const OutlineInputBorder()),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(closeOverlays: true),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Close',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => isLink
                            ? printQrCode(_txtPrintController.text)
                            : printText(),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.print, size: 18),
                        label: const Text('print'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: true,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get printer status: $e',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        borderRadius: 8,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    }
  }

  void dialogStatus() async {
    try {
      final status = await printController.checkStatus();

      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.phone_android,
                        color: Colors.indigo[400],
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Handphone Status',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                StatusItem(
                  icon: Icons.battery_5_bar_rounded,
                  title: 'Battery Level',
                  value: '${status['battery']}%',
                  color: printController.getBatteryColor(status['battery']),
                ),
                const SizedBox(height: 16),
                StatusItem(
                  icon: Icons.bluetooth_rounded,
                  title: 'Bluetooth Status',
                  value: status['bluetooth'] ? 'Active' : 'Inactive',
                  color: status['bluetooth'] ? Colors.indigo : Colors.grey,
                ),
                const SizedBox(height: 16),
                StatusItem(
                  icon: Icons.wifi_rounded,
                  title: 'Connection Status',
                  value: status['connection'] ? 'Connected' : 'Disconnected',
                  color: status['connection'] ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(closeOverlays: true),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Close',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          await printController.checkStatus();
                          Get.back();
                          dialogStatus();
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Refresh'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: true,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get printer status: $e',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        borderRadius: 8,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    }
  }

  void dialogImage() async {
    final ImagePicker picker = ImagePicker();
    File? selectedImage;

    try {
      final status = await printController.checkStatus();

      if (!status['connection']) {
        Get.snackbar(
          'Failed',
          'Pastikan anda sudah terhubung dengan printer',
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      Get.dialog(
        StatefulBuilder(
          builder: (context, setState) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Gambar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  selectedImage != null
                      ? Image.file(
                          selectedImage!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Text('Tidak ada gambar yang dipilih'),
                          ),
                        ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery);

                            if (image != null) {
                              setState(() {
                                selectedImage = File(image.path);
                              });
                              Get.snackbar(
                                'Berhasil',
                                'Gambar berhasil dipilih!',
                                backgroundColor: Colors.green[400],
                                colorText: Colors.white,
                                duration: const Duration(seconds: 3),
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            } else {
                              Get.snackbar(
                                'Info',
                                'Tidak ada gambar yang dipilih.',
                                backgroundColor: Colors.orange[400],
                                colorText: Colors.white,
                                duration: const Duration(seconds: 3),
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.photo_library,
                            size: 13,
                          ),
                          label: const Text('Gallery'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.camera);

                            if (image != null) {
                              setState(() {
                                selectedImage = File(image.path);
                              });
                              Get.snackbar(
                                'Berhasil',
                                'Gambar berhasil diambil!',
                                backgroundColor: Colors.green[400],
                                colorText: Colors.white,
                                duration: const Duration(seconds: 3),
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            } else {
                              Get.snackbar(
                                'Info',
                                'Tidak ada gambar yang diambil.',
                                backgroundColor: Colors.orange[400],
                                colorText: Colors.white,
                                duration: const Duration(seconds: 3),
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.camera_alt,
                            size: 13,
                          ),
                          label: const Text('Camera'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Get.back(closeOverlays: true),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Close'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            if (selectedImage != null) {
                              printImageResize(selectedImage!);
                            } else {
                              Get.snackbar(
                                'Gagal',
                                'Silakan pilih gambar terlebih dahulu.',
                                backgroundColor: Colors.red[400],
                                colorText: Colors.white,
                                duration: const Duration(seconds: 3),
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.print, size: 18),
                          label: const Text('Print'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: true,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get printer status: $e',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        borderRadius: 8,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    }
  }

  void dialogNote() async {
    try {
      // final status = await printController.checkStatus();

      // if (!status['connection']) {
      //   Get.snackbar(
      //     'Failed',
      //     'Pastikan anda sudah terhubung dengan printer',
      //     backgroundColor: Colors.red[400],
      //     colorText: Colors.white,
      //     duration: const Duration(seconds: 3),
      //     snackPosition: SnackPosition.BOTTOM,
      //     margin: const EdgeInsets.all(16),
      //   );
      //   return;
      // }

      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Print Note',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _brandController,
                    maxLength: 30,
                    decoration: InputDecoration(
                      hintText: 'Masukkan brand...',
                      prefixIcon: const Icon(Icons.branding_watermark,
                          color: Colors.indigo),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.indigo, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressController,
                    maxLength: 50,
                    decoration: InputDecoration(
                      hintText: 'Masukkan alamat...',
                      prefixIcon:
                          const Icon(Icons.location_on, color: Colors.indigo),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.indigo, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneNumberController,
                    maxLength: 30,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Masukkan nomor telepon...',
                      prefixIcon: const Icon(Icons.phone, color: Colors.indigo),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.indigo, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _cashierController,
                    maxLength: 30,
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama kasir...',
                      prefixIcon:
                          const Icon(Icons.person, color: Colors.indigo),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.indigo, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(closeOverlays: true),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.indigo),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            printNote(
                              brand: _brandController.text,
                              address: _addressController.text,
                              phoneNumber: _phoneNumberController.text,
                              cashier: _cashierController.text,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.print, size: 20),
                          label: const Text(
                            'Print',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: true,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get printer status: $e',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        borderRadius: 8,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    }
  }

  void dialogScreenshot() async {
    try {
      // final status = await printController.checkStatus();

      // if (!status['connection']) {
      //   Get.snackbar(
      //     'Failed',
      //     'Pastikan anda sudah terhubung dengan printer',
      //     backgroundColor: Colors.red[400],
      //     colorText: Colors.white,
      //     duration: const Duration(seconds: 3),
      //     snackPosition: SnackPosition.BOTTOM,
      //     margin: const EdgeInsets.all(16),
      //   );
      //   return;
      // }

      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.edit_document,
                        size: 28,
                        color: Colors.indigo,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Masukkan Data',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Nomor',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nomorController,
                    keyboardType: TextInputType.number,
                    maxLength: 15,
                    decoration: InputDecoration(
                      hintText: 'Masukkan nomor...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon:
                          const Icon(Icons.numbers, color: Colors.indigo),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.indigo, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.indigo, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Jumlah Transfer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '10000',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon:
                          const Icon(Icons.attach_money, color: Colors.indigo),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.indigo, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.indigo, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Get.back(closeOverlays: true),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            if (_nomorController.text.isEmpty ||
                                _amountController.text.isEmpty) {
                              log('data tidak boleh kosong');
                              return;
                            }
                            Get.to(
                              () => ScreenshotPage(
                                phoneNumber: _nomorController.text,
                                amount: _amountController.text,
                                freeOngkir: true,
                                timestamp:
                                    DateFormat("dd MMM yyyy, HH:mm", "id_ID")
                                        .format(DateTime.now()),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.indigo,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          label: const Text(
                            'SEND',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: true,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get printer status: $e',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        borderRadius: 8,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    }
  }

  void dialogShopping() async {
    try {
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.shopify,
                            size: 28,
                            color: Colors.indigo,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Shopify',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Column(
                        children: List.generate(products.length, (index) {
                          final product = products[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey[200],
                                    image: DecorationImage(
                                      image: AssetImage(product.image),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Rp ${product.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}', // Format harga
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle),
                                      color: Colors.grey,
                                      onPressed: () {
                                        setState(() {
                                          if (product.quantity > 0) {
                                            product.quantity--;
                                          }
                                        });
                                      },
                                    ),
                                    Text(
                                      product.quantity.toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle),
                                      color: Colors.indigo,
                                      onPressed: () {
                                        setState(() {
                                          product.quantity++;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Get.back(closeOverlays: true),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              child: const Text(
                                'Close',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                for (var product in products) {
                                  log(
                                      'Nama: ${product.name}, Harga: ${product.price}, Jumlah: ${product.quantity}');
                                }
                                Get.back(closeOverlays: true);
                              },
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.indigo,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              label: const Text(
                                'SEND',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              icon: const Icon(Icons.send, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        barrierDismissible: true,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to show dialog: $e',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        borderRadius: 8,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
