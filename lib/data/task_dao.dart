import 'package:flutterprojects/data/database.dart';
import 'package:sqflite/sqflite.dart';

import '../components/task.dart';

class TaskDao {
  /*O async determina que um método será assíncrono, ou seja, não irá retornar algo imediatamente, então o aplicativo pode continuar a execução de outras tarefas enquanto o processamento não é finalizado.

  O await serve para determinar que o aplicativo deve esperar uma resposta de uma função antes de continuar a execução. Isso é muito importante pois há casos em que uma função depende do retorno de outra.

  Já o Future determina que uma função irá retornar algo no “futuro”, ou seja, é uma função que levará um tempo até ser finalizada.*/

  //Creating Database
  static const String tableSql = 'CREATE TABLE $_tablename('
      '$_name TEXT, '
      '$_difficulty INTEGER, '
      '$_image TEXT)';

  //Associating/binding the database to the data application
  static const String _tablename = 'taskTable';
  static const String _name = 'name';
  static const String _difficulty = 'difficulty';
  static const String _image = 'image';

  save(Task task) async {
    print('Starting the save: ');
    //Criando banco de dados
    final Database database = await getDatabase();

    //Veriavel que vai verificar se ja existe
    var itemExists = await find(task.name);

    //Transformando a tarefa em um mapa
    Map<String, dynamic> taskMap = toMap(task);

    //se não existe ele insere, se ja existe ela verifica onde estava e altera os valores
    if (itemExists.isEmpty) {
      print('The task does not exists: ');
      return await database.insert(_tablename, taskMap);
    } else {
      print('The task already exists: ');
      return await database.update(_tablename, taskMap,
          where: '$_name = ?', whereArgs: [task.name]);
    }
  }

  //Reponsavel por tranformar uma tarefa em mapa, pra poder inserir no banco de dados
  Map<String, dynamic> toMap(Task task) {
    print('Converting task in map: ');
    final Map<String, dynamic> taskMap = Map();
    taskMap[_name] = task.name;
    taskMap[_difficulty] = task.difficulty;
    taskMap[_image] = task.picture;
    print('Our Task Map is: $taskMap');
    return taskMap;
  }

  //busca todas as tarefas existentes no banco de dados e tranforma em uma lista de tarefas
  Future<List<Task>> findAll() async {
    print('Access findAll: ');
    final Database database = await getDatabase();
    final List<Map<String, dynamic>> result = await database.query(_tablename);
    print('Searching data in database... found: $result');
    return toList(result);
  }

  //Pega um mapa do banco de dados e trasforma em uma lista de tarefas
  List<Task> toList(List<Map<String, dynamic>> taskMap) {
    print('Converting toList: ');
    final List<Task> tasks = [];
    for (Map<String, dynamic> line in taskMap) {
      final Task task = Task(line[_name], line[_image], line[_difficulty]);
      tasks.add(task);
    }
    print('Task List $tasks');
    return tasks;
  }

  //procura uma tarefa especifica no database
  Future<List<Task>> find(String taskName) async {
    print('Access find: ');
    final Database database = await getDatabase();
    final List<Map<String, dynamic>> result = await database.query(
      _tablename,
      where: '$_name = ?',
      whereArgs: [taskName],
    );
    print('Task found: ${toList(result)}');
    return toList(result);
  }

  delete(String taskName) async {
    print('Deleting task: $taskName');
    final Database database = await getDatabase();
    return database.delete(
      _tablename,
      where: '$_name = ?',
      whereArgs: [taskName],
    );
  }
}
