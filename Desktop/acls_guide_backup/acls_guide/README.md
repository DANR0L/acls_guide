# 🫀 ACLS Guide 2025

**Guia Clínico Interativo para Médicos Intensivistas e Emergencistas**

App Flutter baseado nas **Diretrizes AHA 2025** para Advanced Cardiovascular Life Support (ACLS).

---

## 📱 Funcionalidades

- **PCR (Parada Cardiorrespiratória)** — VF/pVT, Assistolia, AESP
- **Bradicardia com Pulso** — BAV 1/2/3 grau, sinusal
- **Taquicardia com Pulso** — TSV, FA, Flutter, TV, Torsades
- **Cuidados Pós-PCR (ROSC)** — TTM, metas hemodinâmicas, ECG
- **SCA / IAMCSST** — ICP primária, trombólise
- **💊 Guia de Fármacos** — Todas as drogas ACLS com doses
- **⏱️ Timer CPR** — Cronômetro de 2 min com alertas
- 100% **Offline** — funciona sem internet na UTI
- **Dark Mode** — otimizado para ambientes de emergência
- **Botões grandes** — para uso com luvas cirúrgicas

---

## 🚀 Como Rodar

### Pré-requisitos

1. Instalar **Flutter SDK**: https://flutter.dev/docs/get-started/install/windows
2. Após instalar, adicionar ao PATH: `C:\flutter\bin`
3. Verificar instalação: `flutter doctor`

### Instalar e Rodar

```powershell
# Entrar na pasta do projeto
cd C:\Users\danro\.gemini\antigravity-ide\scratch\acls_guide

# Instalar dependências
flutter pub get

# Rodar no emulador/dispositivo Android
flutter run

# Gerar APK
flutter build apk --release
```

### Rodar no Dispositivo Físico (Android)
1. Ativar **Modo Desenvolvedor** e **Depuração USB** no Android
2. Conectar via USB
3. `flutter devices` para listar dispositivos
4. `flutter run -d <device-id>`

---

## 🏗️ Estrutura do Projeto

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # Root widget
├── core/
│   ├── theme/app_theme.dart     # Design system dark mode
│   └── router/app_router.dart   # Navegação
├── data/
│   └── algorithms.dart          # Todos os algoritmos ACLS
├── models/
│   └── algorithm_node.dart      # Modelos de dados
├── providers/
│   └── algorithm_provider.dart  # State management (Riverpod)
└── ui/
    ├── screens/
    │   ├── home_screen.dart      # Tela inicial
    │   ├── algorithm_screen.dart # Motor de algoritmos
    │   ├── drugs_screen.dart     # Referência de fármacos
    │   └── about_screen.dart    # Sobre o app
    └── widgets/
        ├── drug_card.dart        # Card de medicamento
        └── timer_widget.dart     # Timer CPR
```

---

## ⚠️ Aviso Médico-Legal

Este aplicativo é uma **ferramenta de apoio à decisão clínica** destinada exclusivamente a **profissionais de saúde treinados**. **Não substitui** o julgamento clínico, o treinamento formal em ACLS, nem as publicações oficiais da AHA.

Baseado em: **AHA 2025 Guidelines for CPR and Emergency Cardiovascular Care** — Circulation, 2025.
