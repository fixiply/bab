import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/forms/form_equipment_page.dart';
import 'package:bab/models/equipment_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/widgets/form_decoration.dart';

// External package
import 'package:dropdown_search/dropdown_search.dart';

class EquipmentField extends FormField<EquipmentModel> {
  final Icon? icon;
  final String? title;
  final Equipment type;
  final void Function(EquipmentModel? value)? onChanged;
  @override
  final FormFieldValidator<dynamic>? validator;

  EquipmentField({Key? key, required BuildContext context, EquipmentModel? initialValue, this.icon, this.title, required this.type, this.onChanged, this.validator}) : super(
      key: key,
      initialValue: initialValue,
      builder: (FormFieldState<EquipmentModel> field) {
        return field.build(field.context);
      }
  );

  @override
  _EquipmentFieldState createState() => _EquipmentFieldState();
}

class _EquipmentFieldState extends FormFieldState<EquipmentModel> {
  final GlobalKey<FormFieldState> _key = GlobalKey<FormFieldState>();
  Future<List<EquipmentModel>>? _equipments;

  @override
  EquipmentField get widget => super.widget as EquipmentField;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didChange(EquipmentModel? value) {
    widget.onChanged?.call(value);
    super.didChange(value);
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: FormDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        icon: widget.icon ?? const Icon(Icons.delete_outline),
        fillColor: FillColor,
        filled: true,
      ),
      child: FutureBuilder<List<EquipmentModel>>(
          future: _equipments,
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return DropdownSearch<EquipmentModel>(
                key: _key,
                selectedItem: widget.initialValue != null ? snapshot.data!.singleWhere((element) => element == widget.initialValue) : null,
                compareFn: (item1, item2) => item1.uuid == item2.uuid,
                itemAsString: (EquipmentModel model) => AppLocalizations.of(context)!.localizedText(model.name),
                asyncItems: (String filter) async {
                  return snapshot.data!.where((element) => AppLocalizations.of(context)!.localizedText(element.name).contains(filter)).toList();
                },
                popupProps: const PopupProps.menu(
                  showSelectedItems: true,
                  showSearchBox: true,
                ),
                dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: FormDecoration(
                      labelText: widget.title ?? AppLocalizations.of(context)!.text('equipment'),
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
                  EquipmentModel newModel = EquipmentModel(
                    type: widget.type
                  );
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return FormEquipmentPage(
                      newModel, widget.type,
                      title: AppLocalizations.of(context)!.text(widget.type == Equipment.fermenter ? 'fermenter' : 'tank'),
                    );
                  })).then((value) { _fetch(); });
                },
                child: Text(AppLocalizations.of(context)!.text(widget.type == Equipment.fermenter ? 'add_fermenter' : 'add_tank')),
              )
            );
          }
      ),
    );
  }

  _fetch() async {
    setState(() {
      _equipments = Database().getEquipments(type: widget.type, ordered: true);
    });
  }
}
