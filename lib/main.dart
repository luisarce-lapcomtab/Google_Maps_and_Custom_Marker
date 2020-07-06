import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as lct;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LatLng currentLocation = LatLng(-2.131910, -79.940287);
  GoogleMapController _mapController;
  lct.Location location;
  BitmapDescriptor icon;

 @override
  void initState(){
    getIcons();
    requestPerms();
    super.initState();
  }

  getLocation() async{
    var currentLocation = await location.getLocation();
    locationUpdate(currentLocation);
  }

  locationUpdate(currentLocation){
    if(currentLocation!= null){
      setState(() {
        this.currentLocation =
          LatLng(currentLocation.latitude, currentLocation.longitude);
        this._mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: this.currentLocation, zoom: 14),
        )); 
      _createMarker(); 
      });
    }
  }


void _onMapCreated(GoogleMapController controller){
  _mapController = controller;
}

changedLocation(){
  location.onLocationChanged.listen((lct.LocationData cLoc) {
    if(cLoc != null) locationUpdate(cLoc);
   });
}

// Pedir permiso de Ubicacion
  requestPerms() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.locationAlways].request();

    var status = statuses[Permission.locationAlways];
    if (status == PermissionStatus.denied) {
      requestPerms();
    } else {
      gpsAnable();
    }
  }

//Activar GPS
  gpsAnable() async {
    location = lct.Location();
    bool statusResult = await location.requestService();

    if (!statusResult) {
      gpsAnable();
    } else {
      getLocation();
      changedLocation();
    }
  }

// icon Marker
  getIcons() async {
    var icon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 3.0),
        "assets/images/markeruser.png");
    setState(() {
      this.icon = icon;
    });
  }

//crear Marker
  Set<Marker> _createMarker() {
    var marker = Set<Marker>();

    marker.add(Marker(
      markerId: MarkerId("MarkerCurrent"),
      position: currentLocation,
      icon: icon,
      infoWindow: InfoWindow(
        title: "Mi Ubicacion",
        snippet: "Lat ${currentLocation.latitude} - Lng ${currentLocation.longitude} ",
      ),
      draggable: true,
      onDragEnd: onDragEnd,
    ));

    return marker;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Maps"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentLocation,
              zoom: 14.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            minMaxZoomPreference: MinMaxZoomPreference(12, 18.6),
            markers: _createMarker(),
            onMapCreated: _onMapCreated,
          ),
        ],
      ),
    );
  }

  onDragEnd(LatLng position) {
    print("nueva posicion $position");
  }
}
