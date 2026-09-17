import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/features/navigation/domain/entities/app_tab.dart';

final selectedTabProvider = NotifierProvider<SelectedTab, AppTab>(
  SelectedTab.new,
);

class SelectedTab extends Notifier<AppTab> {
  @override
  AppTab build() => AppTab.myFeed;

  void select(AppTab tab) => state = tab;
}
