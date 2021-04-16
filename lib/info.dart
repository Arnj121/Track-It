import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database.dart';
import 'package:percent_indicator/percent_indicator.dart';

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
  dynamic todayCard={};
  int notCal=1;
  TextEditingController daily = TextEditingController();
  TextEditingController monthly = TextEditingController();
  dynamic limit=[];
  Future<void> loadData() async {
    this.month=today.month;
    this.day=today.day;
    this.year = today.year;
    this.dates = await db.queryHistory(0);
    this.dates.forEach((element) {
      this.totalSpent+=element['changed'];
      var date = DateTime.parse(element['date']);
      if(date.month==this.month && date.year == this.year){
        this.monthSpend+=element['changed'];
        if(date.day == this.day){
          this.spentToday+=element['changed'];
          if(this.todayCard.containsKey(element['parentId']))
            this.todayCard[element['parentId']]['spent']+=element['changed'];
          else
            this.todayCard[element['parentId']] = {'id':element['parentId'],'name':element['name'],'spent':element['changed']};
        }
      }
    });
    this.todayCard =  this.todayCard.values.toList();
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
    dynamic temp = await db.getLimits();
    temp.forEach((element){limit.add(jsonDecode(jsonEncode(element)));});
    for(int i=0;i<limit.length;i++){
      if(limit[i]['name']=='daily') {
        this.daily.text = limit[i]['limitval'].toString();
        limit[i]['value']=await db.getTodaySpending();
      }
      else if(limit[i]['name']=='monthly') {
        this.monthly.text = limit[i]['limitval'].toString();
         limit[i]['value']=await db.getMonthSpending();
      }
    }
    this.setState(() {
      this.spentToday=this.spentToday;
      this.monthSpend=this.monthSpend;
      this.todayCard=this.todayCard;
      this.limit = this.limit;
      if(this.items.length>0)
        this.notCal=0;
    });
  }

  @override
  void initState() {
    super.initState();
    this.loadData();
  }

  @override
  Widget build(BuildContext context){
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
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
                  SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context,int index){
                            return this.ProgressLimit(this.limit[index]);
                        },
                      childCount: this.limit.length
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2
                    ),
                  ),
                  SliverList(
                      delegate: SliverChildListDelegate(
                          [
                            Center(
                              child: Container(
                                child: Text(
                                  'Daily Spending Stats',
                                  style: GoogleFonts.openSans(
                                      color: Colors.blueGrey[900],
                                      fontSize: 20.0
                                  ),
                                ),
                                margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 10.0),
                              ),
                            ),
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
                                color: Colors.purple[100]
                              ),
                              padding: EdgeInsets.all(5.0),
                              margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 5.0),
                            ),
                          ]
                      )
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                            (BuildContext context,int index){
                          return TodayCardBuilder(index);
                        },
                        childCount:this.todayCard.length
                    ),
                  ),
                  SliverList(delegate: SliverChildListDelegate(
                      [
                        Divider(color: Colors.grey[600],height: 30.0,),
                        Center(
                          child: Container(
                            child: Text(
                              'All time Spending',
                              style: GoogleFonts.openSans(
                              color: Colors.blueGrey[900],
                              fontSize: 20.0
                              ),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 10.0),
                          ),
                        )
                      ]
                    )
                  ),
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
                          Divider(color: Colors.grey[400],height: 30.0,),
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
                                  'Rs '+this.monthSpend.toString()+'.00',
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
                              borderRadius: BorderRadius.circular(100.0),
                              color: Colors.purple[100]
                            ),
                          ),
                          Divider(height: 30.0,color: Colors.grey[600]),
                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: Text(
                                    'Set a Daily Limit',
                                    style: GoogleFonts.openSans(
                                      color: Colors.white,
                                      fontSize: 20.0
                                    ),
                                  ),
                                  margin: EdgeInsets.all(5.0),
                                ),
                                Container(
                                  child: TextField(
                                    controller: this.daily,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(vertical: 2.0,horizontal: 3.0),
                                        border: UnderlineInputBorder()
                                    ),
                                    style: GoogleFonts.openSans(
                                      color: Colors.white
                                    ),
                                  ),
                                  height: 50.0,
                                  width: 100.0,
                                ),
                                Container(
                                  child: TextButton(
                                    child: Text(
                                      'Set',
                                      style: GoogleFonts.openSans(
                                        fontSize: 20.0,
                                        color: Colors.white70
                                      ),
                                    ),
                                    onPressed: ()async{
                                      dynamic val = this.daily.text;
                                      if(val.length == 0){
                                        var sb = SnackBar(
                                            content: Text(
                                              'Enter a Value',
                                              style: GoogleFonts.openSans(),
                                            )
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(sb);
                                      }
                                      else{
                                        val = int.parse(val);
                                        if(val<0){
                                          var sb = SnackBar(
                                              content: Text(
                                                'Limit cannot be negetive',
                                                style: GoogleFonts.openSans(),
                                              )
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(sb);
                                        }else {
                                          await db.updateLimit('daily', val);
                                          var sb = SnackBar(
                                              content: Text(
                                                'Daily limit set',
                                                style: GoogleFonts.openSans(),
                                              )
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(sb);
                                          FocusScope.of(context).unfocus();
                                        }
                                      }
                                    },
                                  ),
                                  margin: EdgeInsets.all(5.0),
                                )
                              ],
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.redAccent[400]
                            ),
                            margin: EdgeInsets.symmetric(vertical:10.0,horizontal:5.0),
                            padding: EdgeInsets.symmetric(vertical:10.0,horizontal:5.0),

                          ),
                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: Text(
                                    'Set a Monthly Limit',
                                    style: GoogleFonts.openSans(
                                        color: Colors.white,
                                        fontSize: 20.0
                                    ),
                                  ),
                                  margin: EdgeInsets.all(5.0),
                                ),
                                Container(
                                  child: TextField(
                                    controller: this.monthly,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(vertical: 2.0,horizontal: 3.0),
                                        border: UnderlineInputBorder(),
                                    ),
                                    style: GoogleFonts.openSans(
                                      color: Colors.white
                                    ),
                                  ),
                                  height: 50.0,
                                  width:100.0,
                                ),
                                Container(
                                  child: TextButton(
                                    child: Text(
                                      'Set',
                                      style: GoogleFonts.openSans(
                                          fontSize: 20.0,
                                          color: Colors.white70
                                      ),
                                    ),
                                    onPressed: ()async{
                                      dynamic val = this.monthly.text;
                                      if(val.length == 0){
                                        var sb = SnackBar(
                                            content: Text(
                                                'Enter a Value',
                                                style: GoogleFonts.openSans(),
                                            )
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(sb);
                                        FocusScope.of(context).unfocus();
                                      }
                                      else{
                                        val = int.parse(val);
                                        if(val<0){
                                          var sb = SnackBar(
                                              content: Text(
                                                'Limit cannot be negetive',
                                                style: GoogleFonts.openSans(),
                                              )
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(sb);
                                        }else {
                                          await db.updateLimit('monthly', val);
                                          var sb = SnackBar(
                                              content: Text(
                                                'Monthly limit set',
                                                style: GoogleFonts.openSans(),
                                              )
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(sb);
                                          FocusScope.of(context).unfocus();
                                        }
                                      }
                                    },
                                  ),
                                  margin: EdgeInsets.all(5.0),
                                )
                              ],
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.redAccent[400]
                            ),
                            margin: EdgeInsets.symmetric(vertical:10.0,horizontal:5.0),
                            padding: EdgeInsets.symmetric(vertical:10.0,horizontal:5.0),
                          ),

                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: Icon(
                                    Icons.info_outline,
                                    color: Colors.amberAccent,
                                  ),
                                  margin: EdgeInsets.symmetric(vertical: 0,horizontal: 5.0),
                                ),
                                Text(
                                  'Spendings will reset Every Month',
                                  style: GoogleFonts.openSans(),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(5.0),
                            margin: EdgeInsets.all(10.0),
                          ),
                          Container(
                            child: Column(
                              children: [
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        child: Icon(
                                          Icons.warning_amber_sharp,
                                          color:Colors.redAccent[400]
                                        ),
                                        margin: EdgeInsets.symmetric(vertical: 0,horizontal: 5.0),
                                      ),
                                      TextButton(
                                        child:Text(
                                          'Erase all the data',
                                          style: GoogleFonts.openSans(
                                            fontSize: 15.0
                                          ),
                                        ),
                                        onPressed: (){
                                          db.deleteHistory();
                                          Navigator.pop(context);
                                        },
                                      )
                                    ],
                                  ),
                                  margin: EdgeInsets.all(5.0),
                                ),
                                Container(
                                  child: Text(
                                    '(This includes card data and history)',
                                    style: GoogleFonts.openSans(),
                                  ),
                                  margin: EdgeInsets.all(0),
                                )
                              ],
                            ),
                            padding: EdgeInsets.all(5.0),
                            margin: EdgeInsets.all(10.0),
                          )
                        ]
                      )
                  )
                ]
            ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
            items:[
              BottomNavigationBarItem(
                icon:IconButton(
                  onPressed: () async{
                    await db.resetToday();
                    Navigator.pop(context,{'refresh':1});
                  },
                  icon: Icon(
                    Icons.sync,
                    size: 30.0,
                    color: Colors.redAccent,
                  ),
                ),
                label: 'Reset',
              ),
              BottomNavigationBarItem(
                icon: IconButton(
                  onPressed: (){
                    Navigator.pushNamed(context, '/choosecard',arguments: this.items);
                  },
                  icon: Icon(
                    Icons.history_outlined,
                    size: 30.0,
                    color: Colors.redAccent,
                  ),
                ),
                label: 'History'
              )
          ]
        ),
      ),
    );
  }
  Container ProgressLimit(Map<String,dynamic> l) {
    dynamic v,txt;
    Icon icon;
    Color color;
    if(l['limitval']==0) {
      v = 0.0;
      txt='0.00 %';
      icon = Icon(
        Icons.check_circle_sharp,
        color: Colors.green,
      );
      color = Colors.green;
    }
    else {
      v = l['value'] / l['limitval'];
      txt = (((l['value'] / l['limitval'])*100)
          .toStringAsFixed(2)).toString() + ' %';
      icon = Icon(
        Icons.check_circle_sharp,
        color: Colors.green,
      );
      color = Colors.green;
      if (v > 1.0) {
        v = 1.0;
        icon = Icon(
          Icons.warning_amber_sharp,
          color: Colors.redAccent,
        );
        txt = (((l['value'] / l['limitval'])*100)
            .toStringAsFixed(2)).toString() + ' %';
        color = Colors.red[300];
      }
    }
    return Container(
      child: CircularPercentIndicator(
        percent:v,
        radius: 100.0,
        lineWidth: 5.0,
        animation: true,
        animationDuration: 1000,
        progressColor: Colors.purpleAccent,
        center: Text(
          txt.toString(),
          style: GoogleFonts.openSans(
              fontSize: 20.0,
              color: color
          ),
        ),
        footer: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              icon,
              Text(
                l['name'] + ' stats',
                style: GoogleFonts.openSans(
                    color: color,
                    fontSize: 20.0
                ),
              ),
            ],
          ),
          margin: EdgeInsets.all(10.0),
        ),
        backgroundColor: Colors.purple[50],
      ),
      margin: EdgeInsets.all(5.0),
    );
  }

  Container TodayCardBuilder(int index){
    return Container(
      child: ListTile(
        leading: Icon(
          Icons.money_sharp,
          size: 30.0,
          color: Colors.white,
        ),
        title: Text(
          this.todayCard[index]['name'],
          style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 25.0
          ),
        ),
        trailing: Text(
          'Rs '+this.todayCard[index]['spent'].toString()+'.00',
          style: GoogleFonts.openSans(
              color: Colors.white
          ),
        ),
        subtitle: Text(
          'Spent today ',
          style: GoogleFonts.openSans(
            color: Colors.white,
          ),
        ),
        onTap: (){Navigator.pushNamed(context, '/history',arguments: {'id':this.todayCard[index]['id']});},
      ),
      margin: EdgeInsets.symmetric(vertical: 3.0,horizontal: 5.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.0),
        color: Colors.redAccent[400],
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
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.amber[700]
      ),

    );
  }

  Container totalExpenditure(){
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
      margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.blueAccent,
      ),
    );
  }
}
