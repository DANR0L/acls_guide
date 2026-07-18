import 'package:flutter/material.dart';

// ── 1. Enum com todos os tipos de taquicardia ──
enum TaquicardiaType {
  sinusal,
  atrial,
  flutter,
  svt,
  faComWpw,
  vtMonomorfica,
  vtPolimorfica,
}

// ── 2. Classe que guarda os parâmetros de CADA ritmo ──
class ECGPattern {
  final TaquicardiaType type;
  final String nome;
  final String descricao;
  final double frequencia;     // bpm
  final double amplitudeR;     // altura do QRS (pixels)
  final double duracaoQrs;     // largura do QRS (ms)
  final double stElevation;    // desnível de ST (mm)
  final bool regular;
  final bool complexoAlargado;
  final String conduta;

  const ECGPattern({
    required this.type,
    required this.nome,
    required this.descricao,
    required this.frequencia,
    required this.amplitudeR,
    required this.duracaoQrs,
    required this.stElevation,
    required this.regular,
    required this.complexoAlargado,
    required this.conduta,
  });
}

// ── 3. Catálogo completo (todas as taquicardias) ──
final Map<TaquicardiaType, ECGPattern> taquicardias = {
  TaquicardiaType.sinusal: ECGPattern(
    type: TaquicardiaType.sinusal,
    nome: 'Taquicardia Sinusal',
    descricao: 'Ritmo sinusal acelerado. Onda P presente, QRS estreito.',
    frequencia: 120,
    amplitudeR: 80,
    duracaoQrs: 80,
    stElevation: 0,
    regular: true,
    complexoAlargado: false,
    conduta: 'Tratar causa base (febre, dor, hipovolemia, ansiedade).',
  ),

  TaquicardiaType.atrial: ECGPattern(
    type: TaquicardiaType.atrial,
    nome: 'Fibrilação Atrial',
    descricao: 'Ritmo irregularmente irregular. Sem onda P. QRS estreito.',
    frequencia: 140,
    amplitudeR: 70,
    duracaoQrs: 80,
    stElevation: 0,
    regular: false,
    complexoAlargado: false,
    conduta: 'Se instável: cardioversão elétrica sincronizada.',
  ),

  TaquicardiaType.flutter: ECGPattern(
    type: TaquicardiaType.flutter,
    nome: 'Flutter Atrial',
    descricao: 'Padrão serrilhado (dente de serra). Condução variável.',
    frequencia: 150,
    amplitudeR: 70,
    duracaoQrs: 80,
    stElevation: 0,
    regular: false,
    complexoAlargado: false,
    conduta: 'Se instável: cardioversão elétrica sincronizada.',
  ),

  TaquicardiaType.svt: ECGPattern(
    type: TaquicardiaType.svt,
    nome: 'TVP / AVNRT',
    descricao: 'Taquicardia regular, estreita, sem onda P visível.',
    frequencia: 180,
    amplitudeR: 75,
    duracaoQrs: 80,
    stElevation: 1,
    regular: true,
    complexoAlargado: false,
    conduta: 'Manobra vagal. Adenossina 6mg IV. Se instável: cardioversão.',
  ),

  TaquicardiaType.faComWpw: ECGPattern(
    type: TaquicardiaType.faComWpw,
    nome: 'FA com Pré-Excitação (WPW)',
    descricao: 'Irregular, QRS largo e bizarro. FC muito rápida. Onda delta.',
    frequencia: 220,
    amplitudeR: 85,
    duracaoQrs: 140,
    stElevation: -1,
    regular: false,
    complexoAlargado: true,
    conduta: 'Usar Amiodarona. EVITAR adenosina/verapamil. Cardioverter se instável.',
  ),

  TaquicardiaType.vtMonomorfica: ECGPattern(
    type: TaquicardiaType.vtMonomorfica,
    nome: 'TV Monomórfica',
    descricao: 'Complexo largo, regular. Dissociação AV pode estar presente.',
    frequencia: 170,
    amplitudeR: 90,
    duracaoQrs: 160,
    stElevation: -2,
    regular: true,
    complexoAlargado: true,
    conduta: 'Cardioversão elétrica sincronizada. Amiodarona.',
  ),

  TaquicardiaType.vtPolimorfica: ECGPattern(
    type: TaquicardiaType.vtPolimorfica,
    nome: 'TV Polimórfica / Torsades',
    descricao: 'Complexo largo, amplitude variável, torce ao redor da linha base.',
    frequencia: 200,
    amplitudeR: 60,
    duracaoQrs: 160,
    stElevation: 0,
    regular: false,
    complexoAlargado: true,
    conduta: 'Sulfato de Magnésio. Se instável: desfibrilação.',
  ),
};