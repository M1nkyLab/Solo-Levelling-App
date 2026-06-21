import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo_levelling_app/features/player/player_provider.dart';
import 'package:solo_levelling_app/features/player/shadow_extraction.dart';

class ShadowNotifier extends Notifier<List<Shadow>> {
  @override
  List<Shadow> build() {
    final player = ref.watch(playerProvider);
    return allAvailableShadows.where((shadow) => 
      player.extractedShadows.contains(shadow.id)
    ).toList();
  }

  void extractShadow(String shadowId) {
    final player = ref.read(playerProvider);
    if (player.extractedShadows.contains(shadowId)) return;

    final newExtracted = [...player.extractedShadows, shadowId];
    ref.read(playerProvider.notifier).state = player.copyWith(
      extractedShadows: newExtracted,
    );
  }
}

final shadowProvider = NotifierProvider<ShadowNotifier, List<Shadow>>(() {
  return ShadowNotifier();
});
