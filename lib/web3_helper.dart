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

  final _contractAddress = EthereumAddress.fromHex('<your-contract-address>');
  final credentials = EthPrivateKey.fromHex(
      "<your-private-key>"); // replace with your celo wallet private key

  static const abi =
      '<your-contract-abi>'; // Replace these with your actual contract ABI

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
