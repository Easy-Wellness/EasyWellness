import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:recase/recase.dart';
import 'package:users/constants/specialties.dart';
import 'package:users/models/device_location.dart';
import 'package:users/screens/pick_location/pick_location_screen.dart';
import 'package:users/utils/identify_device_location.dart';

class SearchServicesForm extends StatefulWidget {
  @override
  _SearchServicesFormState createState() => _SearchServicesFormState();
}

class _SearchServicesFormState extends State<SearchServicesForm> {
  final _formKey = GlobalKey<FormState>();

  DeviceLocation? _pickedLocation;

  @override
  void initState() {
    super.initState();
    identifyDeviceLocation()
        .then((location) => setState(() => _pickedLocation = location))
        .catchError(print);
  }

  _navigateToGetUserLocation(BuildContext context) async {
    final location =
        await Navigator.pushNamed(context, PickLocationScreen.routeName);
    if (location != null)
      setState(() => _pickedLocation = location as DeviceLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          FormField<String>(
            validator: (value) => value == null || value.isEmpty
                ? 'Please select a specialty'
                : null,
            builder: (fieldState) => DropdownSearch<String>(
              mode: Mode.MENU,
              showSelectedItem: true,
              showClearButton: true,
              items: SPECIALTIES,
              itemAsString: (value) => value.titleCase,
              label: 'Specialty',
              popupItemDisabled: (value) => value == fieldState.value,
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
            height: 4,
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
