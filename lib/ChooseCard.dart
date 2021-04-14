import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChooseCard extends StatefulWidget {
  @override
  _ChooseCardState createState() => _ChooseCardState();
}

class _ChooseCardState extends State<ChooseCard> {

  List<Map<String,dynamic>> items=[];
  int empty=0;
  @override
  Widget build(BuildContext context) {
    this.items = ModalRoute.of(context).settings.arguments;
    if(items.length==0)
      this.empty=1;
    // print(this.items);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: BackButton(
                color: Colors.redAccent,
              ),
              titleSpacing: 2.0,
              title: Text(
                'Choose a Card',
                style: GoogleFonts.openSans(
                  color: Colors.redAccent
                ),
              ),
              backgroundColor: Colors.white,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                      (BuildContext context,int index){
                        if(empty==1)
                          return Center(
                            child: Container(
                              child: Text(
                                'No Cards created yet',
                                style: GoogleFonts.openSans(
                                    color: Colors.redAccent[400],
                                    fontSize: 20.0
                                ),
                              ),
                              margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10.0),
                              padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10.0),
                            ),
                          );
                        else return null;
                  },
                  childCount: 1
              ),
            ),
            SliverList(
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context,int index){
                      return this.gridItems(index);
                    },
                  childCount: this.items.length
                )
            )
          ],
        ),
      ),
    );
  }

  Container gridItems(int index){
    return Container(
      child: ListTile(
        leading: Icon(
          Icons.money_sharp,
          size: 30.0,
          color: Colors.white,
        ),
        title: Text(
          this.items[index]['name'],
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 25.0
          ),
        ),
        subtitle: Text(
          'Rs '+this.items[index]['spent'].toString()+'.00',
          style: GoogleFonts.openSans(
            color: Colors.white
          ),
        ),
        trailing: Text(
          'click to View history',
          style: GoogleFonts.openSans(
            color: Colors.white,
          ),
        ),
        tileColor: Colors.redAccent[400],
        onTap: (){Navigator.pushNamed(context, '/history',arguments: {'id':this.items[index]['id']});},

      ),
      margin: EdgeInsets.symmetric(vertical: 3.0,horizontal: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0)
      ),
    );
  }
}
