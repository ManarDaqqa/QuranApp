import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:quran_app/api/api_constants.dart';
import 'package:quran_app/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPage = 20;
  bool isLoaded = false;
  dynamic data;
  int page = 1;
  var listSearch = [];
  String? search;

  List<Text> allAyahs = [];

  void getQuran(int page) async {
    String url = '${ApiConstants.baseUrl}page/$page/quran-uthmani';
    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      setState(() {
        isLoaded = true;
        data = result['data']['ayahs'] as List;
      });
    }
  }

  Future<List> getSearched(String search) async {
    String url = '${ApiConstants.baseUrl}search/$search/all/en';

    http.Response response = await http.get(Uri.parse(url));
    final results = json.decode(response.body);
    data = results['data']['ayahs'] as List;
    for (var i = 0; i < data.length; i++) {
      listSearch.add(data[i]['text']);
    }

    print('listSearch: $listSearch');
    return listSearch;
  }

  @override
  void initState() {
    getQuran(currentPage);
    getSearched(AyahsSearch(listSearch).query);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeecfa6),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffeecfa6),
        title: const Text(
          'Quran App',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: AyahsSearch(listSearch));
            },
            icon: const Icon(Icons.search),
            color: Colors.black,
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Text('${data[0]['surah']['name']}'),
                      // Text('الجزء${data[0]['juz']}'),
                    ]),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: RichText(
                      softWrap: true,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                          text: '',
                          style: const TextStyle(
                              color: Colors.black,
                              fontFamily: 'Kitab',
                              fontSize: 19),
                          children: [
                            for (var item in data) ...{
                              TextSpan(text: ' ${item['text']} '),
                              WidgetSpan(
                                  child: SizedBox(
                                height: 30,
                                width: 25,
                                child: Stack(
                                  children: [
                                    SvgPicture.asset(
                                        'assets/icons/Scheherazade.svg',
                                        fit: BoxFit.fill),
                                    Align(
                                      alignment: AlignmentDirectional.center,
                                      child: Text(
                                        '${item['numberInSurah']} ',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                            }
                          ])),
                ),
                ...allAyahs,
                const Spacer(),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed: () {
                            setState(() {
                              getQuran(currentPage++);
                            });
                          },
                          child: const Text('الصفحة التالية')),
                      Text('$currentPage'),
                      TextButton(
                          onPressed: () {
                            getQuran(currentPage--);
                          },
                          child: const Text('الصفحة السابقة')),
                    ])
              ],
            )),
      ),
    );
  }
}

class AyahsSearch extends SearchDelegate<String> {
  List<dynamic> list;

  AyahsSearch(this.list);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, 'null');
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
   return Text(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var searchList =
        query.isEmpty ? list : list.where((e) => e.startswith(query)).toList();
    return ListView.builder(
        itemCount: searchList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(searchList[index]),
            onTap: (){
              showResults(context);
            },
          );
        });
  }
}
