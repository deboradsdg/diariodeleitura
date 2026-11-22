import 'package:flutter/material.dart';
import '../models/livro.dart';
import '../services/data_access_object.dart';

class DetalhesLivro extends StatefulWidget {
  final Livro livro;

  const DetalhesLivro({super.key, required this.livro});

  @override
  State<DetalhesLivro> createState() => _DetalhesLivroState();
}

class _DetalhesLivroState extends State<DetalhesLivro> {
  late Livro _livro;
  bool _modoEdicao = false;
  bool _salvando = false;
  bool _excluindo = false;

  late TextEditingController _tituloController;
  late TextEditingController _autorController;
  late TextEditingController _urlCapaController;
  late TextEditingController _sinopseController;
  late TextEditingController _generoController;
  late TextEditingController _destaqueController;
  late TextEditingController _comentarioController;
  late TextEditingController _colecaoController;
  late double _nota;
  late bool _ehColecao;

  @override
  void initState() {
    super.initState();
    _livro = widget.livro;
    _inicializarControllers();
  }

  void _inicializarControllers() {
    _tituloController = TextEditingController(text: _livro.titulo);
    _autorController = TextEditingController(text: _livro.autor);
    _urlCapaController = TextEditingController(text: _livro.urlCapa);
    _sinopseController = TextEditingController(text: _livro.sinopse);
    _generoController = TextEditingController(text: _livro.genero);
    _destaqueController = TextEditingController(text: _livro.destaque);
    _comentarioController = TextEditingController(text: _livro.comentario);
    _colecaoController = TextEditingController(text: _livro.nomeColecao);
    _nota = _livro.nota;
    _ehColecao = _livro.ehColecao;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    _urlCapaController.dispose();
    _sinopseController.dispose();
    _generoController.dispose();
    _destaqueController.dispose();
    _comentarioController.dispose();
    _colecaoController.dispose();
    super.dispose();
  }

  Future<void> _salvarAlteracoes() async {
    setState(() {
      _salvando = true;
    });

    final livroAtualizado = Livro(
      id: _livro.id,
      titulo: _tituloController.text.trim(),
      autor: _autorController.text.trim(),
      urlCapa: _urlCapaController.text.trim(),
      sinopse: _sinopseController.text.trim(),
      genero: _generoController.text.trim(),
      nota: _nota,
      destaque: _destaqueController.text.trim(),
      ehColecao: _ehColecao,
      nomeColecao: _ehColecao ? _colecaoController.text.trim() : '',
      comentario: _comentarioController.text.trim(),
    );

    await DataAccessObject.alterarLivro(livroAtualizado);

    if (!mounted) return;

    setState(() {
      _livro = livroAtualizado;
      _modoEdicao = false;
      _salvando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Livro atualizado com sucesso!')),
    );
  }

  Future<void> _excluir() async {
    if (_livro.id == null) return;

    setState(() {
      _excluindo = true;
    });

    final sucesso = await DataAccessObject.excluirLivro(_livro.id!);

    if (!mounted) return;

    setState(() {
      _excluindo = false;
    });

    if (sucesso) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir o livro.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_modoEdicao ? 'Editar Livro' : _livro.titulo),
        actions: [
          if (!_modoEdicao) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar informações',
              onPressed: () => setState(() => _modoEdicao = true),
            ),
            IconButton(
              icon: _excluindo
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.delete),
              tooltip: 'Excluir',
              onPressed: _excluindo ? null : _excluir,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Cancelar edição',
              onPressed: () {
                _inicializarControllers();
                setState(() => _modoEdicao = false);
              },
            ),
          ]
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _modoEdicao ? _construirFormularioEdicao() : _construirVisualizacao(),
      ),
    );
  }

  Widget _construirVisualizacao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _livro.urlCapa.isNotEmpty
                ? Image.network(
                    _livro.urlCapa,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 60),
                  )
                : const Icon(Icons.book, size: 80, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            _livro.titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            _livro.autor.isNotEmpty ? _livro.autor : 'Autor não informado',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            Chip(
              avatar: const Icon(Icons.star, color: Colors.amber, size: 18),
              label: Text('${_livro.nota.toStringAsFixed(1)} ★'),
            ),
            if (_livro.genero.isNotEmpty) Chip(label: Text(_livro.genero)),
            if (_livro.ehColecao && _livro.nomeColecao.isNotEmpty)
              Chip(label: Text('Coleção: ${_livro.nomeColecao}')),
          ],
        ),
        const Divider(height: 32),
        if (_livro.destaque.isNotEmpty) ...[
          const Text('O que mais gostou:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_livro.destaque, style: const TextStyle(fontStyle: FontStyle.italic)),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (_livro.comentario.isNotEmpty) ...[
          const Text('Comentários / Resenha:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(_livro.comentario, style: const TextStyle(fontSize: 15, height: 1.4)),
          const SizedBox(height: 16),
        ],
        const Text('Sinopse:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(
          _livro.sinopse.isNotEmpty ? _livro.sinopse : 'Nenhuma sinopse registada.',
          style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.3),
        ),
      ],
    );
  }

  Widget _construirFormularioEdicao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _urlCapaController,
          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'URL da Capa'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _tituloController,
          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Título'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _autorController,
          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Autor'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _sinopseController,
          maxLines: 4,
          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Sinopse'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _generoController,
          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Gênero'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('Nota: ${_nota.toStringAsFixed(1)} ★', style: const TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: Slider(
                value: _nota,
                min: 1.0,
                max: 5.0,
                divisions: 8,
                onChanged: (val) => setState(() => _nota = val),
              ),
            ),
          ],
        ),
        TextField(
          controller: _destaqueController,
          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'O que mais gostou'),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Faz parte de coleção?'),
          value: _ehColecao,
          onChanged: (val) => setState(() => _ehColecao = val),
        ),
        if (_ehColecao) ...[
          TextField(
            controller: _colecaoController,
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Nome da Coleção'),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _comentarioController,
          maxLines: 4,
          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Comentários'),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _salvando ? null : _salvarAlteracoes,
          icon: _salvando
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.save),
          label: Text(_salvando ? 'Salvando...' : 'Salvar Alterações'),
        ),
      ],
    );
  }
}