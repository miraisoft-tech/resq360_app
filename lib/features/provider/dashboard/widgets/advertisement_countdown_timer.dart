import 'dart:async';
import 'package:resq360/__lib.dart';

class AdvertCountdownTimer extends StatefulWidget {
  const AdvertCountdownTimer({
    required this.endDate,
    super.key,
  });

  final DateTime endDate;

  @override
  State<AdvertCountdownTimer> createState() => _AdvertCountdownTimerState();
}

class _AdvertCountdownTimerState extends State<AdvertCountdownTimer> {
  Timer? _timer;
  String _timeRemaining = '';

  @override
  void initState() {
    super.initState();
    _updateTimeRemaining();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateTimeRemaining();
    });
  }

  void _updateTimeRemaining() {
    final now = DateTime.now();
    final difference = widget.endDate.difference(now);

    if (difference.isNegative) {
      setState(() {
        _timeRemaining = 'Promotion has ended';
      });
      _timer?.cancel();
      return;
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    setState(() {
      if (days > 0) {
        _timeRemaining = '⏳ Promotion ends in ${days}d - ${hours}hrs';
      } else if (hours > 0) {
        _timeRemaining = '⏳ Promotion ends in ${hours}hrs - ${minutes}mins';
      } else {
        _timeRemaining = '⏳ Promotion ends in ${minutes}mins';
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    
    return Container(
      padding: pad(horizontal: 10, vertical: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.error.shade50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: UrbText(
        _timeRemaining,
        color: colors.black,
        weight: FontWeight.w700,
        size: 16,
      ),
    );
  }
}
