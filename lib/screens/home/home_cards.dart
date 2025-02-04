import 'package:flutter/material.dart';

class ExpandableWalletCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Future<List<dynamic>>? future;
  final Widget Function(BuildContext, dynamic)? itemBuilder;

  const ExpandableWalletCard({
    required this.icon,
    required this.title,
    required this.color,
    this.future,
    this.itemBuilder,
    Key? key,
  }) : super(key: key);

  @override
  _ExpandableWalletCardState createState() => _ExpandableWalletCardState();
}

class _ExpandableWalletCardState extends State<ExpandableWalletCard> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          ListTile(
            leading: Icon(widget.icon, color: widget.color),
            title: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            trailing: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: widget.color,
            ),
            onTap: _toggleExpanded,
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 400),
            firstChild: const SizedBox.shrink(),
            secondChild: FutureBuilder<List<dynamic>>(
              future: widget.future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(child: Text("Error: ${snapshot.error}")),
                  );
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      children: snapshot.data!
                          .map((item) => widget.itemBuilder!(context, item))
                          .toList(),
                    ),
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text("No items available")),
                  );
                }
              },
            ),
            crossFadeState:
                _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }
}