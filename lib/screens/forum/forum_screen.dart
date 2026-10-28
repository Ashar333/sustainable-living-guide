import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../models/content_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';

/// Community Forum screen.
class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final _postController = TextEditingController();

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community Forum')),
      body: Consumer<DataProvider>(
        builder: (context, data, _) {
          if (data.posts.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.forum_outlined,
              title: 'No Posts Yet',
              subtitle: 'Be the first to share!',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.posts.length,
            itemBuilder: (context, index) {
              final post = data.posts[index];
              final userId = context.read<AuthProvider>().user?.uid ?? '';
              final isLiked = post.likedBy.contains(userId);
              return GlassmorphismCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.accent,
                          child: Text(post.userName[0].toUpperCase(), style: const TextStyle(color: AppColors.primary)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(_formatTime(post.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(post.content),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : null),
                          onPressed: () => data.toggleLike(post.id!, userId, isLiked),
                        ),
                        Text('${post.likes}'),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.comment_outlined),
                          onPressed: () => _showComments(context, post.id!),
                        ),
                        Text('${post.commentCount}'),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.create),
      ),
    );
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Post'),
        content: TextField(
          controller: _postController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Share your eco thoughts...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (_postController.text.trim().isEmpty) return;
              final auth = context.read<AuthProvider>();
              await context.read<DataProvider>().createPost(PostModel(
                userId: auth.user?.uid ?? '',
                userName: auth.user?.name ?? 'Anonymous',
                content: _postController.text.trim(),
                createdAt: DateTime.now(),
              ));
              _postController.clear();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  void _showComments(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (ctx, scrollController) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Comments', style: Theme.of(context).textTheme.titleLarge),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: context.read<DataProvider>().getComments(postId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final comments = snapshot.data as List<CommentModel>;
                    if (comments.isEmpty) {
                      return const Center(child: Text('No comments yet'));
                    }
                    return ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (ctx, i) {
                        final comment = comments[i];
                        return ListTile(
                          leading: CircleAvatar(child: Text(comment.userName[0])),
                          title: Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text(comment.content),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}
