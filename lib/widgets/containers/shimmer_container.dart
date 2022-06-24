import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/constants.dart';

class ShimmerContainer extends StatefulWidget {
  ShimmerContainer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ShimmerContainerState();
  }
}

class _ShimmerContainerState extends State<ShimmerContainer> {

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[];
    double height = MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top;
    for (var i = 0; i < (height / 270).round(); i++) {
      children.add(_buildEmpty());
    }
    return Container(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: children,
      )
    );
  }

  _buildEmpty() {
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              height: 180,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: FillColor
              )
          ),
          const SizedBox(height: 8),
          Container(
              height: 30,
              width: MediaQuery.of(context).size.height / 2.2,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: FillColor
              )
          ),
          const SizedBox(height: 8),
          Container(
              height: 20,
              width: MediaQuery.of(context).size.height / 3,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: FillColor
              )
          ),
        ]
      )
    );
  }
}