
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movielist/model/MovieData.dart';
class MovieDescriptionActivity extends StatefulWidget {
  const MovieDescriptionActivity({Key? key}) : super(key: key);

  @override
  _MovieDescriptionActivityState createState() => _MovieDescriptionActivityState();
}

class _MovieDescriptionActivityState extends State<MovieDescriptionActivity> {

  late MovieData movieData;

  bool isLoading =true;
  Future<bool> getMovieData(String id) async{

    final Uri uri =Uri.parse(
        "https://api.themoviedb.org/3/movie/$id?api_key=0d2ca8a57687b6cc7527daba6d8e441f"
    );


    final response =await http.get(uri);
    if(response.statusCode ==200){
      final results =movieDataFromJson(response.body);
     movieData=results;

      setState(() {

        isLoading =false;

      });

      return true;
    }else{
      setState(() {

        isLoading =false;

      });
      return false;
    }
  }
  bool isState =true;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if(isState){
      var map=ModalRoute.of(context)?.settings.arguments as Map<String,dynamic>;
      getMovieData(map['id']!.toString());
    }
    isState=false;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading?Center(
        child: CircularProgressIndicator(),
      ):Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
          "http://image.tmdb.org/t/p/w500${movieData.backdropPath}",
                height: MediaQuery.of(context).size.height/2,
                fit: BoxFit.fitHeight,
              ),
              Positioned(
                top: 50,
                left: 10,
                child: Container(
                  child: Row(
                    children: [
                      SizedBox(width: 20,),
                      Image.asset("images/back.png"),
                      SizedBox(width: 10,),
                      Text(movieData==null?"":movieData.title,style: TextStyle(fontSize: 20,color: Colors.white),)
                    ],
                  ),
                ),
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(left: 30,top: 40),
            child:  Text("Overview",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
          ),
          Container(
            margin: EdgeInsets.only(left: 30,top: 20),
            child:  Text(movieData.overview,style: TextStyle(fontSize: 18),),
          ),

        ],
      )
    );
  }
}
