# PDF Maker App
<img src="https://i.ibb.co/7krYHq5/New-Project.png" width="1400" />


<!-- BEGIN LATEST DOWNLOAD BUTTON -->
[![Download](https://custom-icon-badges.demolab.com/badge/-Download-blue?style=for-the-badge&logo=download&logoColor=white "Download")](https://github.com/Nafisarkar/Pdf_Maker_Flutter/releases/download/Releasev1.0.0/pdfmakerv1.apk)
<!-- END LATEST DOWNLOAD BUTTON -->

Overview
========

The PDF Maker App is a Flutter-based mobile application that allows users to
effortlessly convert images into PDF files. The app supports image selection from
the camera, gallery, and document scanner. Users can preview selected images in
a carousel and customize the PDF file name before saving it. This app is
designed with a clean, intuitive user interface and offers light/dark mode themes
for enhanced usability.

Features
========

### Image Selection

*   Capture images using the camera.
*   Choose multiple images from the gallery.
*   Scan documents using a document scanner.

### Image Preview

*   View selected images in a carousel slider.
*   Count of selected images displayed dynamically.

### PDF Generation

*   Converts selected images into a high-quality PDF.
*   Allows users to name the PDF file before saving.
*   Saves PDF files to the device's storage.

### Permissions Handling

*   Requests necessary permissions to ensure smooth functionality, such as
    storage and camera access.

### Theme Support

*   Toggle between light and dark modes.

### Error Handling

*   Informative snack bars for missing inputs, errors, or successful operations.


Tech Stack
========

Programming Language: Dart

Framework: Flutter
Libraries Used:
*   awesome_snackbar_content: For styled snack bar notifications.
*   cunning_document_scanner: For scanning documents.
*   image_picker: For image selection.
*   carousel_slider: For carousel image preview.
*   syncfusion_flutter_pdf: For generating PDF files.
*   permission_handler: For handling app permissions.
*   url_launcher: For opening external URLs.
*   provider: For theme management.
*   logger: For logging debug information.

Installation
============

Clone the repository:

    git clone https://github.com/Nafisarkar/pdf-maker-app.git
    cd pdf-maker-app

Install dependencies:

    flutter pub get

Run the app:

    flutter run

Usage
=====

Select Images:

    Use the camera, gallery, or scanner to add images.

Preview Images:

    Scroll through selected images in the carousel.

Generate PDF:

    Enter a desired file name in the input field.
    Tap the Convert to PDF button to create the PDF.

Access Saved PDF:

    PDFs are stored in the directory 0/Pdfmaker/ (on Android).

Switch Themes:

    Tap the moon icon in the app bar to toggle between light and dark modes.

## License
This project is licensed under the MIT License. See the LICENSE file for details.


