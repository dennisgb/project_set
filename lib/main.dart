import 'package:flutter/material.dart';
import 'dart:math';
import 'end_page.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
      routes: <String, WidgetBuilder>{
        // Key: Value
        "end_page": (BuildContext context) => end_page(),
      },
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Globale Variablen
  var rng = new Random();
  String color;
  String shape;
  String currentCard = "";
  String correct = "richtig";
  String wrong = "falsch";
  int playedCardsCount = 12;
  int cardsTotal = 27;
  bool selected = false;
  bool isInitialized = false;
  String resultAmount;
  String resultColor;
  String resultShape;
  List<String> playedCards = List<String>();
  List<String> cardsOnTableArray = List<String>();
  List<Card> cardsOnTable = List<Card>();
  List<int> selectedCards = List<int>();
  List<int> removedCards = List<int>();
  List<List<Expanded>> cardContentsOnTable = List<List<Expanded>>();
  List<List<Image>> symbols = [
    [
      Image.asset(
        'images/oval.png',
        color: Colors.green,
      ),
      Image.asset('images/raute.png', color: Colors.green),
      Image.asset('images/rechteck.png', color: Colors.green),
    ],
    [
      Image.asset(
        'images/oval.png',
        color: Colors.red,
      ),
      Image.asset('images/raute.png', color: Colors.red),
      Image.asset('images/rechteck.png', color: Colors.red),
    ],
    [
      Image.asset(
        'images/oval.png',
        color: Colors.purple,
      ),
      Image.asset('images/raute.png', color: Colors.purple),
      Image.asset('images/rechteck.png', color: Colors.purple),
    ]
  ];
  var selectedIndex;

  @override
  void initState() {
    super.initState();
    cardContentsOnTable = List.generate(12, (index) {
      return createCardContent(index);
    });
    isInitialized = true;
  }

  List<Expanded> createCardContent(index) {
    List<Expanded> list = new List<Expanded>();
    currentCard = "";
    int symbolAmount;
    var color;
    var shape;
    do {
      list.clear();
      currentCard = "";
      symbolAmount = rng.nextInt(3);
      color = rng.nextInt(3);
      shape = rng.nextInt(3);
      for (var i = 0; i <= symbolAmount; i++) {
        currentCard = currentCard + color.toString() + shape.toString();
        list.add(Expanded(child: Container(child: symbols[color][shape])));
      }
      print("while loop");
    } while (playedCards.contains(currentCard));
    playedCards.add(currentCard);
    if (!isInitialized) {
      cardsOnTableArray.add(currentCard);
    } else {
      cardsOnTableArray[index] = currentCard;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Set"),
          centerTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: GridView.count(
                // Anzahl der Spalten definieren für unser Gitter-Gerüst
                crossAxisCount: 3,
                padding: EdgeInsets.all(10.0),
                children: List.generate(12, (index) {
                  return GestureDetector(
                      child: createCard(index),
                      onTap: () {
                        print(cardsOnTableArray);
                        if (!removeSetFromTable()) {
                          setState(() {
                            selectedCards.contains(index)
                                ? selectedCards.remove(index)
                                : selectedCards.add(index);
                            if (selectedCards.length == 3) {
                              showResultDialog();
                            }
                          });
                        } else {
                          showNewCardsDialog();
                        }
                      });
                }),
              ),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Image.asset(
                    'images/kartenstapel.png',
                    height: 50.0,
                    alignment: Alignment.bottomLeft,
                  ),
                ),
                Text((cardsTotal - playedCardsCount).toString(),
                    style: TextStyle(fontSize: 30)),
                IconButton(
                    icon: Icon(Icons.help_outline),
                    onPressed: () {
                      setState(() {
                        findSet();
                      });
                    })
              ],
            ),
          ],
        ),
        floatingActionButton: removeSetFromTable()
            ? FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () {
                  if (playedCardsCount < cardsTotal) {
                    playNewCards();
                  } else {
                    Navigator.pushNamed(context, "end_page");
                  }
                },
              )
            : null);
  }

  void playNewCards() {
    playedCardsCount += 3;
    for (var cardIndex in selectedCards) {
      cardContentsOnTable[cardIndex] = createCardContent(cardIndex);
    }
    setState(() {
      selectedCards.clear();
    });
  }

  // Globale Funktionen

  Card createCard(index) {
    Card newCard = Card(
      shape: (selectedCards.contains(index))
          ? RoundedRectangleBorder(
              side: BorderSide(width: 3.0, color: Colors.cyan),
              borderRadius: BorderRadius.circular(4.0))
          : RoundedRectangleBorder(
              side: BorderSide(width: 1.0, color: Colors.grey),
              borderRadius: BorderRadius.circular(4.0)),
      margin: EdgeInsets.all(15.0),
      color: Colors.blueGrey[100],
      elevation: 10.0,
      child: Column(
          mainAxisSize: MainAxisSize.max,
          textDirection: TextDirection.ltr,
          children: cardContentsOnTable[index]),
    );
    cardsOnTable.add(newCard);
    if (removeSetFromTable() && selectedCards.contains(index)) {
      return null;
    } else {
      return newCard;
    }
  }

  bool removeSetFromTable() {
    return selectedCards.length == 3 && aSetHasBeenFound();
  }

  bool aSetHasBeenFound() {
    resultAmount = checkCorrectness(
        cardContentsOnTable[selectedCards[0]].length,
        cardContentsOnTable[selectedCards[1]].length,
        cardContentsOnTable[selectedCards[2]].length);

    resultColor = checkCorrectness(
        cardsOnTableArray[selectedCards[0]].substring(0, 1),
        cardsOnTableArray[selectedCards[1]].substring(0, 1),
        cardsOnTableArray[selectedCards[2]].substring(0, 1));

    resultShape = checkCorrectness(
        cardsOnTableArray[selectedCards[0]].substring(1, 2),
        cardsOnTableArray[selectedCards[1]].substring(1, 2),
        cardsOnTableArray[selectedCards[2]].substring(1, 2));

    if (resultAmount == correct &&
        resultColor == correct &&
        resultShape == correct) {
      return true;
    }
    return false;
  }

  String checkCorrectness(value_1, value_2, value_3) {
    if (allEqual(value_1, value_2, value_3) ||
        allDifferent(value_1, value_2, value_3)) {
      return correct;
    } else {
      return wrong;
    }
  }

  bool allEqual(value_1, value_2, value_3) {
    if (value_1 == value_2 && value_2 == value_3) {
      return true;
    }
    return false;
  }

  bool allDifferent(value_1, value_2, value_3) {
    if (value_1 != value_2 && value_2 != value_3 && value_1 != value_3) {
      return true;
    }
    return false;
  }

  void findSet() {
    while (selectedCards.length < 3 || !aSetHasBeenFound()) {
      selectedCards.clear();
      for (var i = 0; i < 3; i++) {
        int random = rng.nextInt(12);
        while (selectedCards.contains(random)) {
          random = rng.nextInt(12);
        }
        selectedCards.add(random);
      }
    }
    showResultDialog();
  }

  void showResultDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: aSetHasBeenFound() ? Text("Set! :)") : Text("Kein Set :("),
          content: Text(
              "Anzahl: $resultAmount\nFarbe: $resultColor\nForm: $resultShape"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                if (!aSetHasBeenFound()) {
                  setState(() {
                    selectedCards.clear();
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showNewCardsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Lege Karten nach"),
          content: Text("Drücke auf den Button unten rechts"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                if (!aSetHasBeenFound()) {
                  setState(() {
                    selectedCards.clear();
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
