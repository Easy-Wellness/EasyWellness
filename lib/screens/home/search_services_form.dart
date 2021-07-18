import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:recase/recase.dart';
import 'package:users/constants/specialties.dart';
import 'package:users/screens/pick_location/pick_location_screen.dart';
import 'package:users/models/location/geo_location.model.dart';
import 'package:users/services/location_service/identify_device_current_location.service.dart';

class SearchServicesForm extends StatefulWidget {
  @override
  _SearchServicesFormState createState() => _SearchServicesFormState();
}

class _SearchServicesFormState extends State<SearchServicesForm> {
  final _formKey = GlobalKey<FormState>();

  GeoLocation? _pickedLocation;

  @override
  void initState() {
    super.initState();
    identifyDeviceCurrentLocation()
        .then((location) => setState(() => _pickedLocation = location))
        .catchError(print);
  }

  _navigateToGetUserLocation(BuildContext context) async {
    final location =
        await Navigator.pushNamed(context, PickLocationScreen.routeName);
    if (location != null)
      setState(() => _pickedLocation = location as GeoLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        children: <Widget>[
          FormField<String>(
            builder: (fieldState) => DropdownSearch<String>(
              validator: (value) =>
                  value == null ? 'Please select a specialty' : null,
              mode: Mode.MENU,
              showSelectedItem: true,
              showClearButton: true,
              items: SPECIALTIES,
              itemAsString: (value) => value.titleCase,
              popupItemDisabled: (value) => value == fieldState.value,
              popupSafeArea: const PopupSafeArea(bottom: true),
              scrollbarProps: ScrollbarProps(
                interactive: true,
              ),
              label: 'Specialty*',
              dropdownSearchDecoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                border: OutlineInputBorder(),
                helperText: '',
              ),
              onChanged: (value) => fieldState.didChange(value),
              popupItemBuilder: (_, value, isSelected) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(0),
                    leading: SizedBox(
                      height: 32,
                      width: 32,
                      child: SvgPicture.asset(
                        'assets/icons/specialty_${value.snakeCase}_icon.svg',
                      ),
                    ),
                    title: Text(
                      value.titleCase,
                      style: isSelected
                          ? TextStyle(
                              color: Theme.of(context).colorScheme.primary)
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 8,
          ),
          TextButton(
            onPressed: () => _navigateToGetUserLocation(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 330,
                  child: Text(
                    _pickedLocation?.address ??
                        'Cannot access your location, tap here to enter',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                Icon(Icons.keyboard_arrow_right),
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          ElevatedButton.icon(
            onPressed: _pickedLocation != null
                ? () => {if (_formKey.currentState!.validate()) {}}
                : null,
            icon: Icon(Icons.search_sharp),
            label: Text('Search'),
          )
        ],
      ),
    );
  }
}
