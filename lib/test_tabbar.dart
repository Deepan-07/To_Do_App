import 'package:flutter/material.dart';

class TestTabBarScreen extends StatefulWidget {
  const TestTabBarScreen({super.key});

  @override
  State<TestTabBarScreen> createState() => _TestTabBarScreenState();
}

class _TestTabBarScreenState extends State<TestTabBarScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TabBar Test'),
        ),
        body: Column(
          children: [
            TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Open'),
                Tab(text: 'Completed'),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (val) => setState(() => _search = val),
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  Center(child: Text('All Tasks')),
                  Center(child: Text('Open Tasks')),
                  Center(child: Text('Completed Tasks')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 