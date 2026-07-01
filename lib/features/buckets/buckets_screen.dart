import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/security_provider.dart'; // 🔥 Import do escudo tático
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/card_initialize_slot.dart';
import 'package:stack_money/core/widgets/expandable_header.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/features/buckets/manager/buckets_manager.dart';
import 'package:stack_money/features/buckets/widgets/bucket_card.dart';
import 'package:stack_money/features/buckets/widgets/bucket_edit_card.dart'; // 🔥 Import necessário para o feedback do drag

class BucketControlScreen extends StatefulWidget {
  const BucketControlScreen({super.key = const ValueKey(route)});

  static const route = '/buckets';

  @override
  State<BucketControlScreen> createState() => _BucketControlScreenState();
}

class _BucketControlScreenState extends State<BucketControlScreen> {
  final _manager = BucketsManager();

  @override
  void initState() {
    super.initState();
    _manager.loadFirebaseBuckets();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ValueListenableBuilder<bool>(
      valueListenable: _manager.isLoading,
      builder: (_, isLoading, _) {
        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: StackMoneyTheme.cyanNeon,
              backgroundColor: StackMoneyTheme.surface,
            ),
          );
        }

        return ValueListenableBuilder<List<Bucket>>(
          valueListenable: _manager.bucketDeckNotifier,
          builder: (_, bucketList, _) {
            return ValueListenableBuilder<Set<String>>(
              valueListenable: _manager.expandedIdsNotifier,
              builder: (_, expandedIds, _) {
                return _buildBucketsContent(l10n, bucketList, expandedIds);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBucketsContent(
    AppLocalizations l10n,
    List<Bucket> bucketList,
    Set<String> expandedIds,
  ) {
    // 🔥 LEITURA REATIVA: Mapeia se o escudo do modo seguro está ativo
    final bool isSecureActive = SecurityProvider.isSecureOf(context);

    final sortedBuckets = List<Bucket>.from(bucketList);
    // Ordenação prioritária baseada no indexador manual de posições
    sortedBuckets.sort((a, b) => a.position.compareTo(b.position));

    return SingleChildScrollView(
      child: Column(
        children: [
          ExpandableHeader(
            title: l10n.bucketsConfig,
            validation: _manager.expandState,
            toggle: _manager.toggleAllBuckets,
          ),
          const SizedBox(height: AppSizes.sizedBoxMedium),

          CardInitializeSlot(
            l10n.newBucket,
            onTap: _manager.initializeNewBucketSlot,
          ),
          const SizedBox(height: AppSizes.sizedBoxSmall),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(sortedBuckets.length, (index) {
              final bucket = sortedBuckets[index];
              final isCardExpanded = expandedIds.contains(bucket.id);

              final bucketCardWidget = BucketCard(
                key: ValueKey(bucket.id),
                bucket: bucket,
                isExpanded: isCardExpanded,
                onHeaderTap: () => _manager.toggleBucketExpansion(bucket.id),
                confirmDismiss: _manager.showTerminalConfirmDialog,
                onDismissed: _manager.purgeBucket,
                onAutoSave: _manager.saveBucketToFirebase,
              );

              // 🔥 BUG FIX EXECUTADO: Se o modo seguro estiver ligado, congela o drag e retorna o card direto
              if (isSecureActive) {
                return bucketCardWidget;
              }

              // Drag System Cyberpunk liberado em modo normal
              return DragTarget<int>(
                onAcceptWithDetails: (details) {
                  _manager.reorderFilteredBuckets(
                    sortedBuckets,
                    details.data,
                    index,
                  );
                },
                builder: (context, candidateData, rejectedData) {
                  final bool isHovered =
                      candidateData.isNotEmpty && candidateData.first != index;
                  final Color techColor = bucket.minValue < 0
                      ? StackMoneyTheme.magentaNeon
                      : StackMoneyTheme.cyanNeon;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🔥 MELHORIA HOMOLOGADA: Linha surge apenas no drag e some $100\%$ no repouso
                      if (isHovered)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: AppSizes.x4,
                          margin: const EdgeInsets.symmetric(
                            vertical: AppSizes.min,
                          ),
                          decoration: BoxDecoration(
                            color: techColor.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusSmall,
                            ),
                            border: Border.all(
                              color: techColor.withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                        ),

                      LongPressDraggable<int>(
                        data: index,
                        axis: Axis.vertical,
                        maxSimultaneousDrags: 1,
                        feedback: Material(
                          color: Colors.transparent,
                          child: Opacity(
                            opacity: 0.75,
                            child: SizedBox(
                              width:
                                  MediaQuery.of(context).size.width -
                                  AppSizes.x16,
                              child: BucketEditCard(
                                bucket: bucket,
                                isExpanded: false,
                                onHeaderTap: () {},
                                onAutoSave: (_) {},
                              ),
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.15,
                          child: BucketEditCard(
                            bucket: bucket,
                            isExpanded: isCardExpanded,
                            onHeaderTap: () {},
                            onAutoSave: (_) {},
                          ),
                        ),
                        child: bucketCardWidget,
                      ),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
