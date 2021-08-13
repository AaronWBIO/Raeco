class util {
  final List<Map<String, dynamic>> _estados = [
    {
      "Estado": "Aguascalientes",
      "Capital": "Aguascalientes",
      "lat": "21.88234",
      "lon": "-102.28259"
    },
    {
      "Estado": "Baja California",
      "Capital": "Mexicali",
      "lat": "32.62781",
      "lon": "-115.45446"
    },
    {
      "Estado": "Baja California Sur",
      "Capital": "La Paz",
      "lat": "24.14437",
      "lon": "-110.3005"
    },
    {
      "Estado": "Campeche",
      "Capital": "Campeche",
      "lat": "19.84386",
      "lon": "-90.52554"
    },
    {
      "Estado": "Chiapas",
      "Capital": "Tuxtla Gutierrez",
      "lat": "16.75973",
      "lon": "-93.11308"
    },
    {
      "Estado": "Chihuahua",
      "Capital": "Chihuahua",
      "lat": "28.63528",
      "lon": "-106.08889"
    },
    {
      "Estado": "Ciudad de México",
      "Capital": "Ciudad de México",
      "lat": "19.42847",
      "lon": "-99.12766"
    },
    {
      "Estado": "Coahuila de Zaragoza",
      "Capital": "Saltillo",
      "lat": "25.42321",
      "lon": "-101.0053"
    },
    {
      "Estado": "Colima",
      "Capital": "Colima",
      "lat": "19.24997",
      "lon": "-103.72714"
    },
    {
      "Estado": "Durango",
      "Capital": "Victoria de Durango",
      "lat": "24.02032",
      "lon": "-104.65756"
    },
    {
      "Estado": "Estado de México",
      "Capital": "Toluca",
      "lat": "19.28786",
      "lon": "-99.65324"
    },
    {
      "Estado": "Guanajuato",
      "Capital": "Guanajuato",
      "lat": "21.018535",
      "lon": "-101.259941"
    },
    {
      "Estado": "Guerrero",
      "Capital": "Chilpancingo",
      "lat": "17.5506",
      "lon": "-99.50578"
    },
    {
      "Estado": "Hidalgo",
      "Capital": "Pachuca",
      "lat": "20.11697",
      "lon": "-98.73329"
    },
    {
      "Estado": "Jalisco",
      "Capital": "Guadalajara",
      "lat": "20.66682",
      "lon": "-103.39182"
    },
    {
      "Estado": "Michoacán de Ocampo",
      "Capital": "Morelia",
      "lat": "19.70078",
      "lon": "-101.18443"
    },
    {
      "Estado": "Morelos",
      "Capital": "Cuernavaca",
      "lat": "18.9261",
      "lon": "-99.23075"
    },
    {
      "Estado": "Nayarit",
      "Capital": "Tepic",
      "lat": "21.50951",
      "lon": "-104.89569"
    },
    {
      "Estado": "Nuevo León",
      "Capital": "Monterrey",
      "lat": "25.67507",
      "lon": "-100.31847"
    },
    {
      "Estado": "Oaxaca",
      "Capital": "Oaxaca",
      "lat": "17.06542",
      "lon": "-96.72365"
    },
    {
      "Estado": "Puebla",
      "Capital": "Puebla",
      "lat": "19.03793",
      "lon": "-98.20346"
    },
    {
      "Estado": "Querétaro",
      "Capital": "Querétaro",
      "lat": "20.58806",
      "lon": "-100.38806"
    },
    {
      "Estado": "Quintana Roo",
      "Capital": "Chetumal",
      "lat": "18.51413",
      "lon": "-88.30381"
    },
    {
      "Estado": "San Luis Potosí",
      "Capital": "San Luis Potosí",
      "lat": "32.45612",
      "lon": "-114.77186"
    },
    {
      "Estado": "Sinaloa",
      "Capital": "Culiacan",
      "lat": "24.785019",
      "lon": "-107.402479"
    },
    {
      "Estado": "Sonora",
      "Capital": "Hermosillo",
      "lat": "29.1026",
      "lon": "-110.97732"
    },
    {
      "Estado": "Tabasco",
      "Capital": "Villahermosa",
      "lat": "17.98689",
      "lon": "-92.93028"
    },
    {
      "Estado": "Tamaulipas",
      "Capital": "Ciudad Victoria",
      "lat": "23.74174",
      "lon": "-99.14599"
    },
    {
      "Estado": "Tlaxcala",
      "Capital": "Tlaxcala",
      "lat": "19.31905",
      "lon": "-98.19982"
    },
    {
      "Estado": "Veracruz de Ignacio de la Llave",
      "Capital": "Xalapa",
      "lat": "19.53124",
      "lon": "-96.91589"
    },
    {
      "Estado": "Yucatán",
      "Capital": "Mérida",
      "lat": "20.97537",
      "lon": "-89.61696"
    },
    {
      "Estado": "Zacatecas",
      "Capital": "Zacatecas",
      "lat": "22.76843",
      "lon": "-102.58141"
    }
  ];

  String getGPSPoint(String nombre) {
    var gps = "";

    for (var i = 0; i < _estados.length; i++) {
      if (_estados[i]['Estado'] == nombre) {
        gps = _estados[i]['lat'] + "," + _estados[i]['lon'];
      }
    }

    return gps;
  }

  static bool isValidEmail(String email) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }

  static String capitalize(String cadena) {
    String result = "";
    result = cadena.trim().toLowerCase();
    result = result[0].toUpperCase() + result.substring(1);
    return result;
  }

  static String dateformat(date) {
    String result = "";
    List<String> temp = date.split("-");
    result = temp[2] + "/" + temp[1] + "/" + temp[0];
    return result;
  }

  static String getMapStyle() {
    String mapStyle = '''
  [
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#BAE0C6"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#9BB2E6"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9BB2E6"
      }
    ]
  }
]
  ''';
    return mapStyle;
  }
}
