import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VidepoPlayer extends StatefulWidget {
  const VidepoPlayer({Key key, this.url, this.play = false}) : super(key: key);
  final String url;
  final bool play;
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
    _controller = VideoPlayerController.network(
      widget.url ??
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    await _controller.initialize();
    await _controller.setLooping(true);
  }

  @override
  didUpdateWidget(VidepoPlayer oldWidget) {
    if (_controller != null) {
      if (widget.play) {
        _controller.play();
      } else {
        _controller.pause();
      }
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
    _controller?.dispose();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            child: AspectRatio(
              aspectRatio: MediaQuery.of(context).size.width /
                  MediaQuery.of(context).size.height,
              child: Stack(
                alignment: Alignment.bottomCenter,
                fit: StackFit.expand,
                children: <Widget>[
                  VideoPlayer(_controller),
                  _ControlsOverlay(controller: _controller),
                ],
              ),
            ),
          ),
        ],
      ),
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
