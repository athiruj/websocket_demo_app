import 'package:alert/alert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

void main() async {
  await Hive.initFlutter();
  await Hive.openBox("uriBox");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController uriController = TextEditingController();
  Box box = Hive.box("uriBox");
  bool connnect = false;
  bool ledState = false;

  // connect to WebSocket
  void connectSocket(String strUri) async {
    try {
      final channel = WebSocketChannel.connect(Uri.parse(strUri));
      channel.stream.listen((event) {
        channel.sink.add("received");
        Alert(message: "Connect to ws://$strUri").show();
        channel.sink.close(status.goingAway);
        box.put("uri", strUri);
      });
    } catch (error) {
      Alert(message: error.toString()).show();
    }
  }

  @override
  void initState() {
    if (box.get("uri") != null && box.get("uri") == "") {
      () => uriController.text = box.get("uri");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
                maxWidth: 300,
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // * Address TextField Part
                    Column(
                      children: [
                        SizedBox(
                          height: 56,
                          width: 300,
                          child: TextField(
                            controller: uriController,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 18),
                            decoration: InputDecoration(
                              hintText: "Enter ip Address",
                              hintStyle: GoogleFonts.inter(fontSize: 18),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: FilledButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              fixedSize: MaterialStateProperty.resolveWith(
                                  (states) => const Size(300, 48)),
                              backgroundColor:
                                  MaterialStateColor.resolveWith((states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.blueGrey;
                                }
                                return Colors.blue;
                              }),
                            ),
                            child: Text(
                              "Connect",
                              style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            onPressed: () => connectSocket(uriController.text),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    // * Controller Part
                    Column(
                      children: [
                        Text(
                            connnect
                                ? "Status: Connected"
                                : "Status: Disconnect",
                            style: GoogleFonts.inter(fontSize: 18)),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: TextButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              fixedSize: MaterialStateProperty.resolveWith(
                                  (states) => const Size(300, 48)),
                              backgroundColor:
                                  MaterialStateColor.resolveWith((states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.blueGrey;
                                }
                                return ledState ? Colors.blue : Colors.blueGrey;
                              }),
                            ),
                            child: Text(
                              ledState ? "On" : "Off",
                              style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            onPressed: () {
                              setState(() {
                                ledState = !ledState;
                              });
                            },
                          ),
                        )
                      ],
                    )
                  ]),
            ),
          ),
        ),
      );
    });
  }
}
