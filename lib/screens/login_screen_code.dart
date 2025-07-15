import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';

class LoginScreenCode extends StatefulWidget {
  const LoginScreenCode({super.key});

  @override
  State<LoginScreenCode> createState() => _LoginScreenCodeState();
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

class _LoginScreenCodeState extends State<LoginScreenCode> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final FocusNode _eventCodeFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _eventCodeFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _eventCodeFocusNode.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        await AuthService.loginCode(_codeController.text.trim());
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.manual,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 190),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurpleAccent.withOpacity(0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 16,
                                    ),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: Colors.white10),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: const [
                                            Icon(Icons.login, color: Colors.white, size: 24),
                                            SizedBox(width: 8),
                                            Text(
                                              'Login',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 19,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Image.asset(
                                          'assets/logo2.png',
                                          height: 46,
                                          fit: BoxFit.contain,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: _codeController,
                                          focusNode: _eventCodeFocusNode,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            labelText: 'Event Code',
                                            labelStyle: const TextStyle(color: Colors.white),
                                            enabledBorder: UnderlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 16,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Digite o código do evento';
                                            }
                                            if (value.contains(' ')) {
                                              return 'O código não pode conter espaços';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 18),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            _isLoading
                                                ? const SizedBox(
                                                    width: 28,
                                                    height: 28,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 3,
                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                                                    ),
                                                  )
                                                : Container(
                                                    decoration: const BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(color: Colors.white, width: 1),
                                                      ),
                                                    ),
                                                    child: ElevatedButton(
                                                      onPressed: _handleLogin,
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.transparent,
                                                        shadowColor: Colors.transparent,
                                                        elevation: 0,
                                                        padding: const EdgeInsets.only(top: 4, bottom: 0),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: const [
                                                          Icon(Icons.login, color: Colors.white),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            'Login',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.w600,
                                                              fontSize: 18,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                          SizedBox(width: 6),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 42),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xFF070707), Colors.black],
                              ),
                              border: Border.all(color: Colors.white10),
                              color: const Color.fromARGB(255, 47, 47, 47),
                              borderRadius: const BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.info_outline, color: Colors.white30, size: 32),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'O código do evento é fornecido por um representante da digitalgarage.com.br após a configuração do evento.',
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(color: Colors.white30, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xFF070707), Colors.black],
                              ),
                              border: Border.all(color: Colors.white10),
                              color: const Color.fromARGB(255, 47, 47, 47),
                              borderRadius: const BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.support_agent_outlined, color: Colors.white30, size: 32),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Instagram: @digitalgarage.com.br\nEmail: support@digitalgarage.com.br',
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(color: Colors.white30, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
