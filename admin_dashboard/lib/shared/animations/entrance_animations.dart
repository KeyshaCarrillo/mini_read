import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension EnterpriseEntrance on Widget {
  Widget enterpriseFade({Duration delay = Duration.zero}) {
    return animate(delay: delay).fadeIn(duration: 260.ms, curve: Curves.easeOutCubic).slideY(begin: .018, end: 0, duration: 260.ms, curve: Curves.easeOutCubic);
  }
}
