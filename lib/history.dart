import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {

  List<Map<String,dynamic>> history=[];
  int empty=0;

  Future<void> loadHistory() async{
    DatabaseHelper db=DatabaseHelper.instance;
    dynamic id = ModalRoute.of(context).settings.arguments;
    List<Map<String,dynamic>> h = await db.queryHistory(id['id']);
    this.setState(() {
      if(h.length==0)
        empty=1;
      this.history=h;
    });
  }


  @override
  Widget build(BuildContext context) {
    this.loadHistory();
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: BackButton(
                color: Colors.redAccent,
              ),
              title: Text(
                'History',
                style: GoogleFonts.openSans(
                  color: Colors.redAccent
                ),
              ),
              backgroundColor: Colors.white,
              titleSpacing: 2.0,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                      (BuildContext context,int index){
                        if(empty==1)
                          return Center(
                            child: Container(
                              child: Text(
                                'No history found for this card',
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
                    return this.historyObj(index);
                  },
                childCount: this.history.length
              ),
            )
          ],
        ),
      ),
    );
  }
  Container historyObj(int index){
    String sign = this.history[index]['changed']>0? '+' : '';
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            this.history[index]['name'],
            style: GoogleFonts.openSans(
              fontSize: 20.0,
              color: Colors.white
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                sign+' '+this.history[index]['changed'].toString(),
                style: GoogleFonts.openSans(
                    fontSize: 15.0,
                    color: Colors.white
                ),
              ),
              SizedBox(height: 5.0),
              Text(
                this.history[index]['spent'].toString(),
                style: GoogleFonts.openSans(
                    fontSize: 20.0,
                    color: Colors.white
                ),
              ),
              SizedBox(height: 5.0),
              Text(
                this.history[index]['date'].toString().substring(0,10),
                style: GoogleFonts.openSans(
                    fontSize: 15.0,
                    color: Colors.white
                ),
              )
            ],
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.redAccent[400]
      ),
      padding: EdgeInsets.symmetric(vertical: 5.0,horizontal:10.0),
      margin: EdgeInsets.all(5.0),
    );
  }
}
