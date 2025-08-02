final defaultPath = 'images/fichas';

class Ficha {
  String nome;
  String caminhoImagem;
  int valor;

  Ficha({required this.nome, required this.caminhoImagem, required this.valor});
}

List<Ficha> fichas = [
  Ficha(nome: "Branca", caminhoImagem: '$defaultPath/white.png', valor: 1),
  Ficha(nome: "Vermelha", caminhoImagem: '$defaultPath/red.png', valor: 5),
  Ficha(nome: "Laranja", caminhoImagem: '$defaultPath/orange.png', valor: 10),
  Ficha(nome: "Amarela", caminhoImagem: '$defaultPath/yellow.png', valor: 20),
  Ficha(nome: "Verde", caminhoImagem: '$defaultPath/green.png', valor: 25),
  Ficha(nome: "Preta", caminhoImagem: '$defaultPath/black.png', valor: 100),
  Ficha(nome: "Roxa", caminhoImagem: '$defaultPath/purple.png', valor: 500),
  Ficha(nome: "Marrom", caminhoImagem: '$defaultPath/brown.png', valor: 1000),
];
