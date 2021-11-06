import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:geolocation/geolocation.dart';
//import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController mapController;
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0,0.0));
  //late Position _currentPosition;

  final LatLng _center = const LatLng(45.521563, -122.677433);
  final LatLng _thailand = const LatLng(13.7650836, 100.5379664);
  late var screenWidth ;
  late var screenHeight;
  String _currentAddress = '';
  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();
  final startAddressFocusNode = FocusNode();
  final destinationAddressFocusNode = FocusNode();
  String _startAddress = '';
  String _destinationAddress = '';
  String? _placeDistance;
  Set<Marker> _markers = {};
  late PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();
 // work on Location
   late LocationData currentLocation ;
   var location = Location();
   late Map<String, double> userLocation;

   MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
   //  _getLocationx();
   /*   location.onLocationChanged.listen((value){
        setState(() {
          currentLocation = value;
        });
      }); */
  }
  Future<Map<String,double>?> _getLocationx() async{
    Map<String, double>? currLocation = <String, double>{};
    try{
      currLocation = (await location.getLocation()) as Map<String, double>;
    }catch(e){
      currLocation = null;
    }
    print("location ====>> ${currLocation!["latitude"]}");
    return currLocation;
  }

  Future <LocationData?> getCurrentLocation() async{
    Location location = Location();
    try{
      return await location.getLocation();
    }on PlatformException catch(e){
      if (e.code == 'PERMISSION_DENIED'){
        // permission denied..
      }
      return null ;
    }
  }
  Future _goToMe() async{

  }
  void _incrementCounter() {
    setState(() {
    });
  }
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  button_zoom_out(){
    return ClipOval(
      child: Material(
        color: Colors.blue.shade100,
        child: InkWell(
          splashColor: Colors.blue,
          child: SizedBox(
            width: 50,
            height: 50,
            child: Icon(Icons.add),
          ),
          onTap: (){
            mapController.animateCamera(CameraUpdate.zoomIn());
          },
        ),
      ),
    );
  }
  button_zoom_in(){
    return ClipOval(
      child: Material(
        color: Colors.blue.shade100,
        child: InkWell(
          splashColor: Colors.blue,
          child: SizedBox(
            width: 50,
            height: 50,
            child: Icon(Icons.remove),
          ),
          onTap: (){
            mapController.animateCamera(CameraUpdate.zoomOut());
          },
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required double width,
    required Icon prefixIcon,
    Widget? sufficIcon,
    required Function(String) locationCallback,
}){
      return Container(
        width: width * 0.8,
        child: TextField(
          onChanged: (value){
            locationCallback(value);
          },
          controller: controller,
          focusNode: focusNode,
          decoration: new InputDecoration(
            prefixIcon: prefixIcon,
            suffixIcon: sufficIcon,
            labelText: label,
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide(color: Colors.grey.shade400,width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.blue.shade300,
                width: 2,
              ),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            contentPadding: EdgeInsets.all(15.0),
            hintText: hint,
          ),
        ),
      );
  }

  show_button_upper(){
    return SafeArea(child: Align(
      alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            width: screenWidth * 0.9 ,
            child: Padding(
              padding: const EdgeInsets.only(top: 10,bottom: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:<Widget> [
                  Text('Places',style: TextStyle(fontSize: 20.0),),
                  SizedBox(height: 10,),
                  _textField(
                      controller: startAddressController,
                      focusNode: startAddressFocusNode,
                      label: 'Start',
                      hint: 'Choose starting point',
                      width: screenWidth,
                      prefixIcon: Icon(Icons.looks_one),
                      sufficIcon: IconButton(
                          onPressed: (){
                            startAddressController.text = _currentAddress;
                            _startAddress = _currentAddress;
                          },
                          icon: Icon(Icons.my_location)),
                      locationCallback: (String value){
                        setState(() {
                          _startAddress = value;
                        });
                      },
                  ),
                  SizedBox(height: 10,),
                  _textField(
                      controller:destinationAddressController,
                      focusNode: destinationAddressFocusNode,
                      label: 'Destination',
                      hint: 'Choose destination',
                      width: screenWidth,
                      prefixIcon: Icon(Icons.looks_two),
                      locationCallback: (String value){
                        _destinationAddress = value;
                      },
                  ),
                  SizedBox(height: 10,),
                  Visibility(
                    visible: _placeDistance == null ? false : true ,
                      child: Text('Distance: $_placeDistance km',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(
                      onPressed: (){}, 
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Show Route".toUpperCase(),style: TextStyle(fontSize: 20,color: Colors.white),),
                      )),
                  SizedBox(height: 10,),
                  // Text("Location:" + userLocation["latitude"].toString() ),
                ],
              ),
            ),
          ),
        ),
    ));
  }

  show_current_location(){
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: EdgeInsets.only(right: 10,bottom: 10),
          child: ClipOval(
            child: Material(
              color: Colors.orange.shade100,
              child: InkWell(
                splashColor: Colors.orange,
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(Icons.my_location),
                ),
                onTap: (){
                  mapController.animateCamera(
                      CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(
                        0.0,
                        0.0
                      ),
                        zoom: 18,
                      ))
                  );
                },
              ),
            ),

          ),
        ),
      ),
    );
  }
  void _onMapTypeButtonPressed(){
    setState(() {
      _currentMapType = _currentMapType == MapType.normal ? MapType.satellite : MapType.normal ;
    });
  }
  late LatLng _currentMapPosition = _center;
  void _onCameraMove(CameraPosition position){
    _currentMapPosition = position.target;
  }
  void _onAddMarkerButtonPressed(){
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(_currentMapPosition.toString()),
        position: _currentMapPosition,
        infoWindow: InfoWindow(
          title: 'Nice Place',
          snippet: 'Welcome to Poland',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    screenWidth = width;
    screenHeight = height;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        height: height,
        width: width,
        child: Stack(
          children: <Widget>[
            // Map View
            GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _thailand,
              zoom: 12.0,
            ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              mapType: _currentMapType,  // MapType.normal
              markers: _markers,
              onCameraMove: _onCameraMove,
          ),
            SafeArea(
              // buttond : zoom in , zoom out on middle-left
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      button_zoom_out(),
                      SizedBox(height: 20,),
                      button_zoom_in(),
                    ],
                  ),
                )),
                show_button_upper(),
                show_current_location(),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Align(
                alignment: Alignment.topRight,
                child: FloatingActionButton(
                  onPressed: _onAddMarkerButtonPressed,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.map,size: 30,),
                ),
              ),
            ),
            FloatingActionButton(
               // onPressed: () => print("you have pressed the button!"),
              onPressed: _onMapTypeButtonPressed,
              child: const Icon(Icons.map,size: 30,),
            ),
          ],

        ),

      ),

    );
  }
}
