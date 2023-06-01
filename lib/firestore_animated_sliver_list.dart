import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

import 'firestore_sliver_list_view.dart';

typedef FirestoreAnimatedSliverItemBuilder<Document> = Widget Function(
    BuildContext context,
    QueryDocumentSnapshot<Document> item,
    Animation<double> animation);

/// Sliver version of the [FirestoreListView]
class FirestoreAnimatedSliverListView<T> extends StatelessWidget {
  final Query<T> query;
  final FirestoreAnimatedSliverItemBuilder<T> itemBuilder;
  final FirestoreLoadingBuilder? loadingBuilder;
  final FirestoreErrorBuilder? errorBuilder;
  final FirestoreEmptyBuilder? emptyBuilder;
  final ChildIndexGetter? findChildIndexCallback;
  final int pageSize;

  const FirestoreAnimatedSliverListView({
    super.key,
    required this.query,
    required this.itemBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.findChildIndexCallback,
    this.pageSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return FirestoreQueryBuilder<T>(
      query: query,
      pageSize: pageSize,
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return loadingBuilder?.call(context) ?? const SliverToBoxAdapter();
        }

        if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error ?? '',
                  snapshot.stackTrace ?? StackTrace.empty) ??
              const SliverToBoxAdapter();
        }

        if (snapshot.docs.isEmpty) {
          return emptyBuilder?.call(context) ?? const SliverToBoxAdapter();
        }

        return SliverAnimatedList(
          initialItemCount: snapshot.docs.length,
          findChildIndexCallback: findChildIndexCallback,
          itemBuilder: (context, index, animation) {
            if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
              // Tell FirestoreQueryBuilder to try to obtain more items.
              // It is safe to call this function from within the build method.
              snapshot.fetchMore();
            }
            return itemBuilder(context, snapshot.docs[index], animation);
          },
        );
      },
    );
  }
}
