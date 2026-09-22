import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Profile settings (name, budget, onboarding) stored on the signed-in user's
/// `users/{uid}` document so they follow the account across devices.
///
/// Field names: [kName], [kBudget], [kOnboardingComplete].
class SettingsRepository {
  static final SettingsRepository instance = SettingsRepository._();

  SettingsRepository._();

  static const kName = 'name';
  static const kBudget = 'budget';
  static const kOnboardingComplete = 'onboardingComplete';

  DocumentReference<Map<String, dynamic>> get _doc {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Settings are only available while signed in.');
    }
    return FirebaseFirestore.instance.collection('users').doc(user.uid);
  }

  /// Live settings. Emits `null` while it is still unknown whether the
  /// document exists (an empty local cache), so callers keep showing a loader
  /// instead of flashing onboarding on a device that hasn't synced yet.
  Stream<Map<String, dynamic>?> watch() =>
      _doc.snapshots().asyncMap((snap) async {
        final data = snap.data();
        if (data != null) return data;
        if (snap.metadata.isFromCache) return null;
        // The server confirms there is no document: first sign-in anywhere.
        return await _migrateLegacyLocalSettings() ?? const {};
      });

  /// Merges [fields] into the document. Not awaited by callers: the local
  /// cache applies it immediately and syncs when the device is online.
  Future<void> update(Map<String, Object> fields) =>
      _doc.set(fields, SetOptions(merge: true));

  /// Uploads settings saved on this device by pre-sync builds, then deletes
  /// them locally so a different account signing in here doesn't inherit them.
  Future<Map<String, Object>?> _migrateLegacyLocalSettings() async {
    final prefs = await SharedPreferences.getInstance();
    const legacyKeys = {
      'user_name': kName,
      'monthly_budget': kBudget,
      'onboarding_complete': kOnboardingComplete,
    };
    final fields = <String, Object>{
      for (final e in legacyKeys.entries)
        if (prefs.get(e.key) != null) e.value: prefs.get(e.key)!,
    };
    if (fields.isEmpty) return null;
    // Pending writes survive in the local cache, so no need to wait for the
    // server before dropping the local copies.
    unawaited(update(fields));
    for (final key in legacyKeys.keys) {
      await prefs.remove(key);
    }
    return fields;
  }
}
