import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../web3_provider.dart';
import '../widgets/custom_text_field.dart';

class GetRecordScreen extends ConsumerStatefulWidget {
  const GetRecordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GetRecordScreen> createState() => _GetRecordScreenState();
}

class _GetRecordScreenState extends ConsumerState<GetRecordScreen> {
  final TextEditingController patientIdController = TextEditingController();

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
        title: const Text('Get Record'),
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
              Visibility(
                visible: state.isVisible,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Text('Name: ${state.name}'),
                    const SizedBox(
                      height: 15,
                    ),
                    Text('Date of Birth: ${state.dob}'),
                    const SizedBox(
                      height: 15,
                    ),
                    Text('Blood Type: ${state.bloodType}'),
                  ],
                ),
              ),
              const SizedBox(
                height: 80,
              ),
              SizedBox(
                width: 200,
                height: 50,
                child: TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.blueGrey),
                  child: state.getRecordStatus == Status.loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Get Record',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                  onPressed: () {
                    if (patientIdController.text.trim().isEmpty) {
                      return;
                    }
                    final response =
                        state.getRecord(patientIdController.text.trim());
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
