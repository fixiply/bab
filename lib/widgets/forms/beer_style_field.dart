import 'package:flutter/material.dart';

// Internal package
import 'package:bab/models/style_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/widgets/form_decoration.dart';

// External package
import 'package:dropdown_search/dropdown_search.dart';

class BeerStyleField extends FormField<StyleModel> {
  final String? title;
  final void Function(StyleModel? value)? onChanged;
  @override
  final FormFieldValidator<dynamic>? validator;

  BeerStyleField({Key? key, required BuildContext context, StyleModel? initialValue, this.title, this.onChanged, this.validator}) : super(
      key: key,
      initialValue: initialValue,
      builder: (FormFieldState<StyleModel> field) {
        return field.build(field.context);
      }
  );

  @override
  _BeerStyleFieldState createState() => _BeerStyleFieldState();
}

class _BeerStyleFieldState extends FormFieldState<StyleModel> {
  final GlobalKey<FormFieldState> _key = GlobalKey<FormFieldState>();
  Future<List<StyleModel>>? _styles;

  @override
  BeerStyleField get widget => super.widget as BeerStyleField;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didChange(StyleModel? value) {
    widget.onChanged?.call(value);
    super.didChange(value);
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: FormDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        icon: const Icon(Icons.how_to_reg),
        fillColor: FillColor,
        filled: true,
      ),
      child: FutureBuilder<List<StyleModel>>(
        future: _styles,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return DropdownSearch<StyleModel>(
              key: _key,
              selectedItem: widget.initialValue != null ? snapshot.data!.singleWhere((element) => element == widget.initialValue) : null,
              compareFn: (item1, item2) => item1.uuid == item2.uuid,
              itemAsString: (StyleModel model) => AppLocalizations.of(context)!.localizedText(model.name),
              asyncItems: (String filter) async {
                return snapshot.data!.where((element) => AppLocalizations.of(context)!.localizedText(element.name).contains(filter)).toList();
              },
              popupProps: const PopupProps.menu(
                showSelectedItems: true,
                showSearchBox: true,
              ),
              dropdownDecoratorProps: DropDownDecoratorProps(
                  baseStyle: DefaultTextStyle.of(context).style.copyWith(overflow: TextOverflow.ellipsis),
                  dropdownSearchDecoration: FormDecoration(
                  labelText: widget.title ?? AppLocalizations.of(context)!.text('style'),
                )
              ),
              onChanged: (value) async {
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
      _styles = Database().getStyles(ordered: true);
    });
  }
}
