import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const route = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String inputPrefix = '+ ';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // DefaultTabController wrapped to showcase the reactive TabBarTheme instantly
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.appName),
          // Dynamic Tabs: Selected turns Magenta Neon, line indicator turns Cyan Neon
          bottom: const TabBar(
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(text: 'DAY 05'),
              Tab(text: 'DAY 20'),
              Tab(text: 'BONUS'),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Typography & Orbitron title style preview
              Text(
                'HUD TERMINAL ACTIVE',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: StackMoneyTheme.cyanNeon,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Welcome, Commander Samir. Reviewing your active wallet parameters...',
                style: TextStyle(height: 1.4),
              ),
              const SizedBox(height: 28),

              // Card Theme Preview (Wallet Box with Delta indicator)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Safety Box',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          // Custom Badge showing Cyan Neon for positive metrics
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: StackMoneyTheme.carbonGrey,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '+R\$ 590,29',
                              style: TextStyle(
                                color: StackMoneyTheme.cyanNeon,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Min:    R\$ 15.000,00',
                        style: TextStyle(color: StackMoneyTheme.mutedGrey),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Actual: R\$ 15.590,29',
                        style: TextStyle(color: StackMoneyTheme.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              const SizedBox(height: 28),

              // Quick Action Buttons (+ and -) using Carbon Grey and Neon icons
              Row(
                children: [
                  ElevatedButton(
                    style: StackMoneyTheme.platinumActionButtonStyle,
                    onPressed: () => setState(() {
                      inputPrefix = "+ ";
                    }),
                    child: Icon(Icons.add, color: StackMoneyTheme.cyanNeon),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: StackMoneyTheme.platinumActionButtonStyle,
                    onPressed: () => setState(() {
                      inputPrefix = "- ";
                    }),
                    child: Icon(
                      Icons.remove,
                      color: StackMoneyTheme.magentaNeon,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: // Interactive TextField Preview (Tap to see the Cyan border and Magenta label flare up)
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefix: Text(inputPrefix),
                        labelText: 'Valor atual',
                        hintText: '0.00',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
