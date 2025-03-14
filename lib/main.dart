// Foungnigue Souleymane Hassan Coulibaly
// Georgia State University
// Mobile App Development

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: MaterialApp(navigatorKey: navigatorKey, home: MyHomePage()),
    ),
  );
}

class CardModel {
  final String image;
  bool isFaceUp;
  bool isMatched;

  CardModel({
    required this.isFaceUp,
    required this.isMatched,
    required this.image,
  });
}

class FlipCard extends StatefulWidget {
  final bool isFaceUp;
  final String image;
  final VoidCallback onTap;

  const FlipCard({
    super.key,
    required this.isFaceUp,
    required this.image,
    required this.onTap,
  });

  @override
  _FlipCardState createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFaceUp) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * pi;
          final transform =
              Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle);

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child:
                _flipAnimation.value < 0.5
                    ? Container(color: Colors.orangeAccent)
                    : Image.asset(
                      widget.image,
                      fit: BoxFit.fitHeight,
                    ), // Front of card
          );
        },
      ),
    );
  }
}

class GameProvider extends ChangeNotifier {
  List<CardModel> cards = [];
  CardModel? firstCard;
  CardModel? secondCard;
  int score = 0;
  int time = 0;
  Timer? timer;

  GameProvider() {
    _initializeGame();
  }

  void _initializeGame() {
    List<String> images = [
      'assets/images/cardA.png',
      'assets/images/cardA.png',
      'assets/images/card2.jpg',
      'assets/images/card2.jpg',
      'assets/images/card3.jpg',
      'assets/images/card3.jpg',
      'assets/images/card4.png',
      'assets/images/card4.png',
    ];
    images.shuffle();
    cards =
        images
            .map(
              (img) => CardModel(isFaceUp: false, isMatched: false, image: img),
            )
            .toList();
    firstCard = null;
    secondCard = null;
    score = 0;
    time = 0;
    notifyListeners();
  }

  void startGame() {
    time = 0;
    score = 0;
    _shuffleCards();
    notifyListeners();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      time++;
      notifyListeners();
    });
  }

  void _shuffleCards() {
    List<String> images = [
      'assets/images/cardA.png',
      'assets/images/cardA.png',
      'assets/images/card2.jpg',
      'assets/images/card2.jpg',
      'assets/images/card3.jpg',
      'assets/images/card3.jpg',
      'assets/images/card4.png',
      'assets/images/card4.png',
    ];
    images.shuffle();
    cards =
        images
            .map(
              (img) => CardModel(isFaceUp: false, isMatched: false, image: img),
            )
            .toList();
    notifyListeners();
  }

  void flipCard(int index) {
    if (cards[index].isFaceUp || cards[index].isMatched) return;
    cards[index].isFaceUp = true;
    notifyListeners();

    if (firstCard == null) {
      firstCard = cards[index];
    } else {
      secondCard = cards[index];
      _checkMatch();
    }
  }

  void _checkMatch() {
    if (firstCard != null && secondCard != null) {
      if (firstCard!.image == secondCard!.image) {
        firstCard!.isMatched = true;
        secondCard!.isMatched = true;
        score += 10;
        firstCard = null;
        secondCard = null;
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          if (firstCard != null && secondCard != null) {
            firstCard!.isFaceUp = false;
            secondCard!.isFaceUp = false;
            notifyListeners();
          }
          firstCard = null;
          secondCard = null;
        });
      }
      if (cards.every((card) => card.isMatched)) {
        _showWinDialog();
      }
      notifyListeners();
    }
  }

  void _showWinDialog() {
    Timer(const Duration(milliseconds: 500), () {
      showDialog(
        context: navigatorKey.currentContext!,
        builder:
            (context) => AlertDialog(
              title: const Text("Congratulations!"),
              content: Text("You won the game!\nFinal Score: $score"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    startGame();
                  },
                  child: const Text("Play Again"),
                ),
              ],
            ),
      );
    });
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CARD GAME"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Consumer<GameProvider>(
              builder:
                  (context, game, child) => Text(
                    "Score: ${game.score}",
                    style: const TextStyle(fontSize: 20),
                  ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Consumer<GameProvider>(
              builder:
                  (context, game, child) => Text(
                    "Time: ${game.time} sec",
                    style: const TextStyle(fontSize: 20),
                  ),
            ),
          ),
          Expanded(
            child: Consumer<GameProvider>(
              builder:
                  (context, game, child) => GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                    itemCount: game.cards.length,
                    itemBuilder: (context, index) {
                      return FlipCard(
                        isFaceUp: game.cards[index].isFaceUp,
                        image: game.cards[index].image,
                        onTap: () => game.flipCard(index),
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<GameProvider>().startGame(),
        child: const Icon(Icons.replay),
      ),
    );
  }
}
