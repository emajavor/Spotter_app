
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:spotter_app/bloc/post/post_bloc.dart';
import 'package:spotter_app/repository/firebase_repo_implementation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter_app/ui/add_post_screen.dart';
import 'package:spotter_app/ui/workout_detail_screen.dart';
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
      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.of(
            context).push
          (MaterialPageRoute(
          builder: (_) => BlocProvider.value(
              value: BlocProvider.of<PostBloc>(context),
              child: AddPostScreen() ),
        ),
        );
      },
      child: Icon(Icons.add),),
      appBar: AppBar(
          title: Text('Your Posts'),
      ),
      body: BlocBuilder<PostBloc, PostState>(
        buildWhen: (prev, curr) => curr is FetchedPosts || curr is FetchingPosts,
        bloc: BlocProvider.of<PostBloc>(context),
        builder: (context, state) {
          print("State in StartScreen is: $state");
          if(state is FetchedPosts){
            return ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(
                        context).push
                        (MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: BlocProvider.of<PostBloc>(context),
                            child: WorkoutDetailScreen(workoutPost: state.allPosts[index],) ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                          top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                      color: Colors.white,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 25.0, left: 15.0, bottom: 10.0),
                                child: SizedBox(
                                    child: ClipOval(
                                      child: Image(
                                       image: NetworkImage('https://avatar.iran.liara.run/public/boy?username=Ash'),
                                        width: MediaQuery.of(context).size.width * 0.15,
                                        height: MediaQuery.of(context).size.width * 0.15,
                                        fit: BoxFit.cover,
                                      ),// Ovo će prilagoditi sliku unutar okvira
                                    ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(
                                          top: 20.0, bottom: 5.0, right: 15.0),
                                      child: Text(
                                        state.allPosts[index].location,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(
                                          top: 5.0, bottom: 5.0, right: 15.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Icon(
                                            Icons.alarm,
                                            size: MediaQuery.of(context).size.width * 0.06,
                                          ),

                                          Text(
                                            state.allPosts[index].duration.toString(),
                                            style: TextStyle(fontSize: 16),
                                            textAlign: TextAlign.right,

                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          Container(
                            alignment: Alignment.centerLeft,
                            padding:
                            EdgeInsets.only(top: 20.0, bottom: 10.0, left: 15.0),
                            child: Text(
                              state.allPosts[index].workout_type,
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.left,
                            ),
                          ),

                          SizedBox(
                            child: Image.network(
                              state.allPosts[index].photoURL,
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: MediaQuery.of(context).size.width * 0.6,
                              fit: BoxFit.cover, // Ovo će prilagoditi sliku unutar okvira

                            ),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(
                                top: 15.0, bottom: 5.0, left: 15.0),
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
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemCount: state.allPosts.length);
          } else if (state is FetchingPosts) {
            return const Center(child: CircularProgressIndicator());
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
