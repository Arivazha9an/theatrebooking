import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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

  final GlobalKey _seatScreenshotKey = GlobalKey();

  Future<void> _captureAndShareSeating() async {
    try {
      RenderRepaintBoundary boundary = _seatScreenshotKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save the image to a temporary file
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/seating_layout.png').create();
      await file.writeAsBytes(pngBytes);

      // Share the image
      await Share.shareXFiles([XFile(file.path)],
          text: "Here is the seating layout.");
    } catch (e) {
      if (kDebugMode) {
        print("Error capturing image: $e");
      }
    }
  }

void _updateSeatLayout(String showtime) {
    selectedShowtime = showtime;

    // Fetch initial seat layout
    setState(() {
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

    // Reference to the seat layout in Firebase Realtime Database
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("${widget.City}/theatres/${widget.theatreName}/movies${widget.movie}/showtimes/${widget.date}/$showtime/layout");

    // Listen for real-time updates
    ref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null && data is List<dynamic>){
        setState(() {
          seatLayout = data.map((row) => List<String>.from(row)).toList();
        });
      }
      else{
        if (kDebugMode) {
          print("no data found");
        }
      }
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
    int? lastPrice;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.movie, style: const TextStyle(fontSize: 20)),
            Text(widget.theatreName, style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _captureAndShareSeating,
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            height: 80,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.amber[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: allShowtimes.map<Widget>((time) {
                bool isSelected = time == selectedShowtime;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: GestureDetector(
                    onTap: () {
                      _updateSeatLayout(time);
                    },
                    child: Container(
                      width: 100,
                      height: 45,
                      decoration: BoxDecoration(
                        color: isSelected ? blue : Colors.amber[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 0.5),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            time,
                            style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
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
            child: RepaintBoundary(
              key: _seatScreenshotKey,
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(10),
                minScale: 0.8,
                maxScale: 1.5,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: IntrinsicWidth(
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
                            children:
                                List.generate(seatLayout.length, (rowIndex) {
                              int price = pricing[rowIndex] ?? 120;
                              Widget priceWidget =
                                  (lastPrice != price || rowIndex == 0)
                                      ? Column(
                                          children: [
                                            Text(
                                              "₹$price",
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 2),
                                          ],
                                        )
                                      : const SizedBox.shrink();
                              lastPrice = price;

                              int seatNumber =
                                  1; // Track seat numbers manually, skipping "X"

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Row Letter (A, B, C, etc.)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: SizedBox(
                                      width: 10,
                                      child: Column(
                                        children: [
                                          Text(
                                            String.fromCharCode(65 +
                                                rowIndex), // Converts to A, B, C...
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 05,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      priceWidget,
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: seatLayout[rowIndex]
                                              .asMap()
                                              .entries
                                              .map<Widget>((entry) {
                                            int colIndex = entry.key;
                                            String seat = entry.value;

                                            if (seat == "X") {
                                              // Render an invisible spacer for layout, but skip numbering
                                              return const SizedBox(
                                                  width: 24, height: 22);
                                            }

                                            // Assign proper seat number (skip "X" seats)
                                            String seatLabel =
                                                "${String.fromCharCode(65 + rowIndex)}$seatNumber";
                                            String seatLabelUI = " $seatNumber";
                                            seatNumber++; // Increment for next actual seat

                                            Color seatColor = seat == "B"
                                                ? Colors.grey
                                                : (selectedSeatsUI
                                                        .contains(seatLabel)
                                                    ? blue
                                                    : Colors.white);
                                            Color borderColor = seat == "B"
                                                ? Colors.grey
                                                : (selectedSeatsUI
                                                        .contains(seatLabel)
                                                    ? blue
                                                    : blue);
                                            Color txtColor = seat == "B"
                                                ? grey[900]!
                                                : (selectedSeatsUI
                                                        .contains(seatLabel)
                                                    ? white
                                                    : blue);

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 3),
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (seat != "B") {
                                                    setState(() {
                                                      if (selectedSeatsUI
                                                          .contains(
                                                              seatLabel)) {
                                                        selectedSeatsUI
                                                            .remove(seatLabel);
                                                        selectedSeatsBackend.remove(
                                                            "$rowIndex-$colIndex");
                                                      } else {
                                                        selectedSeatsUI
                                                            .add(seatLabel);
                                                        selectedSeatsBackend.add(
                                                            "$rowIndex-$colIndex"); // Store only real seats
                                                      }
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                  width: 26,
                                                  height: 26,
                                                  decoration: BoxDecoration(
                                                    color: seatColor,
                                                    border: Border.all(
                                                        color: borderColor,
                                                        width: 0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    seatLabelUI,
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: txtColor),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
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
          selectedSeatsBackend.isEmpty
              ? const SizedBox.shrink()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("₹ ${calculateTotalPrice()}",
                              style: TextStyle(
                                  color: black, fontWeight: FontWeight.bold)),
                          // Group selected seats by price
                          Column(
                            children: (() {
                              Map<int, int> seatCountByPrice = {};
                              for (String seat in selectedSeatsBackend) {
                                int row = int.parse(seat.split('-')[0]);
                                int seatPrice = pricing[row] ?? 120;

                                if (seatCountByPrice.containsKey(seatPrice)) {
                                  seatCountByPrice[seatPrice] =
                                      seatCountByPrice[seatPrice]! + 1;
                                } else {
                                  seatCountByPrice[seatPrice] = 1;
                                }
                              }

                              List<MapEntry<int, int>> sortedEntries =
                                  seatCountByPrice.entries.toList();
                              sortedEntries.sort((a, b) => b.key.compareTo(
                                  a.key)); // Sort by price descending
                              return sortedEntries
                                  .map((entry) => Text(
                                      "${entry.key} x ${entry.value}",
                                      style: TextStyle(color: black)))
                                  .toList();
                            })(),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        minimumSize:
                            WidgetStateProperty.all(const Size(180, 50)),
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
                                      noofSeats: selectedSeatsBackend.length
                                          .toString(),
                                      theatreName: widget.theatreName,
                                      showTime: selectedShowtime,
                                      selectedSeats1: selectedSeatsUI,
                                      selectedSeats: selectedSeatsBackend,
                                      totalPrice:
                                          calculateTotalPrice().toDouble(),
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
                        selectedSeatsBackend.length > 1
                            ? "Book Tickets"
                            : "Book Ticket",
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
