import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../web3_provider.dart';
import '../widgets/custom_drop_down.dart';
import '../widgets/custom_text_field.dart';

class AddPatientScreen extends ConsumerStatefulWidget {
  const AddPatientScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends ConsumerState<AddPatientScreen> {
  final TextEditingController patientIdController = TextEditingController();
  final TextEditingController patientNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController bloodTypeController = TextEditingController();

  late String dobDate;

  Future<dynamic> pickDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked == null) {
      return 'n';
    } else {
      return picked;
    }
  }

  String? selectedBloodGroup;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(web3Provider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Patient'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              CustomTextField(
                controller: patientIdController,
                hintText: 'Enter patient id',
              ),
              const SizedBox(
                height: 30,
              ),
              CustomTextField(
                controller: patientNameController,
                hintText: 'Enter patient name',
              ),
              const SizedBox(
                height: 30,
              ),
              CustomTextField(
                controller: dobController,
                readOnly: true,
                hintText: 'Select date of birth',
                iconButton: IconButton(
                  onPressed: () async {
                    dynamic date = await pickDate();
                    if (date == 'n') return;
                    String pickedDate = DateFormat.yMMMEd().format(date);
                    // String pickedDate = DateFormat('yyyy-MM-dd').format(date);
                    setState(() {
                      dobDate = pickedDate;
                      dobController.text = pickedDate;
                    });
                  },
                  icon: const Icon(Icons.date_range),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              CustomDropDown(
                hintText: 'Select blood type',
                textList: const ['O+', 'O-', 'A', 'B', 'AB'],
                text: selectedBloodGroup,
                onChanged: (val) {
                  setState(() {
                    selectedBloodGroup = val;
                  });
                },
              ),
              const SizedBox(
                height: 80,
              ),
              SizedBox(
                width: 200,
                height: 50,
                child: TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.blueGrey),
                  child: state.addPatientStatus == Status.loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Create Record',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                  onPressed: () {
                    if (patientIdController.text.trim().isEmpty ||
                        patientNameController.text.trim().isEmpty ||
                        dobController.text.trim().isEmpty ||
                        selectedBloodGroup == null) {
                      return;
                    }
                    state.addRecord(
                      patientIdController.text.trim(),
                      patientNameController.text.trim(),
                      dobController.text.trim(),
                      selectedBloodGroup!,
                      context,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
