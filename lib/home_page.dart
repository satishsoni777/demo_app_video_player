import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_player/test_data.dart';
import 'package:poc_player/test_model.dart';
import 'package:poc_player/video_player_page.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:video_player/video_player.dart';

import 'bloc/video_manager_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TestData testData;
  var list = [];
  final _pageControllerTab = PreloadPageController();
  VideoPlayerController videoPlayerController;
  int lastVideoIndex = 0;
  @override
  void initState() {
    testData = TestData.fromJson(mediaJSON);
    BlocProvider.of<VideoManagerBloc>(context).add(VideoInitiate());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VideoManagerBloc, VideoManagerState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is Loading) {
          return Material(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  backgroundColor: Colors.black,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ],
            ),
          );
        } else if (state is VideoManagerDataState) {
          return Scaffold(
              body: PreloadPageView.builder(
                  preloadPagesCount: 5,
                  controller: _pageControllerTab,
                  itemCount: 5,
                  onPageChanged: (s) {
                    BlocProvider.of<VideoManagerBloc>(context).add(NextPage(
                        tab: state.videosMap.keys.toList()[s],
                        videoIndex: lastVideoIndex,
                        controller: videoPlayerController));
                    try {
                      // if (!state.videosMap[key[s]][s].isLoading) {
                      // BlocProvider.of<VideoManagerBloc>(context).add(
                      //     PlayEvent(
                      //         index: state.videosMap[key[s]][s]
                      //             .preloadPageController.page
                      //             .toInt(),
                      //         tabManager: state.videosMap.keys.toList()[s]));
                      //  }
                    } catch (e) {
                      print(e);
                    }
                  },
                  itemBuilder: (c, i) {
                    final isLoading = state.videosMap.keys.toList();
                    if (isLoading[i].isLoading) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.yellow),
                          ),
                        ],
                      );
                    }
                    List<VideoManager> videoManager;
                    List<TabManager> keys;
                    keys = state.videosMap.keys.toList();
                    videoManager = state.videosMap[keys[i]];

                    return PreloadPageView.builder(
                        scrollDirection: Axis.vertical,
                        controller: videoManager[i].preloadPageController,
                        itemCount: videoManager.length,
                        preloadPagesCount: videoManager.length,
                        onPageChanged: (s) {
                          lastVideoIndex = s;
                          videoPlayerController =
                              videoManager[s].videoPlayerController;
                          BlocProvider.of<VideoManagerBloc>(context)
                              .add(PlayEvent(index: s, tabManager: keys[i]));
                        },
                        itemBuilder: (c, i) {
                          if (videoManager[i].isLoading)
                            return Center(child: Text("Loading"));
                          return Center(
                            child: VidepoPlayer(
                              videoManager: videoManager[i],
                            ),
                          );
                        });
                  }));
        } else
          return Container();
      },
    );
  }
}
