# Projetos LaTeX

Repositório com meus trabalhos acadêmicos em LaTeX (Licenciatura em Matemática — Unespar, *campus* de Campo Mourão): TCC, iniciação científica e apresentações em eventos, além de templates para começar novos trabalhos.

## Estrutura

```
.
├── projects/                    # um diretório por trabalho
│   └── [Evento Ano] - Título/
│       ├── src/                 # main.tex, capítulos, .bib  (código-fonte)
│       ├── figures/             # imagens e logos
│       └── build/               # saída da compilação (PDF final é versionado)
├── templates/
│   ├── comum/                   # preâmbulo modular compartilhado
│   ├── tcc-monografia/
│   ├── slides-unespar/
│   ├── relatorio-ic-prppg/
│   ├── artigo/
│   └── novo-projeto.sh          # cria um projeto a partir de um template
└── .vscode/settings.json        # LaTeX Workshop: latexmk + XeLaTeX, saída em ../build
```

Convenções:

- **Nome da pasta:** `[Evento Ano] - Título`, por exemplo `[Ágora 2026] - Slides Jogo 24`. Para o TCC usa-se só `[TCC]`.
- **Arquivo principal:** `src/main.tex`. Imagens ficam em `figures/` e são referenciadas como `../figures/arquivo.png` (ou só pelo nome, quando o preâmbulo define `\graphicspath`).
- **Saída:** `build/`. Os arquivos auxiliares (`.aux`, `.log`, `.bcf`, …) são ignorados pelo git; o PDF final é versionado.

## Requisitos

- TeX Live (com `latexmk`, `xelatex` e `biber`)
- `biblatex-abnt`, para as referências no padrão ABNT
- `asymptote` (programa `asy`), apenas para as figuras 3D do TCC
- Tema beamer **`sthlmnord`**, usado nos slides do Ágora 2026, do TCC e no template `slides-unespar`. Ele **não vem no TeX Live**: instale os arquivos `beamer*sthlmnord*.sty` em `~/texmf/tex/latex/sthlmnord/` e rode `texhash ~/texmf`. Se o tema não estiver disponível, troque `\usetheme[mode=light]{sthlmnord}` por `\usetheme{default}`.

## Como compilar

No VS Code com a extensão LaTeX Workshop, basta salvar um arquivo de `src/`: a compilação é automática e o PDF vai para `build/`.

Pelo terminal, dentro de `src/`:

```bash
latexmk -xelatex -outdir=../build main.tex
```

## Templates

Para criar um projeto novo:

```bash
templates/novo-projeto.sh <template> "[Evento Ano] - Título"
```

O script copia o template para `projects/`, inclusive uma cópia da pasta `comum/`. Assim cada projeto fica independente, e alterações futuras nos templates não quebram trabalhos já entregues.

| Template | Classe | Baseado em | Uso |
|---|---|---|---|
| `tcc-monografia` | `book` | TCC Geometria Riemanniana | Monografia com capa da Unespar, capítulos em arquivos separados e teoremas numerados por capítulo |
| `artigo` | `article` | — | Artigos, notas e listas, com teoremas numerados por seção e contador único |
| `relatorio-ic-prppg` | `article` | Relatório Final IC 2026 | Trabalho final de IC no modelo da PRPPG/Unespar (Times 12, logos e instruções do modelo) |
| `slides-unespar` | `beamer` 16:9 | Slides do TCC e do Ágora 2026 | Apresentações com o tema sthlmnord e logos; tem um bloco opcional de **evento** (nome e logo do evento no rodapé, como no Ágora) |

### Preâmbulo modular (`templates/comum/`)

