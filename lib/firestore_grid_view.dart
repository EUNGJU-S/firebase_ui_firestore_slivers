import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'firestore_sliver_list_view.dart';

/// Grid version of the [FirestoreListView]
class FirestoreGridView<T> extends StatelessWidget {
  final SliverGridDelegate gridDelegate;
  final Query<T> query;
  final FirestoreItemBuilder<T> itemBuilder;
  final FirestoreLoadingBuilder? loadingBuilder;
  final FirestoreErrorBuilder? errorBuilder;
  final FirestoreEmptyBuilder? emptyBuilder;
  final int pageSize;

  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final Clip clipBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final ChildIndexGetter? findChildIndexCallback;

  const FirestoreGridView({
    super.key,
    required this.query,
    required this.itemBuilder,
    required this.gridDelegate,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.pageSize = 10,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.findChildIndexCallback,
  });

  @override
  Widget build(BuildContext context) {
    return FirestoreQueryBuilder<T>(
      query: query,
      pageSize: pageSize,
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return loadingBuilder?.call(context) ??
              const Center(child: CircularProgressIndicator.adaptive());
        }

        if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error ?? '',
                  snapshot.stackTrace ?? StackTrace.empty) ??
              const SizedBox();
        }

        if (snapshot.docs.isEmpty) {
          return emptyBuilder?.call(context) ?? const SizedBox();
        }

        return GridView.builder(
          scrollDirection: scrollDirection,
          padding: padding,
          reverse: reverse,
          controller: controller,
          primary: primary,
          physics: physics,
          shrinkWrap: shrinkWrap,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          cacheExtent: cacheExtent,
          semanticChildCount: semanticChildCount,
          dragStartBehavior: dragStartBehavior,
          clipBehavior: clipBehavior,
          keyboardDismissBehavior: keyboardDismissBehavior,
          restorationId: restorationId,
          findChildIndexCallback: findChildIndexCallback,
          gridDelegate: gridDelegate,
          itemCount: snapshot.docs.length,
          itemBuilder: (context, index) {
            if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
              // Tell FirestoreQueryBuilder to try to obtain more items.
              // It is safe to call this function from within the build method.
              snapshot.fetchMore();
            }

            return itemBuilder(context, snapshot.docs[index]);
          },
        );
      },
    );
  }
}
