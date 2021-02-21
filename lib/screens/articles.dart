import 'package:firebase_admob/firebase_admob.dart';
import 'package:flt_realtime/constants/Theme.dart';
import 'package:flt_realtime/widgets/card-horizontal.dart';
import 'package:flt_realtime/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:url_launcher/url_launcher.dart';

final Map<String, Map<String, dynamic>> articlesCards = {
  "Ice Cream": {
    "title": "종합결제서비스(PG)사 다날의 계열사 다날핀테크가 발행한 암호화폐 &#39;페이코인&#39;이 하루 새 624% 급등했다. 자사 애플리케이션(앱)에서 비트코인으로 결제할 수 있는&nbsp;...",
    "image": "https://t2.gstatic.com/images?q=tbn:ANd9GcRjBdIhoNPdUXfA5_TXm62JX5mYT2t4cd7NEM0GJ2ecf45zwr41f5UsnH1Auw8kgUTT-GOdvhFJ"
  }
};



class Articles extends StatefulWidget {
  Articles({Key key}) : super(key: key);

  @override
  ARTI createState() => ARTI();
}

class ARTI extends State<Articles> {

  static MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['flutter', 'firebase', 'admob'],
    testDevices: <String>[],
  );

  BannerAd bannerAd = BannerAd(
    adUnitId: "ca-app-pub-8632141287861541/1505243467",
    size: AdSize.banner,
    targetingInfo: targetingInfo,
    listener: (MobileAdEvent event) {
      print("BannerAd event is $event");
    },
  );

  List<RssItem> listed = [];
  String text = "오늘";

  @override
  Widget build(BuildContext context) {

    final children = <Widget>[];
    for (int i = 0; i < listed?.length ?? 0; i++) {
      //   if (distributions[i] == null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: CardHorizontal(
              title: listed[i].title,
              img: listed[i].picture ?? 'https://lh3.googleusercontent.com/b5qAumS0PNjXxu0wTSePrVvZLkdOO6OphrP-fd7pfzWqRhsKA-0gHcebfKj_UIt3ZLo=w200-rwa',
              tap: () =>
                  launch('https://search.naver.com/search.naver?query='+listed[i].title)
          ),
        ),
      );
      children.add(
          SizedBox(height: 8.0)
      );
    }


    return Scaffold(
        appBar: AppBar(
          title: new Text(text + "의 토픽"),
          centerTitle: true,
          backgroundColor: ArgonColors.black,
          leading: new Icon(Icons.audiotrack),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.navigate_before, color: ArgonColors.white), onPressed: () => { this.test('y') }),
            IconButton(icon: Icon(Icons.navigate_next, color: ArgonColors.white), onPressed: () => { this.test('n') })
          ],
        ),
        backgroundColor: ArgonColors.bgColorScreen,

        body: Container(
            padding: EdgeInsets.only(right: 24, left: 24, bottom: 36),
            child: SingleChildScrollView(
              child: Column(
                children:
                  children
                ,
              ),
            )
        )
    );
  }


  @override
  void initState() {
    super.initState();
    this.test("n");
    FirebaseAdMob.instance.initialize(
        appId: "ca-app-pub-8632141287861541~4606582352"); // Android Test App ID
    bannerAd..load()..show();

  }

  void test(String yesterday) async {

    var client = new http.Client();

    // RSS feed
    await client.get("https://trends.google.co.kr/trends/trendingsearches/daily/rss?geo=KR").then((response) {
      return response.body;
    }).then((bodyString) {
      var channel = new RssFeed.parse(bodyString);

      List<RssItem> items = channel.items;
      List<RssItem> listed1 = [];
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      String parseFormat = "E, dd MMM yyyy";

      if(items.length == 0 || yesterday == 'y'){
        listed1 = items.where((e) => formatter.format(new DateFormat(parseFormat).parse(e.pubDate)).compareTo(formatter.format(DateTime.now().subtract(new Duration(hours: 9)).subtract(new Duration(days: 1)))) == 0 ).toList();
        text = "어제";
      } else {
        listed1 = items.where((e) => formatter.format(new DateFormat(parseFormat).parse(e.pubDate)).compareTo(formatter.format(DateTime.now())) == 0 ).toList();
        text = "오늘";
      }
      setState(() {
        listed = listed1;
      });

      return channel;
    });

  }
}

