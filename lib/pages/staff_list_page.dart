import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lab_test_izzati/pages/staff_creation_page.dart';
import 'package:lab_test_izzati/service/database.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  Stream? staffStream;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  getOnTheLoad() async {
    staffStream = DatabaseMethods().getStaffDetails();
    setState(() {});
  }

  @override
  void initState() {
    getOnTheLoad();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.forward();
    super.initState();
  }

  Widget allStaffDetails() {
    return StreamBuilder(
      stream: staffStream,
      builder: (context, AsyncSnapshot snapshot) {
        return (snapshot.hasData)
            ? FadeTransition(
                opacity: _fadeAnimation,
                child: ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      child: Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.pink.shade100,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name + Edit/Delete buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Name : ${ds["Name"]}",
                                      style: TextStyle(
                                        color: Colors.pink.shade900,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.pink.shade400),
                                        onPressed: () {
                                          TextEditingController nameController =
                                              TextEditingController(text: ds["Name"]);
                                          TextEditingController idController =
                                              TextEditingController(text: ds["ID Staff"]);
                                          TextEditingController ageController =
                                              TextEditingController(text: ds["Age"]);

                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                backgroundColor: Colors.white,
                                                title: Text("Update Staff Details"),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    TextField(
                                                      controller: nameController,
                                                      decoration: InputDecoration(labelText: "Name"),
                                                    ),
                                                    TextField(
                                                      controller: idController,
                                                      decoration: InputDecoration(labelText: "ID Staff"),
                                                    ),
                                                    TextField(
                                                      controller: ageController,
                                                      decoration: InputDecoration(labelText: "Age"),
                                                      keyboardType: TextInputType.number,
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child: Text("Cancel"),
                                                    onPressed: () => Navigator.pop(context),
                                                  ),
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.pink.shade300,
                                                    ),
                                                    child: Text("Update"),
                                                    onPressed: () async {
                                                      if (nameController.text.trim().isEmpty ||
                                                          idController.text.trim().length < 3 ||
                                                          int.tryParse(ageController.text.trim()) == null) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text("Please enter valid data."),
                                                            backgroundColor: Colors.redAccent,
                                                          ),
                                                        );
                                                        return;
                                                      }

                                                      await DatabaseMethods().updateStaffDetails(ds.id, {
                                                        "Name": nameController.text.trim(),
                                                        "ID Staff": idController.text.trim(),
                                                        "Age": ageController.text.trim(),
                                                      });

                                                      // ignore: use_build_context_synchronously
                                                      Navigator.pop(context);
                                                      // ignore: use_build_context_synchronously
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text("Updated successfully!")),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.redAccent),
                                        onPressed: () async {
                                          await DatabaseMethods().deleteStaff(ds.id);
                                          // ignore: use_build_context_synchronously
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Deleted successfully!")),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // ID and Age
                              Text(
                                "ID Staff: ${ds["ID Staff"]}",
                                style: TextStyle(
                                  color: Colors.pink.shade800,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Age: ${ds["Age"]}",
                                style: TextStyle(
                                  color: Colors.pink.shade800,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink.shade300,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Staff()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        backgroundColor: Colors.pink.shade300,
        centerTitle: true,
        title: Text(
          "Staff Manager",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
        child: Column(
          children: [
            Expanded(child: allStaffDetails()),
          ],
        ),
      ),
    );
  }
}
