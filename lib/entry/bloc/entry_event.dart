part of 'entry_bloc.dart';

sealed class EntryEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

/// The screen opened, or the user retried: show the loading state and read
/// the entry.
final class EntryStarted extends EntryEvent {
  const new();
}

/// The entry may have changed, for instance after editing it: read it again
/// without showing the loading state.
final class EntryRefreshed extends EntryEvent {
  const new();
}

/// The user confirmed deleting the entry.
final class EntryDeleted extends EntryEvent {
  const new();
}
