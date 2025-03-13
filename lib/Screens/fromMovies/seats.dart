import 'package:flutter/material.dart';
import 'package:ticket_booking/Screens/CheckOut.dart';
import 'package:ticket_booking/const/colors.dart';

class TheatreSeatSelectionScreen extends StatefulWidget {
  final String theatreName;
  final String movie;
  final Map<String, dynamic> showtimeData;
  final String date;

  const TheatreSeatSelectionScreen({
    super.key,
    required this.theatreName,
    required this.showtimeData,
    required this.movie,
    required this.date,
  });

  @override
  _TheatreSeatSelectionScreenState createState() =>
      _TheatreSeatSelectionScreenState();
}

class _TheatreSeatSelectionScreenState
    extends State<TheatreSeatSelectionScreen> {
  String selectedShowtime = "";
  List<List<String>> seatLayout = [];
  Map<int, int> pricing = {};
  List<String> selectedSeats = [];

  @override
  void initState() {
    super.initState();
    if (widget.showtimeData.isNotEmpty) {
      selectedShowtime = widget.showtimeData.keys.first;
      _updateSeatLayout(selectedShowtime);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedSeats.clear(); // Reset seats when coming back
  }

  void _updateSeatLayout(String showtime) {
    setState(() {
      selectedShowtime = showtime;

      // ✅ Convert `layout` correctly
      seatLayout = (widget.showtimeData[showtime]["layout"] as List<dynamic>)
          .map((row) => List<String>.from(row))
          .toList();

      // ✅ Fix: Convert `pricing` from List<String> to Map<int, int>
      List<dynamic> pricingList = widget.showtimeData[showtime]["pricing"];
      pricing = {
        for (int i = 0; i < pricingList.length; i++)
          i: int.tryParse(pricingList[i].toString()) ??
              120 // Default to 120 if parsing fails
      };

      selectedSeats.clear(); // Clear seats when switching showtime
    });
  }

  int calculateTotalPrice() {
    int totalPrice = 0;
    for (String seat in selectedSeats) {
      int row = int.parse(seat.split("-")[0]);
      totalPrice += pricing[row] ?? 120;
    }
    return totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    List<String> allShowtimes = widget.showtimeData.keys.toList();
    int? lastPrice;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.movie,
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              widget.theatreName,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 🎬 ShowTime Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: allShowtimes.map<Widget>((time) {
              bool isSelected = time == selectedShowtime;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    _updateSeatLayout(time);
                  },
                  child: Container(
                    height: 35,
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? blue : Colors.amber[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black, width: 0.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      time,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // 🪑 Seat Layout
          Expanded(
            child: Column(
              children: List.generate(seatLayout.length, (rowIndex) {
                int price = pricing[rowIndex] ?? 120;
                Widget priceWidget = (lastPrice != price || rowIndex == 0)
                    ? Column(
                        children: [
                          Text(
                            "₹$price",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                        ],
                      )
                    : const SizedBox.shrink();
                lastPrice = price;

                return Column(
                  children: [
                    priceWidget,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: seatLayout[rowIndex]
                          .asMap()
                          .entries
                          .map<Widget>((entry) {
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

          const SizedBox(height: 20),

          // 🛒 Checkout & Pay Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(const Size(180, 50)),
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
                  minimumSize: WidgetStateProperty.all(const Size(180, 50)),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6))),
                  backgroundColor: WidgetStateProperty.all(
                      selectedSeats.isEmpty ? Colors.grey : blue),
                ),
                onPressed: selectedSeats.isEmpty
                    ? null
                    : () {
                        print("Selected Seats: ${selectedSeats.join(", ")}");
                        print("Selected Date: ${widget.date}");

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckOutScreen(
                              noofSeats: selectedSeats.length,
                              theatreName: widget.theatreName,
                              showTime: selectedShowtime,
                              selectedSeats: selectedSeats,
                              totalPrice: calculateTotalPrice().toDouble(),
                              movieTitle: widget.movie,
                              selectedDate: widget.date,
                            ),
                          ),
                        );
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
    );
  }
}
