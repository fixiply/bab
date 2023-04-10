import 'package:flutter/material.dart';

// Internal package
import 'package:bb/models/style_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/widgets/form_decoration.dart';

// External package
import 'package:dropdown_search/dropdown_search.dart';

class BeerStyleField extends FormField<String> {
  final String? title;
  final void Function(String? value)? onChanged;
  final FormFieldValidator<dynamic>? validator;

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
            return DropdownSearch<StyleModel>(
              key: _key,
              selectedItem: widget.initialValue != null ? snapshot.data!.singleWhere((element) => element.uuid == widget.initialValue) : null,
              compareFn: (item1, item2) => item1.uuid == item2.uuid,
              itemAsString: (StyleModel model) => AppLocalizations.of(context)!.localizedText(model.name),
              asyncItems: (String filter) async {
                return snapshot.data!.where((element) => AppLocalizations.of(context)!.localizedText(element.name).contains(filter)).toList();
              },
              popupProps: PopupProps.menu(
                showSelectedItems: true,
                showSearchBox: true,
              ),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: FormDecoration(
                  labelText: widget.title ?? AppLocalizations.of(context)!.text('style'),
                )
              ),
              onChanged: (value) async {
                didChange(value?.uuid);
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
}
