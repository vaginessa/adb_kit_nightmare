import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/global/pages/terminal.dart';
import 'package:adb_tool/global/widget/item_header.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';

class RemoteDebugPage extends StatefulWidget {
  @override
  _RemoteDebugPageState createState() => _RemoteDebugPageState();
}

class _RemoteDebugPageState extends State<RemoteDebugPage> {
  bool adbDebugOpen = false;
  List<String> address = [];
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final String ipRoute = await YanProcess().exec(
      'ip route',
    );
    for (String ip in ipRoute.split('\n')) {
      ip = ip.trim().replaceAll(RegExp('.* '), '');
      print(ip);
      address.add(ip);
    }
    print('address->$address');
    setState(() {});
    final String result =
        await YanProcess().exec('getprop service.adb.tcp.port');
    if (result == '5555') {
      adbDebugOpen = true;
      setState(() {});
    }
  }

  Future<void> changeState() async {
    adbDebugOpen = !adbDebugOpen;
    setState(() {});
    final int value = adbDebugOpen ? 5555 : -1;

    final StringBuffer buffer = StringBuffer();
    buffer.writeln('su -c "');
    buffer.writeln(
      'setprop service.adb.tcp.port $value',
    );
    buffer.writeln(
      'stop adbd',
    );
    buffer.writeln('start adbd"\n');
    Global.instance.pseudoTerminal.write(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        title: const Text('网络ADB调试'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        // elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '打开网络ADB调试',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: adbDebugOpen,
                    onChanged: (_) async {
                      changeState();
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  const ItemHeader(color: CandyColors.candyPurpleAccent),
                  Text(
                    '本机IP',
                    style: TextStyle(
                      fontSize: Dimens.font_sp20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.fontTitle,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(
                    text: address.join('\n'),
                  ));
                  showToast('IP已复制');
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      address.join('\n'),
                      style: TextStyle(
                        fontSize: Dimens.font_sp16,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const ItemHeader(color: CandyColors.candyBlue),
                  Text(
                    '连接方法',
                    style: TextStyle(
                      fontSize: Dimens.font_sp20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  '1.设备与PC处于于一个局域网',
                  style: TextStyle(
                    fontSize: Dimens.font_sp14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: Dimens.gap_dp4),
                child: Text(
                  '2.打开PC的终端模拟器，执行连接',
                  style: TextStyle(
                    fontSize: Dimens.font_sp14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.gap_dp8,
                  vertical: Dimens.gap_dp8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.contentBorder,
                  borderRadius: BorderRadius.circular(Dimens.gap_dp8),
                ),
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'adb connect \$IP',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: '    \$IP代表的是本机IP',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: Dimens.gap_dp4),
                child: Text(
                  '3.执行adb devices查看设备列表是有新增',
                  style: TextStyle(
                    fontSize: Dimens.font_sp14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.contentBorder,
                  borderRadius: BorderRadius.circular(Dimens.gap_dp8),
                ),
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'adb devices',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: Dimens.gap_dp8,
              ),
              Row(
                children: const [
                  ItemHeader(color: CandyColors.candyPink),
                  Text(
                    '终端',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: Dimens.gap_dp8,
              ),
              const SizedBox(
                height: 200,
                child: TerminalPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
