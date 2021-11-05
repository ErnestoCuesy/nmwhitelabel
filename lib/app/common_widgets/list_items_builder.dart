import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/common_widgets/empty_content.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_progress_indicator.dart';

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class ListItemsBuilder<T> extends StatelessWidget {
  const ListItemsBuilder({Key? key, required this.snapshot, required this.itemBuilder, this.title, this.message, this.axis}) : super(key: key);

  final AsyncSnapshot<List<T>> snapshot;
  final ItemWidgetBuilder<T> itemBuilder;
  final String? title;
  final String? message;
  final Axis? axis;

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasData) {
      final List<T> items = snapshot.data!;
      if (items.isNotEmpty) {
        return _buildList(items);
      } else {
        return EmptyContent(
          title: title,
          message: message,
        );
      }
    } else if (snapshot.hasError) {
      return EmptyContent(
        title: 'Something went wrong',
        message: 'Can\'t load items right now',
      );
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
      //Future.delayed(Duration(seconds: 5));
      return Center(
        child: EmptyContent(
          title: title,
          message: message,
        ),
      );
    } else {
      return Center(
        child: PlatformProgressIndicator(),
      );
    }
  }

  Widget _buildList(List<T> items) {
    return ListView.builder(
      scrollDirection: axis ?? Axis.vertical,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return itemBuilder(context, items[index]);
      },
    );
  }
}
