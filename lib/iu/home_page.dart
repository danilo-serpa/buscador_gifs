import 'dart:convert';

import 'package:buscador_gifs/iu/git_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search = '';
  int _offset = 0;
  final int _limit = 20;
  final String _apiKey = 'C8rUo53SnUgjnPpgxZZOIHhXHwigdm65';

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search == '') {
      Uri url = Uri.parse(
          'https://api.giphy.com/v1/gifs/trending?api_key=$_apiKey&limit=$_limit&rating=g');
      response = await http.get(url);
    } else {
      Uri url = Uri.parse(
          'https://api.giphy.com/v1/gifs/search?api_key=$_apiKey&q=$_search&limit=${_limit - 1}&offset=$_offset&rating=g&lang=en');
      response = await http.get(url);
    }

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Pesquise Aqui',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
              onSubmitted: (value) {
                setState(() {
                  _search = value;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5,
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text(
                        "Erro ao carregar os dados!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ));
                    } else {
                      return _createGifTable(context, snapshot);
                    }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getItemCount(List data) {
    if (_search == '' || _search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(context, snapshot) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: _getItemCount(snapshot.data["data"]),
      itemBuilder: (context, index) {
        if ((_search == '' || _search == null) ||
            index < snapshot.data["data"].length) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GifPage(gifData: snapshot.data['data'][index]),
                ),
              );
            },
            onLongPress: () {
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]
                  ["url"]);
            },
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]["fixed_height"]
                  ["url"],
              height: 300,
              fit: BoxFit.cover,
            ),
          );
        } else {
          return GestureDetector(
            onTap: () {
              setState(() {
                _offset += 19;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 70,
                ),
                Text(
                  'Carregar mais...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                )
              ],
            ),
          );
        }
      },
    );
  }
}
