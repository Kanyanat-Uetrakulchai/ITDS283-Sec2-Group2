import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PostReactionButtons extends StatefulWidget {
  final int postId;
  final int userId;

  const PostReactionButtons({
    Key? key,
    required this.postId,
    required this.userId,
  }) : super(key: key);

  @override
  PostReactionButtonsState createState() => PostReactionButtonsState();
}

class PostReactionButtonsState extends State<PostReactionButtons> {
  String? currentReaction; // 'like', 'unlike', or null
  int likeCount = 0;
  int unlikeCount = 0;
  bool isLoading = false;

  void fetchReaction() {
    fetchCurrentReaction();
  }

  @override
  void initState() {
    super.initState();
    fetchCurrentReaction();
  }

  // Fetch user reaction + reaction counts
  Future<void> fetchCurrentReaction() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(
          '${dotenv.env['url']}/api/reaction?post_id=${widget.postId}&user_id=${widget.userId}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          currentReaction = data['reaction'];
          likeCount = data['likes'];
          unlikeCount = data['unlikes'];
        });
      }
    } catch (e) {
      // Handle error if needed
    } finally {
      setState(() => isLoading = false);
    }
  }

  // React to post
  Future<void> _react(String reactionType) async {
    if (isLoading) return;

    String? newReaction = currentReaction == reactionType ? null : reactionType;

    // Optimistic update
    setState(() {
      if (currentReaction == 'like') likeCount--;
      if (currentReaction == 'unlike') unlikeCount--;

      if (newReaction == 'like') likeCount++;
      if (newReaction == 'unlike') unlikeCount++;

      currentReaction = newReaction;
      isLoading = true;
    });

    try {
      await http.post(
        Uri.parse('${dotenv.env['url']}/react'),
        body: {
          'post_id': widget.postId.toString(),
          'user_id': widget.userId.toString(),
          'reaction': newReaction ?? '',
        },
      );
    } catch (e) {
      // Optionally rollback (you can re-fetch the state)
      fetchCurrentReaction();
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final netScore = likeCount - unlikeCount;
    Color netScoreColor;

    if (netScore > 0) {
      netScoreColor = Colors.green; // Positive score
    } else if (netScore < 0) {
      netScoreColor = Colors.red; // Negative score
    } else {
      netScoreColor = Colors.grey; // Zero score
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
          ), // Add left padding to shift right
          child: Row(
            children: [
              Text('$likeCount'),
              IconButton(
                icon: Icon(
                  Icons.thumb_up,
                  color: currentReaction == 'like' ? Colors.blue : Colors.grey,
                ),
                onPressed: isLoading ? null : () => _react('like'),
              ),
              Text(
                '$netScore',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold, // Make the score bold
                  color: netScoreColor, // Change the color based on score
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.thumb_down,
                  color: currentReaction == 'unlike' ? Colors.red : Colors.grey,
                ),
                onPressed: isLoading ? null : () => _react('unlike'),
              ),
              Text('$unlikeCount'),
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
