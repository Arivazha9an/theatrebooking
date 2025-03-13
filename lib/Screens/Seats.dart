import 'package:flutter/material.dart';
import 'package:ticket_booking/const/colors.dart';

class TheatreSeatSelection extends StatefulWidget {
  const TheatreSeatSelection({super.key});

  @override
  _TheatreSeatSelectionState createState() => _TheatreSeatSelectionState();
}

class _TheatreSeatSelectionState extends State<TheatreSeatSelection> {
  final Map<String, dynamic> theatreData = {
    "theatre_name": "Kamala Cinemas",
    "showtimes": {
      "10:00 AM": {
        "layout": [
          ["S", "S", "X", "S", "S", "S", "X", "V", "V", "V"],
          ["S", "B", "X", "S", "S", "B", "X", "V", "V", "V"],
          ["S", "S", "X", "S", "S", "S", "X", "B", "S", "S"],
          ["B", "B", "B", "X", "X", "X", "X", "B", "B", "B"],
          ["S", "S", "S", "S", "S", "S", "S", "S", "X", "S"]
        ],
        "pricing": {0: 120, 1: 120, 2: 140, 3: 150, 4: 160},
        "end": "1.40 pm"
      },
      "2:00 PM": {
        "layout": [
          ["S", "S", "S", "S", "X", "S", "X", "V", "V", "V"],
          ["S", "B", "S", "X", "S", "B", "X", "V", "V", "V"],
          ["S", "S", "X", "S", "B", "S", "X", "B", "S", "S"],
          ["B", "B", "B", "X", "X", "X", "X", "B", "B", "B"],
          ["S", "S", "S", "S", "S", "S", "S", "S", "X", "S"]
        ],
        "pricing": {0: 130, 1: 130, 2: 150, 3: 160, 4: 170}
      }
    }
  };
  int calculateTotalPrice() {
    int totalPrice = 0;
    for (String seat in selectedSeats) {
      int row = int.parse(seat.split("-")[0]);
      totalPrice += (theatreData["showtimes"][selectedTime]["pricing"][row] ??
          120) as int;
    }
    return totalPrice;
  }

  List<String> selectedSeats = [];
  String selectedTime = "10:00 AM";

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> currentShowtime =
        theatreData["showtimes"][selectedTime] ?? {};
    List<List<String>> layout =
        List<List<String>>.from(currentShowtime["layout"] ?? []);
    Map<int, int> pricing =
        Map<int, int>.from(currentShowtime["pricing"] ?? {});
    int? lastPrice;

    return Scaffold(
      appBar: AppBar(
        title: Text(theatreData["theatre_name"]),
        backgroundColor: white,
      ),
      backgroundColor: white,
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text("Screen This Way",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipPath(
              clipper: ScreenClipper(),
              child: Container(
                width: double.infinity,
                height: 20,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Show time selection
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: theatreData["showtimes"].keys.map<Widget>((time) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedTime = time;
                      selectedSeats.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedTime == time ? blue : Colors.grey,
                  ),
                  child: Text(
                    time,
                    style:
                        TextStyle(color: selectedTime == time ? white : black),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          Expanded(
            child: Column(
              children: List.generate(layout.length, (rowIndex) {
                int price = pricing[rowIndex] ?? 120;
                Widget priceWidget = (lastPrice != price || rowIndex == 0)
                    ? Text("₹$price",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold))
                    : const SizedBox.shrink();
                lastPrice = price;

                return Column(
                  children: [
                    priceWidget,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          layout[rowIndex].asMap().entries.map<Widget>((entry) {
                        int colIndex = entry.key;
                        String seat = entry.value;

                        if (seat == "X") return const SizedBox(width: 30);

                        Color seatColor = seat == "B"
                            ? Colors.grey
                            : (selectedSeats.contains("$rowIndex-$colIndex")
                                ? blue
                                : Colors.white);
                        Color txtColor = seat == "B"
                            ? black
                            : (selectedSeats.contains("$rowIndex-$colIndex")
                                ? white
                                : black);

                        return GestureDetector(
                          onTap: () {
                            if (seat != "B") {
                              setState(() {
                                String seatKey = "$rowIndex-$colIndex";
                                selectedSeats.contains(seatKey)
                                    ? selectedSeats.remove(seatKey)
                                    : selectedSeats.add(seatKey);
                              });
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: seatColor,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "${String.fromCharCode(65 + rowIndex)}${colIndex + 1}",
                              style: TextStyle(fontSize: 12, color: txtColor),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                            color: blue,
                            borderRadius: BorderRadius.circular(6))),
                    const SizedBox(width: 10),
                    Text("Selected", style: TextStyle(color: black)),
                    const SizedBox(width: 10),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.black)),
                    ),
                    const SizedBox(width: 10),
                    Text("Available", style: TextStyle(color: black)),
                    const SizedBox(width: 10),
                    Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                            color: grey,
                            borderRadius: BorderRadius.circular(6))),
                    const SizedBox(width: 10),
                    Text("Booked", style: TextStyle(color: black)),
                    const SizedBox(width: 20),
                  ],
                ),
                Text("Show End time approx : ${currentShowtime["end"] ?? ""}",
                    style: TextStyle(color: black)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        minimumSize:
                            WidgetStateProperty.all(const Size(180, 50)),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6))),
                        backgroundColor: WidgetStateProperty.all(
                            selectedSeats.isEmpty ? Colors.grey : blue),
                      ),
                      child: Text("${selectedSeats.length} Seats Selected",
                          style: TextStyle(color: white)),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        minimumSize:
                            WidgetStateProperty.all(const Size(180, 50)),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6))),
                        backgroundColor: WidgetStateProperty.all(
                            selectedSeats.isEmpty ? Colors.grey : blue),
                      ),
                     onPressed: selectedSeats.isEmpty
                          ? null
                          : () {
                              List<String> formattedSeats =
                                  selectedSeats.map((seat) {
                                List<String> parts = seat.split("-");
                                int row = int.parse(parts[0]) +
                                    1; // Convert to 1-based index
                                int col = int.parse(parts[1]) +
                                    1; // Convert to 1-based index
                                return "${String.fromCharCode(64 + row)}$col"; // Convert row to A, B, C...
                              }).toList();

                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => CheckOutScreen(
                              //       theatreName: theatreData["theatre_name"],
                              //       showTime: selectedTime,
                              //       selectedSeats:
                              //           formattedSeats, // Pass formatted seat names
                              //       totalPrice: calculateTotalPrice(),
                              //       noofSeats: selectedSeats.length,
                              //     ),
                              //   ),
                              // );
                            },
                      child: Text(
                        "Pay ₹${calculateTotalPrice()}",
                        style: TextStyle(color: white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScreenClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 2, -size.height / 2, size.width, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
