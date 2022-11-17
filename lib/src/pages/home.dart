import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/band.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'Drake', votes: 5),
    Band(id: '2', name: 'Travis Scott', votes: 5),
    Band(id: '3', name: 'Queen', votes: 5),
    Band(id: '4', name: 'Jamiroquai', votes: 5),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, i) => BandTile(bands[i]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addNewBand();
        },
        child: Icon(Icons.add),
        elevation: 1,
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();

    if (Platform.isAndroid) {
      //Android
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('New band name:'),
              content: TextField(
                controller: textController,
              ),
              actions: [
                MaterialButton(
                  child: Text('Add'),
                  textColor: Colors.blue,
                  elevation: 5,
                  onPressed: () {
                    addBandToList(textController.text);
                  },
                ),
              ],
            );
          });
    }

    showCupertinoDialog(
      context: context,
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text('New band name:'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              child: Text('Dismiss'),
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: Text('Add'),
              isDefaultAction: true,
              onPressed: () {
                addBandToList(textController.text);
              },
            ),
          ],
        );
      },
    );
  }

  void addBandToList(String name) {
    if (name.length >= 1) {
      //Podemos agregar
      bands.add(new Band(id: DateTime.now.toString(), name: name, votes: 0));
      setState(() {});
      Navigator.pop(context);
    }
  }
}

class BandTile extends StatelessWidget {
  final Band band;

  const BandTile(this.band);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        print(direction);
        print(band.id);
        //TODO: llamar el borrado en el server
      },
      background: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        color: Colors.red,
        child: Align(
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.delete_outline_outlined,
              color: Colors.white,
              size: 30,
            )),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(band.name.substring(0, 2)),
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () {},
      ),
    );
  }
}
