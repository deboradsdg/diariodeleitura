import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/tela_principal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://axmvibhtgnejkjzlerkb.supabase.co',
    publishableKey: 'sb_publishable_lPZiIBvYkyu0iJnjhfPyog_5oCJO6G5',
  );

  runApp(const DiarioLeituraApp());
}

class DiarioLeituraApp extends StatelessWidget {
  const DiarioLeituraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diário de Leitura',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TelaPrincipal(),
    );
  }
}