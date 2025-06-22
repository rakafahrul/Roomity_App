// File: lib/utils/image_helper.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageHelper {
  // Base URL server untuk akses gambar
  static const String baseImageUrl = 'https://localhost:7143'; 
  // Untuk mobile testing, uncomment line berikut:
  // static const String baseImageUrl = 'http://192.168.33.241:5228'; 
  
  /// Convert relative path dari database menjadi full URL
  static String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return getDefaultImageUrl();
    }
    
    // Jika sudah full URL, return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // Jika relative path, gabungkan dengan base URL
    if (imagePath.startsWith('/')) {
      return '$baseImageUrl$imagePath';
    } else {
      return '$baseImageUrl/$imagePath';
    }
  }
  
  /// Get default room image URL
  static String getDefaultImageUrl() {
    return '$baseImageUrl/uploads/default_room.jpg';
  }
  
  /// Validate if image URL is accessible
  static Future<bool> isImageAccessible(String imageUrl) async {
    try {
      final response = await http.head(Uri.parse(imageUrl));
      return response.statusCode == 200;
    } catch (e) {
      print('Image accessibility check failed: $e');
      return false;
    }
  }
  
  /// Get image widget with fallback
  static Widget getImageWidget({
    required String? imagePath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    BorderRadius? borderRadius,
  }) {
    final fullUrl = getFullImageUrl(imagePath);
    
    Widget imageWidget = Image.network(
      fullUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('Error loading image: $fullUrl - $error');
        return errorWidget ?? _buildDefaultErrorWidget(width, height);
      },
    );

    // Apply border radius if provided
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
  
  /// Build default error widget
  static Widget _buildDefaultErrorWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.meeting_room, size: 50, color: Colors.grey[600]),
          const SizedBox(height: 8),
          Text(
            'Gambar tidak dapat dimuat',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Get circular avatar image
  static Widget getCircularImageWidget({
    required String? imagePath,
    required double radius,
    Color? backgroundColor,
  }) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey[300],
      child: ClipOval(
        child: getImageWidget(
          imagePath: imagePath,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// Get image with fade in animation
  static Widget getFadeInImageWidget({
    required String? imagePath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final fullUrl = getFullImageUrl(imagePath);
    
    return FadeInImage.assetNetwork(
      placeholder: 'assets/images/loading.gif', // Add loading gif to assets
      image: fullUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: duration,
      imageErrorBuilder: (context, error, stackTrace) {
        return _buildDefaultErrorWidget(width, height);
      },
    );
  }

  /// Debug image URL
  static void debugImageUrl(String? imagePath) {
    final fullUrl = getFullImageUrl(imagePath);
    print('=== IMAGE DEBUG ===');
    print('Database Path: $imagePath');
    print('Full URL: $fullUrl');
    print('Base URL: $baseImageUrl');
    print('==================');
  }
}