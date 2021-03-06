import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database.dart';
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}


class _HomeState extends State<Home> {
  DatabaseHelper db=DatabaseHelper.instance;
  List<Map<String,dynamic>> items= [];
  dynamic limit=[];
  List<Color> colors = [Colors.purple[200],Colors.red[300],Colors.pinkAccent[400],Colors.blueAccent,Colors.orange[300],Colors.greenAccent];
  var rnd = Random();
  Icon icon = Icon(Icons.add,size:30.0,color: Colors.white);String cmd='Add';
  int empty,addnew=0,crossAxisCount=1,editing=0,index,search=0;dynamic searchtext='No';
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController editController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  String editingName;int editingPrice;
  int todaySpending,monthSpending;
  void refresh() async{
    var snackbar = SnackBar(
      content: Text(
        'refreshed',
        style: GoogleFonts.openSans(),
      ),
    );
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
    List<Map<String,dynamic>> itm = await db.query();
    List<Map<String,dynamic>> temp = [];
    itm.forEach((element) {temp.add(jsonDecode(jsonEncode(element)));});
    this.setState(() {
      this.items=temp;
      if(this.addnew==1){
        this.addnew=0;
        this.cmd='Add';
        this.icon = Icon(Icons.add,size:30.0,color: Colors.white);
      }
      this.editing=0;
    });
  }


  void init() async{
    this.todaySpending=await db.getTodaySpending();
    this.monthSpending=await db.getMonthSpending();
    this.limit=await db.getLimits();
  }

