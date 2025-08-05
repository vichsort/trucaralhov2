final defaultPath = 'images/chips';

class Chip {
  String nome;
  String caminhoImagem;
  int valor;

  Chip({required this.nome, required this.caminhoImagem, required this.valor});
}

List<Chip> chips = [
  Chip(nome: "Branca", caminhoImagem: '$defaultPath/white.png', valor: 1),
  Chip(nome: "Vermelha", caminhoImagem: '$defaultPath/red.png', valor: 5),
  Chip(nome: "Laranja", caminhoImagem: '$defaultPath/orange.png', valor: 10),
  Chip(nome: "Amarela", caminhoImagem: '$defaultPath/yellow.png', valor: 20),
  Chip(nome: "Verde", caminhoImagem: '$defaultPath/green.png', valor: 25),
  Chip(nome: "Preta", caminhoImagem: '$defaultPath/black.png', valor: 100),
  Chip(nome: "Roxa", caminhoImagem: '$defaultPath/purple.png', valor: 500),
  Chip(nome: "Marrom", caminhoImagem: '$defaultPath/brown.png', valor: 1000),
];
