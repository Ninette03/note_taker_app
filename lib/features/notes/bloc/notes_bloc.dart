import 'package:bloc/bloc.dart';
import 'package:note_taker_app/data/models/note_model.dart';
import 'package:note_taker_app/data/repositories/note_respository.dart';

abstract class NotesEvent {}
class NotesFetchRequested extends NotesEvent {}
class NoteAddRequested extends NotesEvent {
  final String text;
  NoteAddRequested(this.text);
}
class NoteUpdateRequested extends NotesEvent {
  final String id;
  final String text;
  NoteUpdateRequested(this.id, this.text);
}
class NoteDeleteRequested extends NotesEvent {
  final String id;
  NoteDeleteRequested(this.id);
}

abstract class NotesState {}
class NotesInitial extends NotesState {}
class NotesLoading extends NotesState {}
class NotesLoaded extends NotesState {
  final List<NoteModel> notes;
  NotesLoaded(this.notes);
}
class NotesOperationSuccess extends NotesState {
  final String message;
  NotesOperationSuccess(this.message);
}
class NotesError extends NotesState {
  final String error;
  NotesError(this.error);
}

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NoteRepository _noteRepository;
  
  NotesBloc(this._noteRepository) : super(NotesInitial()) {
    on<NotesFetchRequested>(_onNotesFetchRequested);
    on<NoteAddRequested>(_onNoteAddRequested);
    on<NoteUpdateRequested>(_onNoteUpdateRequested);
    on<NoteDeleteRequested>(_onNoteDeleteRequested);
  }

  Future<void> _onNotesFetchRequested(
    NotesFetchRequested event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading());
    try {
      final notes = await _noteRepository.fetchNotes();
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onNoteAddRequested(
    NoteAddRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _noteRepository.addNote(event.text);
      emit(NotesOperationSuccess('Note added successfully'));
      add(NotesFetchRequested());
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onNoteUpdateRequested(
    NoteUpdateRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _noteRepository.updateNote(event.id, event.text);
      emit(NotesOperationSuccess('Note updated successfully'));
      add(NotesFetchRequested());
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onNoteDeleteRequested(
    NoteDeleteRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _noteRepository.deleteNote(event.id);
      emit(NotesOperationSuccess('Note deleted successfully'));
      add(NotesFetchRequested());
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }
}