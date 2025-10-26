class Zone {
  final int id;
  final String name;
  final String description;
  final String distance;
  final bool isOpen;
  final String? imageUrl;
  final String openingHours;
  final double rating;
  final bool favorite;
  final bool saved;

  Zone({
    required this.id,
    required this.name,
    required this.description,
    required this.distance,
    required this.isOpen,
    required this.imageUrl,
    required this.openingHours,
    required this.rating,
    this.favorite = false,
    this.saved = false,
  });

  // Método para JSON
  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      distance: json['distance'],
      isOpen: json["true"],
      imageUrl: json['imageUrl'],
      openingHours: json["12:00 PM"],
      rating: (json['rating'] ?? 0).toDouble(),
      favorite: true,
      saved: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'distance': distance,
      'status': true,
      'imageUrl': imageUrl,
      'rating': rating,
    };
  }
}

List<Zone> listZones = [
  Zone(
    id: 1,
    name: 'nombre zona 1',
    description:
        'description de la zona turistica numero 001 para ver el tamaño y la estructura del card',
    distance: '10 km',
    isOpen: true,
    imageUrl:
        'https://blog.incarail.com/wp-content/uploads/2024/11/Caminata-Hacia-La-Montana-7-Colores-1-105-1.webp',
    openingHours: "24 H",
    rating: 4.5,
    favorite: true,
    saved: false,
  ),
  Zone(
    id: 2,
    name: 'nombre zona 2',
    description: 'description',
    distance: '10 km',
    isOpen: false,
    imageUrl:
        'https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,width=620,height=400,dpr=1/tour_img/486e3c936a1e0cf297b1751e546988911372ced5a7138152af8bd007b86f9161.jpg',
    openingHours: "8:00 - 18:00",
    rating: 4.5,
    favorite: true,
    saved: true,
  ),
  Zone(
    id: 3,
    name: 'nombre zona 3',
    description: 'description',
    distance: '10 km',
    isOpen: true,
    imageUrl:
        'https://www.ytuqueplanes.com/imagenes/fotos/novedades/heroes-pampa-quinua.jpg',
    openingHours: "12 PM",
    rating: 4.5,
    favorite: false,
    saved: true,
  ),
  Zone(
    id: 4,
    name: 'nombre zona 4',
    description: 'description',
    distance: '10 km',
    isOpen: true,
    imageUrl: 'https://www.rcrperu.com/wp-content/uploads/2024/02/SWDSRFE.jpg',
    openingHours: "12 PM",
    rating: 4.5,
    favorite: true,
    saved: false,
  ),
  Zone(
    id: 5,
    name: 'nombre zona 5',
    description: 'description',
    distance: '10 km',
    isOpen: true,
    imageUrl: 'https://imageUrl.com',
    openingHours: "12 PM",
    rating: 4.5,
    favorite: false,
    saved: true,
  ),
];
