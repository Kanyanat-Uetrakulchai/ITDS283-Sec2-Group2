import 'package:flutter/material.dart';
import 'package:ruam_mit_application/pages/profile_page.dart';
import 'package:ruam_mit_application/pages/post_page.dart';
import '../components/image_grid.dart';
import '../pages/post_bytag.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback? onTap;
  final bool clickable;
  final bool showDetails;

  const PostCard({
    Key? key,
    required this.post,
    this.onTap,
    this.clickable = true,
    this.showDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          clickable
              ? () {
                if (onTap != null) {
                  onTap!();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostPage(postId: post['postId']),
                    ),
                  );
                }
              }
              : null,
      child: Card(
        color: Colors.white,
        elevation: 3,
        margin: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PostHeader(post: post),
              Divider(color: Color(0xFFACACAC)),
              SizedBox(height: 6),
              Text(
                post['caption'] ?? '',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 10),
              ImageGrid(post: post),

              if (showDetails) ...[SizedBox(height: 15), _buildDetailSection()],

              if (post['tags'] != null && post['tags'].isNotEmpty)
                _buildTagsSection(context),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'อ่านเพิ่มเติม',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      // color: Color(0xffD63939),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 15),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('ธนาคาร', post['mij_bank'] ?? 'N/A'),
        _buildDetailRow('หมายเลขบัญชี', post['mij_bankno'] ?? 'N/A'),
        _buildDetailRow('ชื่อเจ้าของบัญชี', post['mij_name'] ?? 'N/A'),
        _buildDetailRow('ชื่อร้านค้า', post['mij_acc'] ?? 'N/A'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(value, style: TextStyle(fontWeight: FontWeight.w400)),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    // Accept context as parameter
    List<String> tags =
        post['tags'] is String
            ? (post['tags'] as String).split(',')
            : List<String>.from(post['tags'] ?? []);

    return Padding(
      padding: EdgeInsets.only(top: 15),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            tags.map((tag) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostBytag(tag: tag),
                    ),
                  );
                },
                child: Chip(
                  // label: Text(tag, style: TextStyle(color: Colors.white)),
                  label: Text(tag),
                  backgroundColor: Colors.grey[200],
                ),
              );
            }).toList(),
      ),
    );
  }
}

// _PostHeader and PopularTags classes remain unchanged...

class _PostHeader extends StatelessWidget {
  final Map<String, dynamic> post;

  const _PostHeader({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(uid: post['uid']),
          ),
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xffD63939),
          child: Text(
            post['username']?.toString().substring(0, 1).toUpperCase() ?? '?',
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(post['username'].toString()),
        trailing: Text(post['p_timestamp'].toString().split('T')[0]),
      ),
    );
  }
}

class PopularTags extends StatelessWidget {
  final List<Map<String, dynamic>> tags;

  const PopularTags({Key? key, required this.tags}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          tags.map((tag) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffD63939),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostBytag(tag: tag['tag']),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tag['tag'],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    tag['COUNT(p.postId)'].toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
