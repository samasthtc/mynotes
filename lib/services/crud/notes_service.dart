import 'package:flutter/material.dart';
import 'package:mynotes/services/crud/crud_constants.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;

class NotesService {
  Database? _db;

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      // create user table
      await db.execute(createUserTable);
      // create note table
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) throw DatabaseIsNotOpen();
    await db.close();
    _db = null;
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) throw DatabaseIsNotOpen();
    return db;
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      userTable,
      where: '$emailColumn = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (deleteCount != 1) throw CouldNotDeleteUser();
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: '$emailColumn = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) throw UserAlreadyExists();

    final userId = await db.insert(
      userTable,
      {emailColumn: email.toLowerCase()},
    );

    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: '$emailColumn = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) throw CouldNotFindUser();

    return DatabaseUser.fromRow(results.first);
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();
    // make sure owner exists in the DB with correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) throw CouldNotFindUser();

    const text = '';
    // create note
    final noteId = await db.insert(
      noteTable,
      {
        textColumn: text,
        userIdColumn: owner.id,
        isSyncedWithCloudColumn: 1,
      },
    );

    return DatabaseNote(
      id: noteId,
      text: text,
      userId: owner.id,
      isSyncedWithCloud: true,
    );
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: '$idColumn = ?',
      whereArgs: [id],
    );

    if (deletedCount == 0) throw CouldNotDeleteNote();
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(noteTable);
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: '$idColumn = ?',
      whereArgs: [id],
    );

    if (notes.isEmpty) throw CouldNotFindNote();

    return DatabaseNote.fromRow(notes.first);
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);
    final updatedCount = await db.update(
      noteTable,
      {
        textColumn: text,
        isSyncedWithCloudColumn: 0,
      },
      where: '$idColumn = ?',
      whereArgs: [note.id],
    );

    if (updatedCount == 0) throw CouldNotUpdateNote();

    return await getNote(id: note.id);
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'User, ID: $id, Email: $email';

  @override
  bool operator ==(covariant DatabaseUser other) => other.id == id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseNote {
  final int id;
  final String text;
  final int userId;
  final bool isSyncedWithCloud;

  const DatabaseNote({
    required this.id,
    required this.text,
    required this.userId,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        text = map[textColumn] as String,
        userId = map[userIdColumn] as int,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() => 'Note, ID: $id, User ID: $userId, '
      'Is Synced With Cloud: $isSyncedWithCloud';

  @override
  bool operator ==(covariant DatabaseNote other) => other.id == id;

  @override
  int get hashCode => id.hashCode;
}
