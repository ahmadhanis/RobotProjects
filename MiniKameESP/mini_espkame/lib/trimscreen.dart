import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class TrimScreen extends StatefulWidget {
  const TrimScreen({super.key});

  @override
  State<TrimScreen> createState() => _TrimScreenState();
}

class _TrimScreenState extends State<TrimScreen> {
  TextEditingController tctrl1 = TextEditingController();
  TextEditingController tctrl2 = TextEditingController();
  TextEditingController tctrl3 = TextEditingController();
  TextEditingController tctrl4 = TextEditingController();
  TextEditingController tctrl5 = TextEditingController();
  TextEditingController tctrl6 = TextEditingController();
  TextEditingController tctrl7 = TextEditingController();
  TextEditingController tctrl8 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trims Setting")),
      body: Container(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  child: TextField(
                      controller: tctrl3,
                      decoration: const InputDecoration(
                          labelText: 'T3', hintText: 'T3'),
                      keyboardType: TextInputType.number),
                ),
                const SizedBox(
                  width: 16,
                ),
                Flexible(
                  flex: 1,
                  child: TextField(
                      controller: tctrl1,
                      decoration: const InputDecoration(
                          labelText: 'T1', hintText: 'T1'),
                      style: const TextStyle(),
                      keyboardType: TextInputType.number),
                ),
                Flexible(
                  flex: 1,
                  child: TextField(
                      controller: tctrl2,
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
                      controller: tctrl4,
                      decoration: const InputDecoration(
                          labelText: 'T4', hintText: 'T4'),
                      style: const TextStyle(),
                      keyboardType: TextInputType.number),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Image.asset(
              'assets/kamets.png',
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
                      controller: tctrl7,
                      decoration: const InputDecoration(
                        labelText: 'T7',
                        hintText: 'T7',
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
                      decoration: const InputDecoration(
                          labelText: 'T5', hintText: 'T5'),
                      style: const TextStyle(),
                      keyboardType: TextInputType.number),
                ),
                Flexible(
                  flex: 1,
                  child: TextField(
                      controller: tctrl6,
                      decoration: const InputDecoration(
                          labelText: 'T6', hintText: 'T6'),
                      keyboardType: TextInputType.number),
                ),
                const SizedBox(
                  width: 16,
                ),
                Flexible(
                  flex: 1,
                  child: TextField(
                      controller: tctrl8,
                      decoration: const InputDecoration(
                          labelText: 'T8', hintText: 'T8'),
                      style: const TextStyle(),
                      keyboardType: TextInputType.number),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                  onPressed: loadTrim,
                  icon: const Icon(Icons.get_app),
                  label: const Text("Load Trim")),
              ElevatedButton.icon(
                  onPressed: saveTrim,
                  icon: const Icon(Icons.save),
                  label: const Text("Save Trim"))
            ],
          )
        ],
      )),
    );
  }

  void loadTrim() {
    http
        .get(
      Uri.parse("http://192.168.4.1/19"),
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
        tctrl7.text = trimlist[6].toString();
        tctrl8.text = trimlist[7].toString();
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
    });
  }

  void saveTrim() {}
}
