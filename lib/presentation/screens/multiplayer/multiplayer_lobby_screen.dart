import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/game_config.dart';
import '../../../domain/entities/player.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart';
import '../game/game_screen.dart';

/// Multiplayer lobby screen for setting up local multiplayer games
class MultiplayerLobbyScreen extends ConsumerStatefulWidget {
  const MultiplayerLobbyScreen({super.key});

  @override
  ConsumerState<MultiplayerLobbyScreen> createState() =>
      _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState
    extends ConsumerState<MultiplayerLobbyScreen> {
  int _playerCount = 2;
  int _selectedLevel = 5;
  final List<TextEditingController> _nameControllers = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameControllers.clear();
    for (int i = 0; i < 4; i++) {
      _nameControllers.add(TextEditingController(text: 'Player ${i + 1}'));
    }
  }

  @override
  void dispose() {
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startGame() {
    final playerNames = _nameControllers
        .take(_playerCount)
        .map((c) => c.text.trim().isEmpty ? 'Player' : c.text.trim())
        .toList();

    final cardTheme = ref.read(settingsProvider).cardTheme;

    ref.read(gameProvider.notifier).startMultiplayerGame(
          level: _selectedLevel,
          playerNames: playerNames,
          theme: cardTheme,
        );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GameScreen(
          level: _selectedLevel,
          mode: 'multiplayer',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(l10n.localMultiplayer),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Player count selector
            _buildSectionTitle(l10n.playerCount),
            const SizedBox(height: 12),
            _buildPlayerCountSelector(),
            const SizedBox(height: 32),

            // Player names
            _buildSectionTitle(l10n.players),
            const SizedBox(height: 12),
            _buildPlayerNameFields(),
            const SizedBox(height: 32),

            // Level selector
            _buildSectionTitle(l10n.selectLevel),
            const SizedBox(height: 12),
            _buildLevelSelector(),
            const SizedBox(height: 48),

            // Start button
            _buildStartButton(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary(context),
      ),
    );
  }

  Widget _buildPlayerCountSelector() {
    return Row(
      children: [2, 3, 4].map((count) {
        final isSelected = _playerCount == count;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _playerCount = count),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.cardBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.cardBorder(context),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.people,
                      color: isSelected ? Colors.white : AppColors.textSecondary(context),
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlayerNameFields() {
    return Column(
      children: List.generate(_playerCount, (index) {
        final color = Player.colors[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              // Player color indicator
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name input
              Expanded(
                child: TextField(
                  controller: _nameControllers[index],
                  decoration: InputDecoration(
                    hintText: 'Player ${index + 1}',
                    filled: true,
                    fillColor: AppColors.cardBackground(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: color.withOpacity(0.5),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: color.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: color,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLevelSelector() {
    // Show levels 3-7 (reasonable for multiplayer)
    final availableLevels = GameConfig.levels.where((l) => l.level >= 3 && l.level <= 7).toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableLevels.map((level) {
        final isSelected = _selectedLevel == level.level;
        return GestureDetector(
          onTap: () => setState(() => _selectedLevel = level.level),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.cardBackground(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.cardBorder(context),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '${level.rows}x${level.cols}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.textPrimary(context),
                  ),
                ),
                Text(
                  '${level.rows * level.cols ~/ 2} pairs',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? Colors.white.withOpacity(0.8)
                        : AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStartButton(AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: _startGame,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_arrow, size: 28),
          const SizedBox(width: 12),
          Text(
            l10n.startGame,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
