import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:meta/meta.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:video_player/video_player.dart';

part 'video_manager_event.dart';
part 'video_manager_state.dart';

class VideoManagerBloc extends Bloc<VideoManagerEvent, VideoManagerState> {
  VideoManagerBloc() : super(IntiailState());
  int prevIndex = 0;
  int currentIndex = 0;
  TabManager currentKey;
  int nextPageIndex = 1;
  int prevPageIndex = 0;
  VideoPlayerController videoPlayerController;
  int tabLength = 5;
  Map<TabManager, List<VideoManager>> _videosMap = {};

  @override
  Stream<VideoManagerState> mapEventToState(
    VideoManagerEvent event,
  ) async* {
    // AsyncOperation asyncOperation = AsyncOperation<VideoPlayerController>();
    if (event is VideoInitiate) {
      try {
        yield Loading();
        await Future.delayed(const Duration(seconds: 1));

        for (int i = 0; i < tabLength; i++) {
          _videosMap.putIfAbsent(
              TabManager(
                  key: 'tab${i.toString()}',
                  isLoading: true,
                  index: i,
                  preloadPageController: PreloadPageController()),
              () => []);
        }

        await _loadVideos(j: 0);
        await _loadVideos(j: 1);

        currentKey = _videosMap.keys.first;
        currentIndex = 0;

        _videosMap[currentKey][currentIndex].play = true;
        yield VideoManagerDataState(videosMap: _videosMap);
      } catch (_) {
        print(_);
      }
    }
    //
    else if (event is NextPage) {
      if (event.tab.index == 0) {
        if (event.controller != null && event.controller.value.isInitialized)
          await event.controller.pause();
        prevPageIndex = 0;
        nextPageIndex = 1;
        await _loadVideos(j: 0);
        yield dataState.copyWith(videosMap: _videosMap);
      }
      //
      else if (event.tab.index >= 1) {
        prevPageIndex = event.tab.index - 1;
        if (prevPageIndex < 0) {
          prevPageIndex = 0;
        }
        nextPageIndex = event.tab.index + 1;
        if (nextPageIndex > 4) {
          nextPageIndex = 4;
        }
        await _loadVideos(j: nextPageIndex);
      }
      //Apply after 1 index value

      // if (event.tab.index >= prevPageIndex) {
      //   //forward Swipe
      //   if (prevPageIndex != 0) {
      //     await _disposeVideos(prevPageIndex - 2, tab: event.tab);
      //   }
      // } else {
      //   if (prevPageIndex != 0) {
      //     await _disposeVideos(prevPageIndex + 2, tab: event.tab);
      //   }
      //   //backward swipe
      // }

      yield dataState.copyWith(videosMap: _videosMap);
    }
    //
    else if (event is PlayEvent) {
      try {
        if (event.videoPlayerController != null &&
            event.videoPlayerController.value.isInitialized)
          await event.videoPlayerController.play();
        _videosMap[currentKey][currentIndex].play = false;
        _videosMap[event.tabManager][event.index].play = true;
        yield dataState.copyWith(videosMap: _videosMap);
        currentIndex = event.index;
        currentKey = event.tabManager;
      } catch (e) {
        print(e);
      }
    } else if (event is PauseEvent) {
      if (event.videoPlayerController != null) {
        await event.videoPlayerController.pause();
      }
      _videosMap[event.key][event.index].play = false;
      yield dataState.copyWith(videosMap: _videosMap);
    }

    // TODO: implement mapEventToState
  }

  @override
  close() async {
    dataState.videosMap.forEach((key, value) {
      value.forEach((element) {
        // element?.videoPlayerController?.dispose();
      });
    });
    super.close();
  }

  // Parallel VideoPlayerController loading.
  Future<VideoManager> getVideos(int i, int j) async {
    final dataSource = videosData[i];
    final c = VideoPlayerController.network(dataSource);

    return VideoManager(
        isLoading: true,
        key: 'tab${j.toString()}',
        index: i,
        preloadPageController: PreloadPageController(),
        url: videosData[i],
        videoPlayerController: c);
  }

  Future<void> _loadVideos({int j}) async {
    final tab = _videosMap.keys.toList()[j];
    // if (!tab.isVideosDisposed) {
    //   return;
    // }
    tab.isLoading = true;
    final List<Future<VideoManager>> futureList = <Future<VideoManager>>[];
    int videoSize;
    if (_videosMap[tab].isEmpty) {
      videoSize = 6;
    } else {
      videoSize = _videosMap[tab][j].currentVideoSize;
    }

    for (int i = 0; i < videoSize; i++) {
      // if (_videosMap[tab].isNotEmpty) {
      //   if (_videosMap[tab][j].videoPlayerController != null) {
      //     continue;
      //   }
      // }
      futureList.add(getVideos(i, j));
    }
    List<VideoManager> videos = await Future.wait<VideoManager>(futureList);
    tab.isLoading = false;
    _videosMap.update(
      tab,
      (v) => videos,
    );
    _videosMap[tab].forEach((element) {
      element.isLoading = false;
    });
    tab.isVideosDisposed = false;
  }

// Dispose Videos Controllers
  Future<void> _disposeVideos(int j, {TabManager tab}) async {
    // try {
    //   if (_videosMap[tab].isNotEmpty) {
    //     _videosMap.keys.toList()[j].isLoading = true;
    //     for (int i = 0; i < _videosMap[tab]?.length ?? 0; i++) {
    //       _videosMap[tab].forEach((element) {
    //         element.isLoading = true;
    //         if (element.videoPlayerController?.value?.isInitialized ?? false) {
    //           element.videoPlayerController?.dispose();
    //           element.videoPlayerController = null;
    //         }
    //       });
    //     }
    //     _videosMap.keys.toList()[j].isVideosDisposed = true;
    //   }
    // } catch (e) {
    //   print(e);
    // }
  }

  // ignore: missing_return
  VideoManagerDataState get dataState {
    return (state is VideoManagerDataState) ? state : null;
  }
}

class VideoManager {
  VideoManager(
      {this.isLoading,
      this.url,
      this.index,
      this.preloadPageController,
      this.key,
      this.videoPlayerController,
      this.currentVideoSize = 6,
      this.play = false}) {
    this.hasController = preloadPageController != null;
  }
  VideoPlayerController videoPlayerController;
  bool isLoading;
  String url;
  int currentVideoSize;
  bool play;
  String key;
  int index;
  bool hasController;

  PreloadPageController preloadPageController;
}

class TabManager {
  TabManager(
      {this.key,
      this.preloadPageController,
      this.index,
      this.isLoading,
      this.prevIndex,
      this.isVideosDisposed = true,
      this.lastIndex});

  String key;
  int index;
  int prevIndex;
  int lastIndex;
  bool isLoading;
  bool isVideosDisposed;
  PreloadPageController preloadPageController;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabManager &&
          runtimeType == other.runtimeType &&
          key == other.key;
  @override
  int get hashCode => key.hashCode;
}

enum LoadinngStatus { Loading, Success, Failure }
enum TabSwipeDirection { Right, Left }
var videosData = [
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/257.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/255.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/215.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/319.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/350.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/257.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/255.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/215.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/319.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/350.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/257.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/255.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/215.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/319.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/319.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/350.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/257.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/255.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/215.m3u8',
  'https://vibeitup.s3.ap-south-1.amazonaws.com/hls/319.m3u8',
];
