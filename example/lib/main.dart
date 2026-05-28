import 'package:flutter/material.dart';
import 'package:snap_state/snap_state.dart';

// ==========================================================================
// ⚡ SNAPSTATE v1.0.0 — NO BOILERPLATE, NO CONTEXT, NO SETUP
//
// Compare this with BLoC (5+ files) or Riverpod (providers + WidgetRef).
// SnapState: Just declare variables. That's it. Works everywhere.
// ==========================================================================

// ── 1. COUNTER ─────────────────────────────────────────────────────────────
// No Bloc class, no Event, no State, no Provider. Pure Dart variable!
final count = Snap<int>('counter', 0);

void increment() => count.set(count.value + 1);
void decrement() => count.set(count.value - 1);
void reset()     => count.set(0);

// ── 2. Todo LIST ───────────────────────────────────────────────────────────
// Just a list in a Snap. No Cubit, no StateNotifier, no ChangeNotifier.
final todos = Snap<List<String>>('todos', ['Buy groceries', 'Read Flutter docs']);
final newTodoText = Snap<String>('new_todo_text', '');

// Computed: auto-recalculates when 'todos' changes
final todoCount = SnapComputed<int>(
  'todo_count',
  listen: [todos],
  compute: () => todos.value.length,
);

void addTodo() {
  final text = newTodoText.value.trim();
  if (text.isEmpty) return;
  todos.set([...todos.value, text]);
  newTodoText.set('');
}

void removeTodo(int index) {
  final list = List<String>.from(todos.value);
  list.removeAt(index);
  todos.set(list);
}

// ── 3. WEATHER (ASYNC) ─────────────────────────────────────────────────────
// No FutureProvider, no AsyncNotifier, no bloc concurrency packages needed.
// Multi-dependency auto re-run: changes to EITHER city OR unit triggers fetch!
final city = Snap<String>('city', 'Mumbai');
final unit = Snap<String>('unit', 'C');

final weather = SnapAsync<String>(
  'weather',
  listen: [city, unit], // Listens to BOTH! Try this in Riverpod without extra code!
  compute: () async {
    await Future.delayed(const Duration(milliseconds: 700)); // Simulate network
    final c = city.value;
    final u = unit.value;
    final temp = {'Mumbai': 32, 'Delhi': 38, 'London': 15}[c] ?? 25;
    final display = u == 'C' ? '$temp°C' : '${(temp * 9 / 5 + 32).round()}°F';
    return '$c: $display ☀️';
  },
);

// ==========================================================================
// 🎨 UI — Pure StatelessWidgets. No ConsumerWidget, no BlocBuilder wrappers
// ==========================================================================

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SnapState Showcase',
      home: SnapShowcaseApp(),
    ));

