import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../domain/entities/card.dart';

/// Utility class for shuffling and generating cards
class CardShuffle {
  static const _uuid = Uuid();
  static final _random = Random();

  /// List of available theme keys (excluding 'random')
  static List<String> get availableThemes => themeImages.keys.toList();

  /// Get a random theme, excluding the specified theme
  /// This ensures the same theme doesn't appear consecutively
  static String getRandomTheme({String? excludeTheme}) {
    final themes = availableThemes;
    if (excludeTheme != null && themes.length > 1) {
      themes.remove(excludeTheme);
    }
    return themes[_random.nextInt(themes.length)];
  }

  /// Available images for each theme.
  /// Every theme needs at least as many unique images as the largest level
  /// has pairs (level 20: 10x10 = 50 pairs), otherwise that level cannot start.
  static const Map<String, List<String>> themeImages = {
    'animals': [
      '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼',
      '🐨', '🐯', '🦁', '🐮', '🐷', '🐸', '🐵', '🐔',
      '🐧', '🐦', '🐤', '🦆', '🦅', '🦉', '🦇', '🐺',
      '🐗', '🐴', '🦄', '🐝', '🐛', '🦋', '🐌', '🐞',
      '🐢', '🐍', '🦎', '🐙', '🐠', '🐬', '🐳', '🦈',
      '🐊', '🐘', '🦒', '🦓', '🦏', '🐪', '🦘', '🦔',
      '🦛', '🦙', '🦜', '🦚',
    ],
    'fruits': [
      '🍎', '🍐', '🍊', '🍋', '🍌', '🍉', '🍇', '🍓',
      '🫐', '🍈', '🍒', '🍑', '🥭', '🍍', '🥥', '🥝',
      '🍅', '🍆', '🥑', '🥦', '🥬', '🥒', '🌶️', '🫑',
      '🌽', '🥕', '🧄', '🧅', '🥔', '🍠', '🥐', '🥯',
      '🥜', '🌰', '🍄', '🥧', '🍯', '🥛', '🧁', '🍰',
      '🍦', '🍨', '🍮', '🍬', '🍭', '🥖', '🥨', '🍪',
      '🍩', '🍫', '🧀', '🥞',
    ],
    'flags': [
      '🇹🇷', '🇺🇸', '🇬🇧', '🇩🇪', '🇫🇷', '🇮🇹', '🇪🇸', '🇯🇵',
      '🇰🇷', '🇨🇳', '🇧🇷', '🇷🇺', '🇮🇳', '🇦🇺', '🇨🇦', '🇲🇽',
      '🇳🇱', '🇧🇪', '🇸🇪', '🇳🇴', '🇩🇰', '🇫🇮', '🇵🇱', '🇺🇦',
      '🇬🇷', '🇵🇹', '🇦🇷', '🇨🇭', '🇦🇹', '🇮🇪', '🇳🇿', '🇿🇦',
      '🇪🇬', '🇸🇦', '🇰🇿', '🇦🇿', '🇬🇪', '🇨🇿', '🇸🇨', '🇧🇹',
      '🇯🇲', '🇧🇩', '🇨🇴', '🇬🇭', '🇳🇬', '🇰🇪', '🇳🇵', '🇧🇼',
      '🇹🇭', '🇲🇳', '🇧🇧', '🇦🇪',
    ],
    'sports': [
      '⚽', '🏀', '🏈', '⚾', '🥎', '🎾', '🏐', '🏉',
      '🥏', '🎱', '🪀', '🏓', '🏸', '🏒', '🏑', '🥍',
      '🏏', '🪃', '🥅', '⛳', '🪁', '🏹', '🎣', '🤿',
      '🥊', '🥋', '🎿', '⛷️', '🏂', '🪂', '🏋️', '🤸',
      '🏆', '🥇', '🛹', '🛷', '⛸️', '🥌', '🏊', '🏄',
      '🚴', '🏇', '🤺', '🤾', '🎽', '🧗', '🏌️', '🤼',
      '🛶', '🎳', '🎯', '🏁',
    ],
    'nature': [
      '🌸', '🌹', '🌺', '🌻', '🌼', '🌷', '🪻', '🌱',
      '🪴', '🌲', '🌳', '🌴', '🌵', '🌾', '🌿', '☘️',
      '🍀', '🍁', '🍂', '🍃', '🪺', '🪹', '🍄', '🌰',
      '🦀', '🦞', '🦐', '🦑', '🦪', '🐚', '🪸', '🪷',
      '💐', '🏝️', '🌍', '🌙', '⭐', '☀️', '🌈', '⛅',
      '❄️', '🔥', '💧', '🌊', '⚡', '🌋', '🏔️', '🌪️',
      '☔', '☄️', '🐡', '🐙',
    ],
    'travel': [
      '🚗', '🚕', '🚙', '🚌', '🚎', '🏎️', '🚓', '🚑',
      '🚒', '🚐', '🛻', '🚚', '🚛', '🚜', '🛵', '🏍️',
      '🚲', '🛴', '✈️', '🚀', '🛸', '🚁', '⛵', '🚢',
      '🚂', '🚆', '🚇', '🚊', '🚉', '🚝', '🚞', '🚋',
      '🚤', '🚡', '🚟', '🎈', '🗺️', '🏰', '🗼', '🗽',
      '🎡', '🎢', '🎠', '⛽', '🚦', '🚧', '⚓', '🗿',
      '🏖️', '⛺', '🧳', '🛎️',
    ],
    'food': [
      '🍕', '🍔', '🍟', '🌭', '🥪', '🌮', '🌯', '🫔',
      '🥙', '🧆', '🥚', '🍳', '🥘', '🍲', '🫕', '🥣',
      '🥗', '🍿', '🧈', '🧂', '🥫', '🍱', '🍘', '🍙',
      '🍚', '🍛', '🍜', '🍝', '🍠', '🍢', '🍣', '🍤',
      '🍥', '🥟', '🥠', '🥡', '🍖', '🥩', '🥓', '🧀',
      '🥞', '🍞', '🥖', '🥨', '🍡', '🎂', '🍩', '🍪',
      '☕', '🍫', '🥤', '🍯',
    ],
    'objects': [
      '⌚', '📱', '💻', '⌨️', '🖥️', '🖨️', '🖱️', '💾',
      '💿', '📀', '📷', '📸', '📹', '🎥', '📽️', '🎞️',
      '📞', '☎️', '📺', '📻', '🎙️', '🎚️', '🎛️', '🧭',
      '⏱️', '⏲️', '⏰', '🕰️', '💡', '🔦', '🏮', '🪔',
      '🔑', '🔒', '🔔', '📦', '✏️', '📎', '✂️', '📌',
      '📚', '🎁', '🧸', '🔨', '🔧', '🧲', '🔋', '🔌',
      '🔭', '☂️', '🎒', '👓',
    ],
  };

