import 'package:flutter/material.dart';

/// Animations et transitions de l'application BudgetBuddy
/// Constantes et utilitaires pour des animations fluides et cohérentes
class AppAnimations {
  AppAnimations._(); // Constructeur privé

  // ==================== DURÉES ====================

  /// Durée très rapide (100ms)
  static const Duration durationFast = Duration(milliseconds: 100);

  /// Durée rapide (200ms)
  static const Duration durationQuick = Duration(milliseconds: 200);

  /// Durée normale (300ms) - Par défaut
  static const Duration durationNormal = Duration(milliseconds: 300);

  /// Durée moyenne (400ms)
  static const Duration durationMedium = Duration(milliseconds: 400);

  /// Durée lente (500ms)
  static const Duration durationSlow = Duration(milliseconds: 500);

  /// Durée très lente (700ms)
  static const Duration durationVerySlow = Duration(milliseconds: 700);

  // ==================== COURBES ====================

  /// Courbe par défaut (Material)
  static const Curve curveDefault = Curves.easeInOut;

  /// Courbe d'entrée
  static const Curve curveIn = Curves.easeIn;

  /// Courbe de sortie
  static const Curve curveOut = Curves.easeOut;

  /// Courbe rapide au départ
  static const Curve curveFastStart = Curves.fastOutSlowIn;

  /// Courbe rapide à la fin
  static const Curve curveFastEnd = Curves.slowMiddle;

  /// Courbe élastique
  static const Curve curveElastic = Curves.elasticOut;

  /// Courbe rebondissante
  static const Curve curveBounce = Curves.bounceOut;

  /// Courbe linéaire
  static const Curve curveLinear = Curves.linear;

  /// Courbe Material standard
  static const Curve curveMaterial = Curves.easeInOutCubicEmphasized;

  // ==================== TRANSITIONS DE PAGE ====================

  /// Transition de fondu
  static PageRouteBuilder<T> fadeTransition<T>(
    Widget page, {
    Duration duration = durationNormal,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Transition de glissement depuis la droite
  static PageRouteBuilder<T> slideFromRight<T>(
    Widget page, {
    Duration duration = durationNormal,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(
          tween.chain(CurveTween(curve: curveFastStart)),
        );

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  /// Transition de glissement depuis le bas
  static PageRouteBuilder<T> slideFromBottom<T>(
    Widget page, {
    Duration duration = durationNormal,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(
          tween.chain(CurveTween(curve: curveFastStart)),
        );

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  /// Transition de zoom
  static PageRouteBuilder<T> scaleTransition<T>(
    Widget page, {
    Duration duration = durationNormal,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: curveFastStart)),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  /// Transition combinée (glissement + fondu)
  static PageRouteBuilder<T> slideAndFadeTransition<T>(
    Widget page, {
    Duration duration = durationNormal,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(
          tween.chain(CurveTween(curve: curveFastStart)),
        );

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  // ==================== ANIMATIONS DE WIDGETS ====================

  /// Animation de pulsation
  static AnimationController pulseAnimation(
    TickerProvider vsync, {
    Duration duration = durationNormal,
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return AnimationController(vsync: vsync, duration: duration)
      ..repeat(reverse: true);
  }

  /// Animation de rotation
  static AnimationController rotateAnimation(
    TickerProvider vsync, {
    Duration duration = durationSlow,
  }) {
    return AnimationController(vsync: vsync, duration: duration)..repeat();
  }

  /// Animation de rebond
  static Animation<double> bounceAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: curveBounce));
  }

  /// Animation de glissement
  static Animation<Offset> slideAnimation(
    AnimationController controller, {
    Offset begin = const Offset(0.0, 1.0),
    Offset end = Offset.zero,
  }) {
    return Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: controller, curve: curveFastStart));
  }

  // ==================== TRANSITIONS D'ÉTAT ====================

  /// Transition douce pour les changements de couleur
  static Widget colorTransition({
    required Color color,
    required Duration duration,
    required Widget child,
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: curveDefault,
      color: color,
      child: child,
    );
  }

  /// Transition douce pour les changements de taille
  static Widget sizeTransition({
    required double width,
    required double height,
    required Duration duration,
    required Widget child,
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: curveDefault,
      width: width,
      height: height,
      child: child,
    );
  }

  /// Transition douce pour l'opacité
  static Widget opacityTransition({
    required double opacity,
    required Duration duration,
    required Widget child,
  }) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: duration,
      curve: curveDefault,
      child: child,
    );
  }

  // ==================== ANIMATIONS SPÉCIFIQUES ====================

  /// Animation de chargement (shimmer)
  static ShaderMask shimmerEffect({
    required Widget child,
    Color baseColor = const Color(0xFFE0E0E0),
    Color highlightColor = const Color(0xFFF5F5F5),
  }) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [baseColor, highlightColor, baseColor],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds);
      },
      child: child,
    );
  }

  /// Animation de compteur (nombre qui monte)
  static Widget counterAnimation({
    required double begin,
    required double end,
    required Duration duration,
    required TextStyle? style,
    String? suffix,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: begin, end: end),
      duration: duration,
      curve: curveDefault,
      builder: (context, value, child) {
        return Text('${value.toStringAsFixed(0)}${suffix ?? ''}', style: style);
      },
    );
  }

  // ==================== MÉTHODES UTILITAIRES ====================

  /// Délai avant une action
  static Future<void> delay([Duration duration = durationNormal]) {
    return Future.delayed(duration);
  }

  /// Exécute une action après un délai
  static Future<void> delayedAction(
    VoidCallback action, [
    Duration duration = durationNormal,
  ]) async {
    await delay(duration);
    action();
  }

  /// Crée un controller avec une durée spécifique
  static AnimationController createController(
    TickerProvider vsync, {
    Duration duration = durationNormal,
  }) {
    return AnimationController(vsync: vsync, duration: duration);
  }

  /// Animation stagger (décalée) pour les listes
  static List<Animation<double>> staggeredAnimation(
    AnimationController controller,
    int itemCount, {
    Duration delay = const Duration(milliseconds: 50),
  }) {
    final animations = <Animation<double>>[];
    final totalDuration = controller.duration!.inMilliseconds;
    final delayMs = delay.inMilliseconds;

    for (var i = 0; i < itemCount; i++) {
      final start = (i * delayMs) / totalDuration;
      final end = ((i * delayMs) + totalDuration) / totalDuration;

      animations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              start.clamp(0.0, 1.0),
              end.clamp(0.0, 1.0),
              curve: curveDefault,
            ),
          ),
        ),
      );
    }

    return animations;
  }
}
