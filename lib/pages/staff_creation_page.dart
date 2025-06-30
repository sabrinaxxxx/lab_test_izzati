import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:random_string/random_string.dart';
import 'package:lab_test_izzati/service/database.dart';

class Staff extends StatefulWidget {
  const Staff({super.key});

  @override
  State<Staff> createState() => _StaffState();
}

class _StaffState extends State<Staff> with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_animationController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    idController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: Colors.pink.shade300,
        centerTitle: true,
        title: const Text(
          "Staff Form",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTextField(
                    "Name",
                    "Enter your name",
                    nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 25),
                  buildTextField(
                    "ID Staff",
                    "Enter your ID",
                    idController,
                    validator: (value) {
                      if (value == null || value.length < 3) {
                        return 'ID must be at least 3 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 25),
                  buildTextField(
                    "Age",
                    "Enter your age",
                    ageController,
                    keyboard: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Age is required';
                      }
                      int? age = int.tryParse(value);
                      if (age == null || age < 18 || age > 65) {
                        return 'Age must be between 18 and 65';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 35),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade300,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // ignore: non_constant_identifier_names
                          String Id = randomAlphaNumeric(10);

                          Map<String, dynamic> staffInfoMap = {
                            "Name": nameController.text.trim(),
                            "ID Staff": idController.text.trim(),
                            "Age": ageController.text.trim(),
                            "Id": Id,
                          };

                          await DatabaseMethods()
                              .addStaffDetails(staffInfoMap, Id)
                              .then((value) {
                                Fluttertoast.showToast(
                                  msg: "Staff details uploaded successfully.",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.green.shade600,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                                nameController.clear();
                                idController.clear();
                                ageController.clear();
                              });
                        }
                      },
                      child: const Text(
                        "Add",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.pink.shade800,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.pink.shade200),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboard,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}
