import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:terse/history/history.dart';
import 'package:terse/l10n/l10n.dart';

/// The days of the shown month, one dot for each, in rows of seven.
///
/// A day with an entry can be tapped. Days with nothing logged and days in the
/// future cannot.
class MonthGrid extends StatelessWidget {
  const new({required this.state, this.onDayTap, super.key});

  final HistoryState state;

  /// Called with a day that has an entry. Without it no day can be tapped.
  final ValueChanged<DateTime>? onDayTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final material = MaterialLocalizations.of(context);
    final month = state.month!;

    // The column of the first day, counting from the first day of the week.
    final firstColumn =
        (month.weekday % 7 - material.firstDayOfWeekIndex + 7) % 7;
    final dayCount = DateTime(month.year, month.month + 1, 0).day;

    return Column(
      children: [
        Row(
          children: [
            for (var column = 0; column < 7; column++)
              Expanded(
                child: Center(
                  child: Text(
                    material.narrowWeekdays[(material.firstDayOfWeekIndex +
                            column) %
                        7],
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (var blank = 0; blank < firstColumn; blank++)
              const SizedBox.shrink(),
            for (var number = 1; number <= dayCount; number++)
              _cell(context, DateTime(month.year, month.month, number)),
          ],
        ),
      ],
    );
  }

  Widget _cell(BuildContext context, DateTime day) {
    final l10n = context.l10n;
    final coverage = state.coverageOf(day);
    final locale = Localizations.localeOf(context).toString();

    return _DayCell(
      day: day,
      coverage: coverage,
      isToday: day == state.today,
      isFuture: day.isAfter(state.today!),
      description: DateFormat.MMMMd(locale).format(day),
      todayLabel: l10n.historyToday,
      coverageLabel: switch (coverage) {
        DayCoverage.all => l10n.historyLegendAll,
        DayCoverage.some => l10n.historyLegendSome,
        DayCoverage.none => l10n.historyDayNone,
      },
      onTap: onDayTap,
    );
  }
}

class _DayCell extends StatelessWidget {
  const new({
    required this.day,
    required this.coverage,
    required this.isToday,
    required this.isFuture,
    required this.description,
    required this.todayLabel,
    required this.coverageLabel,
    required this.onTap,
  });

  final DateTime day;
  final DayCoverage coverage;
  final bool isToday;
  final bool isFuture;
  final String description;
  final String todayLabel;
  final String coverageLabel;
  final ValueChanged<DateTime>? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tappable = onTap != null && coverage != DayCoverage.none && !isFuture;
    final (Color? fill, Color text) = switch (coverage) {
      DayCoverage.all => (scheme.primary, scheme.onPrimary),
      DayCoverage.some => (scheme.primaryContainer, scheme.onPrimaryContainer),
      DayCoverage.none => (null, isFuture ? scheme.outline : scheme.onSurface),
    };

    return Center(
      child: Semantics(
        button: tappable,
        excludeSemantics: true,
        label: [description, coverageLabel, if (isToday) todayLabel].join(', '),
        child: InkResponse(
          onTap: tappable ? () => onTap!(day) : null,
          customBorder: const CircleBorder(),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: fill,
              shape: BoxShape.circle,
              border: isToday
                  ? Border.all(color: scheme.primary, width: 1.5)
                  : null,
            ),
            child: Text(
              '${day.day}',
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: text),
            ),
          ),
        ),
      ),
    );
  }
}
