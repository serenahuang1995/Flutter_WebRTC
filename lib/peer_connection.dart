import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:webrtc/get_user_media.dart';
import 'dart:core';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class PeerConnection extends StatefulWidget {
  const PeerConnection({super.key});

  @override
  State<PeerConnection> createState() => _PeerConnectionState();
}

class _PeerConnectionState extends State<PeerConnection> {
  late MediaStream _localStream;
  late MediaStream _remoteStream;
  late RTCPeerConnection _remotelConnection;
  late RTCPeerConnection _localConnection;
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  bool _isConnected = false;

  // late Map<String, dynamic> mediaConstraints;

  final Map<String, dynamic> mediaConstraints = {
    'audio': true,
    'video': {
      'madatory': {'minWidth': '640', 'minHeight': '480', 'minFrameRate': '30'},
      'facingMode': 'user',
      'option': []
    }
  };

  final Map<String, dynamic> sdpConstraints = {
    'madatory': {'OfferToReceiveAudio': true, 'OfferToReceiveVideo': true},
    'option': []
  };

  final Map<String, dynamic> pcConstraints = {
    'madatory': {},
    'option': [
      {'DtlsSrtpKeyAgreement': false},
    ]
  };

  final Map<String, dynamic> configuration = {
    'iceServers': [
      {'url': 'stum:stun.l.google.com.19302'},
    ]
  };

  @override
  void initState() {
    super.initState();
    _initRenderer();
  }

  _initRenderer() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  _onLocalCandidate(RTCIceCandidate candidate) {
    print('LocalCandidate:' + candidate.candidate!);
    _remotelConnection.addCandidate(candidate);
  }

  _onLocalIceConnectionState(RTCIceConnectionState state) {
    print(state);
  }

  _onRemoteCandidate(RTCIceCandidate candidate) {
    print('RemoteCandidate:' + candidate.candidate!);
    _localConnection.addCandidate(candidate);
  }

  _onRemoteIceConnectionState(RTCIceConnectionState state) {
    print(state);
  }

  _onRemoteAddStream(MediaStream stream) {
    _remoteStream = stream;
    _remoteRenderer.srcObject = stream;
  }

  _open() async {
    try {
      _localStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;

      _localConnection =
          await createPeerConnection(configuration, pcConstraints);
      _localConnection.onIceCandidate =
          (candidate) => _onLocalCandidate(candidate);
      _localConnection.onIceConnectionState =
          (state) => _onLocalIceConnectionState(state);

      _localConnection.addStream(_localStream);
      _localStream.getAudioTracks()[0].enabled = false;

      _remotelConnection =
          await createPeerConnection(configuration, pcConstraints);
      _remotelConnection.onIceCandidate =
          (candidate) => _onRemoteCandidate(candidate);
      _remotelConnection.onIceConnectionState =
          (state) => _onRemoteIceConnectionState(state);
      _remotelConnection.onAddStream = (stream) => _onRemoteAddStream(stream);

      final RtcSessionDescription offer = (await _localConnection
          .createOffer(sdpConstraints)) as RtcSessionDescription;
      _localConnection.setLocalDescription(offer as RTCSessionDescription);
      _remotelConnection.setRemoteDescription(offer as RTCSessionDescription);

      final RTCSessionDescription answer =
          await _remotelConnection.createAnswer(sdpConstraints);
      _remotelConnection.setLocalDescription(answer);
      _localConnection.setRemoteDescription(answer);
    } catch (e) {
      print(e.toString());
    }

    if (!mounted) return;

    setState(() {
      _isConnected = true;
    });
  }

  _close() async {
    try {
      await _localStream.dispose();
      await _remoteStream.dispose();
      await _localConnection.close();
      await _remotelConnection.close();
      _localRenderer.srcObject = null;
      _remoteRenderer.srcObject = null;
    } catch (e) {
      print(e.toString);
    }

    setState(() {
      _isConnected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PeerConnection example'),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: Stack(
                children: [
                  Align(
                    alignment: orientation == Orientation.portrait
                        ? const FractionalOffset(0.5, 0.1)
                        : const FractionalOffset(0.0, 0.5),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      width: 320,
                      height: 240,
                      child: RTCVideoView(_localRenderer),
                      decoration: BoxDecoration(color: Colors.black54),
                    ),
                  ),
                  Align(
                    alignment: orientation == Orientation.portrait
                        ? const FractionalOffset(0.5, 0.9)
                        : const FractionalOffset(1.0, 0.5),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      width: 320,
                      height: 240,
                      child: RTCVideoView(_remoteRenderer),
                      decoration: BoxDecoration(color: Colors.black54),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _isConnected ? _close() : _open(),
        child: Icon(_isConnected ? Icons.close : Icons.add),
      ),
    );
  }
}
