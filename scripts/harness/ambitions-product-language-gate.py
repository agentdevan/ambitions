#!/usr/bin/env python3
from _ambitions_static_gate_common import run_gate
PATTERNS = {'next_best_move': r'\bnext best move\b|\bRecommended next move\b', 'begin_focus': r'\bBegin Focus\b', 'guilt': r'\bstreak\b|\bshame\b|\bscore\b'}
raise SystemExit(run_gate('ambitions-product-language-gate', PATTERNS))
