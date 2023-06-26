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
  late WebSocketChannel channel;
  late bool connected;
  late bool ledStatus;

  // connect to WebSocket
  void connectSocket({String strUri = "192.168.0.1:81"}) async {
    try {
      channel = WebSocketChannel.connect(Uri.parse("ws://$strUri"));
      channel.stream.listen(
        (message) {
          print(message);
          setState(() {
            if (message == "connected") {
              // channel.sink.add("poweron");
              connected = true; //message is "connected" from NodeMCU
            } else if (message == "poweron") {
              ledStatus = true;
            } else if (message == "poweroff") {
              ledStatus = false;
            }
          });
        },
        onDone: () {
          //if WebSocket is disconnected
          print("Web socket is closed");
          setState(() {
            connected = false;
          });
        },
        onError: (error) {
          print(error.toString());
        },
      );
    } catch (error) {
      Alert(message: error.toString()).show();
    }
  }

  Future<void> sendcmd(String cmd) async {
    if (connected == true) {
      if (ledStatus == false && cmd != "poweron" && cmd != "poweroff") {
        Alert(message: "Send the valid command").show();
        print("Send the valid command");
      } else {
        Alert(message: cmd).show();
        channel.sink.add(cmd); //sending Command to NodeMCU
      }
    } else {
      connectSocket();
      print("Websocket is not connected.");
    }
  }

  @override
  void initState() {
    connected = false;
    ledStatus = false;
    if (box.get("uri") != null && box.get("uri") == "") {
      uriController.text = box.get("uri");
      Future.delayed(Duration.zero, () async {
        connectSocket(
            strUri: box.get("uri")); //connect to WebSocket wth NodeMCU
      });
    }
    uriController.text = "192.168.0.1:81";
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
                            onPressed: () =>
                                connectSocket(strUri: uriController.text),
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
                            connected
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
                                return ledStatus
                                    ? Colors.blue
                                    : Colors.blueGrey;
                              }),
                            ),
                            child: Text(
                              ledStatus ? "On" : "Off",
                              style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            onPressed: () {
                              setState(() {
                                if (ledStatus) {
                                  //if ledStatus is true, then turn off the led
                                  //if led is on, turn off
                                  sendcmd("poweroff");
                                  ledStatus = false;
                                } else {
                                  //if ledStatus is false, then turn on the led
                                  //if led is off, turn on
                                  sendcmd("poweron");
                                  ledStatus = true;
                                }
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
