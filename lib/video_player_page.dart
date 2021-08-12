import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_player/bloc/video_manager_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class VidepoPlayer extends StatefulWidget {
  const VidepoPlayer({Key key, this.videoManager}) : super(key: key);
  final VideoManager videoManager;
  @override
  _VidepoPlayerState createState() => _VidepoPlayerState();
}

class _VidepoPlayerState extends State<VidepoPlayer> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    _controller = widget.videoManager.videoPlayerController;
    if (widget.videoManager.videoPlayerController != null) {
      if (!_controller?.value?.isInitialized ?? true) {
        try {
          await _controller?.initialize();
          if (widget.videoManager.play) await _controller.play();
          setState(() {});
        } catch (e) {
          print(e);
        }
      }
    }
    setState(() {});
  }

  @override
  didUpdateWidget(VidepoPlayer oldWidget) {
    if (oldWidget != widget) {
      _init();
    }
    if (_controller != null) {
      if (widget.videoManager.play) {
        if (_controller.value.isInitialized) _controller.play();
        setState(() {});
      } else {
        if (!_controller.value.isInitialized ?? true) {
          return;
        }
        if (_controller.value.isInitialized && _controller.value.isPlaying)
          _controller.pause();
      }
      setState(() {});
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    // _controller?.dispose();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.videoManager.videoPlayerController);
    if (_controller == null)
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        ],
      );
    return Column(
      children: <Widget>[
        Container(
          child: AspectRatio(
            aspectRatio: MediaQuery.of(context).size.width /
                MediaQuery.of(context).size.height,
            child: Stack(
              alignment: Alignment.bottomCenter,
              fit: StackFit.passthrough,
              children: <Widget>[
                RepaintBoundary(child: VideoPlayer(_controller)),
                IconButton(
                    icon: !_controller.value.isPlaying
                        ? Icon(
                            Icons.play_arrow,
                            size: 80,
                            color: Colors.white,
                          )
                        : Container(),
                    onPressed: () async {
                      if (!_controller.value.isPlaying)
                        await _controller.play();
                      else
                        await _controller.pause();
                      setState(() {});
                    })
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ControlsOverlay extends StatefulWidget {
  const _ControlsOverlay({Key key, this.controller}) : super(key: key);

  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  __ControlsOverlayState createState() => __ControlsOverlayState();
}

class __ControlsOverlayState extends State<_ControlsOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: widget.controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            widget.controller.value.isPlaying
                ? widget.controller.pause()
                : widget.controller.play();
            setState(() {});
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: widget.controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (speed) {
              widget.controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (context) {
              return [
                for (final speed in _ControlsOverlay._examplePlaybackRates)
                  PopupMenuItem(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${widget.controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}
