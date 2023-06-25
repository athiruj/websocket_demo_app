import 'package:alert/alert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

void main() {
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

  void connectSocket(String strUri) async {
    final channel = WebSocketChannel.connect(Uri.parse(strUri));
    channel.stream.listen((event) {
      channel.sink.add("received");
      channel.sink.close(status.goingAway);
    });
  }

  @override
  void initState() {
    try {
      connectSocket("");
    } catch (error) {
      Alert(message: error.toString()).show();
    }
    super.initState();
  }

  bool connnect = false;
  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: GoogleFonts.kanit(fontSize: 18),
      child: LayoutBuilder(
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
                      // ! Setting part
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                            height: 56,
                            width: 300,
                            child: TextField(
                              controller: uriController,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: "Enter ip Address",
                                hintStyle: GoogleFonts.kanit(fontSize: 16),
                              ),
                              onSubmitted: (value) {
                                connectSocket(value);
                              },
                            ),
                          ),
                          TextButton(
                            child: Container(
                              width: 300,
                              decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  "Connect",
                                  style: GoogleFonts.kanit(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            onPressed: () {},
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      // ! Action part
                      Column(
                        children: [
                          Text(
                            connnect
                                ? "Status: Connected"
                                : "Status: Disconnect",
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextButton(
                            child: Container(
                              width: 300,
                              decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  "On",
                                  style: GoogleFonts.kanit(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            onPressed: () {},
                          )
                        ],
                      )
                    ]),
              ),
            ),
          ),
        );
      }),
    );
  }
}
