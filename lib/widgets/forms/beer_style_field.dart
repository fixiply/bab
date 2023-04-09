import 'package:flutter/material.dart';

// Internal package
import 'package:bb/models/style_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/widgets/form_decoration.dart';

// External package
// import 'package:dropdown_search/dropdown_search.dart';

class BeerStyleField extends FormField<String> {
  final String? title;
  final void Function(String? value)? onChanged;
  final FormFieldValidator<String>? validator;

  BeerStyleField({Key? key, required BuildContext context, String? initialValue, this.title, this.onChanged, this.validator}) : super(
      key: key,
      initialValue: initialValue,
      builder: (FormFieldState<String> field) {
        return field.build(field.context);
      }
  );

  @override
  _BeerStyleFieldState createState() => _BeerStyleFieldState();
}

class _BeerStyleFieldState extends FormFieldState<String> {
  final GlobalKey<FormFieldState> _key = GlobalKey<FormFieldState>();
  Future<List<StyleModel>>? _style;

  @override
  BeerStyleField get widget => super.widget as BeerStyleField;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didChange(String? value) {
    widget.onChanged?.call(value);
    super.didChange(value);
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: FormDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        icon: Icon(Icons.how_to_reg),
        fillColor: FillColor,
        filled: true,
      ),
      child: FutureBuilder<List<StyleModel>>(
        future: _style,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            // return DropdownSearch<StyleModel>(
            //   key: _key,
            //   // value: snapshot.data!.contains(widget.initialValue) ? widget.initialValue : null,
            //   // selectedItem: widget.initialValue,
            //   itemAsString: (StyleModel model) => AppLocalizations.of(context)!.localizedText(model.name),
            //   items: snapshot.data!,
            //   onChanged: (value) {
            //     if (value != null) {
            //       didChange(value.uuid!);
            //     }
            //   },
            //   // validator: widget.validator,
            // );
            return DropdownButtonFormField<String>(
              key: _key,
              value: snapshot.data!.contains(widget.initialValue) ? widget.initialValue : null,
              iconEnabledColor: Colors.black45,
              isExpanded: true,
              decoration: FormDecoration(
                // icon: const Icon(Icons.how_to_reg),
                labelText: widget.title ?? AppLocalizations.of(context)!.text('style'),
              ),
              items: _items(snapshot.data as List<StyleModel>),
              onChanged: (value) {
                if (value != null) {
                  if (value.length == 0) {
                    value = null;
                    _key.currentState!.reset();
                  }
                }
                didChange(value);
              },
              validator: widget.validator,
            );
          }
          return Container();
        }
      ),
    );
  }

  _fetch() async {
    setState(() {
      _style = Database().getStyles(ordered: true);
    });
  }

  List<DropdownMenuItem<String>> _items(List<StyleModel> values) {
    List<DropdownMenuItem<String>> items = [
      DropdownMenuItem<String>(
          value: '',
          child: Icon(Icons.clear)
      )
    ];
    for (StyleModel value in values) {
      items.add(DropdownMenuItem(
          value: value.uuid,
          child: Text(AppLocalizations.of(context)!.localizedText(value.name), overflow: TextOverflow.ellipsis)
      ));
    };
    return items;
  }
}
