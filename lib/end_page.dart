import 'package:flutter/material.dart';
import 'package:page_view_indicators/page_view_indicators.dart';

class end_page extends StatefulWidget {
  @override
  _end_pageState createState() => _end_pageState();
}

class _end_pageState extends State<end_page> {
  List<String> titles = ["WOW", "Fantastisch", "Respekt", "Wahnsinn"];
  List<String> imageNames = [
    "images/daumen_hoch.gif",
    "images/zauberer.gif",
    "images/bravocado.gif",
    "images/jubel.gif"
  ];
  final pageController = PageController();
  final currentPage = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text("Ende"),
            centerTitle: true,
          ),
          body: buildBody()),
    );
  }

  buildBody() {
    return Column(
      children: <Widget>[
        buildPageView(),
        buildCircleIndicator(),
      ],
    );
  }

  buildPageView() {
    return Expanded(
          child: Container(
        child: PageView.builder(
            itemCount: titles.length,
            controller: pageController,
            itemBuilder: (BuildContext context, int index) {
              return pageViewContent(index);
            },
            onPageChanged: (int index) {
              currentPage.value = index;
            }),
      ),
    );
  }

  Widget pageViewContent(int i) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(titles[i],
                style: TextStyle(fontSize: 150, fontFamily: "Mallam")),
          ),
          Image.asset(
            imageNames[i],
          ),
        ],
      ),
    );
  }

  buildCircleIndicator() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: CirclePageIndicator(
        size: 16.0,
        selectedSize: 18.0,
        itemCount: titles.length,
        currentPageNotifier: currentPage,
      ),
    );
  }
}
