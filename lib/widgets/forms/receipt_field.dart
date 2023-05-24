import 'package:flutter/material.dart';

// Internal package
import 'package:bb/models/receipt_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/widgets/form_decoration.dart';

// External package
import 'package:dropdown_search/dropdown_search.dart';

class ReceiptField extends FormField<ReceiptModel> {
  final String? title;
  final void Function(ReceiptModel? value)? onChanged;
  @override
  final FormFieldValidator<dynamic>? validator;

  ReceiptField({Key? key, required BuildContext context, ReceiptModel? initialValue, this.title, this.onChanged, this.validator}) : super(
      key: key,
      initialValue: initialValue,
      builder: (FormFieldState<ReceiptModel> field) {
        return field.build(field.context);
      }
  );

  @override
  _BeerStyleFieldState createState() => _BeerStyleFieldState();
}

class _BeerStyleFieldState extends FormFieldState<ReceiptModel> {
  final GlobalKey<FormFieldState> _key = GlobalKey<FormFieldState>();
  Future<List<ReceiptModel>>? _receipts;

  @override
  ReceiptField get widget => super.widget as ReceiptField;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didChange(ReceiptModel? value) {
    widget.onChanged?.call(value);
    super.didChange(value);
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: FormDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        icon: const Icon(Icons.sports_bar_outlined),
        fillColor: FillColor,
        filled: true,
      ),
      child: FutureBuilder<List<ReceiptModel>>(
        future: _receipts,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return DropdownSearch<ReceiptModel>(
              key: _key,
              selectedItem: widget.initialValue != null ? snapshot.data!.singleWhere((element) => element == widget.initialValue) : null,
              compareFn: (item1, item2) => item1.uuid == item2.uuid,
              itemAsString: (ReceiptModel model) => AppLocalizations.of(context)!.localizedText(model.title),
              asyncItems: (String filter) async {
                return snapshot.data!.where((element) => AppLocalizations.of(context)!.localizedText(element.title).contains(filter)).toList();
              },
              popupProps: const PopupProps.menu(
                showSelectedItems: true,
                showSearchBox: true,
              ),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: FormDecoration(
                  labelText: widget.title ?? AppLocalizations.of(context)!.text('style'),
                )
              ),
              onChanged: (value) async {
                didChange(value);
              },
              autoValidateMode: AutovalidateMode.onUserInteraction,
              validator: widget.validator,
            );
          }
          return Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {

              },
              child: Text(AppLocalizations.of(context)!.text('add_recipe')),
            )
          );
        }
      ),
    );
  }

  _fetch() async {
    setState(() {
      _receipts = Database().getReceipts(user: currentUser?.uuid, myData: true, ordered: true);
    });
  }
}
