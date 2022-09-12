import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/admin/styles_page.dart';
import 'package:bb/models/style_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/widgets/form_decoration.dart';

class BeerStyleField extends FormField<String> {
  final String? title;
  final void Function(String? value)? onChanged;
  final FormFieldValidator<String>? validator;

  BeerStyleField({Key? key, required BuildContext context, String? dataset, this.title, this.onChanged, this.validator}) : super(
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
        contentPadding: EdgeInsets.all(0.0),
        icon: Icon(Icons.how_to_reg),
        suffix: Padding(
          padding: EdgeInsets.only(left: 20.0, right: 15.0),
          child: InkWell(
              onTap: () {
                _showPage();
              },
              child: Icon(Icons.chevron_right, color: Colors.black45)
          ),
        ),
      ),
      child: FutureBuilder<List<StyleModel>>(
        future: _style,
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
      _style = Database().getStyles();
    });
  }

  List<DropdownMenuItem<String>> _items(List<StyleModel> values) {
    List<DropdownMenuItem<String>> items = [
      DropdownMenuItem<String>(
          value: '',
          child: Icon(Icons.clear)
      )
    ];
    for (StyleModel dataset in values) {
      items.add(DropdownMenuItem(
          value: dataset.uuid,
          child: Text(dataset.title!, overflow: TextOverflow.ellipsis)
      ));
    };
    return items;
  }

  _showPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return StylesPage();
    })).then((articles) {
      _fetch();
    });
  }
}
