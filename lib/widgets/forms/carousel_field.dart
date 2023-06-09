import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/admin/gallery_page.dart';
import 'package:bab/controller/admin/image_crop_page.dart';
import 'package:bab/models/image_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/widgets/containers/image_container.dart';
import 'package:bab/widgets/form_decoration.dart';

class CarouselField extends FormField<List<ImageModel>> {
  final double? width;
  final double? height;

  final void Function(List<ImageModel> value)? onChanged;

  CarouselField({Key? key, required BuildContext context, this.onChanged, List<ImageModel>? images, this.width = 256, this.height = 144, bool crop = false}) : super(
    key: key,
    initialValue: images,
    builder: (FormFieldState<List<ImageModel>> field) {
      final _CarouselFieldState state = field as _CarouselFieldState;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          InputDecorator(
            decoration: FormDecoration(
              contentPadding: const EdgeInsets.all(0.0),
              icon: const Icon(Icons.image)
            ),
            child: ListTile(
                contentPadding: const EdgeInsets.all(0.0),
                title: Text(AppLocalizations.of(context)!.text('images')),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (crop) Tooltip(
                      message: AppLocalizations.of(context)!.text('crop'),
                      child: IconButton(
                        icon:const Icon(Icons.crop),
                        onPressed: () async {
                          state._showEditor();
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
          ImageContainer(images, width: width, height: height, context: context, round: false, cache: false)
        ]
      );
    }
  );

  @override
  _CarouselFieldState createState() => _CarouselFieldState();
}

class _CarouselFieldState extends FormFieldState<List<ImageModel>> {
  @override
  CarouselField get widget => super.widget as CarouselField;

  @override
  void didChange(List<ImageModel>? value) {
    widget.onChanged?.call(value!);
    super.didChange(value);
  }

  _showEditor() {
    if (widget.initialValue!.isNotEmpty) {
      ImageModel model = widget.initialValue!.first;
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ImageCropPage(model.url!, model.rect);
      })).then((rect) {
        if (rect != null && rect == false) {
          return;
        }
        setState(() {
          model.rect = rect;
        });
        didChange(widget.initialValue);
      });
    }
  }

  _showPicker() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return GalleryPage(widget.initialValue!);
    })).then((result) {
      didChange(result);
    });
  }
}