class SnapShowcaseApp extends StatelessWidget {
  const SnapShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 24),
              _counterCard(),
              const SizedBox(height: 20),
              _weatherCard(),
              const SizedBox(height: 20),
              _todoCard(),
              const SizedBox(height: 32),
              _footerNote(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⚡ SnapState v1.0.0',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900)),
          SizedBox(height: 6),
          Text('No BlocProvider. No ConsumerWidget. No WidgetRef.\nJust declare a variable. That\'s it.',
              style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  // ── Counter Card ─────────────────────────────────────────────────────────

  Widget _counterCard() {
    return _card(
      title: '🔢 Counter',
      subtitle: 'final count = Snap<int>(\'count\', 0);',
      color: const Color(0xFFEEF2FF),
      accentColor: const Color(0xFF6366F1),
      child: Column(
        children: [
          // SnapCell — Pinpoint rebuild! Only THIS text rebuilds when count changes
          SnapCell(
            builder: (ctx) => Text(
              '${count.value}',
              style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF6366F1)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _iconBtn(icon: Icons.remove, color: const Color(0xFF6366F1), onTap: decrement),
              const SizedBox(width: 12),
              _iconBtn(icon: Icons.refresh, color: Colors.grey, onTap: reset),
              const SizedBox(width: 12),
              _iconBtn(icon: Icons.add, color: const Color(0xFF6366F1), onTap: increment),
            ],
          ),
          const SizedBox(height: 12),
          // SnapComputed demo
          SnapCell(
            builder: (ctx) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: count.value % 2 == 0
                    ? const Color(0xFFD1FAE5)
                    : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                count.value % 2 == 0 ? 'Even Number' : 'Odd Number',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: count.value % 2 == 0
                      ? const Color(0xFF065F46)
                      : const Color(0xFF991B1B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Weather Card ─────────────────────────────────────────────────────────

  Widget _weatherCard() {
    return _card(
      title: '🌦️ Async Weather',
      subtitle: 'SnapAsync — multi-dependency, race-condition safe',
      color: const Color(0xFFFFFBEB),
      accentColor: const Color(0xFFF59E0B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // City selector — SnapCell for inline reading
          SnapCell(
            builder: (ctx) => Wrap(
              spacing: 8,
              children: ['Mumbai', 'Delhi', 'London'].map((c) {
                final isSelected = city.value == c;
                return GestureDetector(
                  onTap: () => city.set(c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFF59E0B)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: Text(c,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFFF59E0B),
                        )),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // Unit toggle
          SnapCell(
            builder: (ctx) => Row(
              children: [
                const Text('Unit: ',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                GestureDetector(
                  onTap: () => unit.set(unit.value == 'C' ? 'F' : 'C'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      unit.value == 'C' ? '°Celsius' : '°Fahrenheit',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // SnapAsyncBuilder — clean loading/error/data states
          SnapAsyncBuilder<String>(
            snap: weather,
            loading: (ctx) => const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFFF59E0B),
                  ),
                ),
                SizedBox(width: 12),
                Text('Fetching weather…',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
            error: (ctx, err) => Text('Error: $err',
                style: const TextStyle(color: Colors.red)),
            data: (ctx, w) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Text(
                w,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF92400E),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Todo Card ─────────────────────────────────────────────────────────────

  Widget _todoCard() {
    final controller = TextEditingController();
    return _card(
      title: '✅ Todo List',
      subtitle: 'SnapComputed auto-tracks count — no setState anywhere!',
      color: const Color(0xFFF0FDF4),
      accentColor: const Color(0xFF10B981),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Count badge
          SnapCell(
            builder: (ctx) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${todoCount.value} tasks',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Todo list — only this SnapCell rebuilds on todos change
          SnapCell(
            builder: (ctx) => Column(
              children: [
                for (int i = 0; i < todos.value.length; i++)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.check_circle,
                        color: Color(0xFF10B981)),
                    title: Text(todos.value[i],
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent),
                      onPressed: () => removeTodo(i),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Add todo input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: (v) => newTodoText.set(v),
                  decoration: InputDecoration(
                    hintText: 'Add new task…',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  addTodo();
                  controller.clear();
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      const Icon(Icons.add, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Footer ───────────────────────────────────────────────────────────────

  Widget _footerNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🆚 vs BLoC / Riverpod',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          SizedBox(height: 10),
          _CompareRow(label: 'Setup', snap: 'Zero config', others: 'BlocProvider / Providers'),
          _CompareRow(label: 'Context needed?', snap: 'Never', others: 'Always (BuildContext / WidgetRef)'),
          _CompareRow(label: 'Code generation', snap: 'None', others: 'Riverpod needs build_runner'),
          _CompareRow(label: 'Async race guard', snap: 'Built-in', others: 'Manual / Extra packages'),
          _CompareRow(label: 'Rebuild scope', snap: 'Pinpoint (Element)', others: 'Bloc/Provider level'),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _card({
    required String title,
    required String subtitle,
    required Widget child,
    required Color color,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 11,
                  color: accentColor,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600)),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _iconBtn(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.4))),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

// ── Compare Table Row ─────────────────────────────────────────────────────

class _CompareRow extends StatelessWidget {
  final String label;
  final String snap;
  final String others;

  const _CompareRow(
      {required this.label, required this.snap, required this.others});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: const TextStyle(
                      color: Color(0xFF94A3B8), fontSize: 12))),
          Expanded(
              flex: 2,
              child: Row(children: [
                const Icon(Icons.check_circle,
                    color: Color(0xFF10B981), size: 14),
                const SizedBox(width: 4),
                Flexible(
                    child: Text(snap,
                        style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w700,
                            fontSize: 12))),
              ])),
          Expanded(
              flex: 3,
              child: Row(children: [
                const Icon(Icons.cancel, color: Color(0xFFF87171), size: 14),
                const SizedBox(width: 4),
                Flexible(
                    child: Text(others,
                        style: const TextStyle(
                            color: Color(0xFFF87171), fontSize: 11))),
              ])),
        ],
      ),
    );
  }
}