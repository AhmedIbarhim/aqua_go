import 'package:aqua_go/core/components/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import 'package:dio/dio.dart';

class CarMakeNetworkLogo extends StatefulWidget {
  const CarMakeNetworkLogo({
    super.key,
    required this.logoUrl,
    this.width,
    this.height,
    this.fit,
  });

  final String logoUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  State<CarMakeNetworkLogo> createState() => _CarMakeNetworkLogoState();
}

class _CarMakeNetworkLogoState extends State<CarMakeNetworkLogo> {
  late Future<String?> _svgFuture;
  final _dio = Dio();

  @override
  void initState() {
    super.initState();
    _svgFuture = _fetchSvg(widget.logoUrl);
  }

  @override
  void didUpdateWidget(covariant CarMakeNetworkLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.logoUrl != widget.logoUrl) {
      _svgFuture = _fetchSvg(widget.logoUrl);
    }
  }

  Future<String?> _fetchSvg(String url) async {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('.png') ||
        lowerUrl.contains('.jpg') ||
        lowerUrl.contains('.jpeg') ||
        lowerUrl.contains('.webp')) {
      return null;
    }

    try {
      final response = await _dio.get<String>(
        url,
        options: Options(responseType: ResponseType.plain),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!.trim();
        if (data.contains('<svg') || data.contains('<SVG')) {
          return data;
        }
      }
    } catch (_) {
      // Fallback on error
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _svgFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(width: widget.width, height: widget.height);
        }

        final svgData = snapshot.data;
        if (svgData != null) {
          return SvgPicture.string(
            svgData,
            width: widget.width,
            height: widget.height,
            fit: widget.fit ?? BoxFit.contain,
          );
        }

        Widget image = CustomNetworkImage(
          widget.logoUrl,
          fit: widget.fit ?? BoxFit.fill,
        );
        if (widget.width != null || widget.height != null) {
          image = SizedBox(
            width: widget.width,
            height: widget.height,
            child: image,
          );
        }
        return image;
      },
    );
  }
}
