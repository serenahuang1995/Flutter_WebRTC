import 'package:flutter/material.dart';
import 'package:webrtc/control_device.dart';
import 'dart:core';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class ControlDevice extends StatefulWidget {
  const ControlDevice({super.key});

  @override
  State<ControlDevice> createState() => _ControlDeviceState();
}

class _ControlDeviceState extends State<ControlDevice> {
  late MediaStream _localSrteam;
  final _localRenderer = RTCVideoRenderer();
  bool _isOpen = false;
  bool _cameraOff = false;
  bool _microphineOff = false;
  bool _speakerOn = true;

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
      'video': {'width': 600, 'height': 700}
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
    } catch (e) {
      print(e.toString);
    }

    setState(() {
      _isOpen = false;
    });
  }

  _turnCamera() {
    if (_localSrteam.getVideoTracks().isNotEmpty) {
      var muted = !_cameraOff;
      setState(() {
        _cameraOff = muted;
      });
      _localSrteam.getVideoTracks()[0].enabled = !muted;
    } else {
      print('不能操作');
    }
  }

  _switchCamera() async {
    if (_localSrteam.getVideoTracks().isNotEmpty) {
      // _localSrteam.getVideoTracks()[0].switchCamera();
      MediaStreamTrack videoTrack = _localSrteam.getVideoTracks()[0];

      Map<String, dynamic> constraints = {'facingMode': 'environment'};

      await videoTrack.applyConstraints(
          MediaStreamConstraints(video: constraints) as Map<String, dynamic>?);
    } else {
      print('不能切換');
    }
  }

  _turnMicrophone() {
    if (_localSrteam.getVideoTracks().isNotEmpty) {
      var muted = !_microphineOff;
      setState(() {
        _microphineOff = muted;
      });
      _localSrteam.getAudioTracks()[0].enabled = !muted;

      muted ? print('已靜音') : print('取消靜音');
    } else {
      print('不能操作');
    }
  }

  _switchSpeaker() async {
    setState(() {
      _speakerOn = !_speakerOn;
      MediaStreamTrack audioTrack = _localSrteam.getAudioTracks()[0];
      audioTrack.enableSpeakerphone(_speakerOn);
      print('切換至：' + (_speakerOn ? '擴音' : '耳機'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('control device example'),
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
      bottomNavigationBar: BottomAppBar(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            onPressed: () {
              _turnCamera();
            },
            icon: Icon(_cameraOff ? Icons.videocam_off : Icons.videocam),
          ),
          IconButton(
            onPressed: () {
              _switchCamera();
            },
            icon: const Icon(Icons.switch_camera),
          ),
          IconButton(
            onPressed: () {
              _turnMicrophone();
            },
            icon: Icon(_microphineOff ? Icons.mic_off : Icons.mic),
          ),
          IconButton(
            onPressed: () {
              _switchSpeaker();
            },
            icon: Icon(_speakerOn ? Icons.volume_up : Icons.volume_down),
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _isOpen ? _close() : _open(),
        child: Icon(_isOpen ? Icons.close : Icons.add),
      ),
    );
  }
}
