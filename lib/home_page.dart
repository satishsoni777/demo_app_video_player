import 'package:flutter/material.dart';
import 'package:poc_player/test_data.dart';
import 'package:poc_player/test_model.dart';
import 'package:poc_player/video_player_page.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:video_player/video_player.dart';

final list = [
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/350.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/349.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/257.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/256.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/255.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/215.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/256.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/319.m3u8',
];

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Videos> videos = <Videos>[];
  TestData testData;
  int _index = 0;
  @override
  void initState() {
    testData = TestData.fromJson(mediaJSON);
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: testData == null
          ? CircularProgressIndicator()
          : PreloadPageView.builder(
              preloadPagesCount: 5,
              physics: AlwaysScrollableScrollPhysics(),
              onPageChanged: (s) {
                _index = s;
                setState(() {});
              },
              scrollDirection: Axis.vertical,
              itemCount: list.length,
              itemBuilder: (c, i) {
                return Center(
                  child: VidepoPlayer(
                    url: list[i],
                    play: _index == i,
                  ),
                );
              },
            ),
    );
  }
}
