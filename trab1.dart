import "dart:io";

void main() {
  
  String? input = stdin.readLineSync();

  if (input == null || input.isEmpty) {
    print("Entrada vazia!");
    return;
  }

  if (input.contains(',')) {
    print("Formato numérico inválido!");
    return;
  }

  int? number = int.tryParse(input);
  
  if (number == null) {
    if (input.contains('.')) {
      print("Não é inteiro!");
    } else {
      print("Não é um número!");
    }
    return;
  }

  if (number < 0) {
    print("Número negativo!");
    return;
  }

  bool ehPrimo = true;
  int n = number;
  
  if (n < 2) {
    ehPrimo = false;
  } else {
    for (int i = 2; i * i <= n; i++) {
      if (n % i == 0) {
        ehPrimo = false;
        break;
      }
    }
  }
  
  if (ehPrimo) {
    print("É primo!");
  } else {
    print("Não é primo!");
  }
}