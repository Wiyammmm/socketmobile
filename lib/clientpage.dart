import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:socketserver/services/nfc.dart';
// import 'package:get_ip_address/get_ip_address.dart';
import 'class/client.dart';

class ClientPage extends StatefulWidget {
  @override
  _ClientPageState createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  nfcBackend nfcbackend = nfcBackend();
  Client? client;
  List<String> serverLogs = [];
  TextEditingController controller = TextEditingController();
  String ipAddress = "";
  String _tagId = "";
  initState() {
    super.initState();
    _initNFC();
    _connectToServer();
    _getIPAddress();
  }

  Future<void> _connectToServer() async {
    client = Client(
      hostname: "10.99.72.192",
      port: 4040,
      onData: this.onData,
      onError: this.onError,
    );
    await client?.connect();
  }

  Future<String> _getWifiIP() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        // Check if it's an IPv4 address and not a loopback address
        if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
          return addr.address;
        }
      }
    }
    return 'Unknown';
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

          client!.write({"cardId": "$_tagId", "amount": 100});
          controller.text = "";
          print('tagid: $_tagId');
        });
      },
    );
  }

  Future<void> _getIPAddress() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.wifi) {
        var wifiIP = await _getWifiIP();

        setState(() {
          ipAddress = '$wifiIP';
        });
      }
    } catch (e) {
      setState(() {
        ipAddress = 'Error: $e';
      });
    }
    print('ip address: $ipAddress');
  }

  onData(Uint8List data) {
    serverLogs.add(String.fromCharCodes(data));
    String jsonString = String.fromCharCodes(data);

    // Trim any leading/trailing characters if needed
    jsonString = jsonString.trim();
    jsonString = jsonString.substring(1, jsonString.length - 1);
    // Split the string by commas
    List<String> parts = jsonString.split(',');
    print('parts: $parts');
    // Create an empty map
    Map<String, dynamic> jsonMap = {};

    // Loop through parts and split each part by colon to create key-value pairs

    if (parts.isNotEmpty) {
      parts.forEach((part) {
        List<String> keyValue = part.split(':');
        // Remove leading/trailing spaces and quotes
        String key = keyValue[0].trim().replaceAll('"', '');
        String value = keyValue[1].trim().replaceAll('"', '');
        jsonMap[key] = value;
      });
    }

    // Map<String, dynamic> jsonMap = json.decode("${String.fromCharCodes(data)}");
    print('jsonMap: $jsonMap');
    if (jsonMap['message'].toString() == "logout") {
      print('logout na din');
      confirmReturn();
    }

    setState(() {});
  }

  onError(dynamic error) {
    print(error);
  }

  dispose() {
    controller.dispose();
    client?.disconnect();
    super.dispose();
  }

  confirmReturn() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("ATTENTION"),
          content: Text(
              "Leaving this page will disconnect the client from the socket server"),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text("EXIT", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("CANCEL", style: TextStyle(color: Colors.grey)),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Client",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: client!.connected ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                        ),
                        padding: EdgeInsets.all(5),
                        child: Text(
                          client!.connected ? 'CONNECTED' : 'DISCONNECTED',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (client!.connected) {
                        await client!.disconnect();
                        this.serverLogs.clear();
                      } else {
                        await client!.connect();
                      }
                      setState(() {});
                    },
                    child: Text(!client!.connected
                        ? 'CONNECT TO CLIENT'
                        : 'DISCONNECT TO CLIENT'),
                  ),
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
                        'MESSAGE TO SEND:',
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
                    client!.write({"cardId": "$_tagId", "amount": 100});

                    controller.text = "";
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
