// lib/home_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../auth/presentation/login_page.dart';
import 'grocery_page.dart';
import 'recipe_page.dart';
import 'meal_plan_page.dart';
import 'expense_page.dart';
import 'ai_chat_page.dart';
import 'package:hello/shared_list_page.dart';
import 'family_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const GroceryPage(),
    const RecipePage(),
    const MealPlanPage(),
    const ExpensePage(),
    const AIChatPage(),
    const SharedListPage(),
    const FamilyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[700],
        title: Builder(builder: (context) {
          final user = FirebaseAuth.instance.currentUser;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'KitchenCraft',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (user?.email != null)
                Text(user!.email!, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ],
          );
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Sign out')),
                  ],
                ),
              );
              if (confirm == true) {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/food_wallpaper.jpg'), // Use your downloaded image
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3), // Semi-transparent overlay
              BlendMode.dstATop,
            ),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange[400]!.withOpacity(0.7), Colors.brown[100]!.withOpacity(0.7)],
            stops: const [0.0, 1.0],
          ),
        ),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Grocery'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Recipes'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Meal Plan'),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Expenses'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'AI Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Shared List'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Family'),
        ],
        selectedItemColor: Colors.orange[700],
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white.withOpacity(0.9),
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
    );
  }
}

// Enhanced placeholder page with kitchen/food theme
class KitchenPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String imageAsset;

  const KitchenPage({
    required this.title,
    required this.icon,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imageAsset),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3),
            BlendMode.dstATop,
          ),
        ),
      ),
      child: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white.withOpacity(0.9),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 80,
                  color: Colors.orange[700],
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[900],
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Explore $title Features',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Coming Soon!',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.orange,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}