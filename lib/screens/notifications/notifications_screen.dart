import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:cloudkeja/helpers/loading_effect.dart'; // Replaced with standard loader
import 'package:cloudkeja/models/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTextStyle = theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleLarge;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Notifications',
          style: appBarTextStyle, // Applied theme text style
        ),
        elevation: 0, // Keeping elevation 0 as explicitly set
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('userData')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('notifications')
              .orderBy('timestamp', descending: true) // Added orderBy for consistent ordering
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
              // Show loader if waiting or if no data and not yet done (initial load)
              return const Center(child: CircularProgressIndicator()); // Replaced LoadingEffect
            }
            if (snapshot.hasError) { // Added error handling
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: ${snapshot.error}', style: TextStyle(color: theme.colorScheme.error)),
                ),
              );
            }
            if (snapshot.data!.docs.isEmpty) { // Handle empty state
               return Center(
                child: Text(
                  'No notifications yet.',
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              );
            }

            List<DocumentSnapshot> docs = snapshot.data!.docs;
            return ListView(
              children: List.generate(
                  docs.length,
                  (index) => NotificationsTile(
                        not: NotificationModel.fromJson(docs[index]),
                      )),
            );
          }),
    );
  }
}

class NotificationsTile extends StatelessWidget {
  const NotificationsTile({Key? key, required this.not}) : super(key: key);
  final NotificationModel not;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.secondaryContainer, // Applied theme color
        backgroundImage: not.imageUrl != null && not.imageUrl!.isNotEmpty
            ? NetworkImage(not.imageUrl!)
            : null, // Handle null or empty imageUrl
        child: (not.imageUrl == null || not.imageUrl!.isEmpty)
            ? Icon(Icons.notifications, color: colorScheme.onSecondaryContainer) // Placeholder icon
            : null,
      ),
      title: Text(not.title ?? 'No Title'), // Added null check
      subtitle: Text(not.message ?? 'No Message'), // Added null check
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: colorScheme.onSurface.withOpacity(0.6), // Applied theme color
      ),
      // onTap: () { /* Optional: Handle tap if notifications are interactive */ }
    );
  }
}
