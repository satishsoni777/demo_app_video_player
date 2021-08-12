part of 'video_manager_bloc.dart';

@immutable
abstract class VideoManagerEvent {}

class VideoInitiate extends VideoManagerEvent {}

class NextPage extends VideoManagerEvent {
  NextPage({this.tab, this.videoIndex,this.controller});
  final TabManager tab;
  final int videoIndex;
  final VideoPlayerController controller;
}

class PlayEvent extends VideoManagerEvent {
  PlayEvent({this.index, this.tabManager, this.videoPlayerController});

  final TabManager tabManager;
  final int index;
  final VideoPlayerController videoPlayerController;
}

class PauseEvent extends VideoManagerEvent {
  PauseEvent(
      {this.index, this.key, this.tabManager, this.videoPlayerController});
  final String key;
  final TabManager tabManager;
  final int index;
  final VideoPlayerController videoPlayerController;
}
