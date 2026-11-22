import 'package:flutter/material.dart';
import '../models/google_book_model.dart';
import '../models/livro.dart';
import '../services/api_services.dart';
import '../services/data_access_object.dart';

class CadastroLivro extends StatefulWidget {
  const CadastroLivro({super.key});

  @override
  State<CadastroLivro> createState() => _CadastroLivroState();
}

class _CadastroLivroState extends State<CadastroLivro> {
  final _buscaController = TextEditingController();
  bool _carregandoBusca = false;
  bool _salvando = false;

  final _urlCapaController = TextEditingController();
  final _tituloController = TextEditingController();
  final _autorController = TextEditingController();
  final _sinopseController = TextEditingController();

  final _generoController = TextEditingController();
  final _destaqueController = TextEditingController();
  final _comentarioController = TextEditingController();
  final _colecaoController = TextEditingController();

  double _nota = 5.0;
  bool _ehColecao = false;

  @override
  void dispose() {
    _buscaController.dispose();
    _urlCapaController.dispose();
    _tituloController.dispose();
    _autorController.dispose();
    _sinopseController.dispose();
    _generoController.dispose();
    _destaqueController.dispose();
    _comentarioController.dispose();
    _colecaoController.dispose();
    super.dispose();
  }

  Future<void> _executarBusca() async {
    if (_buscaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o título para buscar')),
      );
      return;
    }

    setState(() {
      _carregandoBusca = true;
    });

    final List<GoogleBookModel> resultados = await ApiServices.buscarLivros(
      termo: _buscaController.text,
    );

    if (!mounted) return;

    setState(() {
      _carregandoBusca = false;
    });

    if (resultados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum livro encontrado. Preencha os campos manualmente.')),
      );
      return;
    }

    _mostrarModalSelecao(resultados);
  }

  void _mostrarModalSelecao(List<GoogleBookModel> opcoes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Selecione a edição correta',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: opcoes.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = opcoes[index];
                    return ListTile(
                      leading: item.urlCapa.isNotEmpty
                          ? Image.network(
                              item.urlCapa,
                              width: 40,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.book),
                            )
                          : const Icon(Icons.book, size: 40),
                      title: Text(item.titulo, maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text(item.autor, maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _tituloController.text = item.titulo;
                          _autorController.text = item.autor;
                          _sinopseController.text = item.sinopse;
                          _urlCapaController.text = item.urlCapa;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _salvarLivro() async {
    if (_tituloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe ao menos o título do livro.')),
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    final novoLivro = Livro(
      titulo: _tituloController.text.trim(),
      autor: _autorController.text.trim(),
      sinopse: _sinopseController.text.trim(),
      urlCapa: _urlCapaController.text.trim(),
      genero: _generoController.text.trim(),
      nota: _nota,
      destaque: _destaqueController.text.trim(),
      ehColecao: _ehColecao,
      nomeColecao: _ehColecao ? _colecaoController.text.trim() : '',
      comentario: _comentarioController.text.trim(),
    );

    await DataAccessObject.incluirLivro(novoLivro);

    if (!mounted) return;

    setState(() {
      _salvando = false;
    });

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Cadastrar Leitura'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _buscaController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Buscar online',
                      hintText: 'Ex.: Orgulho e Preconceito',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: _carregandoBusca ? null : _executarBusca,
                  child: _carregandoBusca
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Buscar'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Prévia da Capa
            if (_urlCapaController.text.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _urlCapaController.text,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
                  ),
                ),
              ),
            if (_urlCapaController.text.isNotEmpty) const SizedBox(height: 16),

            TextField(
              controller: _urlCapaController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Link da Imagem da Capa (URL)',
                hintText: 'https://...',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Título do Livro',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _autorController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Autor(a)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _sinopseController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Sinopse do Livro (digite ou edite aqui)',
              ),
            ),
            const SizedBox(height: 20),

            const Divider(),
            const Text(
              'Avaliação e Notas Pessoais',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _generoController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Gênero literário',
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Text('Nota: ${_nota.toStringAsFixed(1)} ★', style: const TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Slider(
                    value: _nota,
                    min: 1.0,
                    max: 5.0,
                    divisions: 8,
                    label: _nota.toStringAsFixed(1),
                    onChanged: (val) => setState(() => _nota = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _destaqueController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'O que mais gostou no livro?',
              ),
            ),
            const SizedBox(height: 12),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Faz parte de uma série/coleção?'),
              value: _ehColecao,
              onChanged: (val) => setState(() => _ehColecao = val),
            ),
            if (_ehColecao) ...[
              TextField(
                controller: _colecaoController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nome da Coleção',
                ),
              ),
              const SizedBox(height: 12),
            ],

            TextField(
              controller: _comentarioController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Comentário ou resenha geral',
              ),
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _salvando ? null : _salvarLivro,
              icon: _salvando
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check),
              label: Text(_salvando ? 'Salvando...' : 'Salvar no Diário'),
            ),
          ],
        ),
      ),
    );
  }
}