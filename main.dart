import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double padding = 20.0;

  List<GoRestUser> users = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HTTP"),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding/2, vertical: padding),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: loadAllUsers, child: Text("Load Users")),
              SizedBox(height: padding,),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (context, idx) {
                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(Icons.account_circle, color: Colors.blue, size: 50,),
                      Expanded(child: Text("${users[idx].name}\n${users[idx].email}")),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// curl -i -H "Accept:application/json" -H "Content-Type:application/json"
  ///   -XGET "https://gorest.co.in/public/v2/users"
  void loadAllUsers() async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json", //returns result in json
    };
    var url = Uri.parse('https://gorest.co.in/public/v2/users');
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> decoded = json.decode(response.body);
      setState(() {
        users = decoded.map((u) => GoRestUser.fromJson(u)).toList();
      });
    } else {
      print("loadAllUsers() not successful: ${response.toString()}");
    }
  }

  /// curl -i -H "Accept:application/json" -H "Content-Type:application/json"
  ///   -H "Authorization: Bearer ACCESS-TOKEN" -XPOST "https://gorest.co.in/public/v2/users"
  ///   -d '{"name":"Tenali Ramakrishna", "gender":"male", "email":"tenali.ramakrishna@15ce.com",
  ///     "status":"active"}'
  void createUser() async {
    Map<String, String> headers = {
      "Authorization": "Bearer ACCESS-TOKEN",
      "Content-Type": "application/json",
      "Accept": "application/json", //returns result in json
    };
    var newUser = json.encode({
      "name": "eclectify University User",
      "gender": "male",
      "email": "tenali.ramakrishna@15ce.com",
      "status": "active",
    });

    var url = Uri.parse('https://gorest.co.in/public/v2/users');
    var response = await http.post(url, body: newUser, headers: headers);
    if (response.statusCode == 200) {
      print("New user was created");
    } else {
      print("createUser() not successful: ${response.toString()}");
    }
  }

  /// API: https://www.boredapi.com/
  void makeBoredRequest() async {
    var url = Uri.parse('https://www.boredapi.com/api/activity');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      BoredResponse boredResponse = BoredResponse(
        activity: json.decode(response.body)["activity"],
        type: json.decode(response.body)["type"],
        participants: json.decode(response.body)["participants"],
        price: json.decode(response.body)["price"],
        link: json.decode(response.body)["link"],
        key: json.decode(response.body)["key"],
        accessibility: json.decode(response.body)["accessibility"],
      );
      /// print successful result
      print(boredResponse.toString());
    } else {
      print("makeBoredRequest() not successful: ${response.toString()}");
    }
  }

}

/// custom object for user of API: https://gorest.co.in/
class GoRestUser {
  late int id;
  late String name;
  late String email;

  GoRestUser({required this.id, required this.name, required this.email});

  GoRestUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
  }

  @override
  String toString() {
    return "GoRestUser(id: $id, name: $name, email: $email)";
  }
}

/// custom object for response of Bored API activity request
// {
//  "activity":"Take a nap","type":"relaxation","participants":1,"price":0,
//  "link":"","key":"6184514","accessibility":0
// }
class BoredResponse {
  final String activity;
  final String type;
  final int participants;
  final double price;
  final String link;
  final String key;
  final int accessibility;

  BoredResponse({
    required this.activity,
    required this.type,
    required this.participants,
    required this.price,
    required this.link,
    required this.key,
    required this.accessibility,
  });

  @override
  String toString() {
    return "BoredResponse(activity: $activity, type: $type, participants: $participants,"
        "price: $price, link: $link, key: $key, accessibility: $accessibility)";
  }
}

