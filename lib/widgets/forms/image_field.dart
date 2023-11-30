import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/admin/gallery_page.dart';
import 'package:bab/controller/admin/image_crop_page.dart';
import 'package:bab/models/image_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/widgets/containers/image_container.dart';
import 'package:bab/widgets/form_decoration.dart';

// External package
import 'package:image_picker/image_picker.dart';

class ImageField extends FormField<ImageModel> {
  final double? width;
  final double? height;
  final bool? memory;

  final void Function(ImageModel? value)? onChanged;

  ImageField({Key? key, required BuildContext context, this.onChanged, ImageModel? image, this.width = 256, this.height = 144, this.memory = false, bool crop = false}) : super(
    key: key,
    initialValue: image,
    builder: (FormFieldState<ImageModel> field) {
      final _ImageFieldState state = field as _ImageFieldState;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          InputDecorator(
            decoration: FormDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              icon: const Icon(Icons.image)
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(0.0),
              title:  Text(AppLocalizations.of(context)!.text('image')),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (memory == true && (image != null && image.bytes != null)) IconButton(
                    icon:const Icon(Icons.close),
                    onPressed: () async {
                      image.bytes = null;
                      state.didChange(image);
                    }
                  ),
                  if (crop) Tooltip(
                    message: AppLocalizations.of(context)!.text('crop'),
                    child: IconButton(
                      icon:const Icon(Icons.crop),
                      onPressed: () async {
                        state._showResizing();
                      }
                    )
                  ),
                  IconButton(
                    icon:const Icon(Icons.chevron_right),
                    onPressed: () async {
                      state._showPicker();
                    }
                  )
                ]
              )
            )
          ),
          image != null ? Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [ BoxShadow(color: Colors.grey) ]
            ),
            child: ImageContainer(image, width: width, height: height, context: context, cache: false)
          ) : Container()
        ]
      );
    }
  );

  @override
  _ImageFieldState createState() => _ImageFieldState();
}

class _ImageFieldState extends FormFieldState<ImageModel> {
  @override
  ImageField get widget => super.widget as ImageField;

  final picker = ImagePicker();

  @override
  void didChange(ImageModel? value) {
    widget.onChanged?.call(value);
    super.didChange(value);
  }

  String getLabel(Uint8List? image, fractionDigits) {
    if (image == null) {
      return AppLocalizations.of(context)!.text('image');
    }
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    int bytes = image.lengthInBytes;
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(fractionDigits)} ${suffixes[i]}';
  }

  _showResizing() {
    if (widget.initialValue != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ImageCropPage(widget.initialValue!.url!, widget.initialValue!.rect);
      })).then((rect) {
        if (rect != null && rect == false) {
          return;
        }
        setState(() {
          widget.initialValue!.rect = rect;
        });
        didChange(widget.initialValue);
      });
    }
  }

  _showPicker() async {
    if (widget.memory == true) {
      final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          maxWidth: 640,
          // maxHeight: 480,
          imageQuality: 80
      );
      if (pickedFile != null) {
        widget.initialValue!.bytes = await pickedFile.readAsBytes();
        didChange(widget.initialValue);
      }
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        List<ImageModel> images = [];
        if (widget.initialValue != null) {
          images.add(widget.initialValue!);
        }
        return GalleryPage(images, only: true);
      })).then((result) {
        didChange(result);
      });
    }
  }
}
