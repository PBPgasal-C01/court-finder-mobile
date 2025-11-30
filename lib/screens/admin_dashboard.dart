import 'dart:convert';
import 'package:court_finder_mobile/models/user_entry.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late Future<List<UserEntry>> futureUsers;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    futureUsers = fetchUsers(request);
  }

  // ===================== FETCH USERS =====================
  Future<List<UserEntry>> fetchUsers(CookieRequest request) async {
    final response = await request.get(
      "http://127.0.0.1:8000/auth/all-users",
    );
    List<UserEntry> users = [];

    for (var d in response) {
      users.add(UserEntry.fromJson(d));
    }

    return users;
  }

  // ===================== BAN / UNBAN =====================
  Future<void> _banUser(String email) async {
    final request = context.read<CookieRequest>();

    final res = await request.postJson(
      "http://127.0.0.1:8000/auth/ban-user",
      jsonEncode({"email": email}),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(res["message"])));

    setState(() {
      futureUsers = fetchUsers(request);
    });
  }

  // ===================== DELETE =====================
  Future<void> _deleteUser(String email) async {
    final request = context.read<CookieRequest>();

    final res = await request.postJson(
      "http://127.0.0.1:8000/auth/delete-user",
      jsonEncode({"email": email}),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(res["message"])));

    setState(() {
      futureUsers = fetchUsers(request);
    });
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF3F6E48);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Manage Users"), backgroundColor: green),

      body: FutureBuilder(
        future: futureUsers,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildTableHeader(),
              ...users.map((user) => _buildUserRow(user)).toList(),
            ],
          );
        },
      ),
    );
  }

  // ===================== TABLE HEADER =====================
  Widget _buildTableHeader() {
    const green = Color(0xFF6CA06E);

    return Container(
      decoration: BoxDecoration(
        color: green,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: const Row(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                "NAME",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                "EMAIL",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                "JOINED",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                "STATUS",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                "ACTIONS",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== USER ROW =====================
  Widget _buildUserRow(UserEntry user) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(user.username)),
          Expanded(flex: 3, child: Text(user.email)),
          Expanded(flex: 2, child: Text(user.dateJoined)),

          // STATUS BADGE
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: user.isActive
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.isActive ? "Active" : "Banned",
                  style: TextStyle(
                    color: user.isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // ACTION BUTTONS
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // BAN / UNBAN BUTTON
                GestureDetector(
                  onTap: () => _banUser(user.email),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.brown.shade400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      user.isActive ? "Ban" : "Unban",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                // DELETE BUTTON
                GestureDetector(
                  onTap: () => _deleteUser(user.email),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
