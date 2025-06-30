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
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
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
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blueGrey.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name + Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Name: ${ds["Name"]}",
                                      style: TextStyle(
                                        color: Colors.blueGrey.shade900,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blueGrey.shade600),
                                        onPressed: () {
                                          final nameController = TextEditingController(text: ds["Name"]);
                                          final idController = TextEditingController(text: ds["ID Staff"]);
                                          final ageController = TextEditingController(text: ds["Age"]);

                                          showDialog(
                                            context: context,
                                            builder: (_) {
                                              return AlertDialog(
                                                title: const Text("Update Staff Details"),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    TextField(
                                                      controller: nameController,
                                                      decoration: const InputDecoration(labelText: "Name"),
                                                    ),
                                                    TextField(
                                                      controller: idController,
                                                      decoration: const InputDecoration(labelText: "Staff ID"),
                                                    ),
                                                    TextField(
                                                      controller: ageController,
                                                      decoration: const InputDecoration(labelText: "Age"),
                                                      keyboardType: TextInputType.number,
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text("Cancel"),
                                                  ),
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.blueGrey.shade700,
                                                    ),
                                                    onPressed: () async {
                                                      if (nameController.text.trim().isEmpty ||
                                                          idController.text.trim().length < 3 ||
                                                          int.tryParse(ageController.text.trim()) == null) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(
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

                                                      if (context.mounted) {
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text("Updated successfully.")),
                                                        );
                                                      }
                                                    },
                                                    child: const Text("Update"),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                                        onPressed: () async {
                                          await DatabaseMethods().deleteStaff(ds.id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Deleted successfully.")),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Staff ID: ${ds["ID Staff"]}",
                                style: TextStyle(
                                  color: Colors.blueGrey.shade700,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Age: ${ds["Age"]}",
                                style: TextStyle(
                                  color: Colors.blueGrey.shade700,
                                  fontSize: 15.5,
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
            : const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey.shade800,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Staff()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade800,
        centerTitle: true,
        title: const Text(
          "Staff Directory",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.1,
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25),
        child: allStaffDetails(),
      ),
    );
  }
}