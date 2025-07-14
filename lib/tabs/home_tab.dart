import 'package:digitalgarage_futter/services/auth_service.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  final List<String> scannedCodes;
  final VoidCallback onClearLast;

  const HomeTab({
    super.key,
    required this.scannedCodes,
    required this.onClearLast,
  });

  @override
  Widget build(BuildContext context) {
    // final lastCode = scannedCodes.isNotEmpty ? scannedCodes.last : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 110,
        leadingWidth: 130,
        leading: Padding(
          padding: const EdgeInsets.only(left: 26.0),
          child: Image.asset('assets/logo.png', fit: BoxFit.contain),
        ),
        title: const Text(''), // leave empty or use Spacer
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 26.0),
            child: IconButton(
              onPressed: () async {
                await AuthService.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF070707), Colors.black],
            ),
            border: Border(bottom: BorderSide(color: Colors.white10)),
          ),
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          // gradient: LinearGradient(
          //   begin: Alignment.centerLeft,
          //   end: Alignment.centerRight,
          //   colors: [Color(0xFF070707), Colors.black],
          // ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              Container(
                  padding: const EdgeInsets.only(
                    top: 20,
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [
                        Color.fromARGB(255, 255, 209, 71),
                        const Color.fromARGB(255, 222, 6, 193),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.festival_outlined,
                        size: 30,
                        color: Colors.white,
                      ),
                      Text(
                        'Eventos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Righteous',
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white60
                    ),
                    child: Text('Arraia JDM Experience', style: (TextStyle(color: Colors.white))),
                  )
                ],
              )
            ],
          ),
          )
        ),
      ),
    );
  }
}
