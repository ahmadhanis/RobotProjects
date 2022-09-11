import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_settings/open_settings.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final info = NetworkInfo();
  var wifiName;
  String ssid = "...";
  String pass = "";
  var status;
  String os = "";
  bool remember = false;

  @override
  void initState() {
    super.initState();
    getPermission();
    _getWifissid();
    WidgetsBinding.instance.addObserver(this);
    //loadPref();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // These are the callbacks
    switch (state) {
      case AppLifecycleState.resumed:
        getPermission();
        _getWifissid();
        // widget is resumed
        break;
      case AppLifecycleState.inactive:
        // widget is inactive
        break;
      case AppLifecycleState.paused:
        // widget is paused
        break;
      case AppLifecycleState.detached:
        // widget is detached
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Kame Controller'),
          actions: [
            IconButton(
                onPressed: () {
                  changeSSIDDialog();
                },
                icon: const Icon(Icons.settings))
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 110,
                      height: 50,
                      child: ElevatedButton(
                        child: const Text("FORWARD"),
                        onPressed: () {
                          commandKame("1");
                        },
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 100,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("LEFT"),
                          onPressed: () {
                            commandKame("3");
                          },
                        )),
                    const SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                        width: 100,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("HOME"),
                          onPressed: () {
                            commandKame("5");
                          },
                        )),
                    const SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                        width: 100,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("RIGHT"),
                          onPressed: () {
                            commandKame("4");
                          },
                        ))
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 110,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("ZERO"),
                          onPressed: () {
                            commandKame("0");
                          },
                        )),
                    const SizedBox(width: 20),
                    SizedBox(
                        width: 110,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("INIT"),
                          onPressed: () {
                            commandKame("15");
                          },
                        ))
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(
                  height: 1,
                  color: Colors.black,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        width: 100,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("PUSHUP"),
                          onPressed: () {
                            commandKame("6");
                          },
                        )),
                    SizedBox(
                        width: 100,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("UPDOWN"),
                          onPressed: () {
                            commandKame("7");
                          },
                        )),
                    SizedBox(
                        width: 100,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("JUMP"),
                          onPressed: () {
                            commandKame("8");
                          },
                        ))
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        width: 100,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("HELLO"),
                          onPressed: () {
                            commandKame("9");
                          },
                        )),
                    SizedBox(
                        width: 100,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("PUNCH"),
                          onPressed: () {
                            commandKame("10");
                          },
                        )),
                    SizedBox(
                        width: 100,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("DANCE"),
                          onPressed: () {
                            commandKame("11");
                          },
                        ))
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        width: 100,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("MOON"),
                          onPressed: () {
                            commandKame("12");
                          },
                        )),
                    SizedBox(
                        width: 100,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("RUN"),
                          onPressed: () {
                            commandKame("13");
                          },
                        )),
                    SizedBox(
                        width: 100,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("OMNI"),
                          onPressed: () {
                            commandKame("14");
                          },
                        )),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(
                  height: 1,
                  color: Colors.black,
                ),
                const SizedBox(height: 20),
                Text(
                  "Please connect to the quad access point.\nCurrently connected to $ssid",
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      child: const Text("CHECK"),
                      onPressed: () {
                        getPermission();
                        _getWifissid();
                      },
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      child: const Text("WIFI"),
                      onPressed: () {
                        OpenSettings.openWIFISetting();
                      },
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      child: const Text("RESET"),
                      onPressed: () {
                        resetDialog();
                      },
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      child: const Text("CHANGE"),
                      onPressed: () {
                        changeSSIDDialog();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ));
  }

  void changeSSID(newssid, newpass) {
    http
        .get(
      Uri.parse("http://192.168.4.1/16?ssid=$newssid&password=$newpass"),
    )
        .then((response) {
      Fluttertoast.showToast(
          msg: response.body,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    });
  }

  void commandKame(String s) {
    // if (ssid != '"kame"') {
    //   print(ssid);
    //   Fluttertoast.showToast(
    //       msg: "Please connect to KAME access point",
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.BOTTOM,
    //       timeInSecForIosWeb: 1,
    //       fontSize: 16.0);

    //   Timer(const Duration(seconds: 1), () => OpenSettings.openWIFISetting());
    //   return;
    // }
    http
        .get(
      Uri.parse("http://192.168.4.1/$s"),
    )
        //   .timeout(
        // const Duration(seconds: 5),
        // onTimeout: () {
        //   Fluttertoast.showToast(
        //       msg: "Timeout",
        //       toastLength: Toast.LENGTH_SHORT,
        //       gravity: ToastGravity.BOTTOM,
        //       timeInSecForIosWeb: 1,
        //       fontSize: 16.0);
        //   return http.Response(
        //       'Error', 508); // Request Timeout response status code
        // },)
        .then((response) {
      Fluttertoast.showToast(
          msg: response.body,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    });
  }

  Future<void> _getWifissid() async {
    wifiName = await info.getWifiName();
    //wifiName = _networkInfo.getWifiName();
    setState(() {
      if (wifiName == null) {
        ssid = "No SSID";
      } else {
        ssid = wifiName.toString().replaceAll('"', '');
      }
    });
  }

  Future<void> getPermission() async {
    bool isGranted = await requestWifiInfoPermisson();
    if (isGranted) {
      wifiName = await info.getWifiName(); // FooNetwork
      //String? wifiBSSID = await info.getWifiBSSID(); // 11:22:33:44:55:66
    }
  }

  Future<bool> requestWifiInfoPermisson() async {
    // ignore: avoid_print
    print('Checking Android permissions');
    PermissionStatus status = await Permission.location.status;
    // Blocked?
    if (status.isDenied || status.isRestricted) {
      // Ask the user to unblock
      if (await Permission.location.request().isGranted) {
        // Either the permission was already granted before or the user just granted it.
        // ignore: avoid_print
        print('Location permission granted');
        return true;
      } else {
        // ignore: avoid_print
        print('Location permission not granted');
        return false;
      }
    } else {
      // ignore: avoid_print
      print('Permission already granted (previous execution?)');
      return true;
    }
  }

  // Future<void> loadPref() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   ssid = (prefs.getString('ssid')) ?? '';
  //   pass = (prefs.getString('pass')) ?? '';
  //   //remember = (prefs.getBool('remember')) ?? false;
  //   if (remember) {
  //     setState(() {
  //       remember = true;
  //     });
  //   }
  // }

  void changeSSIDDialog() {
    TextEditingController ssidctrl = TextEditingController();
    TextEditingController passctrl = TextEditingController();
    ssidctrl.text = ssid.replaceAll('"', '');
    if (ssidctrl.text == "") {
      Fluttertoast.showToast(
          msg: "Please enter new ssid",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Change robot SSID?",
            style: TextStyle(),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: ssidctrl,
                decoration: InputDecoration(
                    labelText: 'New SSID',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: passctrl,
                // obscureText: true,
                decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                changeSSID(ssidctrl.text, passctrl.text);
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void resetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "This will reset your KAME ssid. Make sure you are connnected to one. Are you sure?",
            style: TextStyle(),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Reset",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                commandKame("17");
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // void _saveRemovePref(bool value, ssid, pass) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   if (value) {
  //     await prefs.setString('ssid', ssid);
  //     await prefs.setString('pass', pass);
  //     Fluttertoast.showToast(
  //         msg: "Preference Stored",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //         timeInSecForIosWeb: 1,
  //         fontSize: 14.0);
  //   } else {
  //     await prefs.setString('ssid', '');
  //     await prefs.setString('pass', '');

  //     Fluttertoast.showToast(
  //         msg: "Preference Removed",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //         timeInSecForIosWeb: 1,
  //         fontSize: 14.0);
  //   }
  // }
}
