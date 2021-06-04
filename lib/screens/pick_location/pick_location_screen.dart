import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class PickLocationScreen extends StatelessWidget {
  static String routeName = '/pick_location';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// If [resizeToAvoidBottomInset] is true, the expandable body will first
      /// reduce its size to make room for the on-screen keyboard -> white
      /// background of the [Scaffold] at the bottom -> keyboard pops up.
      resizeToAvoidBottomInset: false,
      body: LocationSearchBar(),
    );
  }
}

class LocationSearchBar extends StatefulWidget {
  @override
  _LocationSearchBarState createState() => _LocationSearchBarState();
}

class _LocationSearchBarState extends State<LocationSearchBar> {
  final _controller = FloatingSearchBarController();

  @override
  Widget build(BuildContext context) {
    /// [isPortrait = MediaQueryData.orientation == Orientation.portrait]
    /// [axisAlignment: isPortrait ? 0.0 : -1.0], avaiable width > width
    /// [width: isPortrait ? 600 : 500], max width of FSB

    /// Unless [isScrollControlled] is set to true, the expandable body of a
    /// FloatingSearchBar must not have an unbounded height, meaning that
    /// [shrinkWrap] should be set to true on all [Scrollable]s

    /// [progress] to show the LinearProgressIndicator inside the card
    return FloatingSearchBar(
      controller: _controller,
      hint: 'Enter your location...',

      /// [bottom] of [scrollPadding] is the distance from the top of
      /// the on-screen keyboard to the bottom of the expandable body
      scrollPadding: const EdgeInsets.only(top: 8, bottom: 16),
      openAxisAlignment: 0.0,
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOutCubic,

      physics: const BouncingScrollPhysics(),
      debounceDelay: const Duration(milliseconds: 800),
      clearQueryOnClose: false,
      onQueryChanged: (query) {
        // Call your model, bloc, controller here.
      },
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.place),
            onPressed: () => _controller.open(),
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],

      /// The expandable body returned by [FloatingSearchBar.builder]
      /// is nested inside a scrollable.
      builder: (context, transition) => Material(
        color: Colors.white,
        elevation: 4.0,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: List.generate(15, (i) => i)
              .map((location) => InkWell(
                    onTap: () => {},
                    child: ListTile(
                      title: Text('$location) white house'),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
