import 'package:celo_medical_record/web3_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Status { init, loading, done }

final web3Provider = ChangeNotifierProvider((ref) => Web3Provider());

class Web3Provider extends ChangeNotifier {
  List patientRecord = [];

  Status addPatientStatus = Status.init;
  Status getRecordStatus = Status.init;
  bool isVisible = false;
  String name = 'no data';
  String dob = 'no data';
  String bloodType = 'no data';

  Future<void> addRecord(
    String patientId,
    String patientName,
    String dob,
    String bloodType,
    context,
  ) async {
    addPatientStatus = Status.loading;
    notifyListeners();
    final response = await Web3Helper().addRecord(
      patientId,
      patientName,
      dob,
      bloodType,
    );
    if (response != null) {
      const snackBar = SnackBar(content: Text('Success'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    addPatientStatus = Status.done;
    notifyListeners();
  }

  Future<void> getRecord(String patientId) async {
    isVisible = false;
    getRecordStatus = Status.loading;
    notifyListeners();
    final response = await Web3Helper().getRecords(patientId);
    if (response.isNotEmpty) {
      isVisible = true;
      name = response[0];
      dob = response[1];
      bloodType = response[2];
    }

    getRecordStatus = Status.done;
    notifyListeners();
  }
}
