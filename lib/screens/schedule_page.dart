import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pomodautomne/managers/schedule_manager.dart';
import 'package:pomodautomne/managers/theme_manager.dart';
import 'package:pomodautomne/models/schedule_info.dart';
import 'package:pomodautomne/widgets/tab_container.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key, required this.maxWidth});

  final double maxWidth;

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool _fromFrance = false;

  @override
  void initState() {
    super.initState();
    setTimeZone();
  }

  Future<void> setTimeZone() async {
    final preferences = await SharedPreferences.getInstance();
    _fromFrance = preferences.getBool('fromFrance') ?? false;
    setState(() {});
  }

  void toggleTimeZone(bool fromFrance) async {
    _fromFrance = fromFrance;
    final preferences = await SharedPreferences.getInstance();
    preferences.setBool('fromFrance', _fromFrance);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final sm = ScheduleManager.instance;

    return TabContainer(
      maxWidth: widget.maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          ...sm.eventSchedule.map((e) => _StreamerTile(
                info: e,
                fromFrance: _fromFrance,
              )),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  SizedBox _buildHeader(BuildContext context) {
    return SizedBox(
      width: widget.maxWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('HORAIRE', style: Theme.of(context).textTheme.titleLarge),
          Row(
            children: [
              InkWell(
                onTap: () => toggleTimeZone(true),
                child: Text(
                  'France',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight:
                          _fromFrance ? FontWeight.bold : FontWeight.normal,
                      decoration:
                          _fromFrance ? TextDecoration.underline : null),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              InkWell(
                  onTap: () => toggleTimeZone(false),
                  child: Text('Québec',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight:
                              _fromFrance ? FontWeight.normal : FontWeight.bold,
                          decoration:
                              _fromFrance ? null : TextDecoration.underline))),
            ],
          )
        ],
      ),
    );
  }
}

class _StreamerTile extends StatelessWidget {
  const _StreamerTile({required this.info, required this.fromFrance});

  final ScheduleInfo info;
  final bool fromFrance;

  @override
  Widget build(BuildContext context) {
    final tm = ThemeManager.instance;
    DateFormat dateFormat = DateFormat('d MMM HH:mm');

    final now = DateTime.now();

    final startingTime = info.starting.add(Duration(hours: fromFrance ? 6 : 0));
    final endingTime = startingTime.add(info.length);
    final isActive =
        now.compareTo(startingTime) > 0 && now.compareTo(endingTime) < 0;

    return Center(
      child: Card(
        elevation: 5,
        child: LayoutBuilder(builder: (context, constraints) {
          return Container(
            decoration: BoxDecoration(
                color: isActive
                    ? tm.colorButtonSelected
                    : tm.colorButtonUnselected,
                borderRadius: BorderRadius.circular(8)),
            width: constraints.maxWidth * 3 / 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dateFormat.format(startingTime)),
                        if (info.url != null)
                          InkWell(
                              onTap: () {
                                launchUrl(Uri.parse(info.url!));
                              },
                              child: Text(
                                info.url!,
                                style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.black),
                              )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
