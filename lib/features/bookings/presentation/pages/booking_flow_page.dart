import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../temples/domain/entities/temple.dart';
import '../../domain/entities/booking.dart';
import '../providers/bookings_provider.dart';

/// 3-step booking flow: Date → Time Slot → Confirmation.
class BookingFlowPage extends ConsumerStatefulWidget {
  final Temple temple;

  const BookingFlowPage({super.key, required this.temple});

  @override
  ConsumerState<BookingFlowPage> createState() => _BookingFlowPageState();
}

class _BookingFlowPageState extends ConsumerState<BookingFlowPage> {
  int _step = 0;
  DateTime? _selectedDate;
  TimeSlot? _selectedSlot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_step == 2 ? 'Confirm Booking' : 'Book a Visit'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // ── Step Indicator ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                _StepDot(label: 'Date', index: 0, current: _step),
                Expanded(child: _StepLine(active: _step >= 1)),
                _StepDot(label: 'Time', index: 1, current: _step),
                Expanded(child: _StepLine(active: _step >= 2)),
                _StepDot(label: 'Confirm', index: 2, current: _step),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Step Content ───────────────────────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: switch (_step) {
                0 => _DateStep(
                    key: const ValueKey('date'),
                    selectedDate: _selectedDate,
                    onDateSelected: (d) =>
                        setState(() => _selectedDate = d),
                  ),
                1 => _TimeSlotStep(
                    key: const ValueKey('time'),
                    selectedSlot: _selectedSlot,
                    onSlotSelected: (s) =>
                        setState(() => _selectedSlot = s),
                  ),
                2 => _ConfirmStep(
                    key: const ValueKey('confirm'),
                    temple: widget.temple,
                    date: _selectedDate!,
                    slot: _selectedSlot!,
                  ),
                _ => const SizedBox.shrink(),
              },
            ),
          ),
        ],
      ),

      // ── Bottom CTA ──────────────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Row(
            children: [
              if (_step > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _step--),
                    child: const Text('Back'),
                  ),
                ),
              if (_step > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _canProceed ? _onNext : null,
                  child: Text(_step == 2 ? 'Confirm Booking' : 'Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _canProceed => switch (_step) {
        0 => _selectedDate != null,
        1 => _selectedSlot != null,
        2 => true,
        _ => false,
      };

  void _onNext() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      // Create booking
      ref.read(bookingsProvider.notifier).createBooking(
            templeId: widget.temple.id,
            templeName: widget.temple.name,
            templeImageUrl: widget.temple.imageUrl,
            date: _selectedDate!,
            timeSlot: _selectedSlot!,
          );

      // Show success & pop
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: const Text('Booking confirmed! 🙏'),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 3),
          ),
        );
      context.pop();
    }
  }
}

// ── Step 1: Date Picker ──────────────────────────────────────────────────────

class _DateStep extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _DateStep({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Select a date for your visit',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          CalendarDatePicker(
            initialDate: selectedDate ?? now.add(const Duration(days: 1)),
            firstDate: now,
            lastDate: now.add(const Duration(days: 90)),
            onDateChanged: onDateSelected,
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Time Slot ────────────────────────────────────────────────────────

class _TimeSlotStep extends StatelessWidget {
  final TimeSlot? selectedSlot;
  final ValueChanged<TimeSlot> onSlotSelected;

  const _TimeSlotStep({
    super.key,
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Choose a darshan time',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          ...TimeSlot.values.map((slot) {
            final isSelected = slot == selectedSlot;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => onSlotSelected(slot),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.saffron
                          : theme.colorScheme.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected
                        ? AppColors.saffron.withValues(alpha: 0.08)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _iconFor(slot),
                        color: isSelected
                            ? AppColors.saffron
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(slot.displayName,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600)),
                            Text(slot.timeLabel,
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            color: AppColors.saffron),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _iconFor(TimeSlot slot) => switch (slot) {
        TimeSlot.earlyMorning => Icons.wb_twilight,
        TimeSlot.morning => Icons.wb_sunny_outlined,
        TimeSlot.afternoon => Icons.wb_sunny,
        TimeSlot.evening => Icons.wb_cloudy,
        TimeSlot.night => Icons.nights_stay_outlined,
      };
}

// ── Step 3: Confirmation ─────────────────────────────────────────────────────

class _ConfirmStep extends StatelessWidget {
  final Temple temple;
  final DateTime date;
  final TimeSlot slot;

  const _ConfirmStep({
    super.key,
    required this.temple,
    required this.date,
    required this.slot,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(date);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Review your booking',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),

          // Temple card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.colorScheme.surfaceContainerHighest,
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    temple.imageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 64,
                      height: 64,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.temple_hindu),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(temple.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('${temple.city}, ${temple.state}',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _DetailRow(
              icon: Icons.calendar_today, label: 'Date', value: dateStr),
          const SizedBox(height: 14),
          _DetailRow(
              icon: Icons.access_time,
              label: 'Time Slot',
              value: '${slot.displayName} (${slot.timeLabel})'),
          const SizedBox(height: 14),
          _DetailRow(
              icon: Icons.info_outline, label: 'Status', value: 'Confirmed'),

          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.saffron.withValues(alpha: 0.08),
              border: Border.all(
                  color: AppColors.saffron.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppColors.saffron, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You can cancel this booking anytime from the Bookings tab.',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.saffron, height: 1.4),
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            Text(value,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}

// ── Step indicator widgets ────────────────────────────────────────────────────

class _StepDot extends StatelessWidget {
  final String label;
  final int index;
  final int current;

  const _StepDot(
      {required this.label, required this.index, required this.current});

  @override
  Widget build(BuildContext context) {
    final isActive = index <= current;
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.saffron : theme.colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: isActive
                  ? AppColors.saffron
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Center(
            child: index < current
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isActive
                      ? AppColors.saffron
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                )),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool active;
  const _StepLine({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: active
            ? AppColors.saffron
            : Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
