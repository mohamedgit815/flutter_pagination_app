import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class FetchData extends ChangeNotifier {
  List dataList = [];
  bool hasMore = true;


  Future fetchData({ required String url , required int limit,required int page })  async {
    final http.Response _response = await http.get(Uri.parse(url));
    final List<dynamic> _data = await jsonDecode(_response.body);

    if(_response.statusCode == 200 ) {
      page++;

      if(dataList.length < limit) {
        hasMore = false;
      }

      notifyListeners();

       dataList.addAll(_data.map((e) => FetchModel.fromApp(e)).toList());
    }
  }

  Future<void> refreshData(int page) async {
    hasMore = false;
    page = 0;
    dataList.clear();
    notifyListeners();
  }
}

class FetchModel {
  final String title , body;
  final int id;

  const FetchModel({ required this.title , required this.body , required this.id });

  factory FetchModel.fromApp(Map<String , dynamic>map) {
    return FetchModel(
        title: map['title'] ,
        body: map['body'] ,
        id: map['id']
    );
  }

 static Future<List<FetchModel>> fetchData() async {
    final http.Response _response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
    final List<dynamic> _body = await jsonDecode(_response.body);

    if(_response.statusCode == 200) {
     final List<FetchModel> _data =  _body.map((e) => FetchModel.fromApp(e)).toList();
     return _data;
    } else {
      throw Exception('Error');
    }
  }
}

class _MobileFetchScreen{
  final int _limit = 3;
  int _page = 2;
  String _url(){
    return 'https://jsonplaceholder.typicode.com/posts?_limit=$_limit&_page=$_page';
  }

  final _fetchDataProv = ChangeNotifierProvider<FetchData>((ref)=>FetchData());
  final ScrollController _scrollController = ScrollController();
}