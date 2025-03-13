import 'package:flutter/material.dart';
import 'package:ticket_booking/Widgets/CustomAppbar.dart';
import 'package:ticket_booking/const/colors.dart';

class SelectCity extends StatefulWidget {
  const SelectCity({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<SelectCity> {
  final List<Map<String, String>> allDistricts = [
    {
      "name": "Chennai",
      "image":
          "https://www.shutterstock.com/image-vector/chennai-city-icon-central-station-600nw-2186062815.jpg"
    },
    {
      "name": "Coimbatore",
      "image":
          "https://www.shutterstock.com/image-vector/chennai-city-icon-central-station-600nw-2186062815.jpg"
    },
    {
      "name": "Madurai",
      "image":
          "https://www.shutterstock.com/image-vector/chennai-city-icon-central-station-600nw-2186062815.jpg"
    },
    {
      "name": "Tiruchirappalli",
      "image":
          "https://www.shutterstock.com/image-vector/chennai-city-icon-central-station-600nw-2186062815.jpg"
    },
    {
      "name": "Salem",
      "image":
          "https://www.shutterstock.com/image-vector/chennai-city-icon-central-station-600nw-2186062815.jpg"
    },
    {
      "name": "Erode",
      "image":
          "https://www.shutterstock.com/image-vector/chennai-city-icon-central-station-600nw-2186062815.jpg"
    },
    {
      "name": "Thoothukudi",
      "image":
          "https://www.shutterstock.com/image-vector/chennai-city-icon-central-station-600nw-2186062815.jpg"
    },
    {
      "name": "Tirunelveli",
      "image":
          "https://www.shutterstock.com/image-vector/chennai-city-icon-central-station-600nw-2186062815.jpg"
    },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text("Select District", style: TextStyle(color: black)),
        height: 65,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // AppBar(
      //   backgroundColor: amber,
      //   title: Text("Select District", style: TextStyle(color: black)),
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back, color: black),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      // ),
      body: Column(
        children: [
          SizedBox(
            height: 58,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                onChanged: _filterDistricts,
                decoration: InputDecoration(
                  hintText: "Search district",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
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
                return Column(
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
