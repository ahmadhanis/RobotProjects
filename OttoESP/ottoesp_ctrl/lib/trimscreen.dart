import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class TrimScreen extends StatefulWidget {
  const TrimScreen({super.key});

  @override
  State<TrimScreen> createState() => _TrimScreenState();
}

class _TrimScreenState extends State<TrimScreen> {
  @override
  void initState() {
    super.initState();
    loadTrim();
  }

  TextEditingController tctrl1 = TextEditingController(); //body left
  TextEditingController tctrl2 = TextEditingController(); //body right
  TextEditingController tctrl3 = TextEditingController(); //Left Leg
  TextEditingController tctrl4 = TextEditingController(); //Rigth Leg
  TextEditingController tctrl5 = TextEditingController(); //Left Arm
  TextEditingController tctrl6 = TextEditingController(); // Right Arm

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trims Setting")),
      body: SingleChildScrollView(
          child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
                "Trim each servo with value between -9 to 9 only. Use load trim button to load stored value. Save trim to save the value to Otto. Test button use to see if the trim value is enough",
                textAlign: TextAlign.justify),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  child: TextField(
                      controller: tctrl1,
                      onChanged: (value) {
                        int val = int.parse(value);
                        if ((val < -9) || (val > 9)) {
                          tctrl1.text = "0".toString();
                          setState(() {});
                        }
                      },
                      decoration: const InputDecoration(
                          labelText: 'T1', hintText: 'T1'),
                      style: const TextStyle(),
                      keyboardType: TextInputType.number),
                ),
                const SizedBox(
                  width: 16,
                ),
                Flexible(
                  flex: 1,
                  child: TextField(
                      controller: tctrl2,
                      onChanged: (value) {
                        int val = int.parse(value);
                        if ((val < -9) || (val > 9)) {
                          tctrl4.text = "0".toString();
                          setState(() {});
                        }
                      },
                      decoration: const InputDecoration(
                          labelText: 'T2', hintText: 'T2'),
                      keyboardType: TextInputType.number),
                ),
                const SizedBox(
                  width: 16,
                ),
                Flexible(
                  flex: 1,
                  child: TextField(
                      controller: tctrl3,
                      onChanged: (value) {
                        int val = int.parse(value);
                        if ((val < -9) || (val > 9)) {
                          tctrl6.text = "0".toString();
                          setState(() {});
                        }
                      },
                      decoration: const InputDecoration(
                          labelText: 'T3', hintText: 'T3'),
                      style: const TextStyle(),
                      keyboardType: TextInputType.number),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Image.asset(
              'assets/ottobody.png',
              //scale: 0.5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  child: TextField(
                      controller: tctrl4,
                      onChanged: (value) {
                        int val = int.parse(value);
                        if ((val < -9) || (val > 9)) {
                          tctrl2.text = "0".toString();
                          setState(() {});
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'T4',
                        hintText: 'T4',
                      ),
                      keyboardType: TextInputType.number),
                ),
                const SizedBox(
                  width: 16,
                ),
                Flexible(
                  flex: 1,
                  child: TextField(
                      controller: tctrl5,
                      onChanged: (value) {
                        int val = int.parse(value);
                        if ((val < -9) || (val > 9)) {
                          tctrl5.text = "0".toString();
                          setState(() {});
                        }
                      },
                      decoration: const InputDecoration(
                          labelText: 'T5', hintText: 'T5'),
                      keyboardType: TextInputType.number),
                ),
                const SizedBox(
                  width: 16,
                ),
                Flexible(
                  flex: 1,
                  child: TextField(
                      controller: tctrl6,
                      onChanged: (value) {
                        int val = int.parse(value);
                        if ((val < -9) || (val > 9)) {
                          tctrl3.text = "0".toString();
                          setState(() {});
                        }
                      },
                      decoration: const InputDecoration(
                          labelText: 'T6', hintText: 'T6'),
                      style: const TextStyle(),
                      keyboardType: TextInputType.number),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  onPressed: loadTrim, child: const Text("Load Trim")),
              ElevatedButton(
                  onPressed: saveTrim, child: const Text("Save Trim")),
              ElevatedButton(
                  onPressed: testTrim, child: const Text("Test Trim"))
            ],
          )
        ],
      )),
    );
  }

  void loadTrim() {
    http
        .get(
      Uri.parse("http://192.168.4.1/readsetting"),
    )
        .then((response) {
      print(response.body);
      if (response.statusCode == 200) {
        List<String> trimlist = response.body.split(",");
        for (String item in trimlist) {
          print(item);
        }
        tctrl1.text = trimlist[0].toString();
        tctrl2.text = trimlist[1].toString();
        tctrl3.text = trimlist[2].toString();
        tctrl4.text = trimlist[3].toString();
        tctrl5.text = trimlist[4].toString();
        tctrl6.text = trimlist[5].toString();
        // tctrl7.text = trimlist[6].toString();
        // tctrl8.text = trimlist[7].toString();
        setState(() {});
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      }
    }).timeout(const Duration(seconds: 5), onTimeout: () {
      Fluttertoast.showToast(
          msg: "Timeout. Check connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    });
  }

  void saveTrim() {
    String t1 = tctrl1.text;
    String t2 = tctrl2.text;
    String t3 = tctrl3.text;
    String t4 = tctrl4.text;
    String t5 = tctrl5.text;
    String t6 = tctrl6.text;
    // String t7 = tctrl7.text;
    // String t8 = tctrl8.text;
    if (t1.isEmpty ||
        t2.isEmpty ||
        t3.isEmpty ||
        t4.isEmpty ||
        t4.isEmpty ||
        t5.isEmpty ||
        t6.isEmpty) {
      Fluttertoast.showToast(
          msg: "Set your trims!!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
      return;
    }

    String req = "t1=$t1&t2=$t2&t3=$t3&t4=$t4&t5=$t5&t6=$t6";
    print(req);
    http
        .get(
      Uri.parse("http://192.168.4.1/trimssetting?$req"),
    )
        .then((response) {
      print(response.body);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: response.body,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      }
    });
  }

  void testTrim() {
    String t1 = tctrl1.text;
    String t2 = tctrl2.text;
    String t3 = tctrl3.text;
    String t4 = tctrl4.text;
    String t5 = tctrl5.text;
    String t6 = tctrl6.text;

    if (t1.isEmpty ||
        t2.isEmpty ||
        t3.isEmpty ||
        t4.isEmpty ||
        t4.isEmpty ||
        t5.isEmpty ||
        t6.isEmpty) {
      Fluttertoast.showToast(
          msg: "Set your trims!!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
      return;
    }

    String req = "t1=$t1&t2=$t2&t3=$t3&t4=$t4&t5=$t5&t6=$t6";
    log("http://192.168.4.1/testtrims?$req");
    http
        .get(
      Uri.parse("http://192.168.4.1/testtrims?$req"),
    )
        .then((response) {
      print(response.body);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: response.body,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      }
    });
  }
}
