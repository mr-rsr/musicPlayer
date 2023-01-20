// ignore_for_file: sort_child_properties_last, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:async';
import 'package:intl/intl.dart';

import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music_player_intern/Screens/musicList.dart';
import 'package:video_player/video_player.dart';

import '../components/videoPlayerScreen.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen(this.songName, this.songUrl, {super.key});
  final String songName;
  final String songUrl;
  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  final audioPlayer = AudioPlayer();
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    setAudio();
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
    audioPlayer.onDurationChanged.listen((d) {
      setState(() {
        duration = d;
      });
    });
    audioPlayer.onPositionChanged.listen((p) {
      setState(() {
        position = p;
      });
    });
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    _controller = VideoPlayerController.asset(
      'assets/Purple-circle.mp4',
    );
    _controller.setLooping(true);
    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();

    super.dispose();
  }

  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    @override
    String url = widget.songUrl;

    List<bool> selected = <bool>[];
    selected.add(false);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffD2CEF6), Color(0xffD9D9D9)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Stack(children: [
            Positioned(
              top: 0,
              left: 0,
              child: IconButton(
                onPressed: () => {
                  audioPlayer.dispose(),
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MusicList()),
                  )
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: height * .225,
              left: 0,
              right: 0,
              child: Container(
                height: height * .29,
                width: height * .29,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 55, right: 55),
                  child: Container(
                    margin: const EdgeInsets.only(
                        top: 38, bottom: 38, left: 38, right: 38),
                    child: VideoPlayerScreen(
                        initializeVideoPlayerFuture:
                            _initializeVideoPlayerFuture,
                        controller: _controller),
                  ),
                ),
              ),
            ),
            //music slider
            Positioned(
              bottom: height * 0.325,
              left: 0,
              right: 0,
              child: Center(
                child: Text(widget.songName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    )),
              ),
            ),
            Positioned(
              bottom: height * .26,
              child: Builder(builder: (context) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 20,
                  child: Slider(
                    value: position.inSeconds.toDouble(),
                    min: 0,
                    max: duration.inSeconds.toDouble(),
                    activeColor: Color(0xffBB86FC),
                    inactiveColor: Colors.white,
                    onChanged: (value) async {
                      final position = Duration(seconds: value.toInt());
                      await audioPlayer.seek(position);
                      await audioPlayer.resume();
                      // setState(() {
                      //   audioPlayer.seek(Duration(seconds: value.toInt()));
                      // });
                    },
                  ),
                );
              }),
            ),
            Positioned(
              bottom: height * .24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      formatTime(position),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text(
                      formatTime(duration),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: IconButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () async {
                        final position = Duration(seconds: 0);
                        await audioPlayer.seek(position);
                        await audioPlayer.resume();
                      },
                      icon: const Icon(
                        Icons.replay,
                        size: 35,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const IconButton(
                    onPressed: null,
                    padding: EdgeInsets.all(0),
                    icon: Icon(
                      Icons.fast_rewind,
                      size: 40,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: IconButton(
                        splashColor: const Color(0xffBB86FC),
                        splashRadius: 30,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(0),
                        onPressed: () async {
                          if (isPlaying) {
                            await audioPlayer.pause();
                          } else {
                            await audioPlayer.resume();
                          }
                          setState(() {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                          });
                        },
                        icon: _controller.value.isPlaying
                            ? const Icon(
                                Icons.pause,
                                size: 40,
                                color: Color(0xffBB86FC),
                              )
                            : const Icon(
                                Icons.play_arrow,
                                size: 40,
                                color: Color(0xffBB86FC),
                              ),
                      ),
                    ),
                  ),
                  const IconButton(
                    padding: EdgeInsets.all(0),
                    onPressed: null,
                    icon: Icon(
                      Icons.fast_forward,
                      size: 40,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () async {
                        setState(() {
                          selected[0] = !selected[0];
                          selected[0]
                              ? audioPlayer.setReleaseMode(ReleaseMode.loop)
                              : audioPlayer.setReleaseMode(ReleaseMode.release);
                        });
                      },
                      icon: Icon(
                        selected[0]
                            ? Icons.repeat_one_on_rounded
                            : Icons.repeat_rounded,
                        size: 35,
                        color: Colors.black,
                      )),
                ],
              ),
              bottom: height * 0.13,
              left: 0,
              right: 0,
            ),
          ]),
        ),
      ),
    );
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future setAudio() async {
    String url = widget.songUrl;
    await audioPlayer.setSourceUrl(url);
  }
}
