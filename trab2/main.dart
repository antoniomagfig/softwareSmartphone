import 'dart:io';

void main() {
  int? a;
  int? b;

  while (a == null || b == null) {
    stdout.write('a: ');
    String? inputA = stdin.readLineSync();
    stdout.write('b: ');
    String? inputB = stdin.readLineSync();

    if (inputA != null && inputB != null) {
      a = int.tryParse(inputA);
      b = int.tryParse(inputB);
    }

    if (a == null || b == null) {
      print('Entrada inválida.\n');
    }
  }

    print('');

  int inicio = a < b ? a : b;
  int fim = a < b ? b : a;

  List<int> perfeitos = [];
  Map<int, List<int>> fatoresPerfeitos = {};

  int? maiorAbundante;
  int maiorSomaAbundante = -1;
  List<int> fatoresMaiorAbundante = [];

  for (int i = inicio; i <= fim; i++) {
    if (i <= 0) continue;

    List<int> fatores = calcularFatoresProprios(i);
    int soma = fatores.fold(0, (somaAnterior, elemento) => somaAnterior + elemento);

    if (soma == i) {
      perfeitos.add(i);
      fatoresPerfeitos[i] = fatores;
    }

    if (soma > i) {
      if (soma > maiorSomaAbundante) {
        maiorSomaAbundante = soma;
        maiorAbundante = i;
        fatoresMaiorAbundante = fatores;
      }
    }
  }

  if (perfeitos.isEmpty) {
    print('Nenhum número perfeito encontrado no intervalo [$inicio, $fim].');
  } else {
    print('Números Perfeitos encontrados:');
    for (int numero in perfeitos) {
      print('Número: $numero');
      print('Fatores: ${fatoresPerfeitos[numero]}');
    }
  }

  print('');

  if (maiorAbundante == null) {
    print('Nenhum número abundante encontrado no intervalo [$inicio, $fim].');
  } else {
    print('Número Abundante com maior soma de fatores:');
    print('Número: $maiorAbundante');
    print('Soma dos fatores: $maiorSomaAbundante');
    print('Fatores: $fatoresMaiorAbundante');
  }
}

List<int> calcularFatoresProprios(int n) {
  List<int> fatores = [];
  for (int i = 1; i <= n ~/ 2; i++) {
    if (n % i == 0) {
      fatores.add(i);
    }
  }
  return fatores;
}