  @override
  Widget build(BuildContext context) {
    this.init();
    this.items=items.isNotEmpty? items : ModalRoute.of(context).settings.arguments;
    this.empty = this.items.length==0 ? 1 : 0;
    this.crossAxisCount = this.empty == 1 ? 1 : 2;
    return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body:CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: Icon(
                    Icons.account_balance_wallet,
                    size:30.0,
                    color:Colors.redAccent[400]
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.refresh_outlined,
                      size: 30.0,
                      color: Colors.redAccent,
                    ),
                    onPressed: (){
                      // Navigator.pushReplacementNamed(context, '/');
                      this.refresh();
                    },
                  )
                ],
                titleSpacing: 2.0,
                title: Text(
                  'Track-iT',
                  style: GoogleFonts.openSans(
                      fontSize: 25.0,
                      color: Colors.red
                  ),
                ),
                backgroundColor: Colors.white,
              ),
              SliverList(
                delegate:SliverChildListDelegate(
                  [
                    Container(
                      child:TextField(
                        controller: this.searchController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon:Icon(
                              Icons.cancel,
                              color: Colors.grey[850]
                            ),
                            onPressed: ()async{
                              this.searchController.text='';
                              List<Map<String,dynamic>> result = await db.query(),result1=[];
                              result.forEach((element) {result1.add(jsonDecode(jsonEncode(element)));});
                              this.setState(() {
                                this.search=0;
                                this.items=result1;
                              });
                            },
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[850],
                          ),
                          hintText: 'Search cards',
                          hintStyle: GoogleFonts.openSans(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          contentPadding: EdgeInsets.all(3.0),
                          fillColor: Colors.white60,
                        ),
                        onChanged: (text)async {
                          if(text.length>2){
                            dynamic result = await db.search(text);
                            if(result.length ==0){
                              this.setState(() {
                                this.search=1;
                                this.searchtext='No';
                              });
                            }
                            else {
                              this.setState(() {
                                this.search=1;
                                this.searchtext=result.length;
                                this.items = result;
                              });
                            }
                          }
                          else if(this.search==1)
                            {
                              List<Map<String,dynamic>> result = await db.query(),result1=[];
                              result = await db.query();
                              this.setState(() {
                                this.search=0;
                                result.forEach((element) {result1.add(jsonDecode(jsonEncode(element)));});
                                this.items=result1;
                             });
                            }
                        },
                      ),
                      padding: EdgeInsets.all(5.0),
                      margin: EdgeInsets.symmetric(vertical:10.0,horizontal: 15.0)
                    ),
                  ]
                )
              ),
              SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context,int index){
                        if(this.search==1)
                          return Container(
                            child: Center(
                              child: Text(
                                this.searchtext.toString()+' cards found',
                                style: GoogleFonts.openSans(
                                  fontSize: 20.0,
                                  color: Colors.grey[800]
                                ),
                              ),
                            ),
                            margin: EdgeInsets.all(10.0),
                          );
                        else return null;
                        },
                    childCount: 1
                  )
              ),
              SliverList(
                  delegate: SliverChildBuilderDelegate(
                          (BuildContext context,int index){
                        if(this.addnew==1)
                          return this.addNewItemWindow();
                        else return null;
                      },
                      childCount: 1
                  )
              ),
              SliverList(
                  delegate: SliverChildBuilderDelegate(
                          (BuildContext context,int index){
                        if(this.editing==1)
                          return this.showEditWindow();
                        else return null;
                      },
                      childCount: 1
                  )
              ),
              SliverGrid(
                delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      if(empty==0)
                        return this.griditems(items[index], index);
                      else
                        return Center(
                          child: Text(
                            'No cards added',
                            style: GoogleFonts.openSans(
                              fontSize: 20,
                              color: Colors.blueGrey[800]
                            ),
                          ),
                        );
                    },
                    childCount: this.items.length ==0 ? 1: this.items.length
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 10.0,
                  crossAxisCount: this.items.length==0?1:2,
                  crossAxisSpacing: 2.0,
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.orangeAccent,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            items: [
              BottomNavigationBarItem(
                icon: IconButton(
                  icon: this.icon,
                  onPressed: (){
                    this.setState(() {
                      if(this.addnew==1){
                        this.addnew=0;
                        this.cmd='Add';
                        this.icon = Icon(Icons.add,size:30.0,color: Colors.white);
                      }
                      else{
                        this.addnew=1;
                        this.cmd='Cancel';
                        this.icon = Icon(Icons.remove,size:30.0,color: Colors.white);
                      }
                    });},
                ),
                label:this.cmd,
              ),
              BottomNavigationBarItem(
                icon: IconButton(
                  icon: Icon(Icons.info_outline,size: 30.0,color:Colors.white),
                  onPressed: ()async{
                    FocusScope.of(context).unfocus();
                    dynamic ret = await Navigator.pushNamed(context, '/info',arguments:this.items);
                    if(ret!=null && ret['refresh']==1)
                      this.refresh();
                    },
                ),
                label:'Info',
              ),
            ],
          ),
        ),
      );
  }

  Container addNewItemWindow(){
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            child: Icon(
              Icons.money,
              size: 35.0,
              color: Colors.white,
            ),
            backgroundColor: Colors.orangeAccent,
            maxRadius: 30,
          ),
          SizedBox(height: 10,),
          Container(
            child:TextField(
              style: GoogleFonts.openSans(),
              controller: this.nameController,
              decoration: InputDecoration(
                labelText: 'Enter a name',
                labelStyle: GoogleFonts.openSans(),
                contentPadding: EdgeInsets.symmetric(vertical: 2.0,horizontal: 3.0),
                border: UnderlineInputBorder(),
              ),
              textAlign: TextAlign.center,
              cursorHeight: 20,
            ),
            height: 50.0,
            width: 200.0,
          ),
          SizedBox(height: 10,),
          Container(
            child:TextField(
              style: GoogleFonts.openSans(),
              controller: this.priceController,
              keyboardType: TextInputType.number ,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(
                labelText: 'Enter initial price: default 0',
                labelStyle: GoogleFonts.openSans(),
                contentPadding: EdgeInsets.symmetric(vertical: 2.0,horizontal: 3.0),
                border: UnderlineInputBorder(),
              ),
              textAlign: TextAlign.center,
              cursorHeight: 20,
            ),
            height: 50.0,
            width: 200.0,
          ),
          SizedBox(height: 15,),
          CircleAvatar(
            child: IconButton(
              icon: Icon(
                Icons.add,
                size: 30.0,
                color: Colors.white,
              ),
              onPressed: () async{
                String name = this.nameController.text;
                dynamic price=this.priceController.text;
                if(name.length==0){
                  var snackbar = SnackBar(
                    content: Text(
                      'Enter a name',
                      style: GoogleFonts.openSans(),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackbar);
                }
                else{
                  if(price.toString().length==0){price=0;}
                  else price=int.tryParse(price);
                  int rndid=rnd.nextInt(10000);
                  Map<String,dynamic> l={'id':rndid,'name':name,'spent':price};
                  Map<String,dynamic> l1={
                    'id':rnd.nextInt(10000),'name':name,'changed':price,
                    'spent':price,'date':DateTime.now().toString(),'parentId':rndid};
                  await db.insert(l);
                  this.priceController.text='';this.nameController.text='';
                  var snackbar = SnackBar(
                    content: Text(
                      'Card created',
                      style: GoogleFonts.openSans(),
                    ),
                    duration:Duration(milliseconds: 500) ,
                  );
                  if((price>this.limit[0]['limitval'] || price>this.limit[1]['limitval']) && (this.limit[0]['limitval']!=0 || this.limit[1]['limitval']!=0)){
                    snackbar = SnackBar(
                      content: Text(
                        'Expenses Limit reached',
                        style: GoogleFonts.openSans(),
                      ),
                      action: SnackBarAction(label: 'View info', onPressed: (){Navigator.pushNamed(context, '/info',arguments: this.items);}),
                    );
                  }
                  ScaffoldMessenger.of(context).showSnackBar(snackbar);
                  await db.insertHistory(l1);
                  this.setState(() {
                    this.items.add(l);
                    this.addnew=0;
                    this.cmd='Add';
                    this.icon = Icon(Icons.add,size:30.0,color: Colors.blueAccent);
                    if(this.empty==1)
                      this.empty=0;
                    this.crossAxisCount=2;
                  });
                }
              },
            ),
            backgroundColor: Colors.redAccent[400],
            maxRadius: 25,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 15.0,horizontal: 5.0),
      margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
      decoration: BoxDecoration(
        borderRadius:BorderRadius.circular(10),
        // border: Border.all(width: 1.0,color: Colors.grey[700]),
        color: Colors.purple[100],
      ),
    );
  }

  Container showEditWindow(){
    return Container(
      child: Column(
        children: [
          CircleAvatar(
            child: Icon(
              Icons.money,
              size: 35.0,
              color: Colors.white,
            ),
            maxRadius: 30,
            backgroundColor: Colors.orangeAccent,
          ),
          SizedBox(height: 10,),
          Text(
            this.editingName,
            style: GoogleFonts.openSans(
                fontSize: 20.0,
                color: Colors.blueGrey[800]
            ),
          ),
          SizedBox(height: 10,),
          Text(
            'Rs '+this.editingPrice.toString()+'.00',
            style: GoogleFonts.openSans(
                fontSize: 20.0,
                color: Colors.blueGrey[800]
            ),
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  icon: Icon(
                    Icons.remove,
                    color: Colors.redAccent[400],
                    size: 30.0,
                  ),
                  onPressed: ()async{
                    dynamic price = this.editController.text;
                    if(price.length==0){
                      var snackBar = SnackBar(
                        content: Text(
                          'Enter a value to add',
                          style: GoogleFonts.openSans(),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                    else {
                      price = int.parse(price);
                      this.editingPrice-=price;
                      if(this.editingPrice<0){
                        var snackBar = SnackBar(
                          content: Text(
                            'Enter a lower price',
                            style: GoogleFonts.openSans(),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                      else {
                        var l = jsonDecode(jsonEncode(this.items[this.index]));
                        l['spent'] = this.editingPrice;
                        await db.update(l);
                        l['date']=DateTime.now().toString();
                        l['parentId']=l['id'];l['id'] = rnd.nextInt(10000);l['changed']=-price;
                        await db.insertHistory(l);
                        this.setState(() {
                          this.editingPrice = this.editingPrice;
                          this.items[this.index]['spent'] = this.editingPrice;
                        });
                        var snackBar = SnackBar(
                          content: Text(
                            'price updated',
                            style: GoogleFonts.openSans(),
                          ),
                          duration: Duration(milliseconds: 500),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    }
                  }
                  ),
              Container(
                child: TextField(
                  controller: this.editController,
                  textAlign: TextAlign.center,
                  decoration:InputDecoration(
                    labelText: 'Enter a value',
                    labelStyle: GoogleFonts.openSans(),
                    contentPadding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 5.0),
                    border: UnderlineInputBorder(),
                  ) ,
                  keyboardType: TextInputType.number ,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
                margin: EdgeInsets.symmetric(vertical: 2.0,horizontal: 10.0),
                height: 50.0,
                width: 100.0,
              ),
              IconButton(
                  icon: Icon(
                    Icons.add,
                    size: 30.0,
                    color: Colors.blueAccent,
                  ),
                  onPressed: ()async{
                    dynamic price = this.editController.text;
                    if(price.length==0){
                      var snackBar = SnackBar(
                        content: Text(
                          'Enter a value to add',
                          style: GoogleFonts.openSans(),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                    else {
                      price = int.parse(price);
                      var l = jsonDecode(jsonEncode(this.items[this.index]));
                      l['spent'] = this.editingPrice+price;
                      await db.update(l);
                      l['date']=DateTime.now().toString();
                      l['parentId']=l['id'];l['id'] = rnd.nextInt(10000);l['changed']=price;
                      await db.insertHistory(l);
                      var snackBar = SnackBar(
                        content: Text(
                          'price updated',
                          style: GoogleFonts.openSans(),
                        ),
                        duration: Duration(milliseconds: 500),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      if((this.editingPrice+price>this.limit[0]['limitval'] && this.limit[0]['limitval']!=0) ||
                          (this.editingPrice+price>this.limit[1]['limitval'] && this.limit[1]['limitval']!=0)){
                        var snackbar = SnackBar(
                          content: Text(
                            'Expenses Limit reached',
                            style: GoogleFonts.openSans(),
                          ),
                          action: SnackBarAction(label: 'View info', onPressed: (){Navigator.pushNamed(context, '/info',arguments: this.items);}),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      }
                      this.setState(() {
                        this.editingPrice+=price;
                        this.items[this.index]['spent']=this.editingPrice;
                      });
                    }
                  }
              ),
            ],
          ),
          Container(
            child: TextButton(
              child: Text(
                'Done',
                style: GoogleFonts.openSans(
                  fontSize: 20.0,
                  color: Colors.blueAccent
                ),
              ),
              onPressed: (){
                this.setState(() {
                  this.editing=0;
                });
              },
            ),
            padding: EdgeInsets.symmetric(vertical: 5.0,horizontal: 2.0),
            margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 2.0),
          )
        ],
      )
    );
  }

  Container griditems(item,int index){
    int l=rnd.nextInt(this.colors.length);
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CircleAvatar(
            child: Icon(
              Icons.money,
              size: 35.0,
              color: Colors.blueGrey[800],
            ),
            maxRadius: 30,
            backgroundColor: Colors.white,
          ),
          Text(
            item['name'],
            style: GoogleFonts.openSans(
                fontSize: 20.0,
                color: Colors.blueGrey[800]
            ),
          ),
          Text(
            'Rs '+item['spent'].toString()+'.00',
                style: GoogleFonts.openSans(
                    fontSize: 20.0,
                    color: Colors.blueGrey[800]
                ),
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:[
                IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.white60,
                    ),
                    onPressed: () {
                      db.delete(this.items[index]);
                      this.setState(() {
                        this.items.removeAt(index);
                        if(this.items.length==0) {
                          this.empty = 1;
                          this.crossAxisCount=1;
                        }
                      });
                      var snackBar = SnackBar(
                        content: Text(
                          'Card deleted',
                          style: GoogleFonts.openSans(),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                ),
                IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Colors.white60,
                    ),
                    onPressed: (){
                      this.setState(() {
                        this.editController.text='100';
                        this.index=index;
                        this.editingPrice=this.items[index]['spent'];
                        this.editingName = this.items[index]['name'];
                        this.editing=1;
                      });
                    }
                ),
              ]
          )
        ],
      ),
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.symmetric(vertical: 3.0,horizontal: 3.0),
      decoration: BoxDecoration(
        borderRadius:BorderRadius.circular(10),
        color: this.colors[l],
      ),
    );
  }
}

