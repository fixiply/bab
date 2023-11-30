import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// External package
import 'package:extended_image/extended_image.dart';

class CustomImage extends ExtendedImage {
  final String? left;
  final String? right;
  final String? bottom;
  final Rect? rect;
  final Image? emptyImage;

  CustomImage.network(String? src, {
    Key? key,
    double scale = 1.0,
    this.left,
    this.right,
    this.bottom,
    this.rect,
    this.emptyImage,
    double? width,
    double? height,
    BoxFit? fit,
    bool enableLoadState = false,
    bool cache = true
  }) : super.network(src!, key: key, scale: scale, width: width, height: height, fit: fit,
    enableLoadState: enableLoadState,
    cache: cache,
    loadStateChanged: (ExtendedImageState state) {
      switch (state.extendedImageLoadState) {
        case LoadState.loading:
          break;
        case LoadState.completed:
          if (rect != null) {
            var image = state.extendedImageInfo?.image;
            return ExtendedRawImage(
              image: image,
              sourceRect: rect,
              fit: fit,
            );
          }
          break;
        case LoadState.failed:
          return emptyImage;
      }
      return null;
    },
  );

  CustomImage.memory(Uint8List? bytes, {
    Key? key,
    double scale = 1.0,
    this.left,
    this.right,
    this.bottom,
    this.rect,
    this.emptyImage,
    double? width,
    double? height,
    BoxFit? fit,
    bool enableLoadState = false,
    bool cache = true
  }) : super.memory(bytes!, key: key, scale: scale, width: width, height: height, fit: fit,
    enableLoadState: enableLoadState,
    loadStateChanged: (ExtendedImageState state) {
      switch (state.extendedImageLoadState) {
        case LoadState.loading:
          break;
        case LoadState.completed:
          if (rect != null) {
            var image = state.extendedImageInfo?.image;
            return ExtendedRawImage(
              image: image,
              sourceRect: rect,
              fit: fit,
            );
          }
          break;
        case LoadState.failed:
          return emptyImage;
      }
      return null;
    },
  );
}
