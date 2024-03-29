import 'package:flutter/material.dart';

// Internal package
import 'package:bab/models/recipe_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/widgets/form_decoration.dart';

// External package
import 'package:dropdown_search/dropdown_search.dart';

class RecipeField extends FormField<RecipeModel> {
  final String? title;
  final void Function(RecipeModel? value)? onChanged;
  @override
  final FormFieldValidator<dynamic>? validator;

  RecipeField({Key? key, required BuildContext context, RecipeModel? initialValue, this.title, this.onChanged, this.validator}) : super(
      key: key,
      initialValue: initialValue,
      builder: (FormFieldState<RecipeModel> field) {
        return field.build(field.context);
      }
  );

  @override
  _RecipeFieldState createState() => _RecipeFieldState();
}

class _RecipeFieldState extends FormFieldState<RecipeModel> {
  final GlobalKey<FormFieldState> _key = GlobalKey<FormFieldState>();
  Future<List<RecipeModel>>? _recipes;

  @override
  RecipeField get widget => super.widget as RecipeField;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didChange(RecipeModel? value) {
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
      child: FutureBuilder<List<RecipeModel>>(
        future: _recipes,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return DropdownSearch<RecipeModel>(
              key: _key,
              selectedItem: widget.initialValue != null ? snapshot.data!.singleWhere((element) => element == widget.initialValue) : null,
              compareFn: (item1, item2) => item1.uuid == item2.uuid,
              itemAsString: (RecipeModel model) => AppLocalizations.of(context)!.localizedText(model.title),
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
      _recipes = Database().getRecipes(user: currentUser?.uuid, myData: true, ordered: true);
    });
  }
}
