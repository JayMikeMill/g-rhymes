import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ScrollableRowWithArrows extends StatefulWidget {
  final List<Widget> children;
  final double scrollAmount;
  final EdgeInsets padding;
  const ScrollableRowWithArrows({
    super.key,
    required this.children,
    this.scrollAmount = 100,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<ScrollableRowWithArrows> createState() => _ScrollableRowWithArrowsState();
}

class _ScrollableRowWithArrowsState extends State<ScrollableRowWithArrows> {
  final ScrollController _controller = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = true;

  final double _arrowWidth = 20; // width of the arrows

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateScrollState);
  }

  void _updateScrollState() {
    final maxScroll = _controller.position.maxScrollExtent;
    final offset = _controller.offset;

    setState(() {
      _canScrollLeft = offset > 0;
      _canScrollRight = offset < maxScroll;
    });
  }

  void _scrollLeft() {
    _controller.animateTo(
      (_controller.offset - widget.scrollAmount).clamp(0.0, _controller.position.maxScrollExtent),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _controller.animateTo(
      (_controller.offset + widget.scrollAmount).clamp(0.0, _controller.position.maxScrollExtent),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_updateScrollState);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _controller,
          child: Padding(
            padding: widget.padding,
            child: Row(children: widget.children),
          ),
        ),

        // Left arrow
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: AnimatedOpacity(
            opacity: _canScrollLeft ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: GestureDetector(
              onTap: _scrollLeft,
              child: Container(
                width: _arrowWidth,
                alignment: Alignment.centerLeft,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white,
                      Colors.white10,
                    ],
                    stops: [0.3, .7],
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.black.withAlpha(120),
                  size: 20,
                ),
              ),
            ),
          ),
        ),

        // Right arrow
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: AnimatedOpacity(
            opacity: _canScrollRight ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: GestureDetector(
              onTap: _scrollRight,
              child: Container(
                width: _arrowWidth,
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Colors.white,
                      Colors.white10,
                    ],
                    stops: [0.3, .7],
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.black.withAlpha(120),
                  size: 20,
                ),
              ),
            ),
          ),
        ),

      ],
    );
  }
}
