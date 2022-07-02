import 'package:flutter/material.dart';
import 'package:flutter_pagination_app/fetch_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FetchPage extends ConsumerStatefulWidget {
  const FetchPage({Key? key}) : super(key: key);

  @override
  _FetchPageState createState() => _FetchPageState();
}

class _FetchPageState extends ConsumerState<FetchPage> with _MobileFetchScreen {
  @override
  void initState() {
    super.initState();
    ref.read(_fetchDataProv).fetchData(url: _url(), limit: _limit, page: _page);

    _scrollController.addListener(() {
      if(_scrollController.position.maxScrollExtent == _scrollController.offset) {
        ref.read(_fetchDataProv).fetchData(url: _url(), limit: _limit, page: _page++);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pagination"), centerTitle: true),
      body: Consumer(builder: (context, prov, _) {
        return RefreshIndicator(
          onRefresh: () async {
            return prov.watch(_fetchDataProv).refreshData(_page);
          },
          child: ListView.builder(
              itemCount: prov.watch(_fetchDataProv).dataList.length ,
              controller: _scrollController,
              itemBuilder: (context, i) {

                final FetchModel _model = prov.read(_fetchDataProv).dataList.elementAt(i);

                if(i < prov.watch(_fetchDataProv).dataList.length) {

                  return ListTile(
                    title: Text(_model.title) ,
                    subtitle: Text(_model.body)
                  );
                } else {
                  return prov.watch(_fetchDataProv).hasMore ? const Text('Nodata') : const Center(child: CircularProgressIndicator.adaptive());
                }
              }),
        );
      }),
    );
  }
}

class _MobileFetchScreen {
  final int _limit = 10;
  int _page = 1;

  String _url() {
    return 'https://jsonplaceholder.typicode.com/posts?_limit=$_limit&_page=$_page';
  }

  final _fetchDataProv =
      ChangeNotifierProvider<FetchData>((ref) => FetchData());
  final _fetchData =
      FutureProvider<List<FetchModel>>((ref) => FetchModel.fetchData());
  final ScrollController _scrollController = ScrollController();
}
