import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const RebuyApp());
}

enum AuthMode { login, signup }

class RebuyApp extends StatelessWidget {
  const RebuyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReBuy',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const AuthScreen(mode: AuthMode.login),
        '/signup': (context) => const AuthScreen(mode: AuthMode.signup),
        '/dashboard': (context) => const DashboardScreen(),
      },
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE94E92)),
        textTheme: GoogleFonts.spaceGroteskTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF1F1F4),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE4E5EA)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE4E5EA)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE94E92), width: 1.2),
          ),
        ),
      ),
    );
  }
}

// ─── SPLASH SCREEN ───────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF5565), Color(0xFFE845B0)],
          ),
        ),
        child: Center(
          child: Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              'ReBuy',
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0xFF2A2E3A),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── AUTH SCREEN (LOGIN / SIGNUP) ────────────────────────────────────────────

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key, required this.mode});

  final AuthMode mode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _AuthForm(mode: mode),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthForm extends StatefulWidget {
  const _AuthForm({required this.mode});

  final AuthMode mode;

  @override
  State<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<_AuthForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passCtrl;
  late final TextEditingController _confirmCtrl;

  bool get _isSignup => widget.mode == AuthMode.signup;
  String get _title => _isSignup ? 'Sign up' : 'Log in';
  String get _subtitle => _isSignup
      ? 'Login with one of the following options.'
      : 'Login with one of the following options.';
  String get _btnLabel => _isSignup ? 'Create account' : 'Log in';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _passCtrl = TextEditingController();
    _confirmCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _valName(String? v) {
    if (!_isSignup) return null;
    if ((v?.trim() ?? '').isEmpty) return 'Enter your full name.';
    return null;
  }

  String? _valEmail(String? v) {
    final e = v?.trim() ?? '';
    if (e.isEmpty) return 'Enter your email.';
    if (!e.contains('@')) return 'Email must contain @.';
    return null;
  }

  String? _valPass(String? v) {
    final p = v ?? '';
    if (p.isEmpty) return 'Enter your password.';
    if (p.length < 6) return 'At least 6 characters.';
    return null;
  }

  String? _valConfirm(String? v) {
    if (!_isSignup) return null;
    if ((v ?? '').isEmpty) return 'Confirm your password.';
    if (v != _passCtrl.text) return 'Passwords do not match.';
    return null;
  }

  void _switchRoute() {
    Navigator.of(
      context,
    ).pushReplacementNamed(_isSignup ? '/login' : '/signup');
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top row: back arrow + brand
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (_isSignup) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDADCE2)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 14),
                ),
              ),
              const Spacer(),
              Text(
                'ReBuy',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF2A2E3A),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            _title,
            key: const ValueKey('auth_title'),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: const Color(0xFF1A1D2B),
              fontWeight: FontWeight.w800,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF666D80),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Social buttons
          Row(
            children: [
              _SocialBtn(icon: Icons.g_mobiledata, label: 'G'),
              const SizedBox(width: 10),
              _SocialBtn(icon: Icons.close, label: 'X'),
              const SizedBox(width: 10),
              _SocialBtn(icon: Icons.apple, label: 'A'),
            ],
          ),
          const SizedBox(height: 24),

          // Or divider
          Row(
            children: [
              const Expanded(
                child: Divider(color: Color(0xFFE4E7EE), thickness: 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  'or',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8A91A8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Expanded(
                child: Divider(color: Color(0xFFE4E7EE), thickness: 1),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Form fields
          if (_isSignup) ...[
            _Field(
              key: const ValueKey('full_name_field'),
              ctrl: _nameCtrl,
              hint: 'Full name',
              validator: _valName,
            ),
            const SizedBox(height: 14),
          ],
          _Field(
            key: const ValueKey('email_field'),
            ctrl: _emailCtrl,
            hint: 'Email',
            type: TextInputType.emailAddress,
            validator: _valEmail,
          ),
          const SizedBox(height: 14),
          _Field(
            key: const ValueKey('password_field'),
            ctrl: _passCtrl,
            hint: 'Password',
            obscure: true,
            validator: _valPass,
          ),
          if (_isSignup) ...[
            const SizedBox(height: 14),
            _Field(
              key: const ValueKey('confirm_password_field'),
              ctrl: _confirmCtrl,
              hint: 'Confirm password',
              obscure: true,
              validator: _valConfirm,
            ),
          ],
          const SizedBox(height: 28),

          // Action button
          _GradientButton(label: _btnLabel, onPressed: _submit),
          const SizedBox(height: 18),

          // Switch prompt
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                _isSignup
                    ? "Already have an account? "
                    : "Don't have an account? ",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF707792),
                  fontSize: 13,
                ),
              ),
              TextButton(
                key: const ValueKey('auth_switch_button'),
                onPressed: _switchRoute,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  _isSignup ? 'Log in' : 'Sign up',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFE94E92),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── SHARED WIDGETS ──────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    super.key,
    required this.ctrl,
    required this.hint,
    required this.validator,
    this.type,
    this.obscure = false,
  });

  final TextEditingController ctrl;
  final String hint;
  final String? Function(String?) validator;
  final TextInputType? type;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      validator: validator,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF2A3148),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF8D93A6)),
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  const _SocialBtn({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Ink(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE1E4EC)),
          ),
          child: Center(
            child: Icon(icon, size: 24, color: const Color(0xFF36405B)),
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF4F69), Color(0xFFC76FB6)],
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 50,
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── PRODUCT MODEL & CARD ────────────────────────────────────────────────────

