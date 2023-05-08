import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

typedef FirestoreEmptyBuilder = Widget Function(BuildContext context);

int _kDefaultSemanticIndexCallback(Widget _, int localIndex) => localIndex;

/// Sliver version of the [FirestoreListView]
class FirestoreSliverListView<T> extends StatelessWidget {
  final Query<T> query;
  final FirestoreItemBuilder<T> itemBuilder;
  final FirestoreLoadingBuilder? loadingBuilder;
  final FirestoreErrorBuilder? errorBuilder;
  final FirestoreEmptyBuilder? emptyBuilder;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final int semanticIndexOffset;
  final SemanticIndexCallback semanticIndexCallback;
  final ChildIndexGetter? findChildIndexCallback;
  final int pageSize;

  const FirestoreSliverListView({
    super.key,
    required this.query,
    required this.itemBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.findChildIndexCallback,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.semanticIndexCallback = _kDefaultSemanticIndexCallback,
    this.semanticIndexOffset = 0,
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

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                // Tell FirestoreQueryBuilder to try to obtain more items.
                // It is safe to call this function from within the build method.
                snapshot.fetchMore();
              }

              return itemBuilder(context, snapshot.docs[index]);
            },
            childCount: snapshot.docs.length,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
            semanticIndexCallback: semanticIndexCallback,
            semanticIndexOffset: semanticIndexOffset,
          ),
        );
      },
    );
  }
}
