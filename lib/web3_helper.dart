import 'dart:convert';

import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class Web3Helper {
  late Web3Client _client;

  Web3Helper() {
    Client httpClient = Client();
    _client =
        Web3Client('https://alfajores-forno.celo-testnet.org', httpClient);
  }

  final EthereumAddress _contractAddress =
      EthereumAddress.fromHex('0x540C0eB1D15dCa34346eCDF4D9935383B080509b');
  final credentials = EthPrivateKey.fromHex(
      '88093061c7ffd4701cd6c37532868e34043ad3f57ab3f2c08e1d290401b2a7b4');

  static const abi = [
    {
      "inputs": [
        {"internalType": "string", "name": "patientID", "type": "string"},
        {"internalType": "string", "name": "knownAllergies", "type": "string"},
        {
          "internalType": "string",
          "name": "medicalConditions",
          "type": "string"
        }
      ],
      "name": "addAdditionalRecord",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {"internalType": "string", "name": "patientID", "type": "string"},
        {"internalType": "string", "name": "patientName", "type": "string"},
        {"internalType": "string", "name": "DOB", "type": "string"},
        {"internalType": "string", "name": "bloodType", "type": "string"}
      ],
      "name": "addRecord",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {"inputs": [], "stateMutability": "nonpayable", "type": "constructor"},
    {
      "inputs": [
        {"internalType": "string", "name": "patientID", "type": "string"}
      ],
      "name": "getRecords",
      "outputs": [
        {
          "components": [
            {"internalType": "string", "name": "patientName", "type": "string"},
            {"internalType": "string", "name": "DOB", "type": "string"},
            {"internalType": "string", "name": "bloodType", "type": "string"}
          ],
          "internalType": "struct MedicalRecords.Record",
          "name": "",
          "type": "tuple"
        },
        {
          "components": [
            {
              "internalType": "string",
              "name": "knownAllergies",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "medicalConditions",
              "type": "string"
            }
          ],
          "internalType": "struct MedicalRecords.AdditionalRecord",
          "name": "",
          "type": "tuple"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    }
  ];

// Replace these with your actual contract ABI

  final contractABI = json.encode(abi);

  Future<String> addRecord(
    String patientId,
    String patientName,
    String dob,
    String bloodType,
  ) async {
    final contract = DeployedContract(
        ContractAbi.fromJson(contractABI, "MedicalRecords"), _contractAddress);
    final function = contract.function('addRecord');

    final response = await _client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: [patientId, patientName, dob, bloodType],
      ),
      chainId: 44787,
    );

    while (true) {
      final receipt = await _client.getTransactionReceipt(response);
      if (receipt != null) {
        print('Transaction successful');
        print(receipt);
        break;
      }
      // Wait for a while before polling again
      await Future.delayed(const Duration(seconds: 2));
    }
    return response;
  }

  Future<List> getRecords(String id) async {
    try {
      final contract = DeployedContract(
          ContractAbi.fromJson(contractABI, "MedicalRecords"),
          _contractAddress);
      final function = contract.function('getRecords');

      final response = await _client.call(
        contract: contract,
        function: function,
        params: [id],
      );
      return response[0];
    } catch (e) {
      rethrow;
    }
  }
}
