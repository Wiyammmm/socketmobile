import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:socketserver/services/nfc.dart';

import 'class/server.dart';

class ServerPage extends StatefulWidget {
  @override
  _ServerPageState createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  Server? server;
  List<String> serverLogs = [];
  TextEditingController controller = TextEditingController();
  nfcBackend nfcbackend = nfcBackend();
  String _tagId = "";
  initState() {
    super.initState();
    _initNFC();
    _startServer();
  }

  Future<void> _initNFC() async {
    // Start continuous scanning
    print('init nfc');

    // Start Session
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        print('${tag.data}');
        // Do something with an NfcTag instance.
        String tagId = nfcbackend.extractTagId(tag);
        setState(() {
          print('main to');
          _tagId = "tag.data: $tagId";
          server!.broadCast({"cardId": "$_tagId", "amount": 100});
          controller.text = "";
          print('tagid: $_tagId');
        });
      },
    );
  }

  Future<void> _startServer() async {
    server = Server(
      onData: this.onData,
      onError: this.onError,
    );
    await server?.start();
  }

  onData(Uint8List data) {
    serverLogs.add(String.fromCharCodes(data));
    setState(() {});
  }

  onError(dynamic error) {
    print(error);
  }

  dispose() {
    controller.dispose();
    server?.stop();
    super.dispose();
  }

  confirmReturn() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("LOGOUT"),
          content: Text("Are you sure you want to logout?"),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                server!.broadCast(
                    {"cardId": "abcd123", "amount": 100, "message": "logout"});
                controller.text = "";
              },
              child: Text("YES", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("NO", style: TextStyle(color: Colors.grey)),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Server'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: confirmReturn,
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
              child: Column(
                children: <Widget>[
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: <Widget>[
                  //     Text(
                  //       "Server",
                  //       style: TextStyle(
                  //           fontWeight: FontWeight.bold, fontSize: 18),
                  //     ),
                  //     Container(
                  //       decoration: BoxDecoration(
                  //         color: server!.running ? Colors.green : Colors.red,
                  //         borderRadius: BorderRadius.all(Radius.circular(3)),
                  //       ),
                  //       padding: EdgeInsets.all(5),
                  //       child: Text(
                  //         server!.running ? 'ON' : 'OFF',
                  //         style: TextStyle(
                  //           color: Colors.white,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(
                  //   height: 15,
                  // ),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     if (server!.running) {
                  //       await server!.stop();
                  //       this.serverLogs.clear();
                  //     } else {
                  //       await server!.start();
                  //     }
                  //     setState(() {});
                  //   },
                  //   child: Text(server!.running
                  //       ? 'Stop the server'
                  //       : 'Start the server'),
                  // ),
                  Divider(
                    height: 30,
                    thickness: 1,
                    color: Colors.black12,
                  ),
                  Expanded(
                    flex: 1,
                    child: ListView(
                      children: serverLogs.map((String log) {
                        return Padding(
                          padding: EdgeInsets.only(top: 15),
                          child: Text(log),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.grey,
            height: 80,
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'MESSAGE A BROADCASTER :',
                        style: TextStyle(
                          fontSize: 8,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: controller,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                MaterialButton(
                  onPressed: () {
                    controller.text = "";
                  },
                  minWidth: 30,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Icon(Icons.clear),
                ),
                SizedBox(
                  width: 15,
                ),
                MaterialButton(
                  onPressed: () {
                    server!.broadCast({
                      "cardId": "abcd123",
                      "amount": 100,
                      "message": "logout"
                    });
                    controller.text = "";
                  },
                  minWidth: 30,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Icon(Icons.send),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
