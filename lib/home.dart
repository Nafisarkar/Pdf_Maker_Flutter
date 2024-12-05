import 'dart:io';
import 'dart:typed_data';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pdf_aio/themeprovider.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class FileStorage {
  static Future<String> getExternalDocumentPath() async {
    // Check whether permission is given for this app or not.
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      // If not we will ask for permission first.
      await Permission.storage.request();
    }

    Directory _directory;
    if (Platform.isAndroid) {
      // Redirects it to download folder in Android.
      _directory = Directory('/storage/emulated/0/Pdfmaker/');
    } else {
      _directory = await getApplicationDocumentsDirectory();
    }

    final exPath = _directory.path;
    print("Saved Path: $exPath");
    await Directory(exPath).create(recursive: true);
    return exPath;
  }

  static Future<String> get _localPath async {
    // Get the external path from the device's download folder.
    final String directory = await getExternalDocumentPath();
    return directory;
  }

  static Future<File> writeCounter(List<int> bytes, String name) async {
    final path = await _localPath;
    // Create a file for the path of the device and file name with extension.
    File file = File('$path/$name.pdf');
    print("Save file");

    // Write the data in the file you have created.
    return file.writeAsBytes(bytes);
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  final TextEditingController _pdfNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
      Permission.videos,
      Permission.audio,
      Permission.manageExternalStorage
    ].request();

    if (statuses[Permission.manageExternalStorage]!.isGranted) {
      Logger().i('Storage permission granted');
    } else {
      Logger().e('Storage permission denied');
    }
  }

  Future<void> _pickImage(String source) async {
    try {
      if (source == "Gallery") {
        final List<XFile>? pickedImages = await _picker.pickMultiImage();
        if (pickedImages != null && pickedImages.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(pickedImages);
          });
        }
      } else if (source == "Scanner") {
        final List<String>? imagePathStrings =
            await CunningDocumentScanner.getPictures();
        if (imagePathStrings != null && imagePathStrings.isNotEmpty) {
          // Convert List<String> to List<XFile>
          final List<XFile> scannedImages =
              imagePathStrings.map((path) => XFile(path)).toList();
          setState(() {
            _selectedImages.addAll(scannedImages);
          });
        }
      } else {
        // Camera
        final XFile? image =
            await _picker.pickImage(source: ImageSource.camera);
        if (image != null) {
          setState(() {
            _selectedImages.add(image);
          });
        }
      }
    } on Exception catch (e) {
      Logger().e('Error picking image', error: e);
    }
  }

  Future<void> _generatePdf() async {
    if (_selectedImages.isEmpty) {
      Logger().w('No images selected to create PDF');
      const snackBar = SnackBar(
        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'On HAYY!!',
          message: 'Please select images first',

          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: ContentType.help,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    String pdfFileName = _pdfNameController.text.trim();
    if (pdfFileName.isEmpty) {
      Logger().w('PDF file name is empty');
      const snackBar = SnackBar(
        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'On HAYY!!',
          message: 'Please enter a PDF file name',

          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: ContentType.help,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    final pdf = PdfDocument();
    final pageFormat = PdfPageSize.a4;

    // Define margins
    const double leftMargin = 18.0;
    const double rightMargin = 18.0;
    const double topMargin = 18.0;
    const double bottomMargin = 18.0;

    for (final imageFile in _selectedImages) {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final PdfBitmap bitmap = PdfBitmap(imageBytes);

      // Calculate the aspect ratio to maintain the image size
      final double aspectRatio = bitmap.width / bitmap.height;
      final double pageWidth = pageFormat.width - leftMargin - rightMargin;
      final double pageHeight = pageWidth / aspectRatio;

      // Add a new page with the specified margins
      final PdfPage page = pdf.pages.add();
      page.graphics.drawImage(
        bitmap,
        Rect.fromLTWH(leftMargin, topMargin, pageWidth, pageHeight),
      );
    }

    final pdfBytes = await pdf.save();
    pdf.dispose();

    final file = await FileStorage.writeCounter(pdfBytes, pdfFileName);

    final snackBar = SnackBar(
      /// need to set following properties for best effect of awesome_snackbar_content
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'On Snap!',
        message: 'PDF saved at ${file.path}',

        /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
        contentType: ContentType.success,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    Logger().i('PDF saved at ${file.path}');
  }

  @override
  void dispose() {
    _pdfNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        titleSpacing: 18,
        title: Text(
          "PDF MAKER",
          style: TextStyle(
            color: Theme.of(context).secondaryHeaderColor,
            fontFamily: "Pacifico",
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.camera_alt_outlined,
              color: Theme.of(context).secondaryHeaderColor,
            ),
            onPressed: () => _pickImage("Camera"),
          ),
          IconButton(
            icon: Icon(
              Icons.image_outlined,
              color: Theme.of(context).secondaryHeaderColor,
            ),
            onPressed: () => _pickImage("Gallery"),
          ),
          IconButton(
            icon: const Icon(Icons.document_scanner_outlined),
            color: Theme.of(context).secondaryHeaderColor,
            onPressed: () => _pickImage("Scanner"),
          ),
          IconButton(
            icon: const Icon(Icons.dark_mode_outlined),
            color: Theme.of(context).secondaryHeaderColor,
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: _selectedImages.isNotEmpty
                        ? CarouselSlider(
                            options: CarouselOptions(
                              height: MediaQuery.of(context).size.height * 0.5,
                              autoPlay: true,
                              enlargeCenterPage: true,
                            ),
                            items: _selectedImages.map((file) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    decoration:
                                        BoxDecoration(color: Colors.grey[300]),
                                    child: Image.file(
                                      File(file.path),
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          )
                        : Center(
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.5,
                              width: MediaQuery.of(context).size.width - 20,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "No images selected",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                    child: Text(
                      "Selected Images: ${_selectedImages.length}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                            child: TextField(
                              autofocus: false,
                              controller: _pdfNameController,
                              decoration: const InputDecoration(
                                errorMaxLines: 10,
                                border: OutlineInputBorder(),
                                labelText: 'Enter Pdf File Name',
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: const Icon(Icons.refresh_outlined),
                            onPressed: () {
                              setState(() {
                                _selectedImages.clear();
                              });
                            },
                            color: Theme.of(context).primaryColor,
                            tooltip: "Refresh Outlined",
                          ),
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: MediaQuery.of(context).size.width - 24,
                    height: 45,
                    elevation: 5,
                    onPressed: _generatePdf,
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).secondaryHeaderColor,
                    child: const Text("Convert to PDF",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {
                launchUrl(
                  Uri.parse('https://github.com/Nafisarkar'),
                  mode: LaunchMode.externalApplication,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  "Developed by Shaon An Nafi  ",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
