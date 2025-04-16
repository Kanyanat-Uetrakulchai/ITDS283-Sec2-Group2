import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../pages/image_viewer_page.dart';

class ImageGrid extends StatelessWidget {
  final Map<String, dynamic> post;

  const ImageGrid({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    List<String> imageFields = ['p_p1', 'p_p2', 'p_p3', 'p_p4'];
    List<String> imageUrls =
        imageFields
            .map((key) => post[key])
            .whereType<String>()
            .where((url) => url.isNotEmpty)
            .toList();

    if (imageUrls.isEmpty) return const SizedBox.shrink();

    final baseUrl = dotenv.env['url']?.replaceFirst(RegExp(r'/$'), '') ?? '';

    List<Widget> images =
        imageUrls.map((url) {
          final fullUrl = '$baseUrl$url';

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (_) => ImageViewerPage(
                        imageUrls:
                            imageUrls.map((url) => '$baseUrl$url').toList(),
                        initialIndex: imageUrls.indexOf(url),
                      ),
                ),
              );
            },

            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                fullUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 150,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
              ),
            ),
          );
        }).toList();

    switch (images.length) {
      case 1:
        return images[0];
      case 2:
        return Row(
          children:
              images.map((img) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: img != images.last ? 4 : 0),
                    child: img,
                  ),
                );
              }).toList(),
        );
      case 3:
        return Column(
          children: [
            images[0],
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: images[1],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: images[2],
                  ),
                ),
              ],
            ),
          ],
        );
      case 4:
      default:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: images[0],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: images[1],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: images[2],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: images[3],
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }
}
