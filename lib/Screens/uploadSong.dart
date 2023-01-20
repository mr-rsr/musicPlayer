// ignore_for_file: non_constant_identifier_names, prefer_const_constructors

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:music_player_intern/Screens/musicList.dart';
import 'package:path/path.dart';

class UploadSong extends StatefulWidget {
  const UploadSong({super.key});

  @override
  State<UploadSong> createState() => _UploadSongState();
}

class _UploadSongState extends State<UploadSong> {
  final _song = TextEditingController();
  bool _songValidate = false;
  final _artist = TextEditingController();
  bool _artistValidate = false;

  @override
  void dispose() {
    _song.dispose();
    _artist.dispose();
    super.dispose();
  }

  // ignore: non_constant_identifier_names
  File? Song;
  // ignore: prefer_typing_uninitialized_variables
  late String SongPath;
  // ignore: prefer_typing_uninitialized_variables
  var song_down_url;

  final firestoreinstance = FirebaseFirestore.instance;

  void songSelect() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.audio, allowMultiple: false);
    Song = File(result!.files.single.path!);
    setState(() {
      Song = Song;
      SongPath = basename(Song!.path);
      songUpload(Song!.readAsBytesSync(), SongPath);
    });
  }

//Uint8List.fromList(list);
  Future<String> songUpload(List<int> afile, String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = ref.putData(Uint8List.fromList(afile));
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    song_down_url = downloadUrl;
    return downloadUrl;
  }

  finalUpload(context) {
    var data = {
      'song': song_down_url.toString(),
      'song_name': _song.text,
      'artist': _artist.text,
    };
    firestoreinstance
        .collection('songs')
        .doc()
        .set(data)
        .whenComplete(() => showDialog(
              context: context,
              builder: (context) => _onTapButton(
                  context, "You have successfully uploaded the song :)"),
            ));
    ;
  }

  _onTapButton(BuildContext context, data) {
    return AlertDialog(
        title: const Text("Success"),
        content: Text(data),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MusicList()),
                  (route) => false);
            },
            child: const Text('OK'),
          ),
        ],
        icon: const CircleAvatar(
            backgroundColor: Color(0xffD2CEF6),
            child: Icon(
              Icons.check,
              color: Colors.green,
            )));
  }

  @override
  Widget build(BuildContext context) {
    _song.text = (Song != null ? basename(Song!.path) : 'No Song Selected');
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Upload Song',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xffD2CEF6),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Builder(builder: (context) {
          return ListView(
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              const Center(
                child: Text('Upload Your Song',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              GestureDetector(
                onTap: () {
                  songSelect();
                },
                child: Center(
                    child: DottedBorder(
                  dashPattern: const [10, 5],
                  color: Colors.grey,
                  strokeWidth: 2,
                  radius: const Radius.circular(20),
                  borderType: BorderType.RRect,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * .85,
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Icon(
                            Song != null
                                ? Icons.music_note
                                : Icons.audio_file_rounded,
                            size: 60,
                            color: Colors.red,
                          ),
                          Text(
                            Song != null
                                ? basename(Song!.path)
                                : 'Drag and Drop your song here',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ]),
                  ),
                )),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 50),
                child: TextField(
                  controller: _song,
                  keyboardType: TextInputType.text,
                  autofocus: false,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    // prefix:
                    //     Icon(Icons.music_note, color: Colors.black, size: 30),
                    label: const Center(child: Text("Enter Song Name")),
                    errorText:
                        _songValidate ? 'Song Name Can\'t Be Empty' : null,
                    focusColor: Colors.black,
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 50),
                child: TextField(
                  controller: _artist,
                  keyboardType: TextInputType.text,
                  autofocus: false,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    // prefix:
                    //     Icon(Icons.music_note, color: Colors.black, size: 30),
                    label: const Center(child: Text("Enter Artist Name")),
                    errorText:
                        _artistValidate ? 'Artist Name Can\'t Be Empty' : null,
                    focusColor: Colors.black,
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              // upload button
              Center(
                  child: SizedBox(
                width: MediaQuery.of(context).size.width * .8,
                height: MediaQuery.of(context).size.height * 0.07,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _song.text.isEmpty
                          ? _songValidate = true
                          : _songValidate = false;
                      _artist.text.isEmpty
                          ? _artistValidate = true
                          : _artistValidate = false;
                      if (_songValidate == false && _artistValidate == false) {
                        finalUpload(context);
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffD2CEF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Upload',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )),
            ],
          );
        }),
      ),
    );
  }
}
