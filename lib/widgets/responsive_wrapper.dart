import 'package:flutter/material.dart';
import '../core/responsive.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final bool showRightOverlay;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.showRightOverlay = true,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final isLargeScreen = responsive.isDesktop || responsive.isTablet;
    final overlayWidth = responsive.isDesktop ? 40.0 : (responsive.isTablet ? 30.0 : 20.0);

    return Material(
      color: const Color(0xFF070A11),
      child: Stack(
        children: [
          // Main Content
          Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isLargeScreen ? 1200 : double.infinity,
              ),
              child: Padding(
                padding: EdgeInsets.only(right: overlayWidth),
                child: child,
              ),
            ),
          ),

          // Right Overlay (20px)
          if (showRightOverlay)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: overlayWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(5),
                  border: const Border(
                    left: BorderSide(color: Color(0x1AFFFFFF), width: 0.5),
                  ),
                ),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ColorFilter.mode(
                      Colors.black.withAlpha(20),
                      BlendMode.darken,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFFFFB300).withAlpha(10),
                            Colors.transparent,
                            const Color(0xFFFFB300).withAlpha(10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
