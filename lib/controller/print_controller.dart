import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class PrintController extends GetxController {
  RxList<BluetoothInfo> devices = <BluetoothInfo>[].obs;
  RxString? selectedDevice = ''.obs;
  RxBool isSearching = false.obs;


  Color getBatteryColor(int level) {
    if (level >= 60) return Colors.green;
    if (level >= 30) return Colors.orange;
    return Colors.red;
  }

  Future<Map<String, dynamic>> checkStatus() async {
    int battery = await PrintBluetoothThermal.batteryLevel;
    bool bluetooth = await PrintBluetoothThermal.bluetoothEnabled;
    bool connection = await PrintBluetoothThermal.connectionStatus;

    return {
      "battery": battery,
      "bluetooth": bluetooth,
      "connection": connection,
    };
  }

  Future<void> searchDevices() async {
    try {
      log('message');
      // Set status searching
      isSearching.value = true;
      selectedDevice?.value = '';

      // Clear list devices sebelumnya
      devices.clear();

      // Cek permission bluetooth
      bool permission = await PrintBluetoothThermal.bluetoothEnabled;
      if (!permission) {
        Get.snackbar(
          'Bluetooth Error',
          'Please enable bluetooth to search devices',
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      // Cari perangkat bluetooth
      List<BluetoothInfo> foundDevices =
          await PrintBluetoothThermal.pairedBluetooths;

      // Update list devices
      devices.addAll(foundDevices);

      if (devices.isEmpty) {
        Get.snackbar(
          'No Devices Found',
          'Please pair your printer in bluetooth settings first',
          backgroundColor: Colors.orange[400],
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to search devices: $e',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isSearching.value = false;
    }
  }

  // Fungsi untuk menghubungkan ke printer
  Future<void> connectToDevice() async {
    log(selectedDevice!.value);
    if (selectedDevice?.value == null || selectedDevice?.value == '') {
      Get.snackbar(
        'Error',
        'Please select a device first',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (selectedDevice?.value == null || selectedDevice?.value == '') {
      Get.snackbar(
        'Error',
        'Please select a device first',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    try {
      await PrintBluetoothThermal.connect(
          macPrinterAddress: selectedDevice!.value);
      Get.snackbar(
        'Success',
        'Connected to printer',
        backgroundColor: Colors.green[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
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
}
