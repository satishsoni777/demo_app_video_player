part of 'video_manager_bloc.dart';

@immutable
abstract class VideoManagerState {}

class IntiailState extends VideoManagerState {}

class Loading extends VideoManagerState {}

// ignore: must_be_immutable
class VideoManagerDataState extends VideoManagerState {
  final Map<TabManager, List<VideoManager>> videosMap;

  VideoManagerDataState({this.videosMap});

  VideoManagerDataState copyWith(
      {final Map<TabManager, List<VideoManager>> videosMap}) {
    return VideoManagerDataState(videosMap: videosMap ?? this.videosMap);
  }
}
