import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:uuid/uuid.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/domain/service/parameter_service.dart';
import 'package:stack_money/features/buckets/widgets/bucket_edit_card.dart';

class BucketControlScreen extends StatefulWidget {
  const BucketControlScreen({required this.securityMode, super.key});

  static const route = '/buckets_control';
  final ValueListenable<bool> securityMode;

  @override
  State<BucketControlScreen> createState() => _BucketControlScreenState();
}

class _BucketControlScreenState extends State<BucketControlScreen> {
  List<Bucket> _bucketDeck = [];
  bool _isLoading = true;

  // 🗝️ REGISTRO DE CHAVES GLOBAIS PARA CONTROLAR OS POTES EM LOTE
  final List<GlobalKey<BucketEditCardState>> _bucketKeys = [];
  bool _masterExpandState = true;

  @override
  void initState() {
    super.initState();
    _loadFirebaseBuckets();

    // Se fechar o olho na AppBar, o app força o fechamento dos painéis abertos por segurança
    widget.securityMode.addListener(() {
      if (!widget.securityMode.value && mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _loadFirebaseBuckets() async {
    try {
      setState(() => _isLoading = true);
      final data = await ParameterManagementService().getActiveParameters();
      setState(() {
        _bucketDeck = data;

        // Inicializa as chaves globais para cada pote carregado
        _bucketKeys.clear();
        for (var i = 0; i < _bucketDeck.length; i++) {
          _bucketKeys.add(GlobalKey<BucketEditCardState>());
        }

        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG_SYSTEM [BucketControlScreen]: Fail to fetch -> $e');
      setState(() => _isLoading = false);
    }
  }

  // 📡 COMANDO AUTO-SAVE VINCULADO AO FOCUS OUT
  Future<void> _saveBucketToFirebase(Bucket updatedBucket) async {
    try {
      await ParameterManagementService().saveParameter(updatedBucket);
      final index = _bucketDeck.indexWhere((b) => b.id == updatedBucket.id);
      if (index != -1) {
        _bucketDeck[index] = updatedBucket;
        setState(() {}); // Recalcula identidades e estados visuais na hora
      }
    } catch (e) {
      print('DEBUG_SYSTEM [BucketControlScreen]: Save fail -> $e');
    }
  }

  // ➕ MATRIX SLOT INSERTION: Cria o frame fantasma com UUID instantâneo
  void _initializeNewBucketSlot() {
    final newUuid = const Uuid().v4();
    final newBucket = Bucket.withId(
      id: newUuid,
      where: '',
      category: '',
      minValue: 0.0,
      isImmediateLiquidity: false,
    );

    setState(() {
      _bucketDeck.add(newBucket);
      _bucketKeys.add(GlobalKey<BucketEditCardState>());
    });
    _saveBucketToFirebase(newBucket);
  }

  // 🗑️ COMANDO PURGE: Exclui do Firebase e limpa a viewport local
  Future<void> _purgeBucket(String id) async {
    try {
      await ParameterManagementService().deleteParameter(id);
      final index = _bucketDeck.indexWhere((b) => b.id == id);
      if (index != -1) {
        setState(() {
          _bucketDeck.removeAt(index);
          _bucketKeys.removeAt(index);
        });
      }
    } catch (e) {
      print('DEBUG_SYSTEM [BucketControlScreen]: Purge fail -> $e');
      _loadFirebaseBuckets(); // Restaura o estado caso o Safe Interceptor interrompa a deleção
    }
  }

  // 🎯 DISPARA O COMANDO EM LOTE NAS GLOBAL KEYS (SIMETRIA COM O DASHBOARD)
  void _toggleAllBuckets() {
    for (var key in _bucketKeys) {
      key.currentState?.setExpandedState(_masterExpandState);
    }
    setState(() {
      _masterExpandState = !_masterExpandState;
    });
  }

  // 🚨 TERMINAL CONFIRM DIALOG: Prompt limpo e direto em estilo de linha de comando
  Future<bool?> _showTerminalConfirmDialog(String bucketName) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: StackMoneyTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: const BorderSide(color: StackMoneyTheme.magentaNeon, width: 0.5),
          ),
          title: const Text('[SYSTEM_WARNING]', style: TextStyle(fontFamily: 'Orbitron', color: StackMoneyTheme.magentaNeon, fontSize: 14)),
          content: Text(
            'EXECUTE PURGE PROTOCOL ON BUCKET:\n"${bucketName.toUpperCase()}"?\n\nALL ALLOCATION PARAMETERS WILL BE EXPURGED.',
            style: const TextStyle(fontFamily: 'JetBrainsMono', color: StackMoneyTheme.platinumSilver, fontSize: 11, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('[CANCEL]', style: TextStyle(fontFamily: 'JetBrainsMono', color: StackMoneyTheme.mutedGrey, fontSize: 12)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('[PURGE_DATA]', style: TextStyle(fontFamily: 'JetBrainsMono', color: StackMoneyTheme.magentaNeon, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: StackMoneyTheme.cyanNeon,
          backgroundColor: StackMoneyTheme.surface,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisSize: MainAxisSize.min,
        children: [
          // 🎛️ RÓTULO TÁTICO + BOTÃO MESTRE SÍNCRONO REATIVO
          ValueListenableBuilder<bool>(
            valueListenable: widget.securityMode,
            builder: (context, isVisible, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    StackMoneyString.formatTitle('MATRIX_BUCKETS_CONFIG'),
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: AppTypography.weightBold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  if (isVisible)
                    IconButton(
                      onPressed: _toggleAllBuckets,
                      icon: Icon(
                        _masterExpandState
                            ? Icons.unfold_more
                            : Icons.unfold_less,
                        color: _masterExpandState
                            ? StackMoneyTheme.cyanNeon
                            : StackMoneyTheme.magentaNeon,
                        size: AppSizes.x10,
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSizes.x12),

          // 🔋 DECK DE CONFIGURAÇÃO INTEGRADO AO SWIPE-TO-DELETE (DISMISSIBLE)
          ...List.generate(_bucketDeck.length, (index) {
            final bucket = _bucketDeck[index];
            final displayName = bucket.where.isEmpty ? "UNINITIALIZED_SLOT" : "${bucket.category}_${bucket.where}";

            return Dismissible(
              key: Key(bucket.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) => _showTerminalConfirmDialog(displayName),
              onDismissed: (direction) => _purgeBucket(bucket.id),
              background: Container(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: StackMoneyTheme.magentaNeon.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: StackMoneyTheme.magentaNeon.withOpacity(0.3), width: 0.5),
                ),
                alignment: Alignment.centerRight,
                child: const Icon(Icons.delete_forever_rounded, color: StackMoneyTheme.magentaNeon, size: 24),
              ),
              child: BucketEditCard(
                key: _bucketKeys[index], // 🔥 VINCULAÇÃO DE CHAVE HISTÓRICA
                bucket: bucket,
                securityMode: widget.securityMode,
                onAutoSave: _saveBucketToFirebase,
              ),
            );
          }),

          const SizedBox(height: AppSizes.x4),

          // 🛸 MATRIX SLOT INSERTION (O frame de engenharia puramente tracejado nativo)
          GestureDetector(
            onTap: _initializeNewBucketSlot,
            child: Container(
              width: double.infinity,
              height: 52,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: CustomPaint(
                painter: _MatrixDashedPainter(color: StackMoneyTheme.mutedGrey.withOpacity(0.35)),
                child: const Center(
                  child: Text(
                    '+ INITIALIZE_NEW_BUCKET_SLOT',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      color: StackMoneyTheme.mutedGrey,
                      fontSize: 10,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 120), // Margem tática para isolar a Floating Matrix Capsule
        ],
      ),
    );
  }
}

/// 🎨 ENGINE DE PINTURA TRACEJADA CYBERPUNK NATIVA
class _MatrixDashedPainter extends CustomPainter {
  _MatrixDashedPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12.0),
    );

    final Path path = Path()..addRRect(rrect);
    const double dashWidth = 6.0;
    const double dashSpace = 4.0;

    final Path metricsPath = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double length = (distance + dashWidth < metric.length) ? dashWidth : metric.length - distance;
        metricsPath.addPath(metric.extractPath(distance, distance + length), Offset.zero);
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(metricsPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}