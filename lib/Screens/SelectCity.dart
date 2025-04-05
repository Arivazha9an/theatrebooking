import 'package:flutter/material.dart';
import 'package:ticket_booking/Auth/Register.dart';


class SelectCity extends StatefulWidget {
  const SelectCity({super.key, required this.phone});
  final String phone;

  @override
  _SelectCityState createState() => _SelectCityState();
}

class _SelectCityState extends State<SelectCity> {
  final List<Map<String, String>> allDistricts = [
  {
    "name": "Ariyalur",
    "image": "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Gangaikondacholapuram_Temple_4.jpg/1200px-Gangaikondacholapuram_Temple_4.jpg"
  },
  {
    "name": "Chengalpattu",
    "image": "https://upload.wikimedia.org/wikipedia/commons/3/35/Chengalpat_lake.jpg"
  },
  {
    "name": "Chennai",
    "image": "https://upload.wikimedia.org/wikipedia/commons/3/32/Chennai_Central.jpg"
  },
  {
    "name": "Coimbatore",
    "image": "https://s7ap1.scene7.com/is/image/incredibleindia/adiyogi-shiva-statue-coimbatore-tamil-nadu-city-1-hero?qlt=82&ts=1726674526739"
  },
  {
    "name": "Cuddalore",
    "image": "https://www.tamilnadutourism.tn.gov.in/img/pages/large-desktop/cuddalore-1673075322_007060c46155bfd24391.webp"
  },
  {
    "name": "Dharmapuri",
    "image": "https://media-cdn.tripadvisor.com/media/photo-c/1280x250/07/43/3d/9e/hogenakkal-falls.jpg"
  },
  {
    "name": "Dindigul",
    "image": "https://upload.wikimedia.org/wikipedia/commons/f/fb/Dindigul_Fort2.JPG"
  },
  {
    "name": "Erode",
    "image": "https://www.shutterstock.com/image-photo/bhavani-sangameshwarar-temple-erode-tamil-nadu-2186062815"
  },
  {
    "name": "Kallakurichi",
    "image": "https://www.shutterstock.com/image-photo/kalvarayan-hills-kallakurichi-tamil-nadu-2186062815"
  },
  {
    "name": "Kancheepuram",
    "image": "https://www.shutterstock.com/image-photo/kamakshi-amman-temple-kancheepuram-tamil-nadu-2186062815"
  },
  {
    "name": "Kanniyakumari",
    "image": "https://www.shutterstock.com/image-photo/vivekananda-rock-memorial-kanniyakumari-tamil-nadu-2186062815"
  },
  {
    "name": "Karur",
    "image": "https://www.shutterstock.com/image-photo/pasupathieswarar-temple-karur-tamil-nadu-2186062815"
  },
  {
    "name": "Krishnagiri",
    "image": "https://www.shutterstock.com/image-photo/krishnagiri-dam-tamil-nadu-2186062815"
  },
  {
    "name": "Madurai",
    "image": "https://www.shutterstock.com/image-photo/meenakshi-amman-temple-madurai-tamil-nadu-2186062815"
  },
  {
    "name": "Mayiladuthurai",
    "image": "https://www.shutterstock.com/image-photo/vaitheeswaran-koil-mayiladuthurai-tamil-nadu-2186062815"
  },
  {
    "name": "Nagapattinam",
    "image": "https://www.shutterstock.com/image-photo/nagore-dargah-nagapattinam-tamil-nadu-2186062815"
  },
  {
    "name": "Namakkal",
    "image": "https://www.shutterstock.com/image-photo/namakkal-anjaneyar-temple-tamil-nadu-2186062815"
  },
  {
    "name": "Nilgiris",
    "image": "https://www.shutterstock.com/image-photo/ooty-botanical-gardens-nilgiris-tamil-nadu-2186062815"
  },
  {
    "name": "Perambalur",
    "image": "https://www.shutterstock.com/image-photo/ranjankudi-fort-perambalur-tamil-nadu-2186062815"
  },
  {
    "name": "Pudukkottai",
    "image": "https://www.shutterstock.com/image-photo/thirumayam-fort-pudukkottai-tamil-nadu-2186062815"
  },
  {
    "name": "Ramanathapuram",
    "image": "https://www.shutterstock.com/image-photo/rameswaram-temple-ramanathapuram-tamil-nadu-2186062815"
  },
  {
    "name": "Salem",
    "image": "https://www.shutterstock.com/image-photo/yercaud-lake-salem-tamil-nadu-2186062815"
  },
  {
    "name": "Sivaganga",
    "image": "https://www.shutterstock.com/image-photo/karaikudi-mansions-sivaganga-tamil-nadu-2186062815"
  },
  {
    "name": "Tenkasi",
    "image": "https://www.shutterstock.com/image-photo/courtallam-falls-tenkasi-tamil-nadu-2186062815"
  },
  {
    "name": "Thanjavur",
    "image": "https://www.shutterstock.com/image-photo/brihadeeswarar-temple-thanjavur-tamil-nadu-2186062815"
  },
  {
    "name": "Thoothukudi",
    "image": "https://www.shutterstock.com/image-photo/our-lady-snows-basilica-thoothukudi-tamil-nadu-2186062815"
  },
  {
    "name": "Tiruchirappalli",
    "image": "https://www.shutterstock.com/image-photo/rockfort-temple-tiruchirappalli-tamil-nadu-2186062815"
  },
  {
    "name": "Tirunelveli",
    "image": "https://www.shutterstock.com/image-photo/nellaiappar-temple-tirunelveli-tamil-nadu-2186062815"
  }
];

  List<Map<String, String>> filteredDistricts = [];

  @override
  void initState() {
    super.initState();
    filteredDistricts = allDistricts;
  }

  void _filterDistricts(String query) {
    setState(() {
      filteredDistricts = allDistricts
          .where((district) =>
              district['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectDistrict(String districtName) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterScreen(phoneNumber:widget.phone ,selectedDistrict: districtName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select District")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: _filterDistricts,
              decoration: InputDecoration(
                hintText: "Search district",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 25,
                mainAxisSpacing: 20,
                childAspectRatio: 1.0,
              ),
              itemCount: filteredDistricts.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _selectDistrict(filteredDistricts[index]['name']!),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            filteredDistricts[index]['image']!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        filteredDistricts[index]['name']!,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
