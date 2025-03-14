import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: const MaterialApp(home: MyHomePage()),
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
      'assets/card1.png',
      'assets/card1.png',
      'assets/card2.png',
      'assets/card2.png',
      'assets/card3.png',
      'assets/card3.png',
      'assets/card4.png',
      'assets/card4.png',
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
      'assets/card1.png',
      'assets/card1.png',
      'assets/card2.png',
      'assets/card2.png',
      'assets/card3.png',
      'assets/card3.png',
      'assets/card4.png',
      'assets/card4.png',
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
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          firstCard!.isFaceUp = false;
          secondCard!.isFaceUp = false;
          notifyListeners();
        });
      }
      firstCard = null;
      secondCard = null;
    }
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
                    "Score: \${game.score}",
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
                    "Time: \${game.time} sec",
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
                      return GestureDetector(
                        onTap: () => game.flipCard(index),
                        child: Card(
                          color: Colors.orange,
                          child: Center(
                            child:
                                game.cards[index].isFaceUp
                                    ? Image.asset(game.cards[index].image)
                                    : Container(color: Colors.orangeAccent),
                          ),
                        ),
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
