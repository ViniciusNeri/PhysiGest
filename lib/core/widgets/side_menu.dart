import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:physigest/core/theme/app_theme.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  Icon(
                    Icons.monitor_heart,
                    size: 64,
                    color: AppTheme.primaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'PhysiGest',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            _MenuTile(
              icon: Icons.dashboard_outlined,
              title: 'Início',
              iconColor: AppTheme.primaryColor,
              onTap: () {
                context.go('/');
              },
            ),
            _MenuTile(
              icon: Icons.calendar_month_outlined,
              title: 'Agenda',
              iconColor: Colors.blue,
              onTap: () {
                context.go('/schedule');
              },
            ),
            _MenuTile(
              icon: Icons.people_outline,
              title: 'Pacientes',
              iconColor: Colors.green,
              onTap: () {
                context.go('/patients');
              },
            ),
            _MenuTile(
              icon: Icons.attach_money_outlined,
              title: 'Financeiro',
              iconColor: Colors.orange,
               onTap: () {
                context.go('/financial');
              },
            ),
            _MenuTile(
              icon: Icons.fitness_center_outlined,
              title: 'Exercícios e Planos',
              iconColor: Colors.purple,
              onTap: () {},
            ),
            _MenuTile(
              icon: Icons.settings_outlined,
              title: 'Configurações',
              iconColor: Colors.grey.shade700,
              onTap: () {},
            ),
            const Spacer(),
            const Divider(),
            _MenuTile(
              icon: Icons.exit_to_app,
              title: 'Sair',
              onTap: () {
                context.go('/login');
              },
              isDestructive: true,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
  final Color? iconColor;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : (iconColor ?? Colors.grey.shade700),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
