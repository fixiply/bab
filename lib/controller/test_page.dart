import 'package:bab/helpers/device_helper.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TestPage extends StatefulWidget {
@override
_TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Employee> employees = <Employee>[];

  late EmployeeDataSource employeeDataSource;

  @override
  void initState() {
    super.initState();
    employees= getEmployees();
    employeeDataSource = EmployeeDataSource(employees: employees);
  }

  List<Employee> getEmployees() {
    return[
      Employee(10001, 'James', 'Project Lead', 20000),
      Employee(10002, 'Kathryn', 'Manager', 30000),
      Employee(10003, 'Lara', 'Developer', 15000),
      Employee(10004, 'Michael', 'Designer', 15000),
      Employee(10005, 'Martin', 'Developer', 15000),
      Employee(10006, 'Newberry', 'Developer', 15000),
      Employee(10007, 'Balnc', 'Developer', 15000),
      Employee(10008, 'Perry', 'Developer', 15000),
      Employee(10009, 'Gable', 'Developer', 15000),
      Employee(10010, 'Grimes', 'Developer', 15000)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body:  SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child:  Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Table 1'),
                    Flexible(
                      child: FormField(
                        builder: (FormFieldState<int> state) {
                          return SfDataGrid(
                            source: employeeDataSource,
                            allowEditing: true,
                            navigationMode: GridNavigationMode.cell,
                            selectionMode: SelectionMode.single,
                            columnWidthMode: DeviceHelper.isDesktop || DeviceHelper.isTablet ? ColumnWidthMode.fill : ColumnWidthMode.none,
                            columns: <GridColumn>[
                              GridColumn(
                                columnName: 'id',
                                label: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  alignment: Alignment.centerRight,
                                  child: Text('ID',))),
                              GridColumn(
                                allowEditing: true,
                                columnName: 'name',
                                label: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  alignment: Alignment.centerLeft,
                                  child: Text('Name'))),
                              GridColumn(
                                columnName: 'designation',
                                width: 120,
                                label: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  alignment: Alignment.centerLeft,
                                  child: Text('Designation'))),
                              GridColumn(
                                columnName: 'salary',
                                label: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  alignment: Alignment.centerRight,
                                  child: Text('Salary'))),
                            ],
                          );
                        }
                      ),
                    ),
                  ]
                )
              ),
              const SizedBox(height: 10),
              Container(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Table 2'),
                        Flexible(
                          child: FormField(
                              builder: (FormFieldState<int> state) {
                                return SfDataGrid(
                                  source: employeeDataSource,
                                  allowEditing: true,
                                  navigationMode: GridNavigationMode.cell,
                                  selectionMode: SelectionMode.single,
                                  columnWidthMode: DeviceHelper.isDesktop || DeviceHelper.isTablet ? ColumnWidthMode.fill : ColumnWidthMode.none,
                                  columns: <GridColumn>[
                                    GridColumn(
                                        columnName: 'id',
                                        label: Container(
                                          padding: const EdgeInsets.all(16.0),
                                          alignment: Alignment.centerRight,
                                          child: Text('ID'))),
                                    GridColumn(
                                        allowEditing: true,
                                        columnName: 'name',
                                        label: Container(
                                          padding: const EdgeInsets.all(16.0),
                                          alignment: Alignment.centerLeft,
                                          child: Text('Name'))),
                                    GridColumn(
                                        columnName: 'designation',
                                        width: 120,
                                        label: Container(
                                          padding: const EdgeInsets.all(16.0),
                                          alignment: Alignment.centerLeft,
                                          child: Text('Designation'))),
                                    GridColumn(
                                        columnName: 'salary',
                                        label: Container(
                                          padding: const EdgeInsets.all(16.0),
                                          alignment: Alignment.centerRight,
                                          child: Text('Salary'))),
                                  ],
                                );
                              }
                          ),
                        ),
                      ]
                  )
              ),
            ]
          )
        )
      )
    );
  }
}

class Employee {
  Employee(this.id, this.name, this.designation, this.salary);
  final int id;
  final String name;
  final String designation;
  final int salary;
}

class EmployeeDataSource extends DataGridSource {
  EmployeeDataSource({required List<Employee> employees}) {
    _employees = employees.map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<int>(columnName: 'id', value: e.id),
      DataGridCell<String>(columnName: 'name', value: e.name),
      DataGridCell<String>(columnName: 'designation', value: e.designation),
      DataGridCell<int>(columnName: 'salary', value: e.salary),
    ])).toList();
  }

  dynamic newCellValue;
  List<DataGridRow>  _employees = [];

  @override
  List<DataGridRow> get rows =>  _employees;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          alignment: (dataGridCell.columnName == 'id' || dataGridCell.columnName == 'salary')
              ? Alignment.centerRight
              : Alignment.centerLeft,
          padding: const EdgeInsets.all(16.0),
          child: Text(dataGridCell.value.toString()),
        );
      }).toList());
  }

  @override
  Widget? buildEditWidget(DataGridRow dataGridRow,
      RowColumnIndex rowColumnIndex, GridColumn column, CellSubmit submitCell) {
    // Text going to display on editable widget
    final String displayText = dataGridRow.getCells().firstWhere((DataGridCell dataGridCell) =>
    dataGridCell.columnName == column.columnName).value?.toString() ?? '';

    // The new cell value must be reset.
    // To avoid committing the [DataGridCell] value that was previously edited
    // into the current non-modified [DataGridCell].
    newCellValue = null;

    return _buildTextFieldWidget(displayText, column, submitCell);
  }

  @override
  Future<void> onCellSubmit(DataGridRow dataGridRow,
      RowColumnIndex rowColumnIndex, GridColumn column) async {
    final dynamic oldValue = dataGridRow.getCells().firstWhere((DataGridCell dataGridCell) =>
    dataGridCell.columnName == column.columnName).value ?? '';

    final int dataRowIndex = _employees.indexOf(dataGridRow);

    if (newCellValue == null || oldValue == newCellValue) {
      return;
    }

  }

  Widget _buildTextFieldWidget(String displayText, GridColumn column, CellSubmit submitCell) {
    final bool isTextAlignRight =
        column.columnName == 'id' || column.columnName == 'salary';

    final bool isNumericKeyBoardType =
        column.columnName == 'id' || column.columnName == 'salary';

    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment:
      isTextAlignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: TextField(
        autofocus: true,
        controller: TextEditingController()..text = displayText,
        textAlign: isTextAlignRight ? TextAlign.right : TextAlign.left,
        autocorrect: false,
        decoration: const InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 16.0),
            focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black))),
        keyboardType:
        isNumericKeyBoardType ? TextInputType.number : TextInputType.text,
        onChanged: (String value) {
          if (value.isNotEmpty) {
            if (isNumericKeyBoardType) {
              newCellValue = column.columnName == 'salary'
                  ? double.parse(value)
                  : int.parse(value);
            } else {
              newCellValue = value;
            }
          } else {
            newCellValue = null;
          }
        },
        onSubmitted: (String value) {
          /// Call [CellSubmit] callback to fire the canSubmitCell and
          /// onCellSubmit to commit the new value in single place.
          submitCell();
        },
      ),
    );
  }
}
