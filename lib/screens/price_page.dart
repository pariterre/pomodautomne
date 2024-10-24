import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pomodautomne/managers/chatters_manager.dart';
import 'package:pomodautomne/managers/theme_manager.dart';
import 'package:pomodautomne/models/chatter.dart';
import 'package:pomodautomne/widgets/tab_container.dart';

class PricePage extends StatefulWidget {
  const PricePage({super.key, required this.maxWidth});

  final double maxWidth;

  @override
  State<PricePage> createState() => _PricePageState();
}

class _PricePageState extends State<PricePage> {
  final nbParticipantsToDraw = TextEditingController();

  @override
  void initState() {
    super.initState();
    ChattersManager.instance.addListener(refresh);
  }

  @override
  void dispose() {
    nbParticipantsToDraw.dispose();
    ChattersManager.instance.removeListener(refresh);
    super.dispose();
  }

  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final tm = ThemeManager.instance;
    final chatters = ChattersManager.instance;

    if (chatters.isEmpty) {
      return TabContainer(
          maxWidth: widget.maxWidth,
          child: const Text('Aucun auditeur ou auditrice pour l\'instant'));
    }

    const border = InputBorder.none;

    return TabContainer(
        maxWidth: widget.maxWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: tm.colorButtonSelected,
                  borderRadius: BorderRadius.circular(8)),
              width: 290,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 4.0, left: 12, bottom: 8, right: 8),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: nbParticipantsToDraw,
                  decoration: const InputDecoration(
                    border: border,
                    errorBorder: border,
                    enabledBorder: border,
                    focusedBorder: border,
                    disabledBorder: border,
                    focusedErrorBorder: border,
                    isDense: false,
                    label: Text(
                      'Tirer un nom parmi les X premiers',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: _hasPotentialWinners
                    ? () {
                        int? nbParticipants =
                            int.tryParse(nbParticipantsToDraw.text);
                        nbParticipants ??= chatters.length;

                        _drawViewer(nbParticipants);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                    backgroundColor: tm.colorButtonSelected,
                    foregroundColor: Colors.black),
                child: const Text(
                  'Tirer au sort!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
          ],
        ));
  }

  int get minimumTimeToBeEligible => 100 * 60;

  bool get _hasPotentialWinners {
    final chatters = ChattersManager.instance;
    for (final chatter in chatters) {
      if (!chatter.isBanned &&
          chatter.totalWatchingTime > minimumTimeToBeEligible) return true;
    }
    return false;
  }

  void _drawViewer(int nbParticipants) {
    final tm = ThemeManager.instance;
    final chatters = ChattersManager.instance;
    final sortedChatters = [...chatters]
      ..sort((a, b) => b.totalWatchingTime - a.totalWatchingTime);

    Chatter? winner;
    while (winner == null) {
      final winnerIndex =
          Random().nextInt(min(nbParticipants, chatters.length));
      winner = sortedChatters[winnerIndex];
      if (winner.isBanned ||
          winner.totalWatchingTime < minimumTimeToBeEligible) {
        winner = null;
      }
    }

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: tm.colorButtonSelected,
              title: const Text(
                'Gagnants',
                style: TextStyle(color: Colors.black),
              ),
              content: Text(
                  '${winner!.name} (Temps de visionnement : ${winner.totalWatchingTime ~/ 60} minutes})'),
            ));
  }
}
