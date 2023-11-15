import 'package:flutter/material.dart';

// Internal package
import 'package:bab/utils/constants.dart';

class CustomCheckbox extends StatefulWidget {
  bool checked;
  final void Function(bool value)? onChanged;
  CustomCheckbox ({Key? key, this.checked = false, this.onChanged}) : super(key: key);

  @override
  _CustomCheckboxState createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.checked = !widget.checked;
        });
        widget.onChanged?.call(widget.checked);
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.checked ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(4.0),
          border: widget.checked ? null : Border.all(color: TextGrey, width: 1.5),
        ),
        width: 20,
        height: 20,
        child: widget.checked ? Icon(
          Icons.check,
          size: 20,
          color: Colors.white,
        ) : null,
      ),
    );
  }
}
