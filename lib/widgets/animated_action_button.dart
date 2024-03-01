import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AnimatedActionButton extends StatefulWidget {
  final String title;
  final Icon icon;
  final void Function() onPressed;
  final int shrinkDuration;
  final String? tag;
  final Color? backgroundColor;

  AnimatedActionButton({required this.title, required this.icon, required this.onPressed, this.shrinkDuration = 5, this.tag, this.backgroundColor});

  @override
  State<StatefulWidget> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<AnimatedActionButton> {
  bool extended = true;

  @override
  void initState() {
    super.initState();
      Future.delayed(Duration(seconds: widget.shrinkDuration), () {
        _shrink();
      });
  }

  _shrink() {
    if (!mounted) return;
    setState(() {
      extended = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: widget.tag ?? const Uuid().v1(),
      onPressed: widget.onPressed,
      foregroundColor: Colors.white,
      backgroundColor: widget.backgroundColor ?? Theme.of(context).primaryColor,
      tooltip: widget.title,
      extendedPadding: const EdgeInsetsDirectional.only(start: 12.0, end: 12.0),
      label: AnimatedSwitcher(
        duration: const Duration(seconds: 1),
        transitionBuilder: (Widget child, Animation<double> animation) =>
          FadeTransition(
            opacity: animation,
            child: SizeTransition(child: child,
              sizeFactor: animation,
              axis: Axis.horizontal,
            )
          ),
        child: extended ? Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: widget.icon,
            ),
            Text(widget.title)
          ],
        ) : widget.icon,
      )
    );
  }
}
