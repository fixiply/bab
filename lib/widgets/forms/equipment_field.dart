import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/tanks_page.dart';
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/models/equipment_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/widgets/form_decoration.dart';

class EquipmentField extends FormField<String> {
  final String? title;
  final void Function(String? value)? onChanged;
  final FormFieldValidator<String>? validator;

  EquipmentField({Key? key, required BuildContext context, String? dataset, this.title, this.onChanged, this.validator}) : super(
      key: key,
      initialValue: dataset,
      builder: (FormFieldState<String> field) {
        return field.build(field.context);
      }
  );

  @override
  _BeerStyleFieldState createState() => _BeerStyleFieldState();
}

class _BeerStyleFieldState extends FormFieldState<String> {
  final GlobalKey<FormFieldState> _key = GlobalKey<FormFieldState>();
  Future<List<EquipmentModel>>? _equipment;

  @override
  EquipmentField get widget => super.widget as EquipmentField;

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
        icon: Icon(Icons.propane_tank_outlined),
        fillColor: FillColor, filled: true,
        suffix: DeviceHelper.isDesktop ? Padding(
          padding: EdgeInsets.only(left: 20.0, right: 15.0),
          child: IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: () {
              _showPage();
            },
          )
        ) : null,
      ),
      child: FutureBuilder<List<EquipmentModel>>(
        future: _equipment,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return DropdownButtonFormField<String>(
              key: _key,
              value: widget.initialValue,
              iconEnabledColor: Colors.black45,
              isExpanded: true,
              decoration: FormDecoration(
                // icon: const Icon(Icons.how_to_reg),
                labelText: widget.title ?? AppLocalizations.of(context)!.text('style'),
              ),
              items: _items(snapshot.data as List<EquipmentModel>),
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
      _equipment = Database().getEquipments();
    });
  }

  List<DropdownMenuItem<String>> _items(List<EquipmentModel> values) {
    List<DropdownMenuItem<String>> items = [
      DropdownMenuItem<String>(
          value: null,
          child: Text('Par défaut, rendement à $DEFAULT_YIELD%')
      )
    ];
    for (EquipmentModel value in values) {
      items.add(DropdownMenuItem(
          value: value.uuid,
          child: Text(AppLocalizations.of(context)!.localizedText(value.name), overflow: TextOverflow.ellipsis)
      ));
    };
    return items;
  }

  _showPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TanksPage();
    })).then((articles) {
      _fetch();
    });
  }
}
