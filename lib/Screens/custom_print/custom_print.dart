import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/print_purchase_provider.dart';
import 'package:mobile_pos/Widget/primary_button_widget.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

///  PROJECT_NAME:-  pos-saas-app-codecanyon-master
///  Project Created by AGM Khair Sabbir
///  DATE:- 12/4/24
class CustomPrint extends StatefulWidget {
  const CustomPrint({super.key});

  @override
  State<CustomPrint> createState() => _CustomPrintState();
}

class _CustomPrintState extends State<CustomPrint> {
  // final GlobalKey<FlutterSummernoteState> _keyEditor = GlobalKey();
  // String result = '';

  List availableBluetoothDevices = [];
  bool is58mm = true;
  final TextEditingController _controller = TextEditingController();

  Future<void> getBluetooth() async {
    final List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
    availableBluetoothDevices = bluetooths!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          "Custom Print",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: kMainColor,
      ),
      backgroundColor: Colors.white,
      body: Consumer(builder: (context, ref, __) {
        final printerData = ref.watch(printerPurchaseProviderNotifier);
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 2.5,
                  margin: EdgeInsets.only(bottom: 20),
                  child: SizedBox(
                    height: 200,
                    child: TextField(
                      minLines: 6,
                      // Set this
                      maxLines: 8,
                      keyboardType: TextInputType.multiline,
                      controller: _controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Your text here...',
                        hintText: 'Your text here...',
                      ),
                    ),
                  ),

                  /*FlutterSummernote(
                    key: _keyEditor,
                    hint: 'Your text here...',
                    hasAttachment: true,
                    showBottomToolbar: false,
                    customToolbar: """
                    [
                      ['style', ['bold', 'italic', 'underline', 'clear']],
                      ['font', ['strikethrough', 'superscript', 'subscript']],
                      ['insert', ['link', 'table', 'hr']]
                    ]
                              """,
                  ),*/
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                            label: "58 mm",
                            isDisabled: false,
                            selected: is58mm,
                            onPressed: () {
                              setState(() => is58mm = true);
                            }),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: PrimaryButton(
                            label: "80 mm",
                            isDisabled: false,
                            selected: !is58mm,
                            onPressed: () {
                              setState(() => is58mm = false);
                            }),
                      ),
                    ],
                  ),
                ),
                PrimaryButton(
                  label: "Print",
                  onPressed: () async {
                    if (_controller.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Please write something and try again"),
                      ));
                      return;
                    } else {
                      await printerData.getBluetooth();
                      if (connected) {
                        String? isConnected = await BluetoothThermalPrinter.connectionStatus;
                        if (isConnected == "true") {
                          final profile = await CapabilityProfile.load();
                          final generator = Generator(is58mm ? PaperSize.mm58 : PaperSize.mm80, profile);
                          List<int> bytes = [];

                          bytes += generator.text(_controller.text ?? '', styles: const PosStyles(align: PosAlign.left, height: PosTextSize.size1, width: PosTextSize.size2));
                          bytes += generator.cut();

                          await BluetoothThermalPrinter.writeBytes(bytes);
                        }
                      } else {
                        showDialog(
                            context: context,
                            builder: (_) {
                              return WillPopScope(
                                onWillPop: () async => false,
                                child: Dialog(
                                  child: SizedBox(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: printerData.availableBluetoothDevices.isNotEmpty ? printerData.availableBluetoothDevices.length : 0,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              onTap: () async {
                                                String select = printerData.availableBluetoothDevices[index];
                                                List list = select.split("#");
                                                // String name = list[0];
                                                String mac = list[1];
                                                bool isConnect = await printerData.setConnect(mac);
                                                isConnect
                                                    // ignore: use_build_context_synchronously
                                                    ? finish(context)
                                                    : toast('Try Again');
                                              },
                                              title: Text('${printerData.availableBluetoothDevices[index]}'),
                                              subtitle: Text(lang.S.of(context).clickToConnect),
                                            );
                                          },
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 20, bottom: 10),
                                          child: Text(
                                            lang.S.of(context).pleaseConnectYourBluttothPrinter,
                                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Container(height: 1, width: double.infinity, color: Colors.grey),
                                        const SizedBox(height: 15),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Center(
                                            child: Text(
                                              lang.S.of(context).cacel,
                                              style: const TextStyle(color: kMainColor),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                      }
                    }
                  },
                  isDisabled: false,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
