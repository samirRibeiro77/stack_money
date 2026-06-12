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
        title: ValueListenableBuilder<SalaryPlan>(
          valueListenable: _manager.planNotifier,
          builder: (context, currentPlan, _) {
            return Text(
              'EDIT: ${currentPlan.name.toUpperCase()}',
              style: const TextStyle(fontFamily: 'Orbitron', fontSize: 14, fontWeight: FontWeight.bold, color: StackMoneyTheme.platinumSilver),
            );
          },
        ),
        actions: [
          // Botão Rápido para Forçar Ativação Direto do Editor
          ValueListenableBuilder<SalaryPlan>(
            valueListenable: _manager.planNotifier,
            builder: (context, currentPlan, _) {
              if (currentPlan.isActive) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Center(child: Text('[ ACTIVE ]', style: TextStyle(fontFamily: 'Orbitron', color: StackMoneyTheme.cyanNeon, fontSize: 10, fontWeight: FontWeight.bold))),
                );
              }
              return TextButton(
                onPressed: _manager.triggerPlanActivation,
                child: const Text('[ SET_ACTIVE ]', style: TextStyle(fontFamily: 'Orbitron', color: StackMoneyTheme.cyanNeon, fontSize: 11, fontWeight: FontWeight.bold)),
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
                // 🟢 SEÇÃO 1: Fluxo de Entradas
                SliverToBoxAdapter(
                  child: InflowSection(
                    plan: currentPlan,
                    onUpdate: _manager.updateInflow,
                    onRemove: _manager.removeInflow,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSizes.x8)),

                // 🔴 SEÇÃO 2: Fluxo de Descontos
                SliverToBoxAdapter(
                  child: OutflowSection(
                    plan: currentPlan,
                    onAdd: _manager.addOutflow,
                    onUpdate: _manager.updateOutflow,
                    onRemove: _manager.removeOutflow,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSizes.x8)),

                // 📊 STICKY HUD: Divisor Inteligente com Barra de Progresso Preservada no Topo
                SliverPersistentHeader(
                  pinned: true,
                  delegate: NetSalaryStickyHud(plan: currentPlan),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSizes.x8)),

                // ⚡ SEÇÃO 3: Matriz de Distribuição
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