import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ticket_booking/Screens/booking/CheckOut.dart';
import 'package:ticket_booking/Widgets/Screen.dart';
import 'package:ticket_booking/const/colors.dart';

class TheatreSeatSelectionScreen extends StatefulWidget {
  final String theatreName;
  final String movie;
  final Map<String, dynamic> showtimeData;
  final String date;
  final int bookingCharge;
  final String City;

  const TheatreSeatSelectionScreen({
    super.key,
    required this.theatreName,
    required this.showtimeData,
    required this.movie,
    required this.date,
    required this.bookingCharge,
    required this.City,
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
  List<String> selectedSeatsUI = [];
  List<String> selectedSeatsBackend = [];

  @override
  void initState() {
    super.initState();
    if (widget.showtimeData.isNotEmpty) {
      selectedShowtime = widget.showtimeData.keys.first;
      _updateSeatLayout(selectedShowtime);
    }
  }

  void _updateSeatLayout(String showtime) {
    setState(() {
      selectedShowtime = showtime;
      seatLayout = (widget.showtimeData[showtime]["layout"] as List<dynamic>)
          .map((row) => List<String>.from(row))
          .toList();
      List<dynamic> pricingList = widget.showtimeData[showtime]["pricing"];
      pricing = {
        for (int i = 0; i < pricingList.length; i++)
          i: int.tryParse(pricingList[i].toString()) ?? 120
      };
      selectedSeatsBackend.clear();
    });
  }

  int calculateTotalPrice() {
    int totalPrice = 0;
    for (String seat in selectedSeatsBackend) {
      int row = int.parse(seat.split("-")[0]);
      totalPrice += pricing[row] ?? 120;
    }
    return totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    List<String> allShowtimes = widget.showtimeData.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.movie, style: const TextStyle(fontSize: 20)),
            Text(widget.theatreName, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: allShowtimes.map<Widget>((time) {
              bool isSelected = time == selectedShowtime;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GestureDetector(
                  onTap: () {
                    _updateSeatLayout(time);
                  },
                  child: Container(
                    width: 80,
                    height: 35,
                    padding: const EdgeInsets.symmetric(vertical: 6),
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
          Expanded(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(10),
              minScale: 0.8,
              maxScale: 1.5,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context)
                        .size
                        .width, // Ensures proper layout
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height *
                            0.5, // Prevents shrinking
                      ),
                      child: Column(
                        children: List.generate(seatLayout.length, (rowIndex) {
                          int price = pricing[rowIndex] ?? 120;
                          Widget priceWidget = (rowIndex == 0 ||
                                  pricing[rowIndex] != pricing[rowIndex - 1])
                              ? Column(
                                  children: [
                                    Text("₹$price",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                  ],
                                )
                              : const SizedBox.shrink();

                          return Column(
                            children: [
                              priceWidget,
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: seatLayout[rowIndex]
                                      .asMap()
                                      .entries
                                      .map<Widget>((entry) {
                                    int colIndex = entry.key;
                                    String seat = entry.value;

                                    if (seat == "X") {
                                      return const SizedBox(
                                          width: 26,
                                          height: 22); // Spacer for gaps
                                    }

                                    String seatLabel =
                                        "${String.fromCharCode(65 + rowIndex)}${colIndex + 1}";

                                    Color seatColor = seat == "B"
                                        ? Colors.grey
                                        : (selectedSeatsUI.contains(seatLabel)
                                            ? blue
                                            : Colors.white);
                                             
                                    Color txtColor = seat == "B"
                                        ? black
                                        : (selectedSeatsUI.contains(seatLabel)
                                            ? white
                                            : black);

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2),
                                      child: GestureDetector(
                                        onTap: () {
                                          if (seat != "B") {
                                            setState(() {
                                              if (selectedSeatsUI
                                                  .contains(seatLabel)) {
                                                selectedSeatsUI
                                                    .remove(seatLabel);
                                                selectedSeatsBackend.remove(
                                                    "$rowIndex-$colIndex");
                                              } else {
                                                selectedSeatsUI.add(seatLabel);
                                                selectedSeatsBackend
                                                    .add("$rowIndex-$colIndex");
                                              }
                                            });
                                          }
                                        },
                                        child: Container(
                                          width:
                                              26, // Slightly increased width for better spacing
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: seatColor,
                                            border: Border.all(
                                                color: Colors.black,
                                                width: 0.5),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(seatLabel,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: txtColor)),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: blue,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
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
                      color: grey, borderRadius: BorderRadius.circular(6))),
              const SizedBox(width: 10),
              Text("Booked", style: TextStyle(color: black)),
              const SizedBox(width: 20),
            ],
          ),

          const SizedBox(height: 10),
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
                      selectedSeatsBackend.isEmpty ? Colors.grey : blue),
                ),
                child: Text("${selectedSeatsBackend.length} Seats Selected",
                    style: TextStyle(color: white)),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(const Size(180, 50)),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6))),
                  backgroundColor: WidgetStateProperty.all(
                      selectedSeatsBackend.isEmpty ? Colors.grey : blue),
                ),
                onPressed: selectedSeatsBackend.isEmpty
                    ? null
                    : () async {
                        // 👈 Add `async` here
                        if (kDebugMode) {
                          print(
                            "Selected Seats: ${selectedSeatsBackend.join(", ")}");
                        }
                        if (kDebugMode) {
                          print("Selected Date: ${widget.date}");
                        }
                        if (kDebugMode) {
                          print(selectedSeatsUI);
                        }
                        if (kDebugMode) {
                          print(selectedSeatsBackend);
                        }

                        // ✅ Wait for CheckoutScreen to finish before refreshing data
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckOutScreen(
                                noofSeats:
                                    selectedSeatsBackend.length.toString(),
                                theatreName: widget.theatreName,
                                showTime: selectedShowtime,
                                selectedSeats1: selectedSeatsUI,
                                selectedSeats: selectedSeatsBackend,
                                totalPrice: calculateTotalPrice().toDouble(),
                                movieTitle: widget.movie,
                                selectedDate: widget.date,
                                bookingCharge: widget.bookingCharge,
                                City: widget.City),
                          ),
                        );

                        // 🔥 Re-fetch updated seat layout when coming back
                        _updateSeatLayout(selectedShowtime);
                      },
                child: Text(
                  "Pay ₹${calculateTotalPrice()}",
                  style: TextStyle(color: white),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
