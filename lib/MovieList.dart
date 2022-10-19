
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:movielist/model/movie_list.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
class MovieListActivity extends StatefulWidget {
  const MovieListActivity({Key? key}) : super(key: key);

  @override
  _MovieListActivityState createState() => _MovieListActivityState();
}

class _MovieListActivityState extends State<MovieListActivity> {
  int currentPage =1;
  late int totalPages;
  List<Result> movieResults =[];
  var isSearching=false;

  final RefreshController refreshController =RefreshController(initialRefresh: true);
  Future<bool> getMovieList({bool isRefresh=false,String query=""}) async{
    if(query.isEmpty){
      isSearching =false;
    }
    if(isRefresh){
      currentPage=1;
    }else{
      if(currentPage>=totalPages){
        refreshController.loadNoData();
        return false;
      }
    }
    final Uri uri;
    if(isSearching){
    uri =Uri.parse("https://api.themoviedb.org/3/search/movie?query=$query&api_key=0d2ca8a57687b6cc7527daba6d8e441f&page=$currentPage");
    }else{
    uri =Uri.parse("https://api.themoviedb.org/3/discover/movie?api_key=0d2ca8a57687b6cc7527daba6d8e441f&page=$currentPage&size=10");
    }

    final response =await http.get(uri);
    if(response.statusCode ==200){
      final results =movieListDataFromJson(response.body);
      if(isRefresh){
        movieResults =results.results;
      }else{
        movieResults.addAll(results.results);
      }

      totalPages =results.totalPages;
      currentPage++;
      setState(() {

      });
      return true;
    }else{
      return false;
    }
  }
  late TextEditingController _editingController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _editingController = TextEditingController(text: "");
    //getPassengerData();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _editingController.dispose();
    super.dispose();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      body: Column(
        children: [
        Container(
          margin: EdgeInsets.only(top: 50,left: 20,right: 20),
          height: 50,
          child:!isSearching?Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Watch", style:TextStyle(
          color: Colors.black,
                  fontFamily: "Poppins",
                fontSize: 35
          ),),

              InkWell(
                  onTap: (){
                    setState(() {
                      isSearching=!isSearching;
                    });

                  },
                  child: Image.asset("images/search_icon.png",color: Colors.black,width: 30,height: 30)),
            ],): TextField(
            decoration: new InputDecoration.collapsed(
                hintText: 'Search'
            ),
            onChanged: (value){
              setState(() {
                getMovieList(isRefresh: true,query: value);

              });
            },
            onSubmitted: (newValue){

            },
            autofocus: false,

            controller: _editingController,
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height-100,
          child: SmartRefresher(
            controller: refreshController,
            enablePullUp: true,
            onRefresh: ()async{
              final results =await getMovieList(isRefresh: true);
              if(results){
                refreshController.refreshCompleted();

              }else{
                refreshController.refreshFailed();
              }
            },
            onLoading: () async{
              final results =await getMovieList();
              if(results){
                refreshController.loadComplete();

              }else{
                refreshController.loadFailed();
              }
            },
            child:
                ListView.separated(
                    itemBuilder: (context, index){
                      var movieList =movieResults[index];
                      return
                        InkWell(
                          onTap: (){

                            Navigator.of(context).pushNamed("/movieDescription",arguments: {"id":movieList.id});
                          },
                          child: Stack(

                            children: <Widget>[
                              Card(
                                semanticContainer: true,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: Image.network(
                                  "http://image.tmdb.org/t/p/w500${movieList.backdropPath}",
                                  fit: BoxFit.fill,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                elevation: 5,
                                margin: EdgeInsets.all(10),
                              ),
                              Positioned(
                                bottom: 20,
                                left: 10,
                                child: Container(
                                    margin: const EdgeInsets.only(left: 10.0,right: 10.0),
                                    //alignment: Alignment.topLeft,
                                    child: Text(
                                      movieList.originalTitle,
                                      style: const TextStyle(color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          //fontFamily: "Poppins",
                                          fontSize: 22.0),
                                    )),
                              ),
                            ],
                          ),
                        );

                    },
                    separatorBuilder: (context, index) => Container(),
                    itemCount: movieResults.length
                )



          ),
        ),
      ]
      ),
    );
  }
}
