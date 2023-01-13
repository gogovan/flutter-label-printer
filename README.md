# flutter-label-printer

Integrate printers with Flutter apps.

# Supported Printers

- Hanyin (HPRT) HM-A300L

# Setup

# Usage

1. Use an instance of a class implementing `PrinterSearcherInterface` to search for compatible
   printers. It will return a list of `PrinterSearchResult`s.
2. Pass one of the returned `PrinterSearchResult` and use it to connect to a printer through an
   instance of a class implementing `PrinterInterface`. Each instance of `PrinterInterface`
   represent a single printer. If you wish to connect multiple printers, use multiple instances
   of `PrinterInterface`.
3. Use the instance of `PrinterInterface` that has connected to a printer to send printing commands.
4. When you are done, call `disconnect` to disconnect the device from your app.

# Issues

# Contributing
