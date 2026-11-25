# 📚 Diário de Leitura

Trabalho para a disciplina de Desenvolvimento Mobile, feito por Débora De Grande e Paulo Turíbio 

Aplicação multiplataforma (Mobile e Web) desenvolvida em **Flutter** para registro, organização e acompanhamento de leituras pessoais. O projeto conta com banco de dados em nuvem via **Supabase** e integração com APIs REST literárias (**Open Library** e **Google Books**) para busca automatizada de informações e capas.

🌐 **Acesse a versão Web:** [https://deboradsdg.github.io/diariodeleitura2/](https://deboradsdg.github.io/diariodeleitura2/)

---

## 🎯 Funcionalidades

- **CRUD Completo de Livros:** Cadastro de novas leituras, visualização detalhada, edição direta de campos (título, autor, link de capa, sinopse, resenha pessoal, nota por estrelas, gênero e coleção) e exclusão.
- **Busca Online com Seleção:** Pesquisa integrada que lista as edições encontradas via Open Library ou Google Books em modal inferior para escolha direta do usuário.
- **Entrada Manual Flexível:** Opção de preencher ou alterar livremente campos como sinopse e URL de imagem de capa caso a obra não possua metadados completos na web.
- **Filtros e Organização:**
  - Filtro rápido na página inicial por livros lidos, gêneros e coleções/séries.
  - Tela dedicada com abas para navegação agrupada por Coleções e por Gêneros literários.
- **Interface Responsiva e Compacta:** Grade de capas otimizada para melhor aproveitamento de espaço em telas mobile e navegadores desktop.

---

## 🛠️ Tecnologias e Bibliotecas

- **Linguagem:** [Dart](https://dart.dev/)
- **Framework:** [Flutter](https://flutter.dev/) (Android e Web)
- **Backend as a Service:** [Supabase](https://supabase.com/) (`supabase_flutter: ^2.8.0`)
- **Consumo HTTP / REST:** [http](https://pub.dev/packages/http) (`http: ^1.2.0`)
- **APIs Externas:** Open Library Search API & Google Books API
- **Hospedagem Web:** GitHub Pages (branch `gh-pages`)

---

## 🏗️ Estrutura do Projeto

```text
lib/
├── models/
│   ├── google_book_model.dart   # Tratamento dos dados retornados pelas APIs externas
│   └── livro.dart               # Modelo de dados da entidade Livro
├── screens/
│   ├── cadastro_livro.dart      # Formulário de cadastro com busca online e seleção
│   ├── detalhes_livro.dart      # Visualização e edição completa da leitura
│   ├── lista_colecoes.dart      # Agrupamento por Coleções/Séries e Gêneros em abas
│   └── tela_principal.dart      # Grade principal de leituras com barra de filtros
├── services/
│   ├── api_services.dart        # Integração REST com Open Library e Google Books
│   └── data_access_object.dart  # Operações CRUD conectadas à tabela 'livros' do Supabase
└── main.dart                    # Inicialização do Supabase, rotas e tema global
