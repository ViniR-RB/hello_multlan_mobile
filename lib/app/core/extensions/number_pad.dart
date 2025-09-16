extension StringPadding on String {
  // Método para adicionar zero à esquerda para números
  String padZero() {
    // Tenta converter para inteiro primeiro
    int? number = int.tryParse(this);

    // Se for um número válido entre 1 e 9, adiciona zero à esquerda
    if (number != null && number >= 1 && number <= 9) {
      return padLeft(2, '0');
    }

    // Retorna a string original se não for um número entre 1 e 9
    return this;
  }
}
