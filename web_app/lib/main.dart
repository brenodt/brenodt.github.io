import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/services/app_state_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ignore: always_specify_types
    return ChangeNotifierProvider(
      create: (BuildContext context) => AppStateProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primaryColor: const Color(0xFF262626),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppStateProvider>(
          builder: (BuildContext context, AppStateProvider provider, _) {
        return CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              title: Text(widget.title),
              floating: true,
              actions: <Widget>[
                AppbarButton(
                  active: provider.currentState == AppState.home,
                  name: 'Home',
                  handlesState: AppState.home,
                ),
                AppbarButton(
                  active: provider.currentState == AppState.about,
                  name: 'About',
                  handlesState: AppState.about,
                ),
                AppbarButton(
                  active: provider.currentState == AppState.contact,
                  name: 'Contact',
                  handlesState: AppState.contact,
                ),
                AppbarButton(
                  active: provider.currentState == AppState.blog,
                  name: 'Blog',
                  handlesState: AppState.blog,
                ),
              ],
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                containers(),
              ),
            ),
          ],
        );
      }),
    );
  }
}

List<Widget> containers() {
  final List<Widget> _list = <Widget>[];
  for (int i = 0; i < 10; i++) {
    _list.add(Container(
      height: 300,
      color: i % 2 == 0 ? Colors.pink : Colors.purple,
    ));
  }
  return _list;
}

class AppbarButton extends StatelessWidget {
  const AppbarButton({
    Key key,
    this.active,
    @required this.name,
    @required this.handlesState,
  }) : super(key: key);
  final bool active;
  final String name;
  final AppState handlesState;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        AnimateExpansion(
          animate: active,
          child: Container(
            width: 80,
            color: Colors.teal,
          ),
        ),
        GestureDetector(
          onTap: () {
            Provider.of<AppStateProvider>(context, listen: false).currentState =
                handlesState;
          },
          child: Container(
            height: double.maxFinite,
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 12.0,
            ),
            child: Text(name),
          ),
        ),
      ],
    );
  }
}

class AnimateExpansion extends StatefulWidget {
  const AnimateExpansion({
    @required this.animate,
    @required this.child,
  });
  final Widget child;
  final bool animate;

  @override
  _AnimateExpansionState createState() => _AnimateExpansionState();
}

class _AnimateExpansionState extends State<AnimateExpansion>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  void prepareAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInCubic,
      reverseCurve: Curves.easeOutCubic,
    );
  }

  void _toggle() {
    if (widget.animate) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _toggle();
  }

  @override
  void didUpdateWidget(AnimateExpansion oldWidget) {
    super.didUpdateWidget(oldWidget);
    _toggle();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _animation,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
