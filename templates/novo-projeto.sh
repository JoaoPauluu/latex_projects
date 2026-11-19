#!/usr/bin/env bash
# =====================================================================
# novo-projeto.sh — cria um projeto em projects/ a partir de um template
#
# Uso:
#   templates/novo-projeto.sh <template> "<[Evento Ano] - Título>"
#
# Exemplos:
#   templates/novo-projeto.sh slides-unespar "[Ágora 2027] - Slides Grupos de Lie"
#   templates/novo-projeto.sh artigo "[IC 2027] - Relatório Parcial"
#
# Templates disponíveis: as pastas de templates/ (exceto comum/).
# A pasta comum/ é COPIADA para dentro de src/ (o link simbólico do
# template é resolvido), então cada projeto fica independente: mudar
# templates/comum/ depois não altera projetos já criados.
# =====================================================================
set -euo pipefail

raiz="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
templates="$raiz/templates"

listar() {
  find "$templates" -mindepth 1 -maxdepth 1 -type d ! -name comum -printf '  %f\n' | sort
}

if [[ $# -ne 2 ]]; then
  echo "Uso: $0 <template> \"<[Evento Ano] - Título>\"" >&2
  echo "Templates disponíveis:" >&2
  listar >&2
  exit 1
fi

template="$1"
nome="$2"
origem="$templates/$template"
destino="$raiz/projects/$nome"

if [[ "$template" == "comum" || ! -d "$origem/src" ]]; then
  echo "Template '$template' não existe. Disponíveis:" >&2
  listar >&2
  exit 1
fi

if [[ -e "$destino" ]]; then
  echo "Já existe: $destino" >&2
  exit 1
fi

# -L resolve o link src/comum -> ../../comum, copiando os arquivos reais
cp -rL "$origem" "$destino"
rm -f "$destino/build/.gitkeep"

echo "Projeto criado em: projects/$nome"
echo "Arquivo principal: projects/$nome/src/main.tex"
