library social_media_recorder;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_recorder/provider/sound_record_notifier.dart';
import 'package:social_media_recorder/widgets/lock_record.dart';
import 'package:social_media_recorder/widgets/show_counter.dart';
import 'package:social_media_recorder/widgets/show_mic_with_text.dart';
import 'package:social_media_recorder/widgets/sound_recorder_when_locked_design.dart';

import '../audio_encoder_type.dart';

class SocialMediaRecorder extends StatefulWidget {
  /// use it for change back ground of cancel
  final Color? cancelTextBackGroundColor;

  /// function reture the recording sound file
  final Function(File soundFile) sendRequestFunction;

  /// function that returns the state of record bar [isShown] and [isLocked]
  final Function(bool isShown, bool isLocke)? onStatusChange;

  /// recording Icon That pressed to start record
  final Widget? recordIcon;

  /// The Size of the record icon which includes padding.all(4)
  final double recordIconSize;

  /// recording Icon when user locked the record
  final Widget? recordIconWhenLockedRecord;

  /// use to change the backGround Icon when user recording sound
  final Color? recordIconBackGroundColor;

  /// use to change the Icon backGround color when user locked the record
  final Color? recordIconWhenLockBackGroundColor;

  /// use to change all recording widget color
  final Color? backGroundColor;

  /// use to change the counter style
  final TextStyle? counterTextStyle;

  /// text to know user should drag in the left to cancel record
  final String? slideToCancelText;

  /// The colors to animate between for the [slideToCancel] Text
  final List<Color>? slideToCancelAnimationColors;

  /// use to change slide to cancel textstyle
  final TextStyle? slideToCancelTextStyle;

  /// this text show when lock record and to tell user should press in this text to cancel recod
  final String? cancelText;

  /// use to change cancel text style
  final TextStyle? cancelTextStyle;

  /// put you file directory storage path if you didn't pass it take deafult path
  final String? storeSoundRecoringPath;

  /// Chose the encode type
  final AudioEncoderType encode;

  /// use if you want change the raduis of un record
  final BorderRadius? radius;

  // use to change the counter back ground color
  final Color? counterBackGroundColor;

  // use to change lock icon to design you need it
  final Widget? lockButton;

  // The required drag top distance to activate lock, 
  // also controls distance between record button and lock.
  final double lockDragDistance;

  // use it to change send button when user lock the record
  final Widget? sendButtonIcon;

  // ignore: sort_constructors_first
  const SocialMediaRecorder({
    this.sendButtonIcon,
    this.storeSoundRecoringPath = "",
    required this.sendRequestFunction,
    this.onStatusChange,
    this.recordIcon,
    this.recordIconSize = 35,
    this.lockButton,
    this.lockDragDistance = 60,
    this.counterBackGroundColor,
    this.recordIconWhenLockedRecord,
    this.recordIconBackGroundColor = Colors.blue,
    this.recordIconWhenLockBackGroundColor = Colors.blue,
    this.backGroundColor,
    this.cancelTextStyle,
    this.counterTextStyle,
    this.slideToCancelTextStyle,
    this.slideToCancelText = " Slide to Cancel >",
    this.slideToCancelAnimationColors,
    this.cancelText = "Cancel",
    this.encode = AudioEncoderType.AAC,
    this.cancelTextBackGroundColor,
    this.radius,
    Key? key,
  }) : super(key: key);

  @override
  _SocialMediaRecorder createState() => _SocialMediaRecorder();
}

