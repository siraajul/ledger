import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Runs the Google sign-in flow and exchanges the result for a Firebase session.
///
/// Throws [GoogleSignInException] (code `canceled` when the user backs out) or
/// [FirebaseAuthException].
Future<UserCredential> signInWithGoogle() async {
  final account = await GoogleSignIn.instance.authenticate();
  final idToken = account.authentication.idToken;
  if (idToken == null) {
    throw FirebaseAuthException(
      code: 'missing-id-token',
      message: 'Google did not return an ID token.',
    );
  }
  return FirebaseAuth.instance.signInWithCredential(
    GoogleAuthProvider.credential(idToken: idToken),
  );
}

Future<void> signOut() async {
  await GoogleSignIn.instance.signOut();
  await FirebaseAuth.instance.signOut();
}
