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
  String name='';
  Color spendingColor=Colors.white;
  int sortspend=0,asc=1;
  IconData sorticon = Icons.arrow_downward_sharp;
  Future<void> loadHistory() async{
    DatabaseHelper db=DatabaseHelper.instance;
    dynamic id = ModalRoute.of(context).settings.arguments;
    List<Map<String,dynamic>> h = await db.queryHistory(id['id'],sortspend,asc);
    name = await db.getCardName(id['id']);
    this.setState(() {
      if(h.length==0)
        empty=1;
      this.history=h;
      this.name=name;
    });
  }


  @override
  Widget build(BuildContext context) {
    this.loadHistory();
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
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
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: Icon(
                              Icons.money,
                              size: 50.0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            padding: EdgeInsets.all(10.0),
                          ),
                          Text(
                            this.name,
                            style: GoogleFonts.openSans(
                                fontSize: 25.0,
                                color: Colors.grey[850]
                            ),
                          )
                        ],
                      ),
                      margin: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 100.0),
                    ),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.end,
                     crossAxisAlignment: CrossAxisAlignment.center,
                     children: [
                       Container(
                         child: IconButton(
                           icon: Icon(
                             sorticon
                           ),
                           onPressed: (){
                             this.setState(() {
                               if(this.asc==1){
                                 this.sorticon=Icons.arrow_downward_sharp;
                                 this.asc=0;
                               }
                               else{
                                 this.sorticon=Icons.arrow_upward_sharp;
                                 this.asc=1;
                               }
                               loadHistory();
                             });
                           },
                         ),
                       ),
                       Container(
                         child: TextButton.icon(
                             onPressed: (){
                               this.setState(() {
                                 if(this.sortspend==1){
                                   this.sortspend=0;
                                   this.spendingColor=Colors.white;
                                 }
                                 else{
                                   this.sortspend=1;
                                   this.spendingColor=Colors.black;
                                 }
                               });
                               this.loadHistory();
                             },
                             icon: Icon(
                               Icons.sort_sharp
                             ),
                             label: Text(
                               'Spending',
                               style: GoogleFonts.openSans(),
                             )
                         ),
                         color: this.spendingColor,
                         margin: EdgeInsets.symmetric(vertical: 0,horizontal: 5.0),
                       ),

                     ],
                   )
                  ]
                )
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
        color: Colors.redAccent[400],
        borderRadius: BorderRadius.circular(5.0)
      ),
      padding: EdgeInsets.symmetric(vertical: 5.0,horizontal:10.0),
      margin: EdgeInsets.symmetric(vertical: 5.0,horizontal:5.0),
    );
  }
}
