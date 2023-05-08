import 'package:flutter/material.dart';
import 'package:webrtc/get_user_media.dart';
import 'dart:core';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class GetUserMedia extends StatefulWidget {
  const GetUserMedia({super.key});

  @override
  State<GetUserMedia> createState() => _GetUserMediaState();
}

class _GetUserMediaState extends State<GetUserMedia> {
  late MediaStream _localSrteam;
  final _localRenderer = RTCVideoRenderer();
  bool _isOpen = false;

  late Map<String, dynamic> mediaConstraints;

  @override
  void initState() {
    super.initState();
    _initRenderer();
  }

  _initRenderer() async {
    await _localRenderer.initialize();
  }

  _open() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {'width': 1280, 'height': 720}
    };

    try {
      navigator.mediaDevices.getUserMedia(mediaConstraints).then((stream) {
        _localSrteam = stream;
        _localRenderer.srcObject = _localSrteam;
      });
    } catch (e) {
      print(e.toString());
    }

    if (!mounted) return;

    setState(() {
      _isOpen = true;
    });
  }

  _close() async {
    try {
      await _localSrteam.dispose();
      _localRenderer.srcObject = null;
    } catch(e) {
      print(e.toString);
    }

    setState(() {
      _isOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GetUserMedia example'),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: RTCVideoView(_localRenderer),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>  _isOpen ? _close() : _open(),
        child: Icon(_isOpen ? Icons.close : Icons.add),
      ),
    );
  }
}
