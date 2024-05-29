import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:spotter_app/bloc/post/post_bloc.dart';
import 'package:spotter_app/repository/firebase_repo_implementation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  void initState() {
    BlocProvider.of<PostBloc>(context).add(const GetPosts());
    print("calling bloc");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          title: Text('Your Posts')
      ),
      body: BlocBuilder<PostBloc, PostState>(
        bloc: BlocProvider.of<PostBloc>(context),
        builder: (context, state) {

          if(state is FetchedPosts){
            return ListView.separated(
                itemBuilder: (BuildContext context, int index) {



                  return Container(
                    color: Colors.white70,
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(
                              top: 25.0, bottom: 5.0, left: 25.0),
                          child: Text(
                            state.allPosts[index].location,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(
                              top: 5.0, bottom: 5.0, left: 25.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.alarm,
                                size: MediaQuery.of(context).size.width * 0.06,
                              ),

                              Text(
                                state.allPosts[index].duration.toString(),
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.left,

                              ),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(
                              top: 5.0, bottom: 5.0, left: 25.0),
                          child: Text(
                            state.allPosts[index].workout_type,
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left,
                          ),
                        ),

                        SizedBox(
                          child: Image.network(
                            state.allPosts[index].photoURL,
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: MediaQuery.of(context).size.width * 0.4,
                            fit: BoxFit.cover, // Ovo će prilagoditi sliku unutar okvira
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(
                              top: 5.0, bottom: 5.0, left: 25.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.music_note_rounded,
                                size: MediaQuery.of(context).size.width * 0.05,
                              ),
                              SizedBox(width: 8.0), // Prostor između ikone i teksta
                              Expanded(child: Text(
                                state.allPosts[index].playlist,
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                              ),)

                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemCount: state.allPosts.length);
          } else {
            return Container();
          }
        },
      ),


      drawer: Drawer(
        child: ListView(
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(
                  color: Colors.deepPurple
              ),
              child: Text('Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            ListTile(
              title: Text('Item 1'),
            ),
            ListTile(
              title: Text('Item 2'),
            ),
          ],),
      ),
    );
  }
}
