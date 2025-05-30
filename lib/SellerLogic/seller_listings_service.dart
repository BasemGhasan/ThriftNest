// lib/SellerLogic/seller_listings_service.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../SellerLogic/Item_model.dart';

/// A singleton service that keeps a live stream of the current seller’s items.
///
/// - Call `initForOwner(uid)` once you have the seller’s `uid` (e.g. right after login).
/// - Listen to `listings$` in any UI (via `StreamBuilder`) to get updates.
class SellerListingsService {
  SellerListingsService._(); // private
  static final instance = SellerListingsService._();

  final _controller = StreamController<List<ItemModel>>.broadcast();
  Stream<List<ItemModel>> get listings$ => _controller.stream;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  /// Starts (or restarts) listening to `items` where `ownerId == uid`.
  /// We do *not* use `orderBy` in the query (to avoid needing a composite index).
  /// Instead we sort in Dart by the `createdAt` timestamp field.
  void initForOwner(String uid) {
    // Cancel any previous subscription:
    _subscription?.cancel();

    _subscription = FirebaseFirestore.instance
        .collection('items')
        .where('ownerId', isEqualTo: uid)
        // no .orderBy() here
        .snapshots()
        .listen((snapshot) {
      // Take the raw docs
      final docs = snapshot.docs.toList();

      // Sort by createdAt descending in Dart
      docs.sort((a, b) {
        final ta = (a.data()['createdAt'] as Timestamp?)?.toDate();
        final tb = (b.data()['createdAt'] as Timestamp?)?.toDate();
        if (ta == null || tb == null) return 0;
        return tb.compareTo(ta);
      });

      // Map each sorted doc → model
      final items = docs.map((doc) => ItemModel.fromDoc(doc)).toList();
      _controller.add(items);
    }, onError: (err, stack) {
      debugPrint('Error in seller listings subscription: $err');
      _controller.addError(err, stack);
    });
  }

  /// Dispose when you no longer need this service (e.g. app shutdown).
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}