| Arquivo | Conteúdo |
|---|---|
| `packages.tex` | Ponto de entrada: carrega todos os módulos abaixo, na ordem correta |
| `pacotes/idioma.tex` | babel `brazilian`; fontspec (XeLaTeX) ou inputenc/fontenc/lmodern (pdfLaTeX); enumitem |
| `pacotes/matematica.tex` | amsmath, amssymb, amsthm, mathtools, bm, amscd, tikz-cd |
| `pacotes/figuras.tex` | graphicx, TikZ e bibliotecas, pgfplots, float, caption/subcaption; asymptote opcional |
| `pacotes/layout-abnt.tex` | Margens ABNT, espaçamento 1,5, recuo, número de página (não usar em beamer) |
| `pacotes/referencias.tex` | biblatex (biber, estilo ABNT), hyperref, cleveref |
| `theoremstyles.tex` | `theorem`, `proposition`, `lemma`, `corollary`, `definition`, `axiom`, `example(s)`, `observation`, com os nomes em português para `\cref`/`\Cref` |
| `comandos.tex` | `\asyimage` (figura com legenda e rótulo) e o ambiente `citacao` (citação longa ABNT) |

Opções, definidas **antes** de `\input{comum/packages}`:

```latex
\newcommand{\comumNumeracao}{chapter}   % chapter | section | (não definir = 1, 2, 3)
\newcommand{\comumContadorUnico}{}      % Definição 1.1, Teorema 1.2, ... (contador compartilhado)
\newcommand{\comumBibliografia}{referencias.bib}
\newcommand{\comumEstiloBib}{abnt}      % ou authoryear, numeric, ...
\newcommand{\comumAsymptote}{}          % carrega o pacote asymptote
```

Cada arquivo de `comum/` explica, no cabeçalho, o que carrega e de quais outros módulos depende.

## Projetos

### TCC

- **[TCC] - Geometria Riemanniana**: monografia *Geodésicas e o Teorema de Hopf-Rinow na Geometria Riemanniana* (orientação: Welinton Anderson Rocha; coorientação: Roger Emanuel Moraes Pezzott). Apresenta campos em variedades diferenciáveis, métricas Riemannianas e a conexão de Levi-Civita, e chega às geodésicas: existência local, minimização local de distância, o mapa exponencial e o Teorema de Hopf-Rinow. As figuras são feitas em TikZ e Asymptote.
- **[TCC] - Geometria Riemanniana (Antes do Corte)**: cópia da monografia antes da redução dos resultados, guardada como referência.
- **[TCC] - Slides Projeto**: slides da apresentação do projeto de TCC, *O conceito de geodésica e o Teorema de Hopf-Rinow na Geometria Riemanniana*, com contexto histórico (Gauss, Bolyai, Lobachevsky, Riemann e o quinto postulado), problemática, objetivos, justificativa e metodologia.

### Iniciação Científica

- **[IC 2026] - Relatório Final**: trabalho final de IC (bolsa Fundação Araucária) *Condições de Cadeia em Módulos*, no modelo da PRPPG/Unespar, com Gislaine Aparecida Periçaro e Welinton Anderson Rocha. Estuda módulos sobre anéis comutativos e as condições de cadeia ascendente e descendente (módulos Noetherianos e Artinianos), a partir de Atiyah–Macdonald.

### Ágora Matemática (Unespar, Campo Mourão)

- **[Ágora 2025] - Slides TVI**: *Uma Generalização do Teorema do Valor Intermediário para Espaços Topológicos Arbitrários*, com Jéssica Buzatto Prudencio. Parte do TVI clássico e chega à versão topológica usando continuidade e conexidade.
- **[Ágora 2026] - Slides IC Teorema da Base de Hilbert**: apresentação dos resultados da IC: módulos, módulos Noetherianos e Artinianos, sequências e a demonstração do Teorema da Base de Hilbert.
- **[Ágora 2026] - Slides Jogo 24**: *Análise Quantitativa das Soluções do Jogo 24*, com Wallace Carlos Rodrigues, Rodrigo Eber de Almeida e Lucas Gabriel da Silveira Ames. Cobre as regras e estratégias do jogo (método da alavanca), a contagem de jogos possíveis, as árvores de expressões e os resultados de uma implementação computacional.
- **[Ágora 2026] - Slides TCC Orientação**: *Variedades Diferenciáveis Orientáveis e Não Orientáveis*: variedades diferenciáveis, variedades quociente e orientabilidade, ilustradas com a esfera, o cilindro, a faixa de Möbius e o plano projetivo.

## Licença

GPL-3.0. Veja [LICENSE](LICENSE).
