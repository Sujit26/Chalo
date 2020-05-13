class LocationLatLng {
  String name;
  double lat;
  double lon;

  LocationLatLng(this.name, this.lat, this.lon);
  Map<String, dynamic> toJson() => {
        'name': name,
        'lat': lat,
        'lon': lon,
      };
}
