import 'package:flutter/material.dart';
import 'package:stack_money/features/home/widgets/home_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const route = '/home';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        // Desativamos o safearea no topo para a AppBar colar na barra de status lindamente
        bottom: true,
        top: false,
        child: CustomScrollView(
          slivers: [
            // 1. O Header inteligente que flutua e reage ao scroll
            HomeHeader(),

            // 2. O conteúdo da página envelopado em um adaptador
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TODO: Próximo bloco (Feature 5.2 - HUD Patrimonial Total) entrará aqui

                    // Box temporário gigante só para você conseguir testar o scroll no emulador agora
                    SizedBox(height: 1200),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}