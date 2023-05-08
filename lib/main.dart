import 'package:flutter/material.dart';
import 'package:webrtc/get_display_media.dart';
import 'package:webrtc/get_user_media.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter WebRTC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebRTC example'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('get user media example'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const GetUserMedia()));
            },
          ),
          ListTile(
            title: Text('get display media example'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const GetDisplayMedia()));
            },
          )
        ],
        ) 
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
