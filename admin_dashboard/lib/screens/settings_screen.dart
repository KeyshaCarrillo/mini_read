import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/admin_controller.dart';
import '../controllers/auth_controller.dart';
import '../core/constants.dart';
import '../core/formatters.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    final auth = context.watch<AuthController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Configuracion',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 880;
            final cards = [
              _SettingsCard(
                title: 'Sesion administrativa',
                icon: Icons.admin_panel_settings_rounded,
                children: [
                  _KeyValue(label: 'Usuario', value: auth.displayName),
                  _KeyValue(label: 'Rol', value: auth.role),
                  _KeyValue(
                    label: 'Estado',
                    value: auth.status == AuthStatus.signedIn
                        ? 'Acceso verificado'
                        : 'Pendiente',
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: context.read<AuthController>().signOut,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Cerrar sesion'),
                  ),
                ],
              ),
              _SettingsCard(
                title: 'Preferencias del panel',
                icon: Icons.tune_rounded,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Dark Mode'),
                    subtitle: const Text(
                      'Replica el soporte darkMode del prototipo Stitch.',
                    ),
                    value: admin.isDarkMode,
                    onChanged: admin.toggleDarkMode,
                  ),
                  const Divider(),
                  _KeyValue(
                    label: 'Base URL',
                    value: 'https://book-api-nu-six.vercel.app',
                  ),
                  _KeyValue(
                    label: 'Libros cargados',
                    value: '${admin.books.length}',
                  ),
                  _KeyValue(
                    label: 'Usuarios cargados',
                    value: '${admin.users.length}',
                  ),
                ],
              ),
            ];

            if (stacked) {
              return Column(
                children: [
                  for (final card in cards)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: card,
                    ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  Expanded(child: cards[i]),
                  if (i != cards.length - 1) const SizedBox(width: 24),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.psychology_alt_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Historial de Consultas de IA',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (admin.iaChats.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('No hay consultas de IA registradas.'),
                    ),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Pregunta')),
                        DataColumn(label: Text('Libro')),
                        DataColumn(label: Text('Usuario')),
                        DataColumn(label: Text('Fecha')),
                      ],
                      rows: [
                        for (final chat in admin.iaChats.take(20))
                          DataRow(
                            cells: [
                              DataCell(
                                SizedBox(
                                  width: 360,
                                  child: Text(
                                    chat.question.isEmpty
                                        ? 'Pregunta sin texto'
                                        : chat.question,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(chat.bookId.isEmpty ? 'N/A' : chat.bookId),
                              ),
                              DataCell(Text(chat.uid)),
                              DataCell(Text(formatDateTime(chat.createdAt))),
                            ],
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  final String label;
  final String value;

  const _KeyValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}
