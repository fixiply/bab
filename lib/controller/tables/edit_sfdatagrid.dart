import 'package:flutter/material.dart' hide SelectionChangedCallback;

// Internal package
import 'package:bb/controller/tables/edit_data_source.dart';
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/utils/constants.dart';

// External package
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class EditSfDataGrid extends SfDataGrid {
  final void Function(DataGridRow row, int rowIndex)? onRemove;
  EditSfDataGrid(BuildContext context, {
    required EditDataSource source,
    required List<GridColumn> columns,
    this.onRemove,
    SelectionChangedCallback? onSelectionChanged,
    DataGridController? controller,
    bool allowEditing = true,
    bool allowSorting = true,
    bool showCheckboxColumn = true,
    bool? loadMoreRows,
    SelectionMode selectionMode = SelectionMode.multiple
  }) : super(
    source: source,
    columns: columns,
    rowHeight: 40.0,
    controller: controller,
    onSelectionChanged: onSelectionChanged,
    columnWidthMode: DeviceHelper.isDesktop ? ColumnWidthMode.fill : ColumnWidthMode.none,
    allowEditing: allowEditing,
    allowSorting: allowSorting,
    allowMultiColumnSorting: false,
    navigationMode: GridNavigationMode.cell,
    editingGestureType: EditingGestureType.tap,
    shrinkWrapRows: true,
    showCheckboxColumn: showCheckboxColumn,
    selectionMode: selectionMode,
    loadMoreViewBuilder: loadMoreRows == true ? (BuildContext context, LoadMoreRows loadMoreRows) {
      Future<String> loadRows() async {
        // Call the loadMoreRows function to call the
        // DataGridSource.handleLoadMoreRows method. So, additional
        // rows can be added from handleLoadMoreRows method.
        await loadMoreRows();
        return Future<String>.value('Completed');
      }
      return FutureBuilder<String>(
        initialData: 'loading',
        future: loadRows(),
        builder: (context, snapShot) {
          if (snapShot.data == 'loading') {
            return Container(
              height: 60.0,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: BorderDirectional(
                top: BorderSide(width: 1.0, color: Color.fromRGBO(0, 0, 0, 0.26)))
              ),
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(PrimaryColor)));
          } else {
            return SizedBox.fromSize(size: Size.zero);
          }
        }
      );
    } : null,
    gridLinesVisibility: GridLinesVisibility.horizontal,
    allowSwiping: true,
    endSwipeActionsBuilder: (BuildContext context, DataGridRow row, int rowIndex) {
      return GestureDetector(
        onTap: () {
          onRemove?.call(row, rowIndex);
        },
        child: Container(
          color: Colors.redAccent,
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Icon(Icons.delete, color: Colors.white, size: 20),
              SizedBox(width: 16.0),
              Text('DELETE',style: TextStyle(color: Colors.white, fontSize: 15)),
            ],
          ),
        ),
      );
    },
    startSwipeActionsBuilder: (BuildContext context, DataGridRow row, int rowIndex) {
      return GestureDetector(
        onTap: () {

        },
        child: Container(
          color: Colors.blueAccent,
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Icon(Icons.edit, color: Colors.white, size: 20),
              SizedBox(width: 16.0),
              Text('EDIT', style: TextStyle(color: Colors.white, fontSize: 15))
            ],
          ),
        ),
      );
    },
  );

}