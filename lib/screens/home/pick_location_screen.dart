import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:users/models/location/gmp_place_autocomplete.model.dart';
import 'package:users/services/gmp_service/geo_location_from_place_id.service.dart';
import 'package:users/services/gmp_service/predict_similar_places.service.dart';

class PickLocationScreen extends StatelessWidget {
  static const String routeName = '/pick_location';

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
  bool _isLoading = false;
  List<GoogleMapsPlaceAutocomplete> _placePredictions = [];

  @override
  Widget build(BuildContext context) {
    /// [isPortrait = MediaQueryData.orientation == Orientation.portrait]
    /// [axisAlignment: isPortrait ? 0.0 : -1.0], avaiable width > width
    /// [width: isPortrait ? 600 : 500], max width of FSB

    /// Unless [isScrollControlled] is set to true, the expandable body of a
    /// FloatingSearchBar must not have an unbounded height, meaning that
    /// [shrinkWrap] should be set to true on all [Scrollable]s
    /// Read 'Usage with Scrollables' in the doc

    return FloatingSearchBar(
      controller: _controller,

      progress: _isLoading,
      hint: 'Find your location here...',

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
      clearQueryOnClose: true,
      onQueryChanged: (input) async {
        setState(() => _isLoading = true);
        final predictions = await predictSimilarPlaces(input);
        setState(() {
          _isLoading = false;
          _placePredictions = predictions;
        });
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
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 8),
          itemCount: _placePredictions.length,
          itemBuilder: (context, index) => InkWell(
            onTap: () async {
              final location = await geoLocationFromPlaceId(
                  _placePredictions[index].placeId);
              Navigator.pop(context, location);
            },
            child: ListTile(
              title:
                  Text(_placePredictions[index].structuredFormatting.mainText),
              subtitle: Text(
                  _placePredictions[index].structuredFormatting.secondaryText),
              leading: Icon(Icons.place),
            ),
          ),
          separatorBuilder: (_, __) => Divider(thickness: 1),
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
