import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/tables/edit_sfdatagrid.dart';
import 'package:bab/utils/bluetooth.dart';

// External package
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class BluetoothDataTable extends StatefulWidget {
  final Bluetooth bluetooth;
  Widget? title;
  bool allowEditing;
  bool allowSorting;
  bool sort;
  Color? color;
  final void Function(Bluetooth? value)? onChanged;
  BluetoothDataTable({Key? key,
    required this.bluetooth,
    this.title,
    this.allowEditing = true,
    this.allowSorting = false,
    this.sort = false,
    this.color,
    this.onChanged}) : super(key: key);

  @override
  BluetoothDataTableState createState() => BluetoothDataTableState();
}

class BluetoothDataTableState extends State<BluetoothDataTable> with AutomaticKeepAliveClientMixin {
  late BluetoothDataSource _dataSource;
  double dataRowHeight = 30;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _dataSource = BluetoothDataSource(context,
      data: widget.bluetooth.toMap(),
      onChanged: (String key, String? value) {
        widget.bluetooth.set(key, value);
        widget.onChanged?.call(widget.bluetooth);
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: widget.color,
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: SfDataGridTheme(
        data: SfDataGridThemeData(),
        child: EditSfDataGrid(
          context,
          source: _dataSource,
          allowEditing: widget.allowEditing,
          allowSorting: widget.allowSorting,
          allowSwiping: false,
          selectionMode: SelectionMode.single,
          verticalScrollPhysics: const NeverScrollableScrollPhysics(),
          columns: Bluetooth.columns(context: context),
        ),
      )
    );
  }
}

