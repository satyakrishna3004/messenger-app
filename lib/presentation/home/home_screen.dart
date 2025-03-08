import 'package:flutter/material.dart';
import 'package:messenger_app/data/repositories/contact_repository.dart';
import 'package:messenger_app/data/services/service_locator.dart';
import 'package:messenger_app/logic/cubits/auth/auth_cubit.dart';
import 'package:messenger_app/presentation/screens/auth/login_screen.dart';
import 'package:messenger_app/router/app_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ContactRepository _contactRepository;
  @override
  void initState() {
    _contactRepository = getIt<ContactRepository>();
    super.initState();
  }

  void _showContactsList(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Contacts',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: _contactRepository.getRegisteredContacts(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text("Error: ${snapshot.error}"),
                            );
                          }
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final contacts = snapshot.data!;
                          if (contacts.isEmpty) {
                            return Center(
                              child: Text("No contacts found"),
                            );
                          }
                          return ListView.builder(
                              itemCount: contacts.length,
                              itemBuilder: (context, index) {
                                final contact = contacts[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    child:
                                        Text(contact["name"][0].toUpperCase()),
                                  ),
                                  title: Text(contact["name"]),
                                );
                              });
                        }),
                  )
                ],
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
        actions: [
          InkWell(
              onTap: () async {
                await getIt<AuthCubit>().signOut();
                getIt<AppRouter>().pushAndRemoveUntil(LoginScreen());
              },
              child: Icon(Icons.logout)),
        ],
      ),
      body: Center(
        child: Text('User is AUTHENTICATED'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactsList(context),
        child: Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}
