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
  List<Color> colors = [Colors.purple[200],Colors.red[300],Colors.pinkAccent[400],Colors.blueAccent,Colors.orange[300],Colors.greenAccent];
  Color nameFontColor=Colors.grey[850];
  Color priceFontColor=Colors.blueGrey[700];
  Color iconColor = Colors.blueGrey[700];
  Color iconBackColor = Colors.grey[100];
  var rnd = Random();
  Icon icon = Icon(Icons.add,size:30.0,color: Colors.blueAccent);String cmd='Add';
  int empty,addnew=0,crossAxisCount=1,editing=0,index;
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController editController = TextEditingController();
  String editingName;int editingPrice;

  void refresh() async{
    var snackbar = SnackBar(
      content: Text(
        'refreshing',
        style: GoogleFonts.openSans(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
    List<Map<String,dynamic>> itm = await db.query();
    List<Map<String,dynamic>> temp = [];
    itm.forEach((element) {temp.add(jsonDecode(jsonEncode(element)));});
    this.setState(() {
      this.items=temp;
      snackbar = SnackBar(
        content: Text(
          'refreshed',
          style: GoogleFonts.openSans(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    });

  }


  @override
  Widget build(BuildContext context) {
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
                      Navigator.pushReplacementNamed(context, '/');
                      // this.refresh();
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
                        return this.addNewItemCard();
                    },
                    childCount: this.items.length ==0 ? 1: this.items.length
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 10.0,
                  crossAxisCount: 2,
                  crossAxisSpacing: 2.0,
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.white,
            items: [
              BottomNavigationBarItem(
                icon: IconButton(
                  icon: this.icon,
                  onPressed: (){
                    this.setState(() {
                      if(this.addnew==1){
                        this.addnew=0;
                        this.cmd='Add';
                        this.icon = Icon(Icons.add,size:30.0,color: Colors.blueAccent);
                      }
                      else{
                        this.addnew=1;
                        this.cmd='Cancel';
                        this.icon = Icon(Icons.remove,size:30.0,color: Colors.blueAccent);
                      }
                    });},
                ),
                label:this.cmd,
              ),
              BottomNavigationBarItem(
                icon: IconButton(
                  icon: Icon(Icons.info_outline,size: 30.0,color:Colors.blueAccent),
                  onPressed: (){Navigator.pushNamed(context, '/info',arguments:this.items);},
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
          Container(
            child: Icon(
              Icons.money,
              size: 30.0,
              color: this.iconColor,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              color: this.iconBackColor,
            ),
            padding: EdgeInsets.all(8.0),
          ),
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
            ),
            height: 50.0,
            width: 200.0,
          ),
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
            ),
            height: 50.0,
            width: 200.0,
          ),
          Container(
            child: IconButton(
              icon: Icon(
                Icons.add,
                size: 30.0,
                color: Colors.blueGrey[900],
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
                  int rndid=rnd.nextInt(10000);
                  Map<String,dynamic> l={'id':rndid,'name':name,'spent':int.parse(price)};
                  Map<String,dynamic> l1={
                    'id':rnd.nextInt(10000),'name':name,'changed':int.parse(price),
                    'spent':int.parse(price),'date':DateTime.now().toString(),'parentId':rndid};
                  await db.insert(l);
                  this.priceController.text='';this.nameController.text='';
                  var snackbar = SnackBar(
                    content: Text(
                      'Card created',
                      style: GoogleFonts.openSans(),
                    ),
                  );
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
            // padding: EdgeInsets.symmetric(vertical: 0,horizontal: 5.0),
            margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              color: Colors.redAccent[400],
            ),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 5.0,horizontal: 5.0),
      margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
      decoration: BoxDecoration(
        borderRadius:BorderRadius.circular(10),
        // border: Border.all(width: 1.0,color: Colors.grey[700]),
        color: Colors.lime[300],
      ),
    );
  }

  Container addNewItemCard(){
    int l=rnd.nextInt(this.colors.length);
    // print(l);
    // print(287);
    return Container(
      child: Center(
        child: TextButton.icon(
          icon: Icon(
            Icons.add,
            size: 30.0,
            color: Colors.blueGrey[600],
          ),
          label: Text(
            'Add Item',
            style: GoogleFonts.openSans(
              fontSize: 20.0,
              color: Colors.blueGrey[600],
            ),
          ),
          onPressed: (){
            this.setState(() {this.addnew=1;});
          },
        ),
      ),
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.symmetric(vertical: 3.0,horizontal: 3.0),
      decoration: BoxDecoration(
        borderRadius:BorderRadius.circular(10),
        // border: Border.all(width: 1.0,color: Colors.grey[700]),
        color: this.colors[l],
      ),
    );
  }

  Container showEditWindow(){
    return Container(
      child: Column(
        children: [
          Container(
            child: Icon(
              Icons.money,
              size: 30.0,
              color: this.iconColor,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              color: this.iconBackColor,
            ),
            padding: EdgeInsets.all(8.0),
          ),
          Text(
            this.editingName,
            style: GoogleFonts.openSans(
                fontSize: 20.0,
                color: this.nameFontColor
            ),
          ),
          Text(
            'Rs '+this.editingPrice.toString()+'.00',
            style: GoogleFonts.openSans(
                fontSize: 20.0,
                color: this.priceFontColor
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                      this.setState(() {
                        this.editingPrice+=price;
                        this.items[this.index]['spent']=this.editingPrice;
                      });
                    }
                  }
              ),
              Container(
                child: TextField(
                  controller: this.editController,
                  decoration:InputDecoration(
                    labelText: 'Enter a value to add',
                    labelStyle: GoogleFonts.openSans(),
                    contentPadding: EdgeInsets.symmetric(vertical: 2.0,horizontal: 5.0),
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
                    Icons.remove,
                    color: Colors.redAccent,
                    size: 30.0,
                  ),
                  onPressed: ()async{
                    // print(this.editingPrice);
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
                      // print(price);
                      this.editingPrice-=price;
                      // print(this.editingPrice);
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
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
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
    // print(l);
    // print(484);
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            child: Icon(
              Icons.money,
              size: 30.0,
              color: this.iconColor,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              color: this.iconBackColor,
            ),
            padding: EdgeInsets.all(8.0),
          ),
          Text(
            item['name'],
            style: GoogleFonts.openSans(
                fontSize: 20.0,
                color: this.nameFontColor
            ),
          ),
          Text(
            'Rs '+item['spent'].toString()+'.00',
                style: GoogleFonts.openSans(
                    fontSize: 20.0,
                    color: this.priceFontColor
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
        // border: Border.all(width: 1.0,color: Colors.grey[700]),
        color: this.colors[l],
      ),
    );
  }
}

