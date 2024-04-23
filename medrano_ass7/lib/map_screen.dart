import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

final initialPosition = LatLng(16.388628, 119.893354);
final Set<Marker> markers = {};
var descController = TextEditingController();
late CollectionReference faveplaces = FirebaseFirestore.instance.collection('faveplaces');

class _MapScreenState extends State<MapScreen> {

void addMarker(LatLng p, String desc) {
  setState(() {
    markers.add(
      Marker(
        markerId: MarkerId('${p.latitude}-${p.longitude}'),
        position: LatLng(p.latitude, p.longitude),
        infoWindow: InfoWindow(title: 'Favorite', snippet: desc),
        onTap: () => promptDeleteDialog(p),
      ),
    );
  });
}

void promptDescriptionDialog(LatLng position) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: TextField(
          controller: descController,
          decoration: InputDecoration(hintText: 'Enter description'),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              saveFavoritePlace(position, descController.text);
              addMarker(position, descController.text);
              Navigator.of(context).pop();
              descController.clear();
            },
          ),
        ],
      );
    },
  );
}

void promptDeleteDialog(LatLng position) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Remove Pinned Location'),
        content: Text('Do you want to remove this pinned location?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              deleteFavoritePlace('${position.latitude}-${position.longitude}');
              Navigator.of(context).pop();
            },
            child: Text('Remove'),
          ),
        ],
      );
    },
  );
}

void deleteFavoritePlace(String markerId) async {
  markers.removeWhere((marker) => marker.markerId.value == markerId);
  setState(() {});
  QuerySnapshot querySnapshot = await faveplaces.where('details.markerId', isEqualTo: markerId).get();
  querySnapshot.docs.forEach((doc) {
    doc.reference.delete();
  });
}

void saveFavoritePlace(LatLng position, String description) {
  faveplaces.add({'details': {'latitude': position.latitude, 'longitude': position.longitude, 'description': description, 'markerId': '${position.latitude}-${position.longitude}'}});
}

void getfaveplaces() async {
  QuerySnapshot querySnapshot = await faveplaces.get();
  querySnapshot.docs.forEach((doc) {
    var details = doc['details'];
    if (details != null && details is Map<String, dynamic> && details.containsKey('latitude') && details.containsKey('longitude')) {
      double lat = details['latitude'];
      double lng = details['longitude'];
      LatLng position = LatLng(lat, lng);
      addMarker(position, details['description']);
    } else {
      print('Invalid location data in Firestore document: ${doc.id}');
    }
  });
}

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    getfaveplaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Favorite Places", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: GoogleMap(
          //myLocationEnabled: true,
          //myLocationButtonEnabled: true,
          initialCameraPosition: CameraPosition(target: initialPosition, zoom: 12),
          markers: markers,
          onTap: (position) {
            promptDescriptionDialog(position);
          },
          ),
        ),
    );
  }
}