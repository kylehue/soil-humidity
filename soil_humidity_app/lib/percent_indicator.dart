import 'package:flutter/material.dart';

class PercentIndicator extends StatelessWidget {
  final double? percent;
  final Color? color;
  final String? _message;
  const PercentIndicator.connected({super.key, required this.percent})
      : color = null,
        _message = null;
  PercentIndicator.connecting({super.key})
      : percent = null,
        _message = 'Connecting...',
        color = Colors.grey.shade300;
  const PercentIndicator.disconnected({super.key})
      : percent = 1.0,
        _message = 'Disconnected',
        color = Colors.purple;
  const PercentIndicator.error({super.key})
      : percent = 1.0,
        _message = 'Error',
        color = Colors.red;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 250,
          width: 250,
          child: CircularProgressIndicator(
            value: percent,
            color: color,
          ),
        ),
        SizedBox(
          height: 250,
          width: 250,
          child: Center(
            child: Text(
              _message != null
                  ? _message!
                  : '${((percent ?? 0) * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w200,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
