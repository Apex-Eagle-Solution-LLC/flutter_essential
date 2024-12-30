import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'model.dart';

class FlutterEssential {
  static const MethodChannel _methodChannel =
      MethodChannel('flutter_essential');
  static final StreamController<bool> _vpnStatusController =
      StreamController<bool>.broadcast();
  static final StreamController<bool> _internetStatusController =
      StreamController<bool>.broadcast();

  //** State management for VPN status */
  static Stream<bool> get vpnStatusStream => _vpnStatusController.stream;
  static Timer? _vpnStatusTimer;

  //** State management for Internet status */
  static Stream<bool> get internetStatusStream =>
      _internetStatusController.stream;
  static Timer? _internetStatusTimer;

  //* Start VPN status updates */
  static void startVpnStatusUpdates() {
    _vpnStatusTimer ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) async {
        final status = await isVpnConnected();
        _vpnStatusController.add(status);
      },
    );
  }

  //* Stop VPN status updates */
  static void stopVpnStatusUpdates() {
    _vpnStatusTimer?.cancel();
    _vpnStatusTimer = null;
  }

  //* Start Internet status updates */
  static void startInternetStatusUpdates() {
    _internetStatusTimer ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) async {
        final status = await isInternetConnected();
        _internetStatusController.add(status);
      },
    );
  }

  //* Stop Internet status updates */
  static void stopInternetStatusUpdates() {
    _internetStatusTimer?.cancel();
    _internetStatusTimer = null;
  }

  //* Check if VPN is connected */
  static Future<bool> isVpnConnected() async {
    try {
      final bool result = await _methodChannel.invokeMethod('isVpnConnected');
      return result;
    } catch (e) {
      debugPrint('Error checking VPN status: $e');
      return false;
    }
  }

  //* Check if Internet is connected */
  static Future<bool> isInternetConnected() async {
    try {
      final bool result =
          await _methodChannel.invokeMethod('isInternetConnected');
      return result;
    } catch (e) {
      debugPrint('Error checking Internet status: $e');
      return false;
    }
  }

  //* Get package information */
  static Future<PackageInfo?> getPackageInfo() async {
    try {
      final result =
          await _methodChannel.invokeMethod<String>('getPackageInfo');
      if (result != null) {
        final Map<String, dynamic> parsedResult = jsonDecode(result);
        return PackageInfo.fromMap(parsedResult);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching package info: $e');
      return null;
    }
  }

  //* Get Device id */
  static Future<String?> getDeviceId() async {
    try {
      final String? result = await _methodChannel.invokeMethod('getAndroidId');
      return result;
    } catch (e) {
      debugPrint('Error fetching device id: $e');
      return null;
    }
  }
}