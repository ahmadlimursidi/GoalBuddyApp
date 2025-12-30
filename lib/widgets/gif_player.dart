import 'package:flutter/material.dart';

/// Simple GIF player that supports assets and network GIFs using
/// `Image.asset` and `Image.network` (per constraints). It implements
/// in-memory caching of ImageProviders via the global `imageCache` and
/// explicit precaching to improve performance.
class GifPlayer extends StatefulWidget {
  final String src; // asset path or network URL
  final BoxFit fit;
  final bool autoPlay; // if false, image won't be shown until replay pressed
  final double? width;
  final double? height;

  const GifPlayer({
    super.key,
    required this.src,
    this.fit = BoxFit.contain,
    this.autoPlay = true,
    this.width,
    this.height,
  });

  @override
  State<GifPlayer> createState() => _GifPlayerState();
}

class _GifPlayerState extends State<GifPlayer> {
  static final Map<String, ImageProvider> _providerCache = {};
  late final bool _isNetwork;
  ImageProvider? _provider;
  bool _isLoaded = false;
  bool _hasError = false;
  // Changing this key forces Image to rebuild/reload (useful for replay)
  Key _imageKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _isNetwork = widget.src.startsWith('http');
    _initProvider();
  }

  void _initProvider() {
    if (_providerCache.containsKey(widget.src)) {
      _provider = _providerCache[widget.src];
      // Already cached; try to precache to warm the engine
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _precache();
      });
    } else {
      _provider = _isNetwork ? NetworkImage(widget.src) : AssetImage(widget.src);
      _providerCache[widget.src] = _provider!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _precache();
      });
    }
  }

  Future<void> _precache() async {
    setState(() {
      _isLoaded = false;
      _hasError = false;
    });
    try {
      await precacheImage(_provider!, context);
      if (mounted) setState(() => _isLoaded = true);
    } catch (e) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _replay() {
    // Force reload by assigning a new key. This will make the image re-fetch/play.
    setState(() {
      _imageKey = UniqueKey();
      _isLoaded = false;
      _hasError = false;
    });
    // Re-precache to ensure cached bytes are used
    _precache();
  }

  @override
  void didUpdateWidget(covariant GifPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.src != widget.src) {
      _initProvider();
    }
  }

  @override
  Widget build(BuildContext context) {
    // If autoplay is disabled, show placeholder with play button
    if (!_isLoaded && !widget.autoPlay) {
      return _buildPlaceholder();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height ?? double.infinity,
          child: _buildImage(),
        ),
        if (!_isLoaded) const Center(child: CircularProgressIndicator()),
        if (_hasError)
          Positioned.fill(
            child: Container(
              color: Colors.black12,
              child: const Center(
                child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
              ),
            ),
          ),
        // Replay button overlay
        Positioned(
          bottom: 8,
          right: 8,
          child: Row(
            children: [
              IconButton(
                onPressed: _replay,
                icon: const Icon(Icons.replay, color: Colors.white),
                tooltip: 'Replay',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    if (_provider == null) return const SizedBox.shrink();

    // Use Image widget directly with provider for both asset and network
    return Image(
      key: _imageKey,
      image: _provider!,
      fit: widget.fit,
      filterQuality: FilterQuality.medium,
      width: widget.width,
      height: widget.height,
      gaplessPlayback: true,
      // Show error fallback: attempt to display a placeholder asset, else an icon
      errorBuilder: (context, error, stackTrace) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _hasError = true);
        });
        return Image.asset(
          'assets/images/gif_placeholder.png',
          fit: widget.fit,
          width: widget.width,
          height: widget.height,
          errorBuilder: (ctx, err, st) => const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey)),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: GestureDetector(
          onTap: () {
            _precache();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/gif_placeholder.png',
                width: 96,
                height: 96,
                errorBuilder: (ctx, err, st) => const Icon(Icons.play_circle_fill, size: 64, color: Colors.blue),
              ),
              const SizedBox(height: 8),
              const Text('Tap to load', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