class _Product {
  const _Product(this.name, this.category, this.price, this.rating, this.image);
  final String name;
  final String category;
  final int price;
  final double rating;
  final String image;
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});
  final _Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFEDEEF2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  product.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, _, _) => const Center(
                    child: Icon(Icons.image_not_supported_outlined, size: 40, color: Color(0xFF8A91A8)),
                  ),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1D2B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '\$${product.price}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFE94E92),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFFFC107),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8A91A8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── DASHBOARD ───────────────────────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 0;

  static const _categories = [
    ('All', Icons.grid_view_rounded),
    ('Electronics', Icons.devices),
    ('Fashion', Icons.checkroom),
    ('Furniture', Icons.chair),
    ('Books', Icons.menu_book),
    ('Sports', Icons.sports_basketball),
  ];

  static const _products = [
    _Product('iPhone 13', 'Electronics', 549, 4.5, 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=300&h=300&fit=crop'),
    _Product('Nike Air Max', 'Fashion', 89, 4.8, 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300&h=300&fit=crop'),
    _Product('Wooden Desk', 'Furniture', 120, 4.2, 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=300&h=300&fit=crop'),
    _Product('Samsung TV 55"', 'Electronics', 399, 4.6, 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=300&h=300&fit=crop'),
    _Product('Leather Jacket', 'Fashion', 75, 4.3, 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=300&h=300&fit=crop'),
    _Product('Office Chair', 'Furniture', 95, 4.7, 'https://images.unsplash.com/photo-1580480055273-228ff5388ef8?w=300&h=300&fit=crop'),
    _Product('AirPods Pro', 'Electronics', 149, 4.9, 'https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?w=300&h=300&fit=crop'),
    _Product('Running Shoes', 'Sports', 65, 4.4, 'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=300&h=300&fit=crop'),
  ];

  int _selectedCat = 0;

  List<_Product> get _filtered {
    if (_selectedCat == 0) return _products;
    final cat = _categories[_selectedCat].$1;
    return _products.where((p) => p.category == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _navIndex,
          children: [
            _HomeTab(
              categories: _categories,
              products: _products,
              selectedCat: _selectedCat,
              filtered: _filtered,
              onCatChanged: (i) => setState(() => _selectedCat = i),
            ),
            const _ExploreTab(),
            const _SavedTab(),
            const _ChatTab(),
            const _ProfileTab(),
          ],
        ),
      ),

      // ── Bottom nav ──
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFE94E92),
        unselectedItemColor: const Color(0xFF8A91A8),
        backgroundColor: Colors.white,
        elevation: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_rounded),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ─── HOME TAB ────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.categories,
    required this.products,
    required this.selectedCat,
    required this.filtered,
    required this.onCatChanged,
  });

  final List<(String, IconData)> categories;
  final List<_Product> products;
  final int selectedCat;
  final List<_Product> filtered;
  final ValueChanged<int> onCatChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // ── Top bar ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8A91A8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Discover Deals',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1D2B),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEEF2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF3A3F52),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Search bar ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF8A91A8),
                size: 22,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              filled: true,
              fillColor: const Color(0xFFEDEEF2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // ── Categories ──
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final selected = i == selectedCat;
              return GestureDetector(
                onTap: () => onCatChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                            colors: [Color(0xFFFF4F69), Color(0xFFC76FB6)],
                          )
                        : null,
                    color: selected ? null : const Color(0xFFEDEEF2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Icon(
                        categories[i].$2,
                        size: 16,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF5A6078),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        categories[i].$1,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF5A6078),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),

        // ── Product grid ──
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              itemCount: filtered.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, i) => _ProductCard(product: filtered[i]),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── EXPLORE TAB ─────────────────────────────────────────────────────────────

