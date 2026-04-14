import 'package:flutter/material.dart';

void main() {
  runApp(const TouristiqueGuidApp());
}

class TouristiqueGuidApp extends StatelessWidget {
  const TouristiqueGuidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Touristique Guide',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF9A9BC2),
        fontFamily: 'Roboto',
      ),
      home: const MockupPreviewScreen(),
    );
  }
}

class MockupPreviewScreen extends StatelessWidget {
  const MockupPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 1100;
            final cards = [
              const _PhoneFrame(child: _ParkScreen()),
              const _PhoneFrame(child: _RouteScreen()),
              const _PhoneFrame(child: _DiscoverScreen()),
            ];

            if (isWide) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < cards.length; i++) ...[
                    SizedBox(width: 320, child: cards[i]),
                    if (i < cards.length - 1) const SizedBox(width: 24),
                  ],
                ],
              );
            }

            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) => SizedBox(width: 320, child: cards[i]),
              separatorBuilder: (_, __) => const SizedBox(width: 20),
              itemCount: cards.length,
            );
          },
        ),
      ),
    );
  }
}

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A1032),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _ParkScreen extends StatelessWidget {
  const _ParkScreen();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://images.unsplash.com/photo-1521292270410-a8c4d716d518?auto=format&fit=crop&w=900&q=80',
                fit: BoxFit.cover,
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xFF0A1032)],
                    stops: [0.45, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    const Text(
                      'Vanaheim\nNational Park',
                      style: TextStyle(
                        fontSize: 44,
                        height: 1.05,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Lorem ipsum dolor sit amet,\nconsectetur adipiscing.',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        const Icon(Icons.more_vert_outlined, size: 24),
                        const SizedBox(width: 16),
                        const Icon(Icons.favorite_border_outlined, size: 24),
                        const SizedBox(width: 16),
                        const Icon(Icons.send_outlined, size: 24),
                        const Spacer(),
                        const Icon(Icons.star, size: 20, color: Color(0xFFFF9D6A)),
                        const SizedBox(width: 6),
                        const Text(
                          '4.5/5.0',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'INFORMATIONS',
                      style: TextStyle(
                        letterSpacing: 3,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Lorem ipsum dolor sit amet, consectetuer adipiscing elit, '
                      'sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna '
                      'aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud '
                      'exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea '
                      'commodo consequat.',
                      style: TextStyle(fontSize: 13.8, color: Colors.white60, height: 1.45),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Column(
                        children: [
                          Icon(Icons.keyboard_arrow_down_rounded, size: 34),
                          SizedBox(height: 4),
                          Text('Read More', style: TextStyle(fontSize: 26)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const _BottomBar(),
      ],
    );
  }
}

class _RouteScreen extends StatelessWidget {
  const _RouteScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1137), Color(0xFF090F31)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios_new, size: 18),
                Spacer(),
                Text(
                  'Lorem Ipsum\nArea',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Spacer(),
                Icon(Icons.menu, size: 28),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                const Positioned.fill(child: _TopoLines()),
                Positioned(
                  top: 135,
                  left: 132,
                  child: _LabelBubble(
                    title: 'Lorem Ipsum',
                    subtitle: '★ 4.2/5.0',
                  ),
                ),
                const Positioned(
                  top: 240,
                  left: 137,
                  child: _Pin(),
                ),
                const Positioned(
                  top: 196,
                  left: 215,
                  child: _Pin(small: true),
                ),
                const Positioned(
                  top: 308,
                  left: 246,
                  child: _Pin(small: true),
                ),
                const Positioned(
                  top: 160,
                  left: 115,
                  child: _StopDot(),
                ),
                const Positioned(
                  top: 225,
                  left: 161,
                  child: _StopDot(),
                ),
                const Positioned(
                  top: 284,
                  left: 246,
                  child: _StopDot(),
                ),
                const Positioned(
                  left: 16,
                  right: 16,
                  bottom: 18,
                  child: _RouteDetails(),
                ),
              ],
            ),
          ),
          const _BottomBar(),
        ],
      ),
    );
  }
}

