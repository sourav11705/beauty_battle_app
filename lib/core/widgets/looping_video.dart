
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LoopingVideo extends StatefulWidget {
  final String? assetPath;
  final VideoPlayerController? controller;
  final BoxFit fit;

  const LoopingVideo({super.key, this.assetPath, this.controller, this.fit = BoxFit.cover})
      : assert(assetPath != null || controller != null, "Either assetPath or controller must be provided");

  @override
  State<LoopingVideo> createState() => _LoopingVideoState();
}

class _LoopingVideoState extends State<LoopingVideo> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _isExternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _isExternalController = true;
      _initialized = _controller.value.isInitialized;
      if (!_initialized) {
        _controller.initialize().then((_) {
             if (mounted) setState(() => _initialized = true);
        });
      }
       // Ensure looping and playing if external
       if (_initialized) {
          _controller.setLooping(true);
          _controller.play();
       }
    } else {
      _controller = VideoPlayerController.asset(
        widget.assetPath!,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      )..initialize().then((_) {
          _controller.setLooping(true);
          _controller.play();
          if (mounted) {
            setState(() {
              _initialized = true;
            });
          }
        }).catchError((error) {
          debugPrint("Video initialization failed for ${widget.assetPath}: $error");
        });
    }
  }

  @override
  void dispose() {
    if (!_isExternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized && !_controller.value.isInitialized) {
      return Container(color: Colors.black12); // Placeholder
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: widget.fit,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
