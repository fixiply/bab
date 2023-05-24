import 'package:flutter/material.dart';

// Internal package
import 'package:bb/models/image_model.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/widgets/custom_image.dart';
import 'package:bb/utils/text_format.dart';

// External package
import 'package:carousel_slider/carousel_slider.dart';

class ImageContainer extends StatefulWidget {
  final dynamic images;
  final double? height;
  final double? width;
  final Image? emptyImage;
  final bool? round;
  final BoxFit? fit;
  final Color? color;
  final double? fontSize;
  final BuildContext? context;
  final bool cache;

  ImageContainer(
    this.images, {
    this.height = 180,
    this.width = double.infinity,
    this.emptyImage,
    this.round = true,
    this.fit = BoxFit.cover,
    this.color = FillColor,
    this.fontSize = 14,
    this.context,
    this.cache = true
  });

  @override
  State<StatefulWidget> createState() {
    return _ImageContainerState();
  }
}

class _ImageContainerState extends State<ImageContainer> {

  @override
  Widget build(BuildContext context) {
    List<ImageModel> images = [];
    if (widget.images != null) {
      if (widget.images is String) {
        images.add(ImageModel(widget.images));
      } else if (widget.images is ImageModel) {
        images.add(widget.images);
      } else if (widget.images is List) {
        images.addAll(widget.images) ;
      }
    }
    if (images.isNotEmpty) {
      if (images.length == 1) {
        Widget? image = _image(images.first);
        return image ?? Container();
      }
      return Container(
        height: widget.height,
        width: widget.width,
        color: widget.color,
        child: CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 6),
            height: MediaQuery.of(context).size.height,
            viewportFraction: 1.0,
            enlargeCenterPage: true,
            enlargeStrategy: CenterPageEnlargeStrategy.height,
          ),
          items: _items(images)
        )
      );
    }
    return widget.emptyImage ?? Container();
  }

  Widget? _image(ImageModel value) {
    List<Widget> stacks = [];
    CustomImage? image = CustomImage.network(value.url, fit: widget.fit, rect: value.rect, emptyImage: widget.emptyImage, cache: widget.cache);
    if (TextFormat.hasText(value.left)) {
      stacks.add(Positioned(
        top: 8.0,
        left: 6.0,
        child: Text(
          value.left!.text!,
          style: TextStyle(
            fontSize: value.left!.size!,
            fontWeight: value.left!.isBold ? FontWeight.bold : null,
            fontStyle: value.left!.isItalic ? FontStyle.italic : null,
            decoration: value.left!.isUnderline ? TextDecoration.underline : null,
            color: Color(value.left!.color!)
          ),
        ),
      ));
    }
    if (TextFormat.hasText(value.right)) {
      stacks.add(Positioned(
        top: 8.0,
        right: 6.0,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              value.right!.text!,
              style: TextStyle(
                fontSize: value.right!.size!,
                fontWeight: value.right!.isBold ? FontWeight.bold : null,
                fontStyle: value.right!.isItalic ? FontStyle.italic : null,
                decoration: value.right!.isUnderline ? TextDecoration.underline : null,
                color: Color(value.right!.color!)
              ),
            ),
          ),
        ),
      ));
    }
    if (TextFormat.hasText(value.bottom)) {
      stacks.add(Positioned(
        bottom: 8.0,
        left: 6.0,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              value.bottom!.text!,
              style: TextStyle(
                fontSize: value.bottom!.size!,
                fontWeight: value.bottom!.isBold ? FontWeight.bold : null,
                fontStyle: value.bottom!.isItalic ? FontStyle.italic : null,
                decoration: value.bottom!.isUnderline ? TextDecoration.underline : null,
                color: Color(value.bottom!.color!)
              ),
            ),
          ),
        ),
      ));
    }
    if (stacks.isNotEmpty) {
      stacks.insert(0, image);
    }
    return Container(
      height: widget.height,
      width: widget.width,
      color: widget.color,
      child: ClipRRect(
        borderRadius: widget.round! ? const BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(6),
        ) : BorderRadius.circular(0.0),
        child: stacks.isNotEmpty ? Stack(fit: StackFit.expand, children: stacks) : image
      )
    );
  }

  List<Widget> _items(List<ImageModel> values) {
    List<Widget> items = <Widget>[];
    if (values.isNotEmpty) {
      for (ImageModel value in values) {
        Widget? image = _image(value);
        if (image != null) {
          items.add(image);
        }
      }
    }
    return items;
  }
}
