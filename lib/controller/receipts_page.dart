import 'package:bb/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:bb/utils/app_localizations.dart';

class ReceiptsPage extends StatefulWidget {
  ReceiptsPage({Key? key}) : super(key: key);
  _ReceiptsPageState createState() => new _ReceiptsPageState();
}

class _SliderIndicatorPainter extends CustomPainter {
  final double position;
  _SliderIndicatorPainter(this.position);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(20, position), 12, Paint()..color = Colors.black);
  }
  @override
  bool shouldRepaint(_SliderIndicatorPainter old) {
    return true;
  }
}

class _ReceiptsPageState extends State<ReceiptsPage> {
  final List<Color> _colors = [
    Color.fromARGB(255, 250, 250, 210),
    Color.fromARGB(255, 250, 250, 160),
    Color.fromARGB(255, 250, 250, 133),
    Color.fromARGB(255, 250, 250, 105),
    Color.fromARGB(255, 250, 250, 78),
    Color.fromARGB(255, 245, 246, 50),
    Color.fromARGB(255, 240, 238, 46),
    Color.fromARGB(255, 235, 228, 47),
    Color.fromARGB(255, 230, 218, 48),
    Color.fromARGB(255, 224, 206, 50),
    Color.fromARGB(255, 219, 196, 51),
    Color.fromARGB(255, 214, 186, 52),
    Color.fromARGB(255, 209, 176, 54),
    Color.fromARGB(255, 204, 166, 55),
    Color.fromARGB(255, 200, 156, 56),
    Color.fromARGB(255, 197, 146, 56),
    Color.fromARGB(255, 195, 139, 56),
    Color.fromARGB(255, 192, 136, 56),
    Color.fromARGB(255, 192, 132, 56),
    Color.fromARGB(255, 192, 128, 56),
    Color.fromARGB(255, 192, 124, 56),
    Color.fromARGB(255, 192, 120, 56),
    Color.fromARGB(255, 192, 116, 56),
    Color.fromARGB(255, 192, 112, 56),
    Color.fromARGB(255, 192, 109, 56),
    Color.fromARGB(255, 188, 105, 56),
    Color.fromARGB(255, 183, 101, 56),
    Color.fromARGB(255, 178, 97, 56),
    Color.fromARGB(255, 171, 94, 55),
    Color.fromARGB(255, 164, 90, 53),
    Color.fromARGB(255, 157, 86, 52),
    Color.fromARGB(255, 149, 82, 51),
    Color.fromARGB(255, 141, 77, 49),
    Color.fromARGB(255, 134, 73, 46),
    Color.fromARGB(255, 127, 69, 43),
    Color.fromARGB(255, 119, 66, 39),
    Color.fromARGB(255, 112, 62, 36),
    Color.fromARGB(255, 105, 58, 31),
    Color.fromARGB(255, 98, 54, 25),
    Color.fromARGB(255, 91, 51, 19),
    Color.fromARGB(255, 84, 47, 13),
    Color.fromARGB(255, 77, 43, 8),
    Color.fromARGB(255, 69, 39, 11),
    Color.fromARGB(255, 62, 36, 13),
    Color.fromARGB(255, 54, 31, 16),
    Color.fromARGB(255, 47, 27, 19),
    Color.fromARGB(255, 39, 24, 21),
    Color.fromARGB(255, 36, 21, 20),
    Color.fromARGB(255, 33, 20, 19),
    Color.fromARGB(255, 31, 18, 17),
    Color.fromARGB(255, 28, 16, 15),
    Color.fromARGB(255, 28, 15, 14),
    Color.fromARGB(255, 23, 13, 12),
    Color.fromARGB(255, 21, 11, 10),
    Color.fromARGB(255, 18, 10, 9),
    Color.fromARGB(255, 16, 8, 7),
    Color.fromARGB(255, 13, 6, 5),
    Color.fromARGB(255, 11, 5, 4),
    Color.fromARGB(255, 9, 3, 2),
    Color.fromARGB(255, 6, 2, 1),
  ];

  double _colorSliderPosition = 0;
  Color? _currentColor;
  RangeValues _ibu = RangeValues(0, 100);
  RangeValues _alcohol = RangeValues(0, 100);