  /// Generates a shuffled list of cards for the game
  ///
  /// [pairs] - Number of pairs to generate
  /// [theme] - Theme name to get images from
  static List<GameCard> generateCards({
    required int pairs,
    String theme = 'animals',
  }) {
    final images = themeImages[theme] ?? themeImages['animals']!;

    // Take random images for the required number of pairs
    final selectedImages = _selectRandomImages(images, pairs);

    final cards = <GameCard>[];

    // Create two cards for each image (pair)
    for (int i = 0; i < pairs; i++) {
      final pairId = _uuid.v4();
      final image = selectedImages[i];

      // First card of the pair
      cards.add(GameCard(
        id: _uuid.v4(),
        pairId: pairId,
        imageAsset: image,
        position: -1, // Will be set after shuffle
        theme: theme,
      ));

      // Second card of the pair
      cards.add(GameCard(
        id: _uuid.v4(),
        pairId: pairId,
        imageAsset: image,
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

  /// Selects random unique images from the available list
  static List<String> _selectRandomImages(List<String> images, int count) {
    if (count > images.length) {
      throw ArgumentError(
        'Requested $count pairs but only ${images.length} images available',
      );
    }

    final shuffled = List<String>.from(images);
    _fisherYatesShuffle(shuffled);
    return shuffled.take(count).toList();
  }

  /// Fisher-Yates shuffle algorithm for unbiased shuffling
  static void _fisherYatesShuffle<T>(List<T> list) {
    for (int i = list.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
  }
}
