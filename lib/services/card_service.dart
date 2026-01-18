import 'dart:math';
import 'package:uuid/uuid.dart';
import '../domain/entities/card.dart';

/// Service for card operations like shuffling and generating cards
class CardService {
  final Uuid _uuid = const Uuid();
  final Random _random = Random();

  /// Available card images for each theme
  static const Map<String, List<String>> themeImages = {
    'animals': [
      'cat',
      'dog',
      'bird',
      'fish',
      'rabbit',
      'turtle',
      'elephant',
      'lion',
      'monkey',
      'panda',
      'penguin',
      'koala',
      'fox',
      'owl',
      'dolphin',
      'butterfly',
      'bee',
      'ladybug',
      'frog',
      'snail',
      'crab',
      'octopus',
      'whale',
      'shark',
      'horse',
      'cow',
      'pig',
      'sheep',
      'chicken',
      'duck',
      'bear',
      'wolf',
    ],
  };

  /// Generate a shuffled deck of cards for the game
  /// [pairs] - Number of pairs to generate
  /// [theme] - Theme to use for card images
  List<GameCard> generateCards({
    required int pairs,
    String theme = 'animals',
  }) {
    final images = _getThemeImages(theme, pairs);
    final cards = <GameCard>[];

    // Create pairs of cards
    for (int i = 0; i < pairs; i++) {
      final pairId = _uuid.v4();
      final imageAsset = images[i];

      // Create two cards with the same pairId
      cards.add(GameCard(
        id: _uuid.v4(),
        pairId: pairId,
        imageAsset: imageAsset,
        position: -1, // Will be assigned after shuffle
        theme: theme,
      ));

      cards.add(GameCard(
        id: _uuid.v4(),
        pairId: pairId,
        imageAsset: imageAsset,
        position: -1,
        theme: theme,
      ));
    }

    // Shuffle using Fisher-Yates algorithm
    _fisherYatesShuffle(cards);

    // Assign positions after shuffle
    for (int i = 0; i < cards.length; i++) {
      cards[i] = cards[i].copyWith(position: i);
    }

    return cards;
  }

  /// Get images for a theme, limited to the required count
  List<String> _getThemeImages(String theme, int count) {
    final allImages = themeImages[theme] ?? themeImages['animals']!;

    if (count > allImages.length) {
      throw ArgumentError(
        'Not enough images for $count pairs. Theme "$theme" has ${allImages.length} images.',
      );
    }

    // Shuffle and take required count
    final shuffled = List<String>.from(allImages);
    _fisherYatesShuffle(shuffled);
    return shuffled.take(count).toList();
  }

  /// Fisher-Yates shuffle algorithm
  /// Produces an unbiased permutation with O(n) time complexity
  void _fisherYatesShuffle<T>(List<T> list) {
    for (int i = list.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      // Swap elements
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
  }

  /// Get the asset path for a card image
  String getCardAssetPath(String theme, String imageName) {
    return 'assets/images/themes/$theme/$imageName.png';
  }

  /// Get the card back asset path
  String getCardBackAssetPath({String style = 'default'}) {
    return 'assets/images/card_backs/$style.png';
  }
}
