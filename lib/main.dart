import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_taker_app/core/theme/app_theme.dart';
import 'package:note_taker_app/data/repositories/note_respository.dart';
import 'package:note_taker_app/features/auth/bloc/auth_bloc.dart';
import 'package:note_taker_app/features/auth/presentation/screens/login_screen.dart';
import 'package:note_taker_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:note_taker_app/features/notes/bloc/notes_bloc.dart';
import 'package:note_taker_app/features/notes/presentation/screens/notes_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(FirebaseAuth.instance),
        ),
        BlocProvider(
          create: (context) => NotesBloc(
            NoteRepositoryImpl(
              firestore: FirebaseFirestore.instance,
              auth: FirebaseAuth.instance,
            ),
          )..add(NotesFetchRequested()),
        ),
      ],
      child: MaterialApp(
        title: 'Notes App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) {
              return StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  // Show loading indicator while checking auth state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  // User is logged in
                  if (snapshot.hasData) {
                    // Initialize notes if coming from auth flow
                    if (settings.name == '/notes') {
                      context.read<NotesBloc>().add(NotesFetchRequested());
                    }
                    return const NotesScreen();
                  }

                  // User is not logged in - route to appropriate auth screen
                  switch (settings.name) {
                    case '/signup':
                      return const SignUpScreen();
                    case '/login':
                    default:
                      return const LoginScreen();
                  }
                },
              );
            },
          );
        },
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/notes': (context) => const NotesScreen(),
        },
      ),
    );
  }
}