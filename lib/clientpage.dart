import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'class/client.dart';

class ClientPage extends StatefulWidget {
  @override
  _ClientPageState createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  Client? client;
  List<String> serverLogs = [];
  TextEditingController controller = TextEditingController();

  initState() {
    super.initState();

    client = Client(
      hostname: "192.168.1.39",
      port: 4040,
      onData: this.onData,
      onError: this.onError,
    );
  }

  onData(Uint8List data) {
    DateTime time = DateTime.now();
    serverLogs.add(time.hour.toString() +
        "h" +
        time.minute.toString() +
        " : " +
        String.fromCharCodes(data));
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
                    client!.write(controller.text);
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