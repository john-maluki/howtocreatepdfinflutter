import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String assetPdfFile = '';
  String urlPdfPath = '';

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    getFileFromUrl(
            'http://10.0.2.2:8000/api/v1/report/98643771-250e-4c1d-9b3e-f8f318b2244c/9a64d7f9-014a-43b5-b1d3-5889c3e3d84e/')
        .then((f) {
      setState(() {
        urlPdfPath = f.path;
        print(urlPdfPath);
      });
    });

    getFileFromAsset('asset/lec.notes.pdf').then((f) {
      setState(() {
        assetPdfFile = f.path;
        print(assetPdfFile);
      });
    });
    super.initState();
  }

  Future<File> getFileFromAsset(String asset) async {
    try {
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      var dir = await getApplicationDocumentsDirectory();
      File file = File('${dir.path}/std8.pdf');
      File assetFile = await file.writeAsBytes(bytes);
      return assetFile;
    } catch (e) {
      throw Exception('Error opening asset file');
    }
  }

  Future<File> getFileFromUrl(String url) async {
    try {
      var header = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Token 06fc06cfcbf3df257d02c0187e17e5587e6f24a3'
      };
      var data = await http.get(url, headers: header);
      var bytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File('${dir.path}/std8online.pdf');
      File assetUrl = await file.writeAsBytes(bytes);
      return assetUrl;
    } catch (e) {
      throw Exception('Error opening url file');
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
                color: Colors.blue,
                child: Text('Open from Url'),
                onPressed: () {
                  if (urlPdfPath != null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PdfViewPage(
                                  path: urlPdfPath,
                                )));
                  }
                }),
            SizedBox(
              height: 20,
            ),
            RaisedButton(
                color: Colors.cyan,
                child: Text('Open from Asset'),
                onPressed: () {
                  if (assetPdfFile != null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PdfViewPage(
                                  path: assetPdfFile,
                                )));
                  }
                })
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class PdfViewPage extends StatefulWidget {
  final String path;

  const PdfViewPage({Key key, this.path}) : super(key: key);
  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  int _totalpages = 0;
  int _currentPage = 0;
  bool pdfReady = false;
  PDFViewController _pdfViewController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Document'),
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.path,
            autoSpacing: true,
            enableSwipe: true,
            pageSnap: true,
            swipeHorizontal: true,
            onError: (e) {
              print(e);
            },
            onRender: (_pages) {
              setState(() {
                _totalpages = _pages;
                pdfReady = true;
              });
            },
            onViewCreated: (PDFViewController vc) {
              setState(() {
                _pdfViewController = vc;
              });
            },
            onPageChanged: (int page, int total) {
              setState(() {});
            },
            onPageError: (page, e) {},
          ),
          !pdfReady
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Offstage()
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _currentPage > 0
              ? FloatingActionButton.extended(
                  backgroundColor: Colors.red,
                  onPressed: () {
                    _currentPage -= 1;
                    _pdfViewController.setPage(_currentPage);
                  },
                  label: Text('Go to ${_currentPage - 1}'),
                )
              : Offstage(),
          _currentPage < _totalpages
              ? FloatingActionButton.extended(
                  backgroundColor: Colors.green,
                  onPressed: () {
                    _currentPage += 1;
                    _pdfViewController.setPage(_currentPage);
                  },
                  label: Text('Go to ${_currentPage + 1}'),
                )
              : Offstage(),
        ],
      ),
    );
  }
}
