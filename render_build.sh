#!/usr/bin/env bash

# Sair em caso de erro
set -e

# Clonar o SDK do Flutter (estável) se não existir
if [ ! -d "flutter_sdk" ]; then
  git clone https://github.com/flutter/flutter.git -b stable flutter_sdk
fi

# Adicionar Flutter ao PATH
export PATH="$PATH:`pwd`/flutter_sdk/bin"

# Limpar e Buildar para Web
flutter doctor
flutter pub get
flutter build web --release