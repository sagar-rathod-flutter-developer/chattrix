import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    // LOGIN
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(AuthSuccess());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    // SIGNUP
    on<SignupEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: event.email,
              password: event.password,
            );

        final uid = userCredential.user!.uid;
        final token = await FirebaseMessaging.instance.getToken();
        print("Uid : ${userCredential.user?.uid}");
        print("Token : ${token.toString()}");

        // ✅ SAVE USER DATA TO FIRESTORE
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': event.name,
          'email': event.email,
          'fcmToken': token,
          'isOnline': true,
        });

        emit(AuthSuccess());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
