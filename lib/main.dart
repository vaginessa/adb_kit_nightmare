library adb_tool;

import 'dart:developer';
import 'dart:io';
import 'package:signale/signale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'app/routes/app_pages.dart';
import 'config/config.dart';
import 'global/instance/global.dart';

void main() {
  PlatformUtil.setPackageName('com.nightmare.adbtools');
  if (Platform.isAndroid) {
    RuntimeEnvir.initEnvirWithPackageName(Config.packageName);
  } else {
    RuntimeEnvir.initEnvirForDesktop();
  }
  Global.instance;

  runApp(
    NiToastNew(
      child: GetMaterialApp(
        title: 'ADB TOOL',
        initialRoute: AdbPages.INITIAL,
        getPages: AdbPages.routes,
        defaultTransition: Transition.fade,
      ),
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize without device test ids.
  if (Platform.isAndroid) {
    // MobileAds.instance.initialize();÷、
  }
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  enableUdpMulti();
}

Future<void> enableUdpMulti() async {
  if (Platform.isAndroid) {
    final MethodChannel methodChannel = const MethodChannel('multicast-lock');
    bool result = await methodChannel.invokeMethod<bool>('aquire');
    Log.d('result -> $result');
  }
}
