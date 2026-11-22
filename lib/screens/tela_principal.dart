import 'package:flutter/material.dart';
import '../models/livro.dart';
import '../services/data_access_object.dart';
import 'cadastro_livro.dart';
import 'detalhes_livro.dart';
import 'lista_colecoes.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  List<Livro> _livros = [];
  bool _carregando = true;
  String _filtroAtual = 'todos';
  String? _valorFiltro;

  @override
  void initState() {
    super.initState();
    _carregarLivros();
  }

  Future<void> _carregarLivros() async {
    setState(() {
      _carregando = true;
    });

    List<Livro> lista;
    if (_filtroAtual == 'genero' && _valorFiltro != null) {
      lista = await DataAccessObject.obterLivrosPorGenero(_valorFiltro!);
    } else if (_filtroAtual == 'colecao' && _valorFiltro != null) {
      lista = await DataAccessObject.obterLivrosPorColecao(_valorFiltro!);
    } else {
      lista = await DataAccessObject.obterLivros();
    }

    setState(() {
      _livros = lista;
      _carregando = false;
    });
  }

  void _abrirSelecaoFiltro(String tipo) async {
    final todos = await DataAccessObject.obterLivros();
    List<String> opcoes = [];

    if (tipo == 'genero') {
      opcoes = todos
          .map((l) => l.genero)
          .where((g) => g.trim().isNotEmpty)
          .toSet()
          .toList();
    } else {
      opcoes = todos
          .where((l) => l.ehColecao && l.nomeColecao.trim().isNotEmpty)
          .map((l) => l.nomeColecao)
          .toSet()
          .toList();
    }

    if (!mounted) return;

    if (opcoes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nenhum(a) $tipo cadastrado(a) ainda.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return ListView.builder(
          itemCount: opcoes.length,
          itemBuilder: (ctx, index) {
            final item = opcoes[index];
            return ListTile(
              title: Text(item),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _filtroAtual = tipo;
                  _valorFiltro = item;
                });
                _carregarLivros();
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Meu Diário de Leitura', style: TextStyle(fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.collections_bookmark_outlined),
            tooltip: 'Ver Coleções e Gêneros',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListaColecoes()),
              );
              _carregarLivros();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _filtroAtual = 'todos';
                _valorFiltro = null;
              });
              _carregarLivros();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de filtros com chips compactos
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                FilterChip(
                  visualDensity: VisualDensity.compact,
                  label: const Text('Todos', style: TextStyle(fontSize: 12)),
                  selected: _filtroAtual == 'todos',
                  onSelected: (selected) {
                    setState(() {
                      _filtroAtual = 'todos';
                      _valorFiltro = null;
                    });
                    _carregarLivros();
                  },
                ),
                const SizedBox(width: 6),
                FilterChip(
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    _filtroAtual == 'genero' && _valorFiltro != null
                        ? 'Gênero: $_valorFiltro'
                        : 'Por Gênero',
                    style: const TextStyle(fontSize: 12),
                  ),
                  selected: _filtroAtual == 'genero',
                  onSelected: (selected) => _abrirSelecaoFiltro('genero'),
                ),
                const SizedBox(width: 6),
                FilterChip(
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    _filtroAtual == 'colecao' && _valorFiltro != null
                        ? 'Coleção: $_valorFiltro'
                        : 'Por Coleção',
                    style: const TextStyle(fontSize: 12),
                  ),
                  selected: _filtroAtual == 'colecao',
                  onSelected: (selected) => _abrirSelecaoFiltro('colecao'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Grade compacta de 3 colunas
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _livros.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum livro registrado.\nToque no + para começar!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 3 colunas para capas menores
                          childAspectRatio: 0.52, // Altura proporcional ajustada
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _livros.length,
                        itemBuilder: (context, index) {
                          final livro = _livros[index];
                          return Card(
                            elevation: 2,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: InkWell(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetalhesLivro(livro: livro),
                                  ),
                                );
                                _carregarLivros();
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Capa reduzida
                                  Expanded(
                                    child: livro.urlCapa.isNotEmpty
                                        ? Image.network(
                                            livro.urlCapa,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              color: Colors.grey[200],
                                              child: const Icon(Icons.broken_image, size: 28, color: Colors.grey),
                                            ),
                                          )
                                        : Container(
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.book, size: 32, color: Colors.grey),
                                          ),
                                  ),
                                  // Textos menores
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          livro.titulo,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            height: 1.1,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          livro.autor,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, size: 11, color: Colors.amber),
                                            const SizedBox(width: 2),
                                            Text(
                                              livro.nota.toStringAsFixed(1),
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () async {
          final adicionou = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CadastroLivro()),
          );
          if (adicionou == true) {
            _carregarLivros();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}