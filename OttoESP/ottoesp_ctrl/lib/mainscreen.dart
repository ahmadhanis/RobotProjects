import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'trimscreen.dart';
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
        voiceOtto(_lastWords);
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
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Otto Controller'),
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
                    Uri.parse("http://192.168.4.1/readsetting"),
                  )
                      .then((response) {
                    if (response.statusCode == 200) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (content) => const TrimScreen()));
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Failed. Please connect to your Otto first',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          fontSize: 16.0);
                    }
                  }).timeout(const Duration(seconds: 5), onTimeout: () {
                    Fluttertoast.showToast(
                        msg: 'Timeout. Please connect to your Otto first',
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
                const SizedBox(height: 5),
                const Text(
                  "Please connect to Otto access point.\nCurrently connected to:",
                  style: TextStyle(fontSize: 16.0),
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
                ),
                const SizedBox(height: 5),
                const Divider(
                  height: 1,
                  color: Colors.black,
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RawMaterialButton(
                      onPressed: () {
                        commandOtto("1");
                      },
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      padding: const EdgeInsets.all(15.0),
                      fillColor: Colors.white,
                      elevation: 2.0,
                      child: const Icon(Icons.arrow_upward, size: 35),
                    ),
                    // SizedBox(
                    //   width: 150,
                    //   height: 50,
                    //   child: ElevatedButton.icon(
                    //     icon: const Icon(Icons.arrow_upward),
                    //     label: const Text("FORWARD"),
                    //     onPressed: () {
                    //       commandOtto("1");
                    //     },
                    //   ),
                    // )
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RawMaterialButton(
                      onPressed: () {
                        commandOtto("3");
                      },
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      padding: const EdgeInsets.all(15.0),
                      fillColor: Colors.white,
                      elevation: 2.0,
                      child: const Icon(Icons.arrow_back, size: 35),
                    ),
                    // SizedBox(
                    //     width: 120,
                    //     height: 50,
                    //     child: ElevatedButton(
                    //       child: const Text("LEFT"),
                    //       onPressed: () {
                    //         commandOtto("3");
                    //       },
                    //     )),
                    const SizedBox(
                      width: 20,
                    ),
                    RawMaterialButton(
                      onPressed: () {
                        commandOtto("24");
                      },
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      padding: const EdgeInsets.all(15.0),
                      fillColor: Colors.white,
                      elevation: 2.0,
                      child: const Icon(Icons.home, size: 35),
                    ),
                    // SizedBox(
                    //     width: 120,
                    //     height: 50,
                    //     child: ElevatedButton(
                    //       child: const Text("HOME"),
                    //       onPressed: () {
                    //         commandOtto("5");
                    //       },
                    //     )),
                    const SizedBox(
                      width: 20,
                    ),
                    RawMaterialButton(
                      onPressed: () {
                        commandOtto("2");
                      },
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      padding: const EdgeInsets.all(15.0),
                      fillColor: Colors.white,
                      elevation: 2.0,
                      child: const Icon(Icons.arrow_forward, size: 35),
                    ),
                    // SizedBox(
                    //     width: 120,
                    //     height: 50,
                    //     child: ElevatedButton(
                    //       child: const Text("RIGHT"),
                    //       onPressed: () {
                    //         commandOtto("4");
                    //       },
                    //     ))
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RawMaterialButton(
                      onPressed: () {
                        commandOtto("4");
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
                    //     width: 120,
                    //     height: 50,
                    //     child: ElevatedButton(
                    //       child: const Text("ZERO"),
                    //       onPressed: () {
                    //         commandOtto("0");
                    //       },
                    //     )),
                    // const SizedBox(width: 20),
                    // RawMaterialButton(
                    //   onPressed: () {
                    //     commandOtto("15");
                    //   },
                    //   shape: const RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.all(Radius.circular(5)),
                    //   ),
                    //   padding: const EdgeInsets.all(15.0),
                    //   fillColor: Colors.white,
                    //   elevation: 2.0,
                    //   child: const Icon(Icons.start, size: 35),
                    // ),
                    // // SizedBox(
                    // //     width: 120,
                    // //     height: 50,
                    // //     child: ElevatedButton(
                    // //       child: const Text("INIT"),
                    // //       onPressed: () {
                    // //         commandOtto("15");
                    // //       },
                    // //     ))
                  ],
                ),
                const SizedBox(height: 5),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        width: 120,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("BEND-L",style: TextStyle(fontSize: 11),),
                          onPressed: () {
                            commandOtto("5");
                          },
                        )),
                    SizedBox(
                        width: 120,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("MOON",style: TextStyle(fontSize: 11),),
                          onPressed: () {
                            commandOtto("10");
                          },
                        )),
                    SizedBox(
                        width: 120,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("BEND-R",style: TextStyle(fontSize: 11),),
                          onPressed: () {
                            commandOtto("6");
                          },
                        ))
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        width: 120,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("SHAKE-L",style: TextStyle(fontSize: 11),),
                          onPressed: () {
                            commandOtto("7");
                          },
                        )),
                    SizedBox(
                        width: 120,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("JUMP",style: TextStyle(fontSize: 11),),
                          onPressed: () {
                            commandOtto("10");
                          },
                        )),
                    SizedBox(
                        width: 120,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("SHAKE-R",style: TextStyle(fontSize: 11),),
                          onPressed: () {
                            commandOtto("11");
                          },
                        ))
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        width: 120,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("RUN",style: TextStyle(fontSize: 11),),
                          onPressed: () {
                            commandOtto("18");
                          },
                        )),
                    SizedBox(
                        width: 120,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("SWING",style: TextStyle(fontSize: 11),),
                          onPressed: () {
                            commandOtto("12");
                          },
                        )),
                    SizedBox(
                        width: 120,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("JITTER",style: TextStyle(fontSize: 11),),
                          onPressed: () {
                            commandOtto("14");
                          },
                        )),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        width: 120,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("ASC",style: TextStyle(fontSize: 11),),
                          onPressed: () {
                            commandOtto("15");
                          },
                        )),
                    SizedBox(
                        width: 120,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("CRUS",style: TextStyle(fontSize: 11),),
                          onPressed: () {
                            commandOtto("16");
                          },
                        )),
                    SizedBox(
                        width: 120,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("FLAP",style: TextStyle(fontSize: 11),),
                          onPressed: () {
                            commandOtto("17");
                          },
                        )),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        width: 120,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("AUTO",style: TextStyle(fontSize: 11),),
                          onPressed: () {
                            commandOtto("19");
                          },
                        )),
                    SizedBox(
                        width: 120,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("STOP",style: TextStyle(fontSize: 11),),
                          onPressed: () {
                            commandOtto("20");
                          },
                        )),
                    SizedBox(
                        width: 120,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("UPDOWN",style: TextStyle(fontSize: 11),),
                          onPressed: () {
                            commandOtto("9");
                          },
                        )),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        width: 120,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("HAND-W",style: TextStyle(fontSize: 11),),
                          onPressed: () {
                            commandOtto("21");
                          },
                        )),
                    SizedBox(
                        width: 120,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("HAND-U",style: TextStyle(fontSize: 11),),
                          onPressed: () {
                            commandOtto("22");
                          },
                        )),
                    SizedBox(
                        width: 120,
                        height: 50,
                        child: ElevatedButton(
                          child: const Text("HAND-UD",style: TextStyle(fontSize: 11),),
                          onPressed: () {
                            commandOtto("23");
                          },
                        )),
                  ],
                ),
                const SizedBox(height: 5),
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
      Uri.parse("http://192.168.4.1/changename?ssid=$newssid&password=$newpass"),
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

  void voiceOtto(String command) {
    switch (command.toLowerCase()) {
      case "0":
        commandOtto("0");
        break;
      case "forward":
        commandOtto("1");
        break;
      case "right":
        commandOtto("2");
        break;
      case "left":
        commandOtto("3");
        break;
      case "backward":
        commandOtto("4");
        break;
      case "bend left":
        commandOtto("5");
        break;
      case "bend rigth":
        commandOtto("6");
        break;
      case "shake left":
        commandOtto("7");
        break;
      case "shake right":
        commandOtto("8");
        break;
      case "up down":
        commandOtto("9");
        break;
      case "moon":
        commandOtto("10");
        break;
      case "swing":
        commandOtto("12");
        break;
      case "tiptoe swing":
        commandOtto("13");
        break;
      case "jitter":
        commandOtto("14");
        break;
      case "asc":
        commandOtto("15");
        break;
      case "crus":
        commandOtto("16");
        break;
      case "flap":
        commandOtto("17");
        break;
      case "run":
        commandOtto("18");
        break;
      case "auto":
        commandOtto("19");
        break;
      case "auto off":
        commandOtto("20");
        break;
      case "hand wave":
        commandOtto("21");
        break;
      case "hand up":
        commandOtto("22");
        break;
      case "hand up down":
        commandOtto("23");
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

  void commandOtto(String s) {
    if (ssid == "Not available") {
      Fluttertoast.showToast(
          msg: 'Please connect to Otto AP',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
      return;
    }
    http
        .get(
      Uri.parse("http://192.168.4.1/$s"),
    )
        .then((response) {
          log(response.body);
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
            "Change Otto SSID?",
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
            "This will reset your Otto ssid. Make sure you are connnected to one. Are you sure?",
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
                commandOtto("reset");
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
