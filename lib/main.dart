import 'package:flutter/material.dart';
import 'package:widgetstatecrud/models/contact.dart';
import 'package:widgetstatecrud/util/util/database_helper.dart';

const darkBlueColor = Color(0xff486579);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact App',
      theme: ThemeData(
        primaryColor : darkBlueColor,

      ),
      home: MyHomePage(title: 'Contact List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Contact _contact = Contact();
  List<Contact> _contacts = [];
  DatabaseHelper _dbHelper;

  final _ctrlName = TextEditingController();
  final _ctrlMobile = TextEditingController();

  @override
  void initState(){
    super.initState();
    _dbHelper = DatabaseHelper.instance;
    _refreshContactList();
  }

  _refreshContactList() async{
    List<Contact> x = await _dbHelper.fetchContacts();
    setState((){
     _contacts = x;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Center(
          child: Text(
            widget.title,
            style: TextStyle(color: darkBlueColor),
          ),
        ),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[_form(), _list()],
        ),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();
  _form() => Container(
    color: Colors.white,
    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
    child: Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _ctrlName,
            decoration: InputDecoration(labelText: 'Full Name'),
            validator: (val) =>(val.length ==0? 'this field is mendatory':null),
            onSaved: (val) => setState(()=> _contact.name = val),

          ),
          TextFormField(
            controller: _ctrlMobile,
            decoration: InputDecoration(labelText: 'Mobile'),
            validator: (val) =>(val.length < 10? '10 characters required':null),
            onSaved: (val) => setState(()=> _contact.mobile = val),

          ),
          Container(
            margin: EdgeInsets.all(10.0),
            child: RaisedButton(
              onPressed: () => _onSubmit(),
              child: Text('submit'),
              color: darkBlueColor,
              textColor: Colors.white,
            ),

          ),
        ],
      )
    )
  );
  _list() => Expanded(
    child: Card(
      margin: EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: Scrollbar(
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index){
           return Column(
             children: <Widget>[
               ListTile(
                 leading: Icon(
                   Icons.account_circle,
                   color: darkBlueColor,
                   size: 40.0,
                 ),
                 title: Text(
                   _contacts[index].name.toUpperCase(),
                   style: TextStyle(
                    color: darkBlueColor, fontWeight: FontWeight.bold),
                    ),
                   subtitle: Text(_contacts[index].mobile),
                    onTap: (){
                      _showForEdit(index);
                    },
                   trailing: IconButton(
                     icon: Icon(Icons.delete_sweep,color: darkBlueColor),
                     onPressed: () async {
                       await _dbHelper.deleteContact(_contacts[index].id);
                       _resetForm();
                       _refreshContactList();
                     }
                   ),
               ),
            Divider(height: 5.0,),
             ],
           );
          },
          itemCount: _contacts.length,

        ),
      ),
    ),


  );
  _showForEdit(index){
    setState(() {
      _contact = _contacts[index];
      _ctrlName.text = _contacts[index].name;
      _ctrlMobile.text = _contacts[index].mobile;
    });
  }

  _onSubmit() async {
    var form = _formKey.currentState;
    if(form.validate()){
      form.save();
      await _dbHelper.insertContact(_contact);
      form.reset();
      await _refreshContactList();

//      print('''
//      Full Name : ${_contact.name}
//      Mobile : ${_contact.mobile}
//      ''');
//      _contacts.add(Contact(id:null,name:_contact.name, mobile:_contact.mobile));
    }
    if(_contact.id == null)
      await _dbHelper.insertContact(_contact);
    else
      await _dbHelper.updateContact(_contact);
      _resetForm();
  }

  _resetForm(){
    setState(() {
      _formKey.currentState.reset();
      _ctrlName.clear();
      _ctrlMobile.clear();
      _contact.id = null;
    });
  }

}
