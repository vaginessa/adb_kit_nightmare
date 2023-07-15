import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:responsive_framework/utils/responsive_utils.dart';
import 'package:screenshot/screenshot.dart';
import 'package:settings/settings.dart';
import 'package:app_manager/app_manager.dart' as am;
import 'package:window_manager/window_manager.dart';
import 'app/controller/controller.dart';
import 'app/routes/app_pages.dart';
import 'config/config.dart';
import 'config/settings.dart';
import 'generated/l10n.dart';
import 'global/instance/global.dart';

Future<void> initSetting() async {
  await initSettingStore(RuntimeEnvir.configPath);
  if (Settings.serverPath.setting.get() == null) {
    Settings.serverPath.setting.set(Config.adbLocalPath);
  }
}

class MaterialAppWrapper extends StatefulWidget {
  const MaterialAppWrapper({
    Key? key,
    this.isNativeShell = false,
  }) : super(key: key);
  final bool isNativeShell;

  @override
  State createState() => _MaterialAppWrapperState();
}

class _MaterialAppWrapperState extends State<MaterialAppWrapper> with WidgetsBindingObserver {
  ConfigController config = Get.put(ConfigController());
  bool isFull = false;

  @override
  void initState() {
    super.initState();
    _lastSize = WidgetsBinding.instance.window.physicalSize;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Size? _lastSize;

  @override
  void didChangeMetrics() {
    _lastSize = WidgetsBinding.instance.window.physicalSize;
    setState(() {});
  }

  ScreenshotController screenshotController = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return ToastApp(
      child: Stack(
        children: [
          background(),
          app(),
        ],
      ),
    );
  }

  BackdropFilter app() {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 24.0,
        sigmaY: 24.0,
      ),
      child: GetBuilder<ConfigController>(
        builder: (config) {
          return Screenshot(
            controller: screenshotController,
            child: RawKeyboardListener(
              autofocus: true,
              focusNode: FocusNode(),
              onKey: ((value) {
                // Log.w(value);
                // if (value is RawKeyDownEvent) {
                //   screenshotController.captureAndSave('./screenshot');
                // }
              }),
              child: GetMaterialApp(
                showPerformanceOverlay: config.showPerformanceOverlay,
                showSemanticsDebugger: config.showSemanticsDebugger,
                debugShowMaterialGrid: config.debugShowMaterialGrid,
                checkerboardRasterCacheImages: config.checkerboardRasterCacheImages,
                debugShowCheckedModeBanner: false,
                title: 'ADB工具箱',
                navigatorKey: Global.instance!.navigatorKey,
                themeMode: ThemeMode.light,
                localizationsDelegates: const [
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                locale: window.locale,
                supportedLocales: S.delegate.supportedLocales,
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                ),
                defaultTransition: Transition.fadeIn,
                initialRoute: AdbPages.initial,
                getPages: AdbPages.routes + am.AppPages.routes,
                useInheritedMediaQuery: true,
                builder: (BuildContext context, Widget? navigator) {
                  return ResponsiveBreakpoints.builder(
                    child: Builder(
                      builder: (context) {
                        print(ResponsiveBreakpoints.of(context).breakpoint);
                        print(ResponsiveBreakpoints.of(context).screenHeight);
                        print(ResponsiveBreakpoints.of(context).screenWidth);
                        print(ResponsiveBreakpoints.of(context).isDesktop);
                        print(ResponsiveBreakpoints.of(context).isTablet);
                        print(ResponsiveBreakpoints.of(context).isMobile);
                        if (ResponsiveBreakpoints.of(context).isDesktop || ResponsiveBreakpoints.of(context).isTablet) {
                          ScreenAdapter.init(896);
                        } else {
                          ScreenAdapter.init(414);
                        }
                        return Theme(
                          data: config.theme!,
                          child: navigator ?? const SizedBox(),
                        );
                      },
                    ),
                    // landscapePlatforms: [
                    //   ResponsiveTargetPlatform.macOS,
                    // ],
                    breakpoints: const [
                      Breakpoint(start: 0, end: 400, name: MOBILE),
                      Breakpoint(start: 400, end: 800, name: TABLET),
                      Breakpoint(start: 800, end: 2000, name: DESKTOP),
                    ],
                    breakpointsLandscape: [
                      const Breakpoint(start: 0, end: 450, name: MOBILE),
                      const Breakpoint(start: 451, end: 800, name: TABLET),
                      const Breakpoint(start: 801, end: double.infinity, name: DESKTOP),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  GetBuilder<ConfigController> background() {
    return GetBuilder<ConfigController>(builder: (config) {
      if (config.backgroundStyle == BackgroundStyle.normal) {
        return Container(
          color: config.theme!.colorScheme.background,
        );
      }
      if (config.backgroundStyle == BackgroundStyle.image) {
        return SizedBox(
          height: double.infinity,
          child: Image.asset(
            'assets/b.png',
            fit: BoxFit.cover,
          ),
        );
      } else {
        return const SizedBox();
      }
    });
  }
}
