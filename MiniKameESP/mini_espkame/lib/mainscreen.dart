import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:mini_espkame/trimscreen.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_settings/open_settings.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

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
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  final NetworkInfo _networkInfo = NetworkInfo();
  @override
  void initState() {
    super.initState();
    getPermission();
    _getWifissid();
    WidgetsBinding.instance.addObserver(this);
    _initSpeech();
    //loadPref();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
    // if (_speechToText.isAvailable) {
    //   print("YES AVAILABLE");
    // } else {
    //   print("SORRY NOT AVAILABLE");
    // }
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      if (result.finalResult) {
        voiceKame(_lastWords);
      }
    });
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
                  Fluttertoast.showToast(
                      msg: 'Connecting...',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      fontSize: 16.0);
                  http
                      .get(
                    Uri.parse("http://192.168.4.1/15"),
                  )
                      .then((response) {
                    if (response.statusCode == 200) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (content) => const TrimScreen()));
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Failed. Please connect to your Kame first',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          fontSize: 16.0);
                    }
                  }).timeout(const Duration(seconds: 5), onTimeout: () {
                    Fluttertoast.showToast(
                        msg: 'Timeout. Please connect to your Kame first',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        fontSize: 16.0);
                  });
                },
                icon: const Icon(Icons.settings)),
            IconButton(
                onPressed: () {
                  aboutApp();
                },
                icon: const Icon(Icons.info)),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Please connect to Kame access point.\nCurrently connected to:",
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.justify,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    ssid,
                    style: const TextStyle(fontSize: 24.0),
                  ),
                ),
                const SizedBox(height: 5),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        child: const Text(
                          "CHECK",
                          style: TextStyle(fontSize: 12),
                        ),
                        onPressed: () {
                          getPermission();
                          _getWifissid();
                        },
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        child: const Text(
                          "WIFI",
                          style: TextStyle(fontSize: 12),
                        ),
                        onPressed: () {
                          OpenSettings.openWIFISetting();
                        },
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        child: const Text(
                          "RESET",
                          style: TextStyle(fontSize: 12),
                        ),
                        onPressed: () {
                          resetDialog();
                        },
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        child: const Text(
                          "CHANGE",
                          style: TextStyle(fontSize: 12),
                        ),
                        onPressed: () {
                          changeSSIDDialog();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(
                  height: 1,
                  color: Colors.black,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RawMaterialButton(
                      onPressed: () {
                        commandKame("1");
                      },
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      padding: const EdgeInsets.all(15.0),
                      fillColor: Colors.white,
                      elevation: 2.0,
                      child: const Icon(Icons.arrow_upward, size: 35),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RawMaterialButton(
                      onPressed: () {
                        commandKame("3");
                      },
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      padding: const EdgeInsets.all(15.0),
                      fillColor: Colors.white,
                      elevation: 2.0,
                      child: const Icon(Icons.arrow_back, size: 35),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    RawMaterialButton(
                      onPressed: () {
                        commandKame("5");
                      },
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      padding: const EdgeInsets.all(15.0),
                      fillColor: Colors.white,
                      elevation: 2.0,
                      child: const Icon(Icons.home, size: 35),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    RawMaterialButton(
                      onPressed: () {
                        commandKame("4");
                      },
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      padding: const EdgeInsets.all(15.0),
                      fillColor: Colors.white,
                      elevation: 2.0,
                      child: const Icon(Icons.arrow_forward, size: 35),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RawMaterialButton(
                      onPressed: () {
                        commandKame("16");
                      },
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      padding: const EdgeInsets.all(15.0),
                      fillColor: Colors.white,
                      elevation: 2.0,
                      child: const Icon(Icons.arrow_downward, size: 35),
                    ),
                    // SizedBox(
                    //     width: 110,
                    //     height: 50,
                    //     child: ElevatedButton(
                    //       child: const Text("ZERO"),
                    //       onPressed: () {
                    //         commandKame("0");
                    //       },
                    //     )),
                    const SizedBox(width: 20),
                    RawMaterialButton(
                      onPressed: () {
                        commandKame("15");
                      },
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      padding: const EdgeInsets.all(15.0),
                      fillColor: Colors.white,
                      elevation: 2.0,
                      child: const Icon(Icons.start, size: 35),
                    ),
                    // SizedBox(
                    //     width: 110,
                    //     height: 50,
                    //     child: ElevatedButton(
                    //       child: const Text("INIT"),
                    //       onPressed: () {
                    //         commandKame("15");
                    //       },
                    //     ))
                  ],
                ),
                const SizedBox(height: 5),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        width: 100,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text(
                            "PUSHUP",
                            style: TextStyle(fontSize: 12),
                          ),
                          onPressed: () {
                            commandKame("6");
                          },
                        )),
                    SizedBox(
                        width: 100,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text(
                            "UPDOWN",
                            style: TextStyle(fontSize: 12),
                          ),
                          onPressed: () {
                            commandKame("7");
                          },
                        )),
                    SizedBox(
                        width: 100,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text(
                            "JUMP",
                            style: TextStyle(fontSize: 12),
                          ),
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
                          child: const Text(
                            "HELLO",
                            style: TextStyle(fontSize: 12),
                          ),
                          onPressed: () {
                            commandKame("9");
                          },
                        )),
                    SizedBox(
                        width: 100,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text(
                            "PUNCH",
                            style: TextStyle(fontSize: 12),
                          ),
                          onPressed: () {
                            commandKame("10");
                          },
                        )),
                    SizedBox(
                        width: 100,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text(
                            "DANCE",
                            style: TextStyle(fontSize: 12),
                          ),
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
                          child: const Text(
                            "MOON",
                            style: TextStyle(fontSize: 12),
                          ),
                          onPressed: () {
                            commandKame("12");
                          },
                        )),
                    SizedBox(
                        width: 100,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text(
                            "RUN",
                            style: TextStyle(fontSize: 12),
                          ),
                          onPressed: () {
                            commandKame("13");
                          },
                        )),
                    SizedBox(
                        width: 100,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text(
                            "OMNI",
                            style: TextStyle(fontSize: 12),
                          ),
                          onPressed: () {
                            commandKame("14");
                          },
                        )),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(
                  height: 1,
                  color: Colors.black,
                ),
                const SizedBox(height: 5),
                const Text("VOICE COMMAND",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _speechToText.isListening
                        ? _lastWords
                        : _speechEnabled
                            ? 'Tap the microphone to start listening...'
                            : 'Speech not available',
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    _startListening();

                    // _speechToText.isNotListening
                    //     ? _stopListening
                    //     : _startListening;
                  },
                  icon: Icon(
                      _speechToText.isNotListening ? Icons.mic_off : Icons.mic),
                ),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text("Command: $_lastWords",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
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

  void voiceKame(String command) {
    switch (command.toLowerCase()) {
      case "0":
        commandKame("0");
        break;
      case "forward":
        commandKame("1");
        break;
      case "down":
        commandKame("2");
        break;
      case "left":
        commandKame("3");
        break;
      case "right":
        commandKame("4");
        break;
      case "home":
        commandKame("5");
        break;
      case "push-up":
        commandKame("6");
        break;
      case "up down":
        commandKame("7");
        break;
      case "jump":
        commandKame("8");
        break;
      case "hello":
        commandKame("9");
        break;
      case "punch":
        commandKame("10");
        break;
      case "dance":
        commandKame("11");
        break;
      case "moonwalk":
        commandKame("12");
        break;
      case "run":
        commandKame("13");
        break;
      case "omni":
        commandKame("14");
        break;
      case "initialise":
        commandKame("15");
        break;
      default:
        Fluttertoast.showToast(
            msg: "Command not available",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        break;
    }
  }

  void commandKame(String s) {
    if (ssid == "Not available") {
      Fluttertoast.showToast(
          msg: 'Please connect to Kame AP',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    http
        .get(
      Uri.parse("http://192.168.4.1/$s"),
    )
        .then((response) {
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: response.body,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    }).timeout(const Duration(seconds: 20), onTimeout: () {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg:
            'Request timed out. Please try again. Check your connection to Kame AP.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
      );
    });
  }

  Future<void> _getWifissid() async {
    wifiName = await info.getWifiName();
    //wifiName = _networkInfo.getWifiName();
    setState(() {
      if (wifiName == null) {
        ssid = "Not available";
      } else {
        ssid = wifiName.toString().replaceAll('"', '');
      }
    });
    // ignore: deprecated_member_use
    //var status = await _networkInfo.getLocationServiceAuthorization();
    // if (status == LocationAuthorizationStatus.notDetermined) {
    //   // ignore: deprecated_member_use
    //   status = await _networkInfo.requestLocationServiceAuthorization();
    // }
    // if (status == LocationAuthorizationStatus.authorizedAlways ||
    //     status == LocationAuthorizationStatus.authorizedWhenInUse) {
    //   wifiName = await _networkInfo.getWifiName();
    // } else {
    //   wifiName = await _networkInfo.getWifiName();
    // }
    // setState(() {
    //   wifiName = wifiName;
    // });
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

  void changeSSIDDialog() {
    TextEditingController ssidctrl = TextEditingController();
    TextEditingController passctrl = TextEditingController();
    ssidctrl.text = ssid;
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
            "Change KAME SSID?. Make sure you are connected to Kame AP.",
            style: TextStyle(fontSize: 16),
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
            "This will reset your KAME ssid to 'NewKame'.All the trims settings will be reset. Make sure you are connnected to Kame. Are you sure?",
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.justify,
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
}
