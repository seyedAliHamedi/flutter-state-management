import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => BreadCrumbProvider(),
      child: MaterialApp(
        home: const HomePage(),
        routes: {
          '/new': (context) => const NewBreadCrumbWidget(),
        },
      ),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      body: SafeArea(
        child: Column(
          children: [
            Consumer<BreadCrumbProvider>(builder: (context, value, child) {
              return BreadCrumbsWidget(breadCrumbs: value.items);
            }),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed("/new");
              },
              child: const Text("Add new Bread Crumb"),
            ),
            TextButton(
              onPressed: () {
                context.read<BreadCrumbProvider>().reset();
              },
              child: const Text("Reset"),
            ),
          ],
        ),
      ),
    );
  }
}

class BreadCrumb {
  final String name;
  final String id;
  bool isActive;

  BreadCrumb({required this.name, required this.isActive})
      : id = const Uuid().v4();

  void activate() {
    isActive = true;
  }

  String get title => isActive ? "$name > " : name;

  @override
  bool operator ==(covariant BreadCrumb other) =>
      isActive == other.isActive && name == other.name && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class BreadCrumbProvider extends ChangeNotifier {
  final List<BreadCrumb> _items = [];
  UnmodifiableListView<BreadCrumb> get items => UnmodifiableListView(_items);

  void add(BreadCrumb breadCrumb) {
    for (BreadCrumb item in _items) {
      item.activate();
    }
    _items.add(breadCrumb);
    notifyListeners();
  }

  void reset() {
    _items.clear();
    notifyListeners();
  }
}

class BreadCrumbsWidget extends StatelessWidget {
  const BreadCrumbsWidget({super.key, required this.breadCrumbs});
  final UnmodifiableListView<BreadCrumb> breadCrumbs;
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: breadCrumbs.map((e) {
        return Text(e.title,
            style: TextStyle(color: e.isActive ? Colors.blue : Colors.black));
      }).toList(),
    );
  }
}

class NewBreadCrumbWidget extends StatefulWidget {
  const NewBreadCrumbWidget({super.key});

  @override
  State<NewBreadCrumbWidget> createState() => _NewBreadCrumbWidgetState();
}

class _NewBreadCrumbWidgetState extends State<NewBreadCrumbWidget> {
  late final TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ADD a bread crump")),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration:
                const InputDecoration(hintText: "Enter a bread crumb here"),
          ),
          TextButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                context
                    .read<BreadCrumbProvider>()
                    .add(BreadCrumb(name: _controller.text, isActive: false));
              }
              Navigator.of(context).pop();
            },
            child: const Text("add"),
          )
        ],
      ),
    );
  }
}
