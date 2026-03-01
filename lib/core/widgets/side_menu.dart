import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:physigest/core/theme/app_theme.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _MenuTile(
                      icon: Icons.grid_view_rounded,
                      title: 'Início',
                      baseColor: Colors.indigo, // Cor do ícone
                      isSelected: location == '/',
                      onTap: () => context.go('/'),
                    ),
                    _MenuTile(
                      icon: Icons.calendar_today_rounded,
                      title: 'Agenda',
                      baseColor: Colors.blue, 
                      isSelected: location.startsWith('/schedule'),
                      onTap: () => context.go('/schedule'),
                    ),
                    _MenuTile(
                      icon: Icons.people_alt_rounded,
                      title: 'Pacientes',
                      baseColor: Colors.teal,
                      isSelected: location.startsWith('/patients'),
                      onTap: () => context.go('/patients'),
                    ),
                    _MenuTile(
                      icon: Icons.payments_rounded,
                      title: 'Financeiro',
                      baseColor: Colors.orange,
                      isSelected: location.startsWith('/financial'),
                      onTap: () => context.go('/financial'),
                    ),
                    _MenuTile(
                      icon: Icons.fitness_center_rounded,
                      title: 'Exercícios',
                      baseColor: Colors.purple,
                      isSelected: false,
                      onTap: () {},
                    ),
                    const Spacer(),
                    _MenuTile(
                      icon: Icons.settings_rounded,
                      title: 'Configurações',
                      baseColor: Colors.blueGrey,
                      isSelected: false,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: const Icon(Icons.monitor_heart_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          const Text(
            'PhysiGest',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: _MenuTile(
        icon: Icons.logout_rounded,
        title: 'Sair da conta',
        baseColor: Colors.red,
        isSelected: false,
        isDestructive: true,
        onTap: () => context.go('/login'),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color baseColor; // Nova cor obrigatória
  final bool isSelected;
  final bool isDestructive;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.baseColor,
    this.isSelected = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = isDestructive ? Colors.red.shade600 : baseColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? effectiveColor.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Ícone com fundo colorido sutil
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? effectiveColor.withOpacity(0.12) 
                      : effectiveColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: effectiveColor,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? effectiveColor : const Color(0xFF475569),
                ),
              ),
              if (isSelected) const Spacer(),
              if (isSelected)
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: effectiveColor,
                    shape: BoxShape.circle,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}