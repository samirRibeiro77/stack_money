import 'package:flutter/material.dart';
import 'package:stack_money/features/bucket_card/manager/bucket_card_manager.dart';

class BucketCardScope extends InheritedWidget {
  final BucketCardManager manager;

  const BucketCardScope({
    super.key,
    required this.manager,
    required super.child,
  });

  static BucketCardManager of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<BucketCardScope>();
    assert(
      scope != null,
      'Nenhum BucketCardScope encontrado no BuildContext fornecido.',
    ); //TODO: l10n with better message here
    return scope!.manager;
  }

  @override
  bool updateShouldNotify(BucketCardScope oldWidget) {
    return manager != oldWidget.manager;
  }
}