class _DiscoverScreen extends StatelessWidget {
  const _DiscoverScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF090F33),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios_new, size: 18),
                Spacer(),
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Discover',
                    style: TextStyle(fontSize: 52, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Lorem ipsum dolor sit amet,\nconsectetuer adipiscing.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 18),
                  _SearchBar(),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      _TagChip(label: 'Trending', active: true),
                      SizedBox(width: 8),
                      _TagChip(label: 'Asia'),
                      SizedBox(width: 8),
                      _TagChip(label: 'Europe'),
                      SizedBox(width: 8),
                      _TagChip(label: 'America'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        const _TravelCard(
                          title: 'Lorem Ipsum',
                          subtitle: 'Lorem ipsum',
                          image:
                              'https://images.unsplash.com/photo-1583422409516-2895a77efded?auto=format&fit=crop&w=900&q=80',
                        ),
                        const SizedBox(width: 12),
                        const _TravelCard(
                          title: 'Lorem Ipsum',
                          subtitle: 'Lorem ipsum',
                          image:
                              'https://images.unsplash.com/photo-1558862107-d49ef2a04d72?auto=format&fit=crop&w=900&q=80',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'MORE CATEGORIES',
                    style: TextStyle(
                      letterSpacing: 3,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Row(
                    children: [
                      Expanded(
                        child: _CategoryCard(
                          title: 'Lorem',
                          icon: Icons.local_cafe_outlined,
                          active: true,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _CategoryCard(
                          title: 'Ipsum',
                          icon: Icons.forest_outlined,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _CategoryCard(
                          title: 'Dolor',
                          icon: Icons.sailing_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const _BottomBar(),
        ],
      ),
    );
  }
}

class _TravelCard extends StatelessWidget {
  const _TravelCard({
    required this.title,
    required this.subtitle,
    required this.image,
  });

  final String title;
  final String subtitle;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF474A67),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              image,
              height: 95,
              width: 200,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const Spacer(),
                    const Text('4.5', style: TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
                Text(subtitle, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Spacer(),
                    Icon(Icons.star, size: 18, color: Colors.orange.shade300),
                  ],
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF845A), Color(0xFFEB338F)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Read More'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.icon,
    this.active = false,
  });

  final String title;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        gradient: active
            ? const LinearGradient(colors: [Color(0xFFFF845A), Color(0xFFEB338F)])
            : null,
        color: active ? null : const Color(0xFF414462),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: active
            ? const LinearGradient(colors: [Color(0xFFFF845A), Color(0xFFEB338F)])
            : null,
        color: active ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : Colors.white54,
          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3F4262),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(6)),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: const Text(
                'Search for destination...',
                style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
              ),
            ),
          ),
          Container(
            width: 64,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFFF845A), Color(0xFFEB338F)]),
              borderRadius: BorderRadius.horizontal(right: Radius.circular(6)),
            ),
            child: const Icon(Icons.search, size: 26),
          ),
        ],
      ),
    );
  }
}

class _RouteDetails extends StatelessWidget {
  const _RouteDetails();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.route_outlined, color: Colors.white70, size: 22),
        const SizedBox(height: 8),
        const Text('75km', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text(
          'Vanaheim National Park',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const Text(
          '123 Streets, Your City,\nYour Province, Your Countries',
          style: TextStyle(color: Colors.white60, height: 1.4),
        ),
        const SizedBox(height: 10),
        const Text(
          'Lorem ipsum dolor sit amet, consectetuer adipiscing elit,\n'
          'sed diam nonummy nibh euismod tincidunt ut laoreet magna\n'
          'aliquam erat volutpat.',
          style: TextStyle(color: Colors.white70, height: 1.45),
        ),
        const SizedBox(height: 8),
        Center(
          child: Column(
            children: [
              const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
              const SizedBox(height: 2),
              const Text('Read More', style: TextStyle(fontSize: 22)),
            ],
          ),
        ),
      ],
    );
  }
}

class _LabelBubble extends StatelessWidget {
  const _LabelBubble({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TooltipArrowPainter(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE9368B), Color(0xFFC61282)],
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _TooltipArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFC61282);
    final path = Path()
      ..moveTo(size.width * 0.45, size.height)
      ..lineTo(size.width * 0.62, size.height)
      ..lineTo(size.width * 0.53, size.height + 10)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Pin extends StatelessWidget {
  const _Pin({this.small = false});

  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: small ? 28 : 34,
      height: small ? 28 : 34,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFE9368B), Color(0xFFC61282)]),
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Icon(Icons.location_on_outlined, size: 20),
    );
  }
}

class _StopDot extends StatelessWidget {
  const _StopDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _TopoLines extends StatelessWidget {
  const _TopoLines();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TopographicPainter(),
    );
  }
}

class _TopographicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final topoPaint = Paint()
      ..color = const Color(0xFF252A57)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final routePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE3368D), Color(0xFFFFAA52)],
      ).createShader(Rect.fromLTWH(40, 120, size.width - 80, 220))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    for (var i = 0; i < 15; i++) {
      final y = i * 32.0;
      final path = Path()
        ..moveTo(0, y + 10)
        ..quadraticBezierTo(size.width * 0.2, y - 4, size.width * 0.45, y + 14)
        ..quadraticBezierTo(size.width * 0.7, y + 34, size.width, y + 6);
      canvas.drawPath(path, topoPaint);
    }

    final route = Path()
      ..moveTo(24, 140)
      ..cubicTo(80, 95, 118, 170, 162, 225)
      ..cubicTo(196, 266, 220, 220, 246, 286)
      ..quadraticBezierTo(260, 320, 286, 290);
    canvas.drawPath(route, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      color: const Color(0xFF090F33),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.search, color: Colors.white60),
          Icon(Icons.bookmark_border_outlined, color: Colors.white60),
          Icon(Icons.home_outlined, color: Colors.white70),
          Icon(Icons.person_outline, color: Colors.white60),
          Icon(Icons.grid_view_outlined, color: Colors.white60),
        ],
      ),
    );
  }
}
