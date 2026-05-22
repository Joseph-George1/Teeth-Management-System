import 'package:flutter/material.dart';
import 'package:thoutha_mobile_app/tour/tour_config.dart';
import 'package:thoutha_mobile_app/tour/tour_service.dart';

class MultiTourWidget extends StatefulWidget {
  final Widget child;
  const MultiTourWidget({super.key, required this.child});

  static MultiTourWidgetState? of(BuildContext context) {
    return context.findAncestorStateOfType<MultiTourWidgetState>();
  }

  @override
  MultiTourWidgetState createState() => MultiTourWidgetState();
}

class MultiTourWidgetState extends State<MultiTourWidget> {
  OverlayEntry? _overlayEntry;

  void startTour(List<List<TourStep>> groups) {
    if (groups.isEmpty) return;
    if (_overlayEntry != null) return;
    if (!mounted) return;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => MultiTourOverlay(
        groups: groups,
        onComplete: _removeOverlay,
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class MultiTourOverlay extends StatefulWidget {
  final List<List<TourStep>> groups;
  final VoidCallback onComplete;

  const MultiTourOverlay({
    super.key,
    required this.groups,
    required this.onComplete,
  });

  @override
  State<MultiTourOverlay> createState() => _MultiTourOverlayState();
}

class _MultiTourOverlayState extends State<MultiTourOverlay> with TickerProviderStateMixin {
  int _currentGroupIndex = 0;
  late AnimationController _animController;
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _floatingController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _next() async {
    for (var step in widget.groups[_currentGroupIndex]) {
      await TourService.markSeen(step.id);
    }

    if (_currentGroupIndex < widget.groups.length - 1) {
      setState(() {
        _currentGroupIndex++;
      });
      _animController.forward(from: 0.0);
    } else {
      widget.onComplete();
    }
  }

  void _skip() async {
    await TourService.skipAll();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentGroupIndex >= widget.groups.length) return const SizedBox.shrink();
    
    final currentGroup = widget.groups[_currentGroupIndex];
    final size = MediaQuery.sizeOf(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    
    // Find drawer bounds for the whole group to constrain highlights/tooltips
    Rect? drawerRect;
    for (var step in currentGroup) {
      final ctx = step.key.currentContext;
      if (ctx == null) continue;
      
      ctx.visitAncestorElements((element) {
        final box = element.findRenderObject();
        if (box is RenderBox && box.hasSize) {
          final s = box.size;
          // Detect drawer: height is almost full screen, width is less than full screen
          if (s.height > size.height * 0.8 && s.width < size.width - 10) {
            final pos = box.localToGlobal(Offset.zero);
            drawerRect = pos & s;
            return false;
          }
        }
        return true;
      });
      if (drawerRect != null) break;
    }

    List<Rect> holes = [];
    List<Widget> tooltips = [];

    for (int i = 0; i < currentGroup.length; i++) {
      final step = currentGroup[i];
      final context = step.key.currentContext;
      if (context == null) continue;
      
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final position = renderBox.localToGlobal(Offset.zero);
        final rect = position & renderBox.size;
        holes.add(rect);

        // Animation logic
        Offset slideOffset;
        if (i % 3 == 0) {
          slideOffset = const Offset(0, -1);
        } else if (i % 3 == 1) {
          slideOffset = const Offset(0, 1);
        } else {
          slideOffset = const Offset(1, 0);
        }

        // Smart positioning
        double top = rect.bottom + 15;
        double left = rect.left;
        
        if (top > size.height - 150) {
          top = rect.top - 150;
        }
        
        if (left > size.width - 280) {
          left = size.width - 290;
        }
        if (left < 10) left = 10;

        if (drawerRect != null) {
          if (left < drawerRect!.left + 10) left = drawerRect!.left + 10;
          if (left + 270 > drawerRect!.right - 10) left = drawerRect!.right - 280;
        }

        tooltips.add(
          Positioned(
            top: top,
            left: left,
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 8 * _floatingController.value),
                  child: child,
                );
              },
              child: SlideTransition(
                position: Tween<Offset>(begin: slideOffset, end: Offset.zero).animate(
                  CurvedAnimation(parent: _animController, curve: Curves.easeOutBack)
                ),
                child: FadeTransition(
                  opacity: _animController,
                  child: GestureDetector(
                    onTap: _next,
                    child: _buildTooltip(step, drawerRect),
                  ),
                ),
              ),
            ),
          )
        );
      }
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          GestureDetector(
            onTap: _next,
            behavior: HitTestBehavior.opaque,
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: MultiHolePainter(
                    holes,
                    drawerRect: drawerRect,
                    pulseValue: _floatingController.value,
                  ),
                );
              },
            ),
          ),
          
          ...tooltips,
          
          Positioned(
            top: viewPadding.top + 16,
            left: 16,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
                CurvedAnimation(parent: _animController, curve: Curves.easeOutBack)
              ),
              child: GestureDetector(
                onTap: _skip,
                child: _buildSkipButton(context),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSkipButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.close_rounded, size: 18, color: Color(0xFF6366F1)),
          const SizedBox(width: 8),
          Text(
            'تخطي الجولة',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontWeight: FontWeight.w800,
              fontSize: 13,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltip(TourStep step, Rect? drawerRect) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalSteps = widget.groups.length;
    final currentStep = _currentGroupIndex + 1;
    
    // Modern Professional Palette
    const primaryAccent = Color(0xFF6366F1); // Indigo
    const secondaryAccent = Color(0xFF8B5CF6); // Violet
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryAccent.withValues(alpha: isDark ? 0.3 : 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(
          color: primaryAccent.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with Gradient
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryAccent.withValues(alpha: 0.15), secondaryAccent.withValues(alpha: 0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [primaryAccent, secondaryAccent]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        fontFamily: 'Cairo',
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Message Body
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: Text(
                step.description,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Cairo',
                  color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black54,
                  height: 1.6,
                ),
              ),
            ),

            // Action Button with Gradient
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(colors: [primaryAccent, secondaryAccent]),
                  boxShadow: [
                    BoxShadow(
                      color: primaryAccent.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    currentStep == totalSteps ? 'انطلق الآن' : 'التالي',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MultiHolePainter extends CustomPainter {
  final List<Rect> holes;
  final Rect? drawerRect;
  final double pulseValue;

  MultiHolePainter(this.holes, {this.drawerRect, this.pulseValue = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    for (final hole in holes) {
      Rect inflatedHole = hole.inflate(6);
      if (drawerRect != null && inflatedHole.overlaps(drawerRect!)) {
        inflatedHole = inflatedHole.intersect(drawerRect!);
      }
      path.addRRect(RRect.fromRectAndRadius(inflatedHole, const Radius.circular(12)));

      // Draw Intense Pulse/Glow Effect
      final glowPaint = Paint()
        ..color = const Color(0xFF6366F1).withValues(alpha: 0.8 * (1 - pulseValue))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4 + (8 * pulseValue)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 + 8 * pulseValue);

      canvas.drawRRect(
        RRect.fromRectAndRadius(inflatedHole.inflate(10 * pulseValue), const Radius.circular(12)),
        glowPaint,
      );
    }
    
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, backgroundPaint);
  }

  @override
  bool shouldRepaint(MultiHolePainter oldDelegate) => true;
}
