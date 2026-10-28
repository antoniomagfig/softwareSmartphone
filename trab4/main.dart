import 'dart:convert';
import 'dart:io';

const String baseUrl = 'https://barra.cos.ufrj.br/rest';

const String nome = 'Tom';
const String email = 'tom@email.com';
const String senha = 'senha123';

Future<void> main() async {
  final client = HttpClient();

  try {
    await registraUsuario(client);

    final token = await fazerLogin(client);

    await garanteListaVazia(client, token);

    print(token);
  } catch (e) {
    stderr.writeln('Erro: $e');
    exit(1);
  } finally {
    client.close(force: true);
  }
}

Future<void> registraUsuario(HttpClient client) async {
  final uri = Uri.parse('$baseUrl/rpc/registra_usuario');
  final request = await client.postUrl(uri);
  request.headers.set('Content-Type', 'application/json');
  request.write(jsonEncode({
    'nome': nome,
    'email': email,
    'senha': senha,
  }));

  final response = await request.close();
  final body = await response.transform(utf8.decoder).join();

  if (response.statusCode == 200) {
    stderr.writeln('Usuário cadastrado com sucesso.');
    return;
  }

  if (response.statusCode == 400) {
    Map<String, dynamic>? decoded;
    try {
      decoded = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      decoded = null;
    }
    final message = decoded != null ? decoded['message'] : null;
    if (message == 'O email já está em uso') {
      stderr.writeln('Email já cadastrado, prosseguindo para o login.');
      return;
    }
  }

  throw Exception(
      'Falha ao registrar usuário. Status ${response.statusCode}: $body');
}

Future<String> fazerLogin(HttpClient client) async {
  final uri = Uri.parse('$baseUrl/rpc/fazer_login');
  final request = await client.postUrl(uri);
  request.headers.set('Content-Type', 'application/json');
  request.write(jsonEncode({
    'email': email,
    'senha': senha,
  }));

  final response = await request.close();
  final body = await response.transform(utf8.decoder).join();

  if (response.statusCode != 200) {
    throw Exception('Falha ao fazer login. Status ${response.statusCode}: $body');
  }

  final decoded = jsonDecode(body) as Map<String, dynamic>;
  final token = decoded['token'];
  if (token == null || token is! String) {
    throw Exception('Resposta de login sem token: $body');
  }

  stderr.writeln('Login realizado com sucesso.');
  return token;
}

Future<void> garanteListaVazia(HttpClient client, String token) async {
  // GET /tarefas
  final getUri = Uri.parse('$baseUrl/tarefas');
  final getRequest = await client.getUrl(getUri);
  getRequest.headers.set('Authorization', 'Bearer $token');

  final getResponse = await getRequest.close();
  final getBody = await getResponse.transform(utf8.decoder).join();

  if (getResponse.statusCode != 200) {
    throw Exception(
        'Falha ao consultar tarefas. Status ${getResponse.statusCode}: $getBody');
  }

  final decoded = jsonDecode(getBody);
  if (decoded is! List) {
    throw Exception('Resposta inesperada de GET /tarefas: $getBody');
  }

  if (decoded.isEmpty) {
    await criaLista(client, token);
  } else {
    await esvaziaLista(client, token);
  }
}

Future<void> criaLista(HttpClient client, String token) async {
  final uri = Uri.parse('$baseUrl/tarefas');
  final request = await client.postUrl(uri);
  request.headers.set('Authorization', 'Bearer $token');
  request.headers.set('Content-Type', 'application/json');
  request.write(jsonEncode({
    'email': email,
    'valor': [],
  }));

  final response = await request.close();
  final body = await response.transform(utf8.decoder).join();

  if (response.statusCode != 201 && response.statusCode != 200) {
    throw Exception(
        'Falha ao criar lista de tarefas. Status ${response.statusCode}: $body');
  }

  stderr.writeln('Lista de tarefas criada (vazia).');
}

Future<void> esvaziaLista(HttpClient client, String token) async {
  final uri = Uri.parse('$baseUrl/tarefas')
      .replace(queryParameters: {'email': 'eq.$email'});
  final request = await client.patchUrl(uri);
  request.headers.set('Authorization', 'Bearer $token');
  request.headers.set('Content-Type', 'application/json');
  request.write(jsonEncode({
    'valor': [],
  }));

  final response = await request.close();
  final body = await response.transform(utf8.decoder).join();

  if (response.statusCode != 204 && response.statusCode != 200) {
    throw Exception(
        'Falha ao esvaziar lista de tarefas. Status ${response.statusCode}: $body');
  }

  stderr.writeln('Lista de tarefas esvaziada.');
}