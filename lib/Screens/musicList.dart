import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:music_player_intern/Screens/musicScreen.dart';
import 'package:music_player_intern/Screens/uploadSong.dart';

class MusicList extends StatefulWidget {
  const MusicList({super.key});

  @override
  State<MusicList> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  Future getData() async {
    QuerySnapshot qn =
        await FirebaseFirestore.instance.collection("songs").get();
    return qn.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          elevation: 2,
          title: Text(
            'Music List',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Color(0xffD2CEF6),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      //upload song fab button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UploadSong()),
          );
        },
        backgroundColor: Color(0xffD2CEF6),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
          future: getData(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MusicScreen(
                                  snapshot.data[index].data()['song_name'],
                                  snapshot.data[index].data()['song'])),
                        );
                      },
                      child: listSong(snapshot.data[index].data()['song_name'],
                          snapshot.data[index].data()['artist']),
                    );
                  });
            }
          }),
    );
  }

  Widget listSong(String songName, String artistName) {
    return ListTile(
      //tileColor: Color(0xffD9D9D9),
      leading: const CircleAvatar(
          backgroundColor: Color(0xffD9D9D9),
          child: Icon(Icons.music_note,
              size: 25, color: Color.fromARGB(255, 221, 46, 33))),
      title: Text(songName),
      subtitle: Text(artistName),
      trailing: const CircleAvatar(
          radius: 15,
          backgroundColor: Color.fromARGB(255, 221, 46, 33),
          child: Icon(Icons.play_arrow_rounded, color: Colors.white)),
    );
  }
}
