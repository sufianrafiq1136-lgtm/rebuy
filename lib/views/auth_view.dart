import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'shared_widgets.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  bool _isSignup = false;

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
              child: _isSignup
                  ? _SignupForm(onSwitchToLogin: () => setState(() => _isSignup = false))
                  : _LoginForm(onSwitchToSignup: () => setState(() => _isSignup = true)),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  final VoidCallback onSwitchToSignup;
  const _LoginForm({required this.onSwitchToSignup});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailCtrl;
  late TextEditingController _passCtrl;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController();
    _passCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      return 'Invalid email format';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) return 'Password is required';
    if (value!.length < 8) return 'At least 8 characters';
    return null;
  }

  void _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.login(_emailCtrl.text.trim(), _passCtrl.text);

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.error ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Spacer(),
              Text('ReBuy', style: theme.textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 32),
          Text('Log in', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 32)),
          const SizedBox(height: 8),
          Text('Sign in to your account', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF666D80))),
          const SizedBox(height: 28),
          CustomField(controller: _emailCtrl, hint: 'Email', validator: _validateEmail),
          const SizedBox(height: 14),
          CustomField(
            controller: _passCtrl,
            hint: 'Password',
            obscure: true,
            validator: _validatePassword,
          ),
          const SizedBox(height: 28),
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, _) => GradientButton(
              label: authViewModel.isLoading ? 'Logging in...' : 'Log in',
              onPressed: authViewModel.isLoading ? null : _submit,
              isLoading: authViewModel.isLoading,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account? ", style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF707792))),
              TextButton(
                onPressed: widget.onSwitchToSignup,
                child: Text('Sign up', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFFE94E92), fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignupForm extends StatefulWidget {
  final VoidCallback onSwitchToLogin;
  const _SignupForm({required this.onSwitchToLogin});

  @override
  State<_SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<_SignupForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _passCtrl;
  late TextEditingController _confirmCtrl;

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

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Full name is required';
    if (name.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      return 'Invalid email format';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) return 'Password is required';
    if (value!.length < 8) return 'At least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Must contain uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Must contain lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Must contain a number';
    return null;
  }

  String? _validateConfirm(String? value) {
    if ((value ?? '').isEmpty) return 'Confirm password is required';
    if (value != _passCtrl.text) return 'Passwords do not match';
    return null;
  }

  void _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.signup(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text);

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.error ?? 'Signup failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              InkWell(
                onTap: widget.onSwitchToLogin,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFDADCE2))),
                  child: const Icon(Icons.arrow_back_ios_new, size: 14),
                ),
              ),
              const Spacer(),
              Text('ReBuy', style: theme.textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 32),
          Text('Sign up', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 32)),
          const SizedBox(height: 28),
          CustomField(controller: _nameCtrl, hint: 'Full name', validator: _validateName),
          const SizedBox(height: 14),
          CustomField(controller: _emailCtrl, hint: 'Email', validator: _validateEmail),
          const SizedBox(height: 14),
          CustomField(controller: _passCtrl, hint: 'Password', obscure: true, validator: _validatePassword),
          const SizedBox(height: 14),
          CustomField(controller: _confirmCtrl, hint: 'Confirm password', obscure: true, validator: _validateConfirm),
          const SizedBox(height: 28),
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, _) => GradientButton(
              label: authViewModel.isLoading ? 'Creating account...' : 'Create account',
              onPressed: authViewModel.isLoading ? null : _submit,
              isLoading: authViewModel.isLoading,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Already have an account? ', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF707792))),
              TextButton(
                onPressed: widget.onSwitchToLogin,
                child: Text('Log in', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFFE94E92), fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
