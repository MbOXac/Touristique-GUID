import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StreetViewWidget extends StatefulWidget {
  final LatLng position;
  final String destinationName;
  final String googleMapsApiKey;
  final double heading;
  final double pitch;
  final double fov;

  const StreetViewWidget({
    super.key,
    required this.position,
    required this.destinationName,
    required this.googleMapsApiKey,
    this.heading = 0,
    this.pitch = 0,
    this.fov = 90,
  });

  @override
  State<StreetViewWidget> createState() => _StreetViewWidgetState();
}

class _StreetViewWidgetState extends State<StreetViewWidget> {
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_getStreetViewHtml());
  }

  String _getStreetViewHtml() {
    final lat = widget.position.latitude;
    final lng = widget.position.longitude;
    final heading = widget.heading.toInt();
    final pitch = widget.pitch.toInt();
    final fov = widget.fov.toInt();

    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Street View - ${widget.destinationName}</title>
        <style>
            body {
                margin: 0;
                padding: 0;
                height: 100vh;
                font-family: Arial, sans-serif;
            }
            #street-view {
                width: 100%;
                height: 100%;
            }
            .controls {
                position: absolute;
                bottom: 20px;
                left: 50%;
                transform: translateX(-50%);
                background: rgba(0, 0, 0, 0.7);
                color: white;
                padding: 12px 20px;
                border-radius: 8px;
                font-size: 12px;
                z-index: 100;
            }
            .destination-name {
                position: absolute;
                top: 15px;
                left: 15px;
                background: rgba(0, 0, 0, 0.8);
                color: white;
                padding: 8px 12px;
                border-radius: 4px;
                font-weight: bold;
                font-size: 14px;
                z-index: 100;
            }
        </style>
    </head>
    <body>
        <div id="street-view"></div>
        <div class="destination-name">${widget.destinationName}</div>
        <div class="controls">Heading: $heading° | Pitch: $pitch° | FOV: $fov°</div>

        <script async defer
            src="https://maps.googleapis.com/maps/api/js?key=${widget.googleMapsApiKey}">
        </script>
        <script>
            function initStreetView() {
                const panorama = new google.maps.StreetViewPanorama(
                    document.getElementById('street-view'),
                    {
                        position: {lat: $lat, lng: $lng},
                        pov: {
                            heading: $heading,
                            pitch: $pitch
                        },
                        zoom: $fov,
                        addressControl: true,
                        panControl: true,
                        zoomControl: true,
                        fullscreenControl: true,
                        motionTrackingControl: true,
                        scrollwheel: true,
                        clickToGo: true
                    }
                );

                // Allow external JavaScript to control the panorama
                window.streetViewPanorama = panorama;
                
                // Log when street view is ready
                window.streetViewReady = true;
                console.log('Street View initialized for: ${widget.destinationName}');
            }

            // Wait for Google Maps API to load
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', initStreetView);
            } else {
                initStreetView();
            }
        </script>
    </body>
    </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: WebViewWidget(controller: _webViewController),
    );
  }
}