class _ExploreTab extends StatelessWidget {
  const _ExploreTab();

  static const _trending = [
    _Product('MacBook Air M2', 'Electronics', 999, 4.9, 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=300&h=300&fit=crop'),
    _Product('Dyson Vacuum', 'Electronics', 299, 4.7, 'https://images.unsplash.com/photo-1558317374-067fb5f30001?w=300&h=300&fit=crop'),
    _Product('Yoga Mat Pro', 'Sports', 35, 4.6, 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=300&h=300&fit=crop'),
    _Product('Vintage Lamp', 'Furniture', 55, 4.3, 'https://images.unsplash.com/photo-1513506003901-1e6a229e2d15?w=300&h=300&fit=crop'),
  ];

  static const _nearYou = [
    _Product('PS5 Controller', 'Electronics', 49, 4.5, 'https://images.unsplash.com/photo-1592840496694-26d035b52b48?w=300&h=300&fit=crop'),
    _Product('Denim Jacket', 'Fashion', 42, 4.2, 'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?w=300&h=300&fit=crop'),
    _Product('Bookshelf Oak', 'Furniture', 88, 4.4, 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=300&h=300&fit=crop'),
    _Product('Basketball', 'Sports', 28, 4.1, 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=300&h=300&fit=crop'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              'Explore',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1D2B),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Search ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search categories, brands...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF8A91A8),
                  size: 22,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: const Color(0xFFEDEEF2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Featured Banner ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF4F69), Color(0xFFC76FB6)],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Up to 50% Off',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Weekend special on electronics',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Shop Now',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFE94E92),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.local_offer_rounded,
                    size: 64,
                    color: Colors.white24,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Trending Now ──
          _SectionHeader(title: 'Trending Now'),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _trending.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (_, i) => SizedBox(
                width: 150,
                child: _ProductCard(product: _trending[i]),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Near You ──
          _SectionHeader(title: 'Near You'),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _nearYou.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (_, i) => SizedBox(
                width: 150,
                child: _ProductCard(product: _nearYou[i]),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── SAVED TAB ───────────────────────────────────────────────────────────────

class _SavedTab extends StatefulWidget {
  const _SavedTab();

  @override
  State<_SavedTab> createState() => _SavedTabState();
}

class _SavedTabState extends State<_SavedTab> {
  final List<_Product> _saved = [
    const _Product('iPhone 13', 'Electronics', 549, 4.5, 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=300&h=300&fit=crop'),
    const _Product('Nike Air Max', 'Fashion', 89, 4.8, 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300&h=300&fit=crop'),
    const _Product('Office Chair', 'Furniture', 95, 4.7, 'https://images.unsplash.com/photo-1580480055273-228ff5388ef8?w=300&h=300&fit=crop'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Text(
            'Saved Items',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1D2B),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Text(
            '${_saved.length} items in your wishlist',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF8A91A8),
            ),
          ),
        ),

        // ── List ──
        Expanded(
          child: _saved.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_border_rounded,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No saved items yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF8A91A8),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _saved.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final p = _saved[i];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Thumbnail
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDEEF2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  p.image,
                                  fit: BoxFit.cover,
                                  width: 72,
                                  height: 72,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Color(0xFFB0B5C3),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1A1D2B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    p.category,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF8A91A8),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '\$${p.price}',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFE94E92),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Remove
                            IconButton(
                              onPressed: () =>
                                  setState(() => _saved.removeAt(i)),
                              icon: const Icon(
                                Icons.favorite_rounded,
                                color: Color(0xFFE94E92),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ─── PROFILE TAB ─────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),

          // ── Avatar + Name ──
          Center(
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF4F69), Color(0xFFC76FB6)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE94E92).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Shahzaib',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1D2B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'shahzaib@rebuy.pk',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8A91A8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Stats Row ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatItem(value: '12', label: 'Listed'),
                  Container(
                    width: 1,
                    height: 36,
                    color: const Color(0xFFE4E7EE),
                  ),
                  _StatItem(value: '5', label: 'Sold'),
                  Container(
                    width: 1,
                    height: 36,
                    color: const Color(0xFFE4E7EE),
                  ),
                  _StatItem(value: '3', label: 'Bought'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Menu Items ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _ProfileMenuItem(
                  icon: Icons.shopping_bag_outlined,
                  label: 'My Orders',
                ),
                _ProfileMenuItem(
                  icon: Icons.location_on_outlined,
                  label: 'My Addresses',
                ),
                _ProfileMenuItem(
                  icon: Icons.payment_outlined,
                  label: 'Payment Methods',
                ),
                _ProfileMenuItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                ),
                _ProfileMenuItem(
                  icon: Icons.help_outline_rounded,
                  label: 'Help & Support',
                ),
                const SizedBox(height: 8),
                _ProfileMenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Log Out',
                  isDestructive: true,
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1D2B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFF8A91A8),
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    this.isDestructive = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? const Color(0xFFE94E92)
        : const Color(0xFF3A3F52);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1D2B),
            ),
          ),
          const Spacer(),
          Text(
            'See all',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFFE94E92),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CHAT TAB ────────────────────────────────────────────────────────────────

class _ChatTab extends StatefulWidget {
  const _ChatTab();

  @override
  State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> {
  static final List<_ChatConversation> _conversations = [
    _ChatConversation(
      name: 'Ali Hassan',
      avatar: 'A',
      lastMessage: 'Is the iPhone 13 still available?',
      time: '2m ago',
      unread: 2,
      online: true,
    ),
    _ChatConversation(
      name: 'Sara Khan',
      avatar: 'S',
      lastMessage: 'Can you do \$80 for the Nike Air Max?',
      time: '15m ago',
      unread: 1,
      online: true,
    ),
    _ChatConversation(
      name: 'Usman Malik',
      avatar: 'U',
      lastMessage: 'Thanks! I\'ll pick it up tomorrow.',
      time: '1h ago',
      unread: 0,
      online: false,
    ),
    _ChatConversation(
      name: 'Fatima Noor',
      avatar: 'F',
      lastMessage: 'Is the desk solid wood?',
      time: '3h ago',
      unread: 0,
      online: false,
    ),
    _ChatConversation(
      name: 'Ahmed Raza',
      avatar: 'R',
      lastMessage: 'Deal! Sending payment now.',
      time: 'Yesterday',
      unread: 0,
      online: true,
    ),
    _ChatConversation(
      name: 'Zainab Shah',
      avatar: 'Z',
      lastMessage: 'Do you ship to Lahore?',
      time: 'Yesterday',
      unread: 3,
      online: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              Text(
                'Messages',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1D2B),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE94E92),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_conversations.where((c) => c.unread > 0).length} new',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Search ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search conversations...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF8A91A8), size: 22),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              filled: true,
              fillColor: const Color(0xFFEDEEF2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ── Conversations ──
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _conversations.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 70),
            itemBuilder: (_, i) {
              final c = _conversations[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: c.unread > 0
                                  ? [const Color(0xFFFF4F69), const Color(0xFFC76FB6)]
                                  : [const Color(0xFFBDC3D4), const Color(0xFF8A91A8)],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              c.avatar,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        if (c.online)
                          Positioned(
                            right: 2,
                            bottom: 2,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    // Message info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  c.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: c.unread > 0 ? FontWeight.w700 : FontWeight.w600,
                                    color: const Color(0xFF1A1D2B),
                                  ),
                                ),
                              ),
                              Text(
                                c.time,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: c.unread > 0
                                      ? const Color(0xFFE94E92)
                                      : const Color(0xFF8A91A8),
                                  fontWeight: c.unread > 0 ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  c.lastMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: c.unread > 0
                                        ? const Color(0xFF3A3F52)
                                        : const Color(0xFF8A91A8),
                                    fontWeight: c.unread > 0 ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ),
                              if (c.unread > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE94E92),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${c.unread}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ChatConversation {
  const _ChatConversation({
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.online,
  });
  final String name;
  final String avatar;
  final String lastMessage;
  final String time;
  final int unread;
  final bool online;
}
