import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// VideoPlayerWidget: simple wrapper around `video_player` that supports
/// asset and network MP4 playback with loading indicator, looping and error handling.
class VideoPlayerWidget extends StatefulWidget {
  final String src; // asset path or network URL
  final bool autoPlay;
  final bool looping;
  final BoxFit fit;
  final double? width;
  final double? height;

  const VideoPlayerWidget({
    super.key,
    required this.src,
    this.autoPlay = true,
    this.looping = true,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  bool get _isNetwork => widget.src.startsWith('http');

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    try {
      _controller = _isNetwork
          ? VideoPlayerController.network(widget.src)
          : VideoPlayerController.asset(widget.src);

      await _controller!.initialize();
      _controller!.setLooping(widget.looping);
      if (widget.autoPlay) _controller!.play();

      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.src != widget.src) {
      _controller?.dispose();
      _controller = null;
      _isInitialized = false;
      _hasError = false;
      _initController();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey));
    }

    if (!_isInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: FittedBox(
        fit: widget.fit,
        alignment: Alignment.center,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }
}
