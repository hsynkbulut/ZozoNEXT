import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:teachmate_pro/features/auth/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:teachmate_pro/features/dashboard/domain/models/activity_model.dart';

final recentActivitiesProvider = StreamProvider<List<ActivityModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('activities')
      .where('userId', isEqualTo: user.id)
      .orderBy('timestamp', descending: true)
      .limit(5)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ActivityModel.fromJson(doc.data()))
          .toList());
});

class RecentActivitiesList extends ConsumerWidget {
  const RecentActivitiesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(recentActivitiesProvider);

    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return const Center(
            child: Text('Henüz bir aktivite bulunmuyor.'),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final activity = activities[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  _getActivityIcon(activity.type),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(activity.title),
              subtitle: Text(
                DateFormat.yMMMd().add_Hm().format(activity.timestamp),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to activity details
                if (activity.route != null) {
                  context.push(activity.route!);
                }
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Hata: $error'),
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'lesson_plan':
        return Icons.book;
      case 'exam':
        return Icons.quiz;
      case 'chat':
        return Icons.psychology;
      case 'performance':
        return Icons.analytics;
      default:
        return Icons.history;
    }
  }
}
