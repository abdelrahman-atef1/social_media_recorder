library social_media_recorder;

import 'package:flutter/material.dart';
import 'package:social_media_recorder/provider/sound_record_notifier.dart';

/// This Class Represent Icons To swap top to lock recording
class LockRecord extends StatefulWidget {
  /// Object From Provider Notifier
  final SoundRecordNotifier soundRecorderState;
  // ignore: sort_constructors_first

  final Widget? lockIcon;
  const LockRecord({
    this.lockIcon,
    required this.soundRecorderState,
    Key? key,
  }) : super(key: key);
  @override
  _LockRecordState createState() => _LockRecordState();
}

class _LockRecordState extends State<LockRecord> with TickerProviderStateMixin {
  double get maxDragDistance => widget.soundRecorderState.dragDistance;
  @override
  Widget build(BuildContext context) {
    /// If click the Button Then send show lock and un lock icon
    if (!widget.soundRecorderState.buttonPressed) return const SizedBox();
    print(widget.soundRecorderState.second % 2 == 0 );
    return AnimatedPadding(
      duration: const Duration(seconds: 1),
      padding:
          EdgeInsets.all(widget.soundRecorderState.second % 2 == 0 ? 0 : 5),
      child: Transform.translate(
        offset: Offset(0, -maxDragDistance),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
            opacity: widget.soundRecorderState.edge >= maxDragDistance ? 0 : 1,
            child: Container(
              height: maxDragDistance - widget.soundRecorderState.heightPosition < 0
                  ? 0
                  : maxDragDistance - widget.soundRecorderState.heightPosition,
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: widget.lockIcon ??
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeIn,
                              opacity: widget.soundRecorderState.second % 2 != 0
                                  ? 0
                                  : 1,
                              child: const Icon(Icons.lock_outline_rounded)),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeIn,
                              opacity: widget.soundRecorderState.second % 2 == 0
                                  ? 0
                                  : 1,
                              child: const Icon(Icons.lock_open_rounded)),
                        ),
                      ],
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
