import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'api/model.dart';

class ApiHome extends StatefulWidget {
  const ApiHome({super.key});

  @override
  State<ApiHome> createState() => _ApiHomeState();
}

class _ApiHomeState extends State<ApiHome> {
  late Future<CoinCharts> futureCoincharts;

  @override
  void initState() {
    super.initState();
    futureCoincharts = fetchCoins();
  }

  Future<CoinCharts> fetchCoins() async {
    final response = await http
        .get(Uri.parse('https://api.coindesk.com/v1/bpi/currentprice.json'));

    if (response.statusCode == 200) {
      return CoinCharts.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load temperatures');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<CoinCharts>(
        future: futureCoincharts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: 3, // Assuming you want to display USD, GBP, and EUR
              itemBuilder: (context, index) {
                Eur eur;
                switch (index) {
                  case 0:
                    eur = snapshot.data!.bpi.usd;
                    break;
                  case 1:
                    eur = snapshot.data!.bpi.gbp;
                    break;
                  case 2:
                    eur = snapshot.data!.bpi.eur;
                    break;
                  default:
                    throw Exception('Invalid index');
                }

                return ListTile(
                  title: Text(eur.code),
                  subtitle: Column(
                    children: [
                      Text('${eur.rate} ${eur.symbol}'),
                      Text(eur.description)
                    ],
                  ),
                  // Add more information as needed
                );
              },
            );
          }
        },
      ),
    );
  }
}
