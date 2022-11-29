import 'dart:io';

import 'package:band_names/src/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import '../models/band.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];
  @override
  void initState() {
    //! SOLO CUANDO SE INICIA LA APP, NO HACE FALTA REDIBUJAR ESTO
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    final socketService = Provider.of<SocketService>(context);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            // child:
            child: (socketService.serverStatus == ServerStatus.Online) ? Icon(Icons.check_circle, color: Colors.blue) : Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: Column(
        children: [
          _PieChart(bands),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, i) => BandTile(bands[i]),
            ),
          ),
        ],
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
        builder: (_) => AlertDialog(
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
        ),
      );
    }

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
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
      ),
    );
  }

  void addBandToList(String name) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    if (name.length >= 1) {
      //Podemos agregar
      socketService.emit('add-band', {'name': name});
      setState(() {});
      Navigator.pop(context);
    }
  }
}

class _PieChart extends StatelessWidget {
  const _PieChart(this.bands);
  final List<Band> bands;

  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = new Map();

    final List<Color> colorList = [
      Colors.blue.shade100,
      Colors.blue.shade200,
      Colors.pink.shade100,
      Colors.pink.shade200,
      Colors.orange.shade100,
      Colors.orange.shade200,
      Colors.green.shade100,
    ];

    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });
    return Container(
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: dataMap,
        chartValuesOptions: ChartValuesOptions(
            showChartValuesInPercentage: true, chartValueBackgroundColor: Colors.black12, chartValueStyle: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        colorList: colorList,
      ),
    );
  }
}

class BandTile extends StatelessWidget {
  final Band band;

  const BandTile(this.band);

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          socketService.emit('delete-band', {'id': band.id});
        }
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
        onTap: () {
          socketService.emit('vote-band', {'id': band.id});
        },
      ),
    );
  }
}
