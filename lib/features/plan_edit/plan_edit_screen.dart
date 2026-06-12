import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/features/plan_edit/manager/plan_edit_manager.dart';
import 'package:stack_money/features/plan_edit/widgets/inflow_section.dart';
import 'package:stack_money/features/plan_edit/widgets/outflow_section.dart';
import 'package:stack_money/features/plan_edit/widgets/net_salary_sticky_hud.dart';
import 'package:stack_money/features/plan_edit/widgets/distribution_section.dart';

class PlanEditScreen extends StatefulWidget {
  final SalaryPlan plan;

  const PlanEditScreen({required this.plan, super.key});

  @override
  State<PlanEditScreen> createState() => _PlanEditScreenState();
}

class _PlanEditScreenState extends State<PlanEditScreen> {
  late final PlanEditManager _manager;

  @override
  void initState() {
    super.initState();
    _manager = PlanEditManager(widget.plan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StackMoneyTheme.background,
      appBar: AppBar(
        backgroundColor: StackMoneyTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: StackMoneyTheme.platinumSilver, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),

        // 🔥 MELHORIA 1.1: Título Transformado em campo de texto editável direto na barra
        title: TextFormField(
          initialValue: _manager.currentPlan.name,
          style: const TextStyle(fontFamily: 'Orbitron', fontSize: 15, fontWeight: FontWeight.bold, color: StackMoneyTheme.platinumSilver),
          decoration: InputDecoration(
            border: InputBorder.none,       // Remove a borda padrão de erro/desabilitado
            enabledBorder: InputBorder.none,// Sem borda quando o campo está ocioso
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: StackMoneyTheme.cyanNeon, // Cor da linha ao clicar
                width: 1.0,                            // Espessura da linha
              ),
            ),
            filled: false,                  // Garante que não haverá cor de fundo
            isDense: true,                  // Compacta o espaço interno do campo
            contentPadding: const EdgeInsets.symmetric(vertical: 8.0), // Ajusta o respiro acima da linha
          ),
          onChanged: _manager.updatePlanName,
        ),
        centerTitle: false,
        actions: [
          ValueListenableBuilder<SalaryPlan>(
            valueListenable: _manager.planNotifier,
            builder: (context, currentPlan, _) {
              if (currentPlan.isActive) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Center(child: Text('[ ACTIVE ]', style: TextStyle(fontFamily: 'Orbitron', color: StackMoneyTheme.cyanNeon, fontSize: 10, fontWeight: FontWeight.bold))),
                );
              }

              // 🔥 MELHORIA 1.2: Botão inerte/inativo rebaixado para cor fosca Platinum sem o ciano neon chamativo
              return TextButton(
                onPressed: () async {
                  await _manager.triggerPlanActivation();
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('[ SET_ACTIVE ]', style: TextStyle(fontFamily: 'Orbitron', color: StackMoneyTheme.platinumSilver, fontSize: 11)),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<SalaryPlan>(
        valueListenable: _manager.planNotifier,
        builder: (context, currentPlan, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: InflowSection(
                    plan: currentPlan,
                    onBaseUpdate: _manager.updateBaseSalary,
                    onUpdate: _manager.updateInflow,
                    onRemove: _manager.removeInflow,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSizes.x8)),

                SliverToBoxAdapter(
                  child: OutflowSection(
                    plan: currentPlan,
                    onUpdate: _manager.updateOutflow,
                    onRemove: _manager.removeOutflow,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSizes.x8)),

                SliverPersistentHeader(
                  pinned: true,
                  delegate: NetSalaryStickyHud(plan: currentPlan),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSizes.x8)),

                SliverToBoxAdapter(
                  child: DistributionSection(
                    plan: currentPlan,
                    onAddSlot: _manager.initializeNewDistributionSlot,
                    onUpdate: _manager.updateDistribution,
                    onRemove: _manager.removeDistribution,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          );
        },
      ),
    );
  }
}