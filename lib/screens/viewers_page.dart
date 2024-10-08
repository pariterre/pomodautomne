import 'package:flutter/material.dart';
import 'package:pomodautomne/managers/chatters_manager.dart';
import 'package:pomodautomne/managers/schedule_manager.dart';
import 'package:pomodautomne/managers/theme_manager.dart';
import 'package:pomodautomne/models/chatter.dart';
import 'package:pomodautomne/widgets/animated_expanding_card.dart';
import 'package:pomodautomne/widgets/tab_container.dart';

class ViewersPage extends StatefulWidget {
  const ViewersPage(
      {super.key,
      required this.isInitialized,
      required this.isAdmistration,
      required this.maxWidth});

  final double maxWidth;
  final bool isInitialized;
  final bool isAdmistration;

  @override
  State<ViewersPage> createState() => _ViewersPageState();
}

class _ViewersPageState extends State<ViewersPage> {
  @override
  void initState() {
    super.initState();
    ChattersManager.instance.addListener(refresh);
  }

  @override
  void dispose() {
    ChattersManager.instance.removeListener(refresh);
    super.dispose();
  }

  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return TabContainer(
      maxWidth: widget.maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AUDITEURS ET AUDITRICES',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _buildChattersListTile(context),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildChattersListTile(BuildContext context) {
    final tm = ThemeManager.instance;

    final chatters = ChattersManager.instance;
    final sortedChatters = [...chatters]
      ..sort((a, b) => b.totalWatchingTime - a.totalWatchingTime);

    final sm = ScheduleManager.instance;

    return !sm.hasEventStarted && !widget.isAdmistration && !sm.hasEventFinished
        ? const Text(
            'Lors de l\'événement, votre temps de participation sera enregistré ici! '
            'Revenez régulièrement sur cette page pour vous comparer aux autres participantes et participants ;-)')
        : !widget.isInitialized
            ? Center(child: CircularProgressIndicator(color: tm.titleColor))
            : (sortedChatters.isEmpty
                ? const Text('Aucun auditeur ou auditrice pour l\'instant')
                : Column(
                    children: sortedChatters
                        .map((e) => _ChatterTile(
                            chatter: e, isAdmistration: widget.isAdmistration))
                        .toList()));
  }
}

class _ChatterTile extends StatelessWidget {
  const _ChatterTile({required this.chatter, required this.isAdmistration});

  final Chatter chatter;
  final bool isAdmistration;

  @override
  Widget build(BuildContext context) {
    final tm = ThemeManager.instance;

    final watchingTime = chatter.totalWatchingTime ~/ 60;

    return chatter.isEmpty || (chatter.isBanned && !isAdmistration)
        ? Container()
        : AnimatedExpandingCard(
            expandedColor:
                chatter.isBanned ? Colors.white : tm.colorButtonSelected,
            closedColor:
                chatter.isBanned ? Colors.white : tm.colorButtonUnselected,
            header: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chatter.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                      'Participation : $watchingTime minute${watchingTime > 1 ? 's' : ''}'),
                  if (isAdmistration)
                    InkWell(
                      onTap: () =>
                          ChattersManager.instance.toggleIsBan(chatter),
                      borderRadius: BorderRadius.circular(25),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        height: 40,
                        width: 40,
                        child: Icon(
                            chatter.isBanned ? Icons.person_off : Icons.person),
                      ),
                    )
                ],
              ),
            ),
            builder: (context, isExpanded) => isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(
                        left: 12.0, right: 12.0, bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Par chaîne',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...chatter.streamerNames.map((streamer) {
                          final watchingStreamer =
                              chatter.watchingTime(of: streamer) ~/ 60;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(streamer),
                              Text(
                                  '$watchingStreamer minute${watchingStreamer > 1 ? 's' : ''}'),
                            ],
                          );
                        }),
                      ],
                    ),
                  )
                : Container(),
          );
  }
}
