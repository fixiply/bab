import 'package:flutter/material.dart' hide SelectionChangedCallback;

// Internal package
import 'package:bab/controller/tables/edit_data_source.dart';
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';

// External package
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class EditSfDataGrid extends SfDataGrid {
  final void Function(int rowIndex)? onRemove;
  final void Function(int rowIndex)? onEdit;
  EditSfDataGrid(BuildContext context, {
    required EditDataSource source,
    required List<GridColumn> columns,
    List<GridTableSummaryRow>? tableSummaryRows,
    this.onRemove,
    this.onEdit,
    DataGridCellTapCallback? onCellTap,
    SelectionChangedCallback? onSelectionChanged,
    DataGridController? controller,
    bool allowEditing = true,
    bool allowSorting = true,
    bool allowSwiping = true,
    bool showCheckboxColumn = false,
    bool? loadMoreRows,
    SelectionMode? selectionMode,
    ScrollPhysics? verticalScrollPhysics,
    ScrollPhysics? horizontalScrollPhysics
  }) : super(
    source: source,
    columns: columns,
    tableSummaryRows: tableSummaryRows ?? <GridTableSummaryRow>[],
    rowHeight: 40.0,
    controller: controller,
    onCellTap: onCellTap,
    onSelectionChanged: onSelectionChanged,
    columnWidthMode: DeviceHelper.isDesktop || DeviceHelper.isTablet ? ColumnWidthMode.fill : ColumnWidthMode.none,
    allowEditing: allowEditing,
    allowSorting: allowSorting,
    allowSwiping: allowSwiping && allowEditing,
    allowMultiColumnSorting: false,
    navigationMode: GridNavigationMode.cell,
    editingGestureType: EditingGestureType.tap,
    shrinkWrapRows: true,
    showCheckboxColumn: showCheckboxColumn,
    selectionMode: selectionMode ?? SelectionMode.none,
    // columnWidthCalculationRange: ColumnWidthCalculationRange.allRows,
    verticalScrollPhysics: verticalScrollPhysics ?? const AlwaysScrollableScrollPhysics(),
    horizontalScrollPhysics: horizontalScrollPhysics ?? const AlwaysScrollableScrollPhysics(),
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
              decoration: const BoxDecoration(
                color: Colors.white,
                border: BorderDirectional(
                top: BorderSide(width: 1.0, color: Color.fromRGBO(0, 0, 0, 0.26)))
              ),
              alignment: Alignment.center,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(PrimaryColor)));
          } else {
            return SizedBox.fromSize(size: Size.zero);
          }
        }
      );
    } : null,
    gridLinesVisibility: GridLinesVisibility.horizontal,
    endSwipeActionsBuilder: (BuildContext context, DataGridRow row, int rowIndex) {
      return GestureDetector(
        onTap: () {
          onRemove?.call(rowIndex);
        },
        child: Container(
          color: Colors.redAccent,
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(AppLocalizations.of(context)!.text('delete').toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 15)),
              const SizedBox(width: 16.0),
              const Icon(Icons.delete, color: Colors.white, size: 20),
            ],
          ),
        ),
      );
    },
    startSwipeActionsBuilder: (BuildContext context, DataGridRow row, int rowIndex) {
      return GestureDetector(
        onTap: () {
          onEdit?.call(rowIndex);
        },
        child: Container(
          color: Colors.blueAccent,
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Icon(Icons.edit, color: Colors.white, size: 20),
              const SizedBox(width: 16.0),
              Text(AppLocalizations.of(context)!.text('replace').toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 15))
            ],
          ),
        ),
      );
    },
  );
}