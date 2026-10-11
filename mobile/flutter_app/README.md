# scheme_mate_ai

A new Flutter project.

## Document scanning

On Android and iOS, document images are checked for QR codes first. If a
matching identifier is not found in a QR code, Google ML Kit text recognition
extracts a possible document number on-device. The image is not sent to the
backend by the scan flow. Review and correct the extracted number, or enter it
manually, before saving it to the profile.

QR/OCR extraction does not authenticate a document. Users should verify every
value themselves. Other platforms retain manual document-number entry.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
