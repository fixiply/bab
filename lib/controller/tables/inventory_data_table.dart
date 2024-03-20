import 'package:flutter/material.dart';

// Internal package
import 'package:bab/models/inventory_model.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/widgets/containers/error_container.dart';
import 'package:bab/widgets/image_animate_rotate.dart';
import 'package:bab/widgets/search_text.dart';

// External package

class InventoryDataTable extends StatefulWidget {
  final Ingredient ingredient;
  bool edit;
  InventoryDataTable({Key? key, required this.ingredient, this.edit = true}) : super(key: key);

  @override
  _InventoryDataTableState createState() => _InventoryDataTableState();
}

class _InventoryDataTableState extends State<InventoryDataTable> with AutomaticKeepAliveClientMixin {
  TextEditingController _searchQueryController = TextEditingController();
  double dataRowHeight = 30;
  List<InventoryModel> _selected = [];
  Future<List<InventoryModel>>? _data;

  List<InventoryModel> get selected => _selected;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Colors.white,
      child: FutureBuilder<List<InventoryModel>>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child:  Row(
                    children: [
                      Expanded(child: SearchText(
                        _searchQueryController,
                        () {  _fetch(); }
                      )),
                      const SizedBox(width: 4),
                      if (widget.edit) TextButton(
                        child: const Icon(Icons.add),
                        style: TextButton.styleFrom(
                          backgroundColor: FillColor,
                          shape: const CircleBorder(),
                        ),
                        onPressed: add,
                      ),
                      if(_selected.isNotEmpty) TextButton(
                        child: const Icon(Icons.delete_outline),
                        style: TextButton.styleFrom(
                          backgroundColor: FillColor,
                          shape: const CircleBorder(),
                        ),
                        onPressed: () {

                        },
                      )
                    ],
                  )
                ),
                const Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        // child: DataTable(
                        //   dataRowHeight: dataRowHeight,
                        //   columnSpacing: 10,
                        //   sortColumnIndex: _currentSortColumn,
                        //   sortAscending: _isAscending,
                        //   headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        //   columns: <DataColumn>[
                        //     DataColumn(label: Text(AppLocalizations.of(context)!.text('name')),
                        //       onSort: (columnIndex, _) {
                        //         setState(() {
                        //           _currentSortColumn = columnIndex;
                        //           if (_isAscending == true) {
                        //             _isAscending = false;
                        //             // sort the product list in Ascending, order by Price
                        //             snapshot.data!.sort((e1, e2) =>
                        //                 e2.localizedName(locale)!.compareTo(e1.localizedName(locale)!));
                        //           } else {
                        //             _isAscending = true;
                        //             // sort the product list in Descending, order by Price
                        //             snapshot.data!.sort((e1, e2) =>
                        //                 e1.localizedName(locale)!.compareTo(e2.localizedName(locale)!));
                        //           }
                        //         });
                        //       }
                        //     ),
                        //     DataColumn(label: Text(AppLocalizations.of(context)!.text('type')),
                        //       onSort: (columnIndex, _) {
                        //         setState(() {
                        //           _currentSortColumn = columnIndex;
                        //           if (_isAscending == true) {
                        //             _isAscending = false;
                        //             snapshot.data!.sort((e1, e2) =>
                        //                 AppLocalizations.of(context)!.text(e2.type.toString().toLowerCase()).compareTo(AppLocalizations.of(context)!.text(e1.type.toString().toLowerCase())));
                        //           } else {
                        //             _isAscending = true;
                        //             // sort the product list in Descending, order by Price
                        //             snapshot.data!.sort((e1, e2) =>
                        //                 AppLocalizations.of(context)!.text(e1.type.toString().toLowerCase()).compareTo(AppLocalizations.of(context)!.text(e2.type.toString().toLowerCase())));
                        //           }
                        //         });
                        //       }
                        //     ),
                        //     DataColumn(label: Text(AppLocalizations.of(context)!.text('amount')), numeric: true),
                        //   ],
                        //   rows: List<DataRow>.generate(snapshot.hasData ? snapshot.data!.length : 0, (int index) {
                        //     InventoryModel model = snapshot.data![index];
                        //     Function(InventoryModel) onEdit = (model) {
                        //       if (model.isEdited == null || model.isEdited == false) {
                        //         setState(() {
                        //           model.isEdited = true;
                        //         });
                        //       }
                        //     };
                        //     Function(InventoryModel) onSave = (model) {
                        //       Database().update(model).then((value) async {
                        //         setState(() {
                        //           model.isEdited = false;
                        //         });
                        //         _showSnackbar(AppLocalizations.of(context)!.text('saved_item'));
                        //       }).onError((e, s) {
                        //         _showSnackbar(e.toString());
                        //       });
                        //     };
                        //     return DataRow(
                        //       selected: _selected.contains(model),
                        //       onSelectChanged: (bool? value) {
                        //         setState(() {
                        //           if (_selected.contains(model)) {
                        //             _selected.remove(model);
                        //           } else {
                        //             _selected.add(model);
                        //           }
                        //         });
                        //       },
                        //       cells: [
                        //         DataCell(
                        //           Text(model.localizedName(locale) ?? ''),
                        //           placeholder: true,
                        //           onDoubleTap: () => onEdit(model)
                        //         ),
                        //         DataCell(model.isEdited == true ? TextFormField(
                        //           style: TextStyle(height: dataRowHeight),
                        //           initialValue: model.localizedAmount(locale),
                        //           keyboardType: TextInputType.number,
                        //           inputFormatters: <TextInputFormatter>[
                        //             FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                        //           ], // Only numbers can be entered
                        //           onEditingComplete: () => onSave(model),
                        //           onChanged: (value) => model.amount = double.tryParse(value)
                        //         ) : Text(model.localizedAmount(locale)),
                        //           placeholder: true,
                        //           onDoubleTap: () => onEdit(model)
                        //         ),
                        //       ]
                        //     );
                        //   })
                        // )
                    ),
                  ),
                ),
              ]
            );
          }
          if (snapshot.hasError) {
            return ErrorContainer(snapshot.error.toString());
          }
          return Center(
              child: ImageAnimateRotate(
                child: Image.asset('assets/images/logo.png', width: 60, height: 60, color: Theme.of(context).primaryColor),
              )
          );
        }
      )
    );
  }

  _fetch() async {
    setState(() {
      _data = Database().getInventories(ingredient: widget.ingredient, ordered: true);
    });
  }

  add() async {
    setState(() {
      _data!.then((value) {
        value.insert(0, InventoryModel(isEdited : true));
        return value;
      });
    });
  }
}

