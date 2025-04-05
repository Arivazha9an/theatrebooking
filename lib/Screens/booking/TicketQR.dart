import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ticket_booking/Widgets/CustomZigZagDivider.dart';
import 'package:ticket_booking/const/colors.dart';
import 'package:permission_handler/permission_handler.dart';

class TicketScreen extends StatefulWidget {
  final String theatreName;
  final String showTime;
  final List<String> selectedSeats;
  final String totalPrice;
  final String noofSeats;
  final String movieName;
  final String movieImage;
  final String movieLanguage;
  final String movieFormat;
  final String orderId;
  final String date;
  final String likes;

  const TicketScreen(
      {
      super.key,
      required this.theatreName,
      required this.showTime,
      required this.selectedSeats,
      required this.totalPrice,
      required this.noofSeats,
      required this.movieName,
      required this.movieImage,
      required this.movieLanguage,
      required this.movieFormat,
      required this.orderId,
      required this.date,
      required this.likes
      }
      );

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final GlobalKey _ticketKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          "Your Ticket",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildTicketCard(),
              const SizedBox(height: 20),
              _buildDownloadShareButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard() {
    return RepaintBoundary(
      key: _ticketKey,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.movieImage,
                            width: 150,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.movieName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${widget.movieLanguage} • ${widget.movieFormat}",
                                style: const TextStyle(fontSize: 11.5),
                              ),
                              // Row(
                              //   children: [
                              //     Icon(
                              //       CupertinoIcons.heart_solid,
                              //       color: Colors.red,
                              //     ),
                              //     Text('${widget.likes}% ',
                              //         style:
                              //             const TextStyle(color: Colors.grey)),
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Ticket Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTicketInfo1("Theatre", widget.theatreName),
                            SizedBox(height: 20),
                            _buildTicketInfo1("Date", widget.showTime),
                            SizedBox(height: 20),
                            _buildTicketInfo1("Order ID", widget.orderId),
                            SizedBox(height: 20),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildTicketInfo(
                                "Seats", widget.selectedSeats.join(", ")),
                            SizedBox(height: 20),
                            _buildTicketInfo("Time", widget.showTime),
                            SizedBox(height: 20),
                            _buildTicketInfo(
                                "Amount", widget.totalPrice.toString()),
                            SizedBox(height: 20),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
              CustomZigZag(height: 12, width: 5, color: white),
              const SizedBox(height: 10),
              QrImageView(
                data: widget.orderId,
                size: 140,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 5),
              const Text("Get this QR scanned at the entrance",
                  style: TextStyle(fontSize: 12)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildTicketInfo1(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }


  Widget _buildDownloadShareButtons() {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: _captureAndSaveTicket,
            label: const Text("Download"),
            style: ElevatedButton.styleFrom(
              backgroundColor: blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          const SizedBox(width: 20),
          ElevatedButton.icon(
            onPressed: _captureAndShareTicket,
            label: const Text("Share"),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
              backgroundColor: blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _captureAndSaveTicket() async {
    if (await Permission.storage.request().isGranted ||
        await Permission.manageExternalStorage.request().isGranted) {
      try {
        // 📌 Ask user where to save
        String? selectedDirectory =
            await FilePicker.platform.getDirectoryPath();
        if (selectedDirectory == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ No folder selected")),
          );
          return;
        }

        // Capture ticket as an image
        RenderRepaintBoundary boundary = _ticketKey.currentContext!
            .findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        // 📌 Save in selected directory
        String filePath = "$selectedDirectory/ticket_${widget.orderId}.png";
        File file = File(filePath);
        await file.writeAsBytes(pngBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Ticket saved in: $filePath")),
        );
      } catch (e) {
        if (kDebugMode) {
          print("Error saving ticket: $e");
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to save ticket.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text("❌ Storage permission denied! Please allow access."),
          action: SnackBarAction(
            label: "Open Settings",
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    }
  }

  Future<void> _captureAndShareTicket() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/ticket_${widget.orderId}.png';

      // Capture ticket
      RenderRepaintBoundary boundary = _ticketKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to temp file
      File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // Share the file
      await Share.shareXFiles([XFile(filePath)],
          text: "Here is your movie ticket!");
    } catch (e) {
      if (kDebugMode) {
        print("Error sharing ticket: $e");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to share ticket.")),
      );
    }
  }
}
