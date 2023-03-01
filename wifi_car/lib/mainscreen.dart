import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

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
  String status = "Stop";
  String os = "";
  bool auto = false;
  bool sumoauto = false;
  bool remember = false;
  String statusauto = "off";
  String statussumo = "off";
  late double screenHeight, screenWidth;

  @override
  void initState() {
    super.initState();
    getPermission();
    _getWifissid();
    setNetwork();
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
        setNetwork();
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
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: const Text('WiFiCar Controller'),
          actions: [
            IconButton(
                onPressed: () {
                  changeSSIDDialog();
                },
                icon: const Icon(Icons.settings)),
            IconButton(
                onPressed: () {
                  _getWifissid();
                  setNetwork();
                },
                icon: const Icon(Icons.refresh)),
            IconButton(
                onPressed: () {
                  aboutApp();
                },
                icon: const Icon(Icons.info))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Instructions:\n1. Please disable your mobile data.\n2. Connect to the robot car WiFi access point.\n\nCurrently connected to $ssid",
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ]),
                ),
              ),
              const Divider(
                height: 5,
                color: Colors.blueGrey,
              ),
              Text("Controller: $status",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      iconSize: 48,
                      onPressed: () {
                        commandCar("backwardleft");
                        setState(() {
                          status = "Forward Left";
                        });
                      },
                      icon: const Icon(Icons.arrow_left)),
                  IconButton(
                      iconSize: 48,
                      onPressed: () {
                        commandCar("forward");
                        setState(() {
                          status = "Forward";
                        });
                      },
                      icon: const Icon(Icons.arrow_upward)),
                  IconButton(
                      iconSize: 48,
                      onPressed: () {
                        commandCar("backwardright");
                        setState(() {
                          status = "Forward Right";
                        });
                      },
                      icon: const Icon(Icons.arrow_right)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      iconSize: 48,
                      onPressed: () {
                        commandCar("right");
                        setState(() {
                          status = "Right";
                        });
                      },
                      icon: const Icon(Icons.arrow_back)),
                  const SizedBox(
                    width: 24,
                  ),
                  IconButton(
                      iconSize: 48,
                      onPressed: () {
                        commandCar("stop");
                        setState(() {
                          status = "Stop";
                        });
                      },
                      icon: const Icon(Icons.stop)),
                  const SizedBox(width: 22),
                  IconButton(
                      iconSize: 48,
                      onPressed: () {
                        commandCar("left");
                        setState(() {
                          status = "Left";
                        });
                      },
                      icon: const Icon(Icons.arrow_forward))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 22,
                  ),
                  IconButton(
                      iconSize: 48,
                      onPressed: () {
                        commandCar("backwardright");
                        setState(() {
                          status = "Backward Right";
                        });
                      },
                      icon: const Icon(Icons.arrow_left)),
                  IconButton(
                      iconSize: 48,
                      onPressed: () {
                        commandCar("backward");
                        setState(() {
                          status = "Backward";
                        });
                      },
                      icon: const Icon(Icons.arrow_downward)),
                  IconButton(
                      iconSize: 48,
                      onPressed: () {
                        commandCar("backwardleft");
                        setState(() {
                          status = "Backward Left";
                        });
                      },
                      icon: const Icon(Icons.arrow_right)),
                  const SizedBox(width: 20),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(
                height: 5,
                color: Colors.blueGrey,
              ),
              Text("Auto Mode: $statusauto",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                  ),
                  IconButton(
                      iconSize: 48,
                      onPressed: () {
                          if (statussumo == "on") {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("One mode at a time")));
                          return;
                        }
                        setState(() {
                          statusauto = "on";
                        });
                        commandCar("autoon");
                      },
                      icon: const Icon(Icons.run_circle)),
                  const SizedBox(width: 20),
                  IconButton(
                      iconSize: 48,
                      onPressed: () {
                        setState(() {
                          statusauto = "off";
                        });
                        commandCar("autooff");
                      },
                      icon: const Icon(Icons.stop_circle_outlined)),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(
                height: 5,
                color: Colors.blueGrey,
              ),
              Text("Sumo Mode: $statussumo",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                  ),
                  IconButton(
                      iconSize: 48,
                      onPressed: () {
                        if (statusauto == "on") {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("One mode at a time")));
                          return;
                        }
                        setState(() {
                          statussumo = "on";
                        });
                        commandCar("sumoon");
                      },
                      icon: const Icon(Icons.run_circle)),
                  const SizedBox(width: 20),
                  IconButton(
                      iconSize: 48,
                      onPressed: () {
                        setState(() {
                          statussumo = "off";
                        });
                        commandCar("sumooff");
                      },
                      icon: const Icon(Icons.stop_circle_outlined)),
                ],
              ),
            ],
          ),
        ));
  }

  void changeSSID(newssid, newpass) {
    http
        .get(
      Uri.parse("http://192.168.4.1/settings?ssid=$newssid&password=$newpass"),
    )
        .then((response) {
      if (response.body == "SUCCESS") {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("New SSID Updated")));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Failed")));
      }
    });
  }

  void commandCar(String s) {
    http
        .get(
          Uri.parse("http://192.168.4.1/$s"),
        )
        .then((response) {});
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Currently connected to $ssid")));
    });
  }

  Future<void> getPermission() async {
    bool isGranted = await requestWifiInfoPermisson();
    if (isGranted) {
      wifiName = await info.getWifiName(); // FooNetwork
      //String? wifiBSSID = await info.getWifiBSSID(); // 11:22:33:44:55:66
    }
    if (await Permission.location.isGranted) {
      wifiName = await info.getWifiName();
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

  Future<void> setNetwork() async {
    final info = NetworkInfo();
    var locationStatus = await Permission.location.status;
    if (locationStatus.isDenied) {
      await Permission.locationWhenInUse.request();
    }
    if (await Permission.location.isRestricted) {
      openAppSettings();
    }

    if (await Permission.location.isGranted) {
      var wifiName = await info.getWifiName();
      print('wifiName $wifiName');
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
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          title: const Text(
            "Change robot SSID?",
            style: TextStyle(),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: ssidctrl,
                decoration: const InputDecoration(
                  labelText: 'New SSID',
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: passctrl,
                // obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
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
            "This will reset your WiFi Car ssid. Make sure you are connnected to one. Are you sure?",
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
                commandCar("17");
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

  void aboutApp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          title: const Text(
            "About APP",
            style: TextStyle(),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/hanis2.jpg',
                scale: 4,
              ),
              const Text(
                "This application was developed by Ahmad Hanis from the School of Computing UUM. He can be contacted via email at ahmadhanis@uum.edu.my.",
                textAlign: TextAlign.justify,
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Close",
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