  @override
  Widget build(BuildContext context) {
    SliderThemeData data = SliderTheme.of(context).copyWith(
      activeTrackColor: Colors.white.withOpacity(1),
      inactiveTrackColor: Colors.white.withOpacity(.5),
      trackHeight: 4.0,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
      overlayColor: Colors.white.withOpacity(.4),
      thumbColor: primaryColor.withOpacity(.2),
      activeTickMarkColor: Colors.white,
    );
    SliderThemeData data2 = SliderTheme.of(context).copyWith(
      activeTrackColor: primaryColor.withOpacity(1),
      inactiveTrackColor: primaryColor.withOpacity(.5),
      trackShape: RoundedRectSliderTrackShape(),
      trackHeight: 4.0,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
      thumbColor: primaryColor,
      overlayColor: primaryColor.withAlpha(32),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
      tickMarkShape: RoundSliderTickMarkShape(),
      activeTickMarkColor: primaryColor.withOpacity(1),
      inactiveTickMarkColor: primaryColor.withOpacity(.5),
      valueIndicatorShape: PaddleSliderValueIndicatorShape(),
      valueIndicatorColor: primaryColor,
      valueIndicatorTextStyle: TextStyle(
        color: Colors.white,
      ),
    );
    Decoration decoration = new BoxDecoration(
      borderRadius: new BorderRadius.all(
        Radius.circular((40 * .3)),
      ),
      gradient: new LinearGradient(
          colors: [
            primaryColor.withOpacity(.3),
            primaryColor,
          ],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(1.0, 1.00),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp
      ),
    );
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(AppLocalizations.of(context)!.text('receipts')),
        backgroundColor: primaryColor,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              flex: 3,
              child: Row(
                children: [
                  Expanded(
                    child: Image.asset('assets/images/beer.png')
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragStart: (DragStartDetails details) {
                      print("_-------------------------STARTED DRAG");
                      _colorChangeHandler(details.localPosition.dy);
                    },
                    onHorizontalDragUpdate: (DragUpdateDetails details) {
                      _colorChangeHandler(details.localPosition.dy);
                    },
                    onTapDown: (TapDownDetails details) {
                      _colorChangeHandler(details.localPosition.dy);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: 40,
                        decoration: BoxDecoration(
                          // border: Border.all(width: 1),
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: _colors,
                            begin: Alignment.topCenter, end: Alignment.bottomCenter),
                        ),
                        child: CustomPaint(
                          painter: _SliderIndicatorPainter(_colorSliderPosition),
                        ),
                      )
                    ),
                  )
                ]
              )
            ),
            Flexible(
              flex: 1,
              child:  Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:  [
                    Container(
                      height: 40,
                      // decoration: decoration,
                      child: SliderTheme(
                        data: data2,
                        child: SfRangeSlider(
                          values: _ibu,
                          min: 0,
                          max: 100,
                          onChanged: (value) {
                            setState(() {
                              _ibu = value;
                            });
                          },
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      // decoration: decoration,
                      child: SliderTheme(
                        data: data2,
                        child: RangeSlider(
                          values: _alcohol,
                          min: 0,
                          max: 100,
                          onChanged: (value) {
                            setState(() {
                              _alcohol = value;
                            });
                          },
                        ),
                      ),
                    )
                  ]
                )
              )
            )
          ],
        )
      )
    );
  }

  _colorChangeHandler(double position) {
    print("New pos: $position");
    setState(() {
      _colorSliderPosition = position;
      _currentColor = _calculateSelectedColor(_colorSliderPosition);
    });
  }

  Color? _calculateSelectedColor(double position) {
    //determine color
    double positionInColorArray = (position * (_colors.length - 1));
    print(positionInColorArray);
    int index = positionInColorArray.truncate();
    print(index);
    /*
    double remainder = positionInColorArray - index;
    if (remainder == 0.0) {
      _currentColor = _colors[index];
    } else {
      //calculate new color
      int redValue = _colors[index].red == _colors[index + 1].red
          ? _colors[index].red
          : (_colors[index].red +
          (_colors[index + 1].red - _colors[index].red) * remainder)
          .round();
      int greenValue = _colors[index].green == _colors[index + 1].green
          ? _colors[index].green
          : (_colors[index].green +
          (_colors[index + 1].green - _colors[index].green) * remainder)
          .round();
      int blueValue = _colors[index].blue == _colors[index + 1].blue
          ? _colors[index].blue
          : (_colors[index].blue +
          (_colors[index + 1].blue - _colors[index].blue) * remainder)
          .round();
      _currentColor = Color.fromARGB(255, redValue, greenValue, blueValue);
    }
    */
    return _currentColor;
  }
}

