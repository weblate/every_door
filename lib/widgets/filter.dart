import 'package:every_door/constants.dart';
import 'package:every_door/widgets/radio_field.dart';
import 'package:every_door/models/address.dart';
import 'package:every_door/models/filter.dart';
import 'package:every_door/models/floor.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/providers/poi_filter.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PoiFilterPane extends ConsumerStatefulWidget {
  final LatLng location;

  const PoiFilterPane(this.location);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PoiFilterPaneState();
}

class _PoiFilterPaneState extends ConsumerState<PoiFilterPane> {
  List<StreetAddress> nearestAddresses = [];
  List<Floor> floors = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      loadAddresses();
      updateFloors();
    });
  }

  loadAddresses() async {
    final osmData = ref.read(osmDataProvider);
    final addr = await osmData.getAddressesAround(widget.location, limit: 3);
    setState(() {
      nearestAddresses = addr;
    });
  }

  updateFloors() async {
    final filter = ref.watch(poiFilterProvider);
    final osmData = ref.read(osmDataProvider);
    List<Floor> floors;
    try {
      floors = await osmData.getFloorsAround(widget.location, filter.address);
    } on Exception catch (e) {
      print(e);
      floors = [];
    }
    if ((filter.floor?.isNotEmpty ?? false) && !floors.contains(filter.floor)) {
      ref.read(poiFilterProvider.state).state =
          filter.copyWith(floor: PoiFilter.nullFloor);
    }
    setState(() {
      this.floors = floors;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(poiFilterProvider);
    if (nearestAddresses.isEmpty) {
      return Text('No addresses nearby');
    }

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter by address:', style: kFieldTextStyle),
          RadioField(
            options:
                nearestAddresses.map((e) => e.toString()).toList() + ['empty'],
            value: (filter.address?.isEmpty ?? false)
                ? 'empty'
                : filter.address?.toString(),
            onChange: (value) {
              if (value == null) {
                // On clear, clearing all fields.
                ref.read(poiFilterProvider.state).state = filter.copyWith(
                  address: PoiFilter.nullAddress,
                  floor: PoiFilter.nullFloor,
                );
              } else if (value == 'empty') {
                ref.read(poiFilterProvider.state).state =
                    filter.copyWith(address: StreetAddress.empty);
              } else {
                final addr = nearestAddresses
                    .firstWhere((element) => element.toString() == value);
                // Clearing floors when the address has changed.
                ref.read(poiFilterProvider.state).state = filter.copyWith(
                  address: addr,
                  floor: PoiFilter.nullFloor,
                );
              }
              updateFloors();
            },
          ),
          SizedBox(height: 10.0),
          Text('Filter by floor:', style: kFieldTextStyle),
          RadioField(
            options: floors.map((e) => e.string).toList() + ['empty'],
            value: (filter.floor?.isEmpty ?? false)
                ? 'empty'
                : filter.floor?.string,
            onChange: (value) {
              Floor newFloor;
              if (value == null) {
                newFloor = PoiFilter.nullFloor;
              } else if (value == 'empty') {
                newFloor = Floor.empty;
              } else {
                newFloor = floors.firstWhere((e) => e.string == value);
              }
              ref.read(poiFilterProvider.state).state =
                  filter.copyWith(floor: newFloor);
            },
          ),
          SizedBox(height: 10.0),
          SwitchListTile(
            value: filter.notChecked,
            onChanged: (value) {
              ref.read(poiFilterProvider.state).state =
                  filter.copyWith(notChecked: value);
            },
            title: Text('Only non-confirmed amenities', style: kFieldTextStyle),
          ),
        ],
      ),
    );
  }
}
