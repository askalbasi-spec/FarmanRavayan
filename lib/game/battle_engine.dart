import 'card.dart';

class BattleState {
  BattleState({
    required this.playerHealth,
    required this.enemyHealth,
    required this.energy,
    required this.maxEnergy,
    required this.hand,
    required this.playerBoard,
    required this.enemyBoard,
    required this.deck,
    required this.enemyDeck,
    this.playerTurn = true,
    this.message = 'نوبت شماست؛ یک کارت انتخاب کنید.',
    this.winner,
  });

  int playerHealth;
  int enemyHealth;
  int energy;
  int maxEnergy;
  List<GameCard> hand;
  List<GameCard> playerBoard;
  List<GameCard> enemyBoard;
  List<GameCard> deck;
  List<GameCard> enemyDeck;
  bool playerTurn;
  String message;
  String? winner;

  bool get isOver => winner != null;
}

class BattleEngine {
  BattleEngine() {
    final shuffled = List<GameCard>.of(starterCards)..shuffle();
    state = BattleState(
      playerHealth: 20,
      enemyHealth: 20,
      energy: 1,
      maxEnergy: 1,
      hand: shuffled.take(4).toList(),
      playerBoard: [],
      enemyBoard: [],
      deck: shuffled.skip(4).toList(),
      enemyDeck: List<GameCard>.of(starterCards)..shuffle(),
    );
  }

  late final BattleState state;

  void playCard(int handIndex) {
    if (state.isOver || !state.playerTurn || handIndex < 0 || handIndex >= state.hand.length) return;
    final card = state.hand[handIndex];
    if (card.cost > state.energy) {
      state.message = 'انرژی کافی برای این کارت ندارید.';
      return;
    }
    state.energy -= card.cost;
    state.hand.removeAt(handIndex);
    _resolve(card, player: true);
    if (!state.isOver) state.message = 'کارت undefined اجرا شد.';
  }

  void endPlayerTurn() {
    if (state.isOver || !state.playerTurn) return;
    state.playerTurn = false;
    for (final unit in List<GameCard>.of(state.playerBoard)) {
      state.enemyHealth -= unit.attack;
      if (state.enemyHealth <= 0) {
        state.enemyHealth = 0;
        state.winner = 'شما';
        state.message = 'پیروزی! نیروهای شما فرمانده دشمن را شکست دادند.';
        return;
      }
    }
    _enemyTurn();
    if (state.isOver) return;
    state.maxEnergy = (state.maxEnergy + 1).clamp(1, 10);
    state.energy = state.maxEnergy;
    _draw(player: true);
    state.playerTurn = true;
    state.message = 'نوبت شماست؛ انرژی بازیابی شد.';
  }

  void _enemyTurn() {
    state.message = 'فرمانده دشمن در حال حرکت است...';
    if (state.enemyDeck.isNotEmpty) {
      final affordable = state.enemyDeck.where((c) => c.cost <= state.maxEnergy).toList()
        ..sort((a, b) => b.cost.compareTo(a.cost));
      if (affordable.isNotEmpty) {
        final card = affordable.first;
        state.enemyDeck.remove(card);
        _resolve(card, player: false);
      }
    }
    if (state.isOver) return;
    for (final unit in List<GameCard>.of(state.enemyBoard)) {
      state.playerHealth -= unit.attack;
      if (state.playerHealth <= 0) {
        state.playerHealth = 0;
        state.winner = 'دشمن';
        state.message = 'فرمانده شما شکست خورد.';
        return;
      }
    }
    _draw(player: false);
    state.message = 'دشمن حمله کرد؛ نوبت شماست.';
  }

  void _resolve(GameCard card, {required bool player}) {
    if (card.type == CardType.spell) {
      if (player) {
        state.enemyHealth = (state.enemyHealth - card.attack).clamp(0, 20);
        state.playerHealth = (state.playerHealth + card.heal).clamp(0, 20);
      } else {
        state.playerHealth = (state.playerHealth - card.attack).clamp(0, 20);
        state.enemyHealth = (state.enemyHealth + card.heal).clamp(0, 20);
      }
    } else if (player) {
      state.playerBoard.add(card);
    } else {
      state.enemyBoard.add(card);
    }
    if (state.enemyHealth <= 0) {
      state.winner = 'شما';
      state.message = 'پیروزی! فرمانده دشمن شکست خورد.';
    } else if (state.playerHealth <= 0) {
      state.winner = 'دشمن';
      state.message = 'فرمانده شما شکست خورد.';
    }
  }

  void _draw({required bool player}) {
    final source = player ? state.deck : state.enemyDeck;
    final destination = player ? state.hand : null;
    if (source.isEmpty) return;
    final card = source.removeAt(0);
    if (destination != null && destination.length < 7) destination.add(card);
  }
}
