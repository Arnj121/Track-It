import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database.dart';
class Info extends StatefulWidget {
  @override
  _InfoState createState() => _InfoState();
}

class _InfoState extends State<Info> {

  int totalSpent=0;
  List<Map<String,dynamic>> items =[];
  List<Map<String,dynamic>> spendings=[
    {'title':'Most spent on','item':'','spent':-1},
    {'title':'Least spent on','item':'','spent':9999999}
    ];
  DateTime today = DateTime.now();
  int month,day,year;
  int spentToday=0,monthSpend=0;
  List<Map<String,dynamic>> dates=[];
  DatabaseHelper db = DatabaseHelper.instance;
  int notCal=1;
  Future<void> getHistory() async {
    this.month=today.month;
    this.day=today.day;
    this.year = today.year;
    this.dates = await db.queryHistory(0);
    this.dates.forEach((element) {
      this.totalSpent+=element['changed'];
      var date = DateTime.parse(element['date']);
      if(date.month==this.month && date.year == this.year){
        this.monthSpend+=element['changed'];
        if(date.day == this.day)
          this.spentToday+=element['changed'];
      }
    });
    items=ModalRoute.of(context).settings.arguments;
    items.forEach((element) {
      if(element['spent']>this.spendings[0]['spent']){
        this.spendings[0]['item']=element['name'];
        this.spendings[0]['spent']=element['spent'];
      }
      if(element['spent']<this.spendings[1]['spent']) {
        this.spendings[1]['item'] = element['name'];
        this.spendings[1]['spent'] = element['spent'];
      }
    });
    this.setState(() {
      this.spentToday=this.spentToday;
      this.monthSpend=this.monthSpend;
      if(this.items.length>0)
        this.notCal=0;
    });
  }

  @override
  void initState() {
    super.initState();
    this.getHistory();
  }

  @override
  Widget build(BuildContext context){
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    leading: BackButton(color: Colors.redAccent),
                    backgroundColor: Colors.white,
                    titleSpacing: 2.0,
                    title: Text(
                      'Info',
                      style: GoogleFonts.openSans(
                        color: Colors.redAccent
                      ),
                    ),
                    pinned: true,
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
                                      Icons.money_sharp,
                                      size: 50.0,
                                      color: Colors.blueGrey[700],
                                    ),
                                    padding: EdgeInsets.all(10.0),
                                    margin: EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(100.0)
                                    ),
                                  ),
                                  Text(
                                    'Money Spent Today',
                                    style: GoogleFonts.openSans(
                                      fontSize: 20.0,
                                      color: Colors.white60
                                    ),
                                  ),
                                  SizedBox(height: 10.0),
                                  Text(
                                    'Rs '+this.spentToday.toString()+'.00',
                                    style: GoogleFonts.openSans(
                                        fontSize: 20.0,
                                        color: Colors.white
                                    ),
                                  ),
                                  SizedBox(height: 10.0),
                                ],
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.amber[800]
                              ),
                              padding: EdgeInsets.all(5.0),
                              margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 5.0),
                            ),
                            Container(
                              child: Text(
                                'All time Spending',
                                style: GoogleFonts.openSans(
                                  color: Colors.blueGrey[900],
                                  fontSize: 20.0
                                ),
                              ),
                              margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 10.0),
                            )
                          ]
                  )),
                  SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 5.0,
                      mainAxisSpacing: 5.0
                    ),
                    delegate:SliverChildBuilderDelegate(
                        (BuildContext context,int index){
                          return this.totalExpenditure();
                        },
                      childCount: 1
                    ),
                  ),
                  SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context,int index){
                          if(this.notCal==0)
                            return this.buildSpentRank(index);
                          return null;
                        },
                      childCount: 2
                    ),
                  ),
                  SliverList(
                      delegate:SliverChildListDelegate(
                        [
                          Divider(color: Colors.grey[400],),
                          Container(
                            child: Text(
                              'This month\'s spending',
                              style: GoogleFonts.openSans(
                                  color: Colors.blueGrey[900],
                                  fontSize: 20.0
                              ),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 10.0),
                          ),
                          Container(
                            child:Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 10.0),
                                Text(
                                  'Money spent this month',
                                  style: GoogleFonts.openSans(
                                    fontSize: 20.0,
                                    color: Colors.white60
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  'RS '+this.monthSpend.toString()+'.00',
                                  style: GoogleFonts.openSans(
                                      fontSize: 20.0,
                                      color: Colors.white
                                  ),
                                ),
                                SizedBox(height: 10.0),
                              ],
                            ),
                            padding: EdgeInsets.all(5.0),
                            margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.deepOrange[300]
                            ),
                          )
                        ]
                      )
                  )
                ],
              ),
              height: MediaQuery.of(context).size.height*0.85,
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: TextButton.icon(
                        onPressed: (){
                          db.deleteHistory();
                          this.setState(() {

                          });
                        },
                        icon: Icon(
                          Icons.restore,
                          size: 30.0,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Reset',
                          style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontSize: 20.0
                          ),
                        ),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100.0),
                      color: Colors.redAccent
                    ),
                    padding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 5.0),
                    margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 5.0),
                    height: MediaQuery.of(context).size.width*0.15,
                  ),
                  Container(
                    child: TextButton.icon(
                      onPressed: (){
                        Navigator.pushNamed(context, '/choosecard',arguments: this.items);
                      },
                      icon: Icon(
                        Icons.history_outlined,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      label: Text(
                        'History',
                        style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontSize: 20.0
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.0),
                        color: Colors.redAccent,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 5.0),
                    margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 5.0),
                    height: MediaQuery.of(context).size.width*0.15,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  Container buildSpentRank(int index){
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            this.spendings[index]['title'],
            style: GoogleFonts.openSans(
              fontSize: 20.0,
              color: Colors.blueGrey[600]
            ),
          ),
          Text(
            this.spendings[index]['item'],
            style: GoogleFonts.openSans(
              fontSize: 25.0,
              color: Colors.grey[800],
            ),
          ),
          Text(
            'Rs '+this.spendings[index]['spent'].toString()+'.00',
            style: GoogleFonts.openSans(
              fontSize: 25.0,
              color: Colors.white
            ),
          ),
        ],
      ),
      padding: EdgeInsets.all(5.0),
      margin: EdgeInsets.symmetric(vertical: 2.0,horizontal: 3.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.amber[700]
      ),

    );
  }

  Container totalExpenditure(){
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Icon(
              Icons.money_sharp,
              size: 50.0,
              color: Colors.blueGrey[700],
            ),
            padding: EdgeInsets.all(10.0),
            margin: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100.0)
            ),
          ),
          Text(
            'Total Money spent',
            style: GoogleFonts.openSans(
              color: Colors.white60,
              fontSize: 20.0
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            'Rs '+totalSpent.toString()+'.00',
            style: GoogleFonts.openSans(
              fontSize: 30.0,
              color: Colors.white
            ),
          )
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 5.0,horizontal: 2.0),
      margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 2.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.blueAccent,
      ),
    );
  }
}
