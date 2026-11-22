import 'package:flutter/material.dart';
import '../models/livro.dart';
import '../services/data_access_object.dart';
import 'detalhes_livro.dart';

class ListaColecoes extends StatefulWidget {
  const ListaColecoes({super.key});

  @override
  State<ListaColecoes> createState() => _ListaColecoesState();
}

class _ListaColecoesState extends State<ListaColecoes> {
  bool _carregando = true;
  Map<String, List<Livro>> _colecoes = {};
  Map<String, List<Livro>> _generos = {};

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _carregando = true;
    });

    final todosOsLivros = await DataAccessObject.obterLivros();

    final Map<String, List<Livro>> mapaColecoes = {};
    final Map<String, List<Livro>> mapaGeneros = {};

    for (var livro in todosOsLivros) {
      // Coleções
      if (livro.ehColecao && livro.nomeColecao.trim().isNotEmpty) {
        final col = livro.nomeColecao.trim();
        if (!mapaColecoes.containsKey(col)) {
          mapaColecoes[col] = [];
        }
        mapaColecoes[col]!.add(livro);
      }
      // Gêneros
      if (livro.genero.trim().isNotEmpty) {
        final gen = livro.genero.trim();
        if (!mapaGeneros.containsKey(gen)) {
          mapaGeneros[gen] = [];
        }
        mapaGeneros[gen]!.add(livro);
      }
    }

    if (!mounted) return;

    setState(() {
      _colecoes = mapaColecoes;
      _generos = mapaGeneros;
      _carregando = false;
    });
  }

  Widget _construirListaAgrupada(Map<String, List<Livro>> mapa, String tipo) {
    final chaves = mapa.keys.toList()..sort();

    if (chaves.isEmpty) {
      return Center(
        child: Text(
          'Nenhum livro com $tipo registado ainda.',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      itemCount: chaves.length,
      itemBuilder: (context, index) {
        final nome = chaves[index];
        final livros = mapa[nome]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 6),
          elevation: 1.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ExpansionTile(
            dense: true,
            tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            leading: CircleAvatar(
              radius: 14,
              child: Icon(
                tipo == 'coleção' ? Icons.collections_bookmark : Icons.category,
                size: 16,
              ),
            ),
            title: Text(
              nome,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            subtitle: Text(
              '${livros.length} livro(s)',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            children: livros.map((livro) {
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: livro.urlCapa.isNotEmpty
                      ? Image.network(
                          livro.urlCapa,
                          width: 32,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 32,
                            height: 48,
                            color: Colors.grey[200],
                            child: const Icon(Icons.book, size: 16),
                          ),
                        )
                      : Container(
                          width: 32,
                          height: 48,
                          color: Colors.grey[200],
                          child: const Icon(Icons.book, size: 16),
                        ),
                ),
                title: Text(
                  livro.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${livro.autor} • ${livro.nota.toStringAsFixed(1)} ★',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalhesLivro(livro: livro),
                    ),
                  );
                  _carregarDados();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Biblioteca', style: TextStyle(fontSize: 18)),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Coleções / Séries'),
              Tab(text: 'Gêneros'),
            ],
          ),
        ),
        body: _carregando
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _construirListaAgrupada(_colecoes, 'coleção'),
                  _construirListaAgrupada(_generos, 'gênero'),
                ],
              ),
      ),
    );
  }
}