class _SocialMediaRecorder extends State<SocialMediaRecorder> {
  late SoundRecordNotifier soundRecordNotifier;
  bool lastIsShow = false;
  bool lastIsLocked = false;
  @override
  void initState() {
    soundRecordNotifier = SoundRecordNotifier(
      dragDistance: widget.lockDragDistance
    );
    if(widget.onStatusChange != null) {
      soundRecordNotifier.addListener(_onStatusChangeListener);
    }
    soundRecordNotifier.initialStorePathRecord =
        widget.storeSoundRecoringPath ?? "";
    soundRecordNotifier.isShow = false;
    soundRecordNotifier.voidInitialSound();
    super.initState();
  }
  void _onStatusChangeListener () {
    if(lastIsShow != soundRecordNotifier.isShow || lastIsLocked != soundRecordNotifier.isLocked){
      lastIsShow = soundRecordNotifier.isShow;
      lastIsLocked = soundRecordNotifier.isLocked;
      widget.onStatusChange!(soundRecordNotifier.isShow,soundRecordNotifier.isLocked);
    }
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => soundRecordNotifier),
        ],
        child: Consumer<SoundRecordNotifier>(
          builder: (context, value, _) {
            return Directionality(
                textDirection: TextDirection.rtl, child: makeBody(value));
          },
        ));
  }

  Widget makeBody(SoundRecordNotifier state) {
    return Column(
      children: [
        GestureDetector(
          onHorizontalDragUpdate: (scrollEnd) {
            state.updateScrollValue(scrollEnd.globalPosition, context);
          },
          onHorizontalDragEnd: (x) {},
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: recordVoice(state),
          ),
        )
      ],
    );
  }

  Widget recordVoice(SoundRecordNotifier state) {
    if (state.lockScreenRecord == true) {
      return SoundRecorderWhenLockedDesign(
        cancelText: widget.cancelText,
        sendButtonIcon: widget.sendButtonIcon,
        cancelTextBackGroundColor: widget.cancelTextBackGroundColor,
        cancelTextStyle: widget.cancelTextStyle,
        counterBackGroundColor: widget.counterBackGroundColor,
        recordIconWhenLockBackGroundColor:
            widget.recordIconWhenLockBackGroundColor ?? Colors.blue,
        counterTextStyle: widget.counterTextStyle,
        recordIconWhenLockedRecord: widget.recordIconWhenLockedRecord,
        sendRequestFunction: widget.sendRequestFunction,
        soundRecordNotifier: state,
      );
    }

    return Listener(
      onPointerDown: (details) async {
        state.setNewInitialDraggableHeight(details.position.dy);
        state.resetEdgePadding();

        soundRecordNotifier.isShow = true;
        state.record();
      },
      onPointerUp: (details) async {
        if (!state.isLocked) {
          if (state.buttonPressed) {
            if (state.second > 1 || state.minute > 0) {
              String path = state.mPath;
              widget.sendRequestFunction(File.fromUri(Uri(path: path)));
            }
          }
          state.resetEdgePadding();
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: soundRecordNotifier.isShow ? 0 : 300),
        height: widget.recordIconSize + 10,
        alignment: Alignment.center,
        width: (soundRecordNotifier.isShow)
            ? MediaQuery.of(context).size.width
            : widget.recordIconSize + 5,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(right: state.edge),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: soundRecordNotifier.isShow
                      ? BorderRadius.circular(12)
                      : widget.radius != null && !soundRecordNotifier.isShow
                          ? widget.radius
                          : BorderRadius.circular(0),
                  color: widget.backGroundColor ?? Colors.grey.shade100,
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Center(
                        child: ShowMicWithText(
                          counterBackGroundColor: widget.counterBackGroundColor,
                          backGroundColor: widget.recordIconBackGroundColor,
                          recordIcon: widget.recordIcon,
                          recordIconSize: widget.recordIconSize,
                          shouldShowText: soundRecordNotifier.isShow,
                          soundRecorderState: state,
                          slideToCancelTextStyle: widget.slideToCancelTextStyle,
                          slideToCancelText: widget.slideToCancelText,
                          slideToCancelAnimationColors: widget.slideToCancelAnimationColors,
                        ),
                      ),
                    ),
                    if (soundRecordNotifier.isShow)
                      ShowCounter(
                          counterTextStyle: widget.counterTextStyle,
                          counterBackGroundColor: widget.counterBackGroundColor,
                          soundRecorderState: state),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: LockRecord(
                soundRecorderState: state,
                lockIcon: widget.lockButton,
              ),
            )
          ],
        ),
      ),
    );
  }
}
