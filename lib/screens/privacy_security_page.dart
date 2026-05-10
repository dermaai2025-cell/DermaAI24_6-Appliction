import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Resetpasswod_screen.dart';
import 'privacy_policy_screen.dart';
import 'login_screen.dart';
import 'delete_data_screen.dart';

class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Privacy & Security",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            /// TOP CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),

              child: Row(
                children: const [

                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xffEAF2FF),

                    child: Icon(
                      Icons.lock_outline,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),

                  SizedBox(width: 15),

                  Expanded(
                    child: Text(
                      "Your medical scans and personal information are safely protected.",

                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// CHANGE PASSWORD
            GestureDetector(
              onTap: () {

                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        const ResetPasswordScreen(),
                  ),
                );
              },

              child: _buildTile(
                icon: Icons.password,
                title: "Change Password",
              ),
            ),

            /// PRIVACY POLICY
            GestureDetector(
              onTap: () {

                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        const PrivacyPolicyScreen(),
                  ),
                );
              },

              child: _buildTile(
                icon: Icons.privacy_tip_outlined,
                title: "Privacy Policy",
              ),
            ),

            /// DELETE DATA
            GestureDetector(
              onTap: () {

                showDialog(
                  context: context,

                  builder: (_) => AlertDialog(

                    title: const Text(
                      "Warning",
                    ),

                    content: const Text(
                      "Deleting your data will permanently remove scans, monitors, and chats. This action cannot be undone.",
                    ),

                    actions: [

                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },

                        child: const Text(
                          "Cancel",
                        ),
                      ),

                      TextButton(
                        onPressed: () {

                          Navigator.pop(context);

                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) =>
                                  const DeleteDataScreen(),
                            ),
                          );
                        },

                        child: const Text(
                          "Continue",

                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },

              child: _buildTile(
                icon: Icons.delete_outline,
                title: "Delete My Data",
                color: Colors.red,
              ),
            ),

            const Spacer(),

            /// BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),

                onPressed: () {},

                child: const Text(
                  "Save Changes",

                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    Color color = Colors.black,
  }) {

    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: [

          Icon(
            icon,
            color: color,
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Text(
              title,

              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18,
          ),
        ],
      ),
    );
  }
}