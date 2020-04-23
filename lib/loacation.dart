class Location {
  String name;
  double lat;
  double lon;

  Location(this.name, this.lat, this.lon);
  Map<String, dynamic> toJson() => {
        'name': name,
        'lat': lat,
        'lon': lon,
      };
}
