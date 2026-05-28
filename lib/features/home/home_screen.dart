import 'package:flutter/material.dart';
import 'package:stack_money/features/home/widgets/home_header.dart';
import 'package:stack_money/features/home/widgets/patrimonial_hud.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const route = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<bool> _visibilityNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _visibilityNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: true,
        top: false,
        child: CustomScrollView(
          slivers: [
            HomeHeader(visibilityNotifier: _visibilityNotifier),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PatrimonialHud(
                      totalAmount: 223025.27, // Seu valor real do dia 22/05!
                      liquidityAmount: 3283.76, // Exemplo somando NuConta + NuCaixa do histórico
                      visibilityListenable: _visibilityNotifier,
                    ),

                    const SizedBox(height: 24),

                    // TODO: Próximo bloco (Feature 5.3 - Gráfico de Mini-linha + Filtros flutuantes) entrará aqui

                    const SizedBox(height: 800), // Espaçador de scroll temporário
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