enum ImageryType {
  tms,
  wms,
  bing,
}

enum ImageryCategory {
  photo,
  map,
  other,
}

class Imagery {
  final String id;
  final ImageryType type;
  final ImageryCategory? category;
  final String name;
  final String? icon;
  final String? attribution;
  final String url;
  final int minZoom;
  final int maxZoom;
  final bool best;
  final int tileSize;
  final bool wms4326;

  const Imagery({
    required this.id,
    required this.type,
    this.category,
    required this.name,
    this.icon,
    this.attribution,
    required this.url,
    int? minZoom,
    int? maxZoom,
    this.best = false,
    this.tileSize = 256,
    this.wms4326 = false,
  })  : minZoom = minZoom ?? 0,
        maxZoom = maxZoom ?? 20;

  factory Imagery.fromJson(Map<String, dynamic> data) {
    return Imagery(
      id: data['id'],
      type: data['is_wms'] == 1 ? ImageryType.wms : ImageryType.tms,
      name: data['name'],
      attribution: data['attribution'],
      icon: data['icon'],
      url: data['url'],
      minZoom: data['min_zoom'],
      maxZoom: data['max_zoom'],
      best: data['best'] == 1,
      tileSize: data['tile_size'] ?? 256,
      wms4326: data['wms_4326'] == 1,
    );
  }

  Imagery copyWith({String? url, int? tileSize, String? attribution, int? minZoom, int? maxZoom}) {
    return Imagery(
      id: id,
      type: type,
      name: name,
      attribution: attribution ?? this.attribution,
      icon: icon,
      url: url ?? this.url,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      best: best,
      tileSize: tileSize ?? this.tileSize,
    );
  }
}
