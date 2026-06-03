"""Train a lightweight text ML model for EcoShare listings.

This script intentionally uses only Python standard library so it can run on
almost any laptop without heavy ML dependencies. It trains two multinomial
Naive Bayes classifiers:
1. category classifier: food vs non_food
2. safety classifier: safe vs risky

Run:
    python ml/train_model.py
"""
from __future__ import annotations

import csv
import json
import math
import random
import re
from collections import Counter, defaultdict
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parent
DATASET = ROOT / "data" / "training_data.csv"
OUT_DIR = ROOT / "model_artifacts"
MODEL_PATH = OUT_DIR / "food_waste_model.json"
METRICS_PATH = OUT_DIR / "metrics.json"

TOKEN_RE = re.compile(r"[a-zA-ZÀ-ÿ0-9_]+")


def tokenize(text: str) -> list[str]:
    return [t.lower() for t in TOKEN_RE.findall(text or "") if len(t) > 1]


def train_nb(rows: list[dict[str, str]], label_key: str) -> dict:
    label_counts: Counter[str] = Counter()
    token_counts: dict[str, Counter[str]] = defaultdict(Counter)
    total_tokens: Counter[str] = Counter()
    vocabulary: set[str] = set()

    for row in rows:
      label = row[label_key]
      text = f"{row['title']} {row['description']}"
      label_counts[label] += 1
      for token in tokenize(text):
          vocabulary.add(token)
          token_counts[label][token] += 1
          total_tokens[label] += 1

    return {
        "labels": sorted(label_counts),
        "label_counts": dict(label_counts),
        "token_counts": {k: dict(v) for k, v in token_counts.items()},
        "total_tokens": dict(total_tokens),
        "vocabulary": sorted(vocabulary),
    }


def predict_nb(model: dict, text: str) -> tuple[str, dict[str, float]]:
    labels = model["labels"]
    vocabulary = set(model["vocabulary"])
    vocab_size = max(len(vocabulary), 1)
    total_docs = sum(model["label_counts"].values())
    tokens = [t for t in tokenize(text) if t in vocabulary]
    scores: dict[str, float] = {}

    for label in labels:
        doc_count = model["label_counts"].get(label, 0)
        score = math.log((doc_count + 1) / (total_docs + len(labels)))
        total = model["total_tokens"].get(label, 0)
        counts = model["token_counts"].get(label, {})
        for token in tokens:
            score += math.log((counts.get(token, 0) + 1) / (total + vocab_size))
        scores[label] = score

    max_score = max(scores.values())
    exp_scores = {k: math.exp(v - max_score) for k, v in scores.items()}
    total_exp = sum(exp_scores.values()) or 1
    probs = {k: round(v / total_exp, 4) for k, v in exp_scores.items()}
    best = max(probs, key=probs.get)
    return best, probs


def evaluate(model: dict, rows: Iterable[dict[str, str]], label_key: str) -> dict:
    rows = list(rows)
    correct = 0
    confusion: dict[str, Counter[str]] = defaultdict(Counter)
    for row in rows:
        y_true = row[label_key]
        y_pred, _ = predict_nb(model, f"{row['title']} {row['description']}")
        correct += int(y_true == y_pred)
        confusion[y_true][y_pred] += 1
    return {
        "accuracy": round(correct / len(rows), 4) if rows else None,
        "n": len(rows),
        "confusion_matrix": {k: dict(v) for k, v in confusion.items()},
    }


def main() -> None:
    with DATASET.open(encoding="utf-8") as f:
        rows = list(csv.DictReader(f))

    random.seed(42)
    random.shuffle(rows)
    split = max(1, int(len(rows) * 0.8))
    train_rows, valid_rows = rows[:split], rows[split:]

    category_model = train_nb(train_rows, "category")
    safety_model = train_nb(train_rows, "safety_label")

    model = {
        "model_name": "ecoshare_food_waste_nb_v1",
        "model_type": "multinomial_naive_bayes_text",
        "language": ["id", "en"],
        "training_rows": len(train_rows),
        "labels": {
            "category": category_model["labels"],
            "safety": safety_model["labels"],
        },
        "category_model": category_model,
        "safety_model": safety_model,
        "scoring_config": {
            "fresh_words": ["fresh", "segar", "baru", "hari", "ini", "pagi", "siang", "segel", "sealed", "tertutup", "kulkas", "kemasan", "utuh"],
            "risk_words": ["basi", "bau", "jamur", "mold", "expired", "kadaluarsa", "lewat", "mentah", "raw", "bocor", "asam", "berubah", "semalam"],
            "water_liters_per_meal": 1250,
            "non_food_reuse_water_credit": 420
        }
    }

    metrics = {
        "dataset": str(DATASET.name),
        "train_rows": len(train_rows),
        "validation_rows": len(valid_rows),
        "category": evaluate(category_model, valid_rows, "category"),
        "safety": evaluate(safety_model, valid_rows, "safety_label"),
        "note": "Metrics are calculated on the included labeled sample. For production accuracy, retrain with real EcoShare transaction/listing moderation data."
    }

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    MODEL_PATH.write_text(json.dumps(model, indent=2, ensure_ascii=False), encoding="utf-8")
    METRICS_PATH.write_text(json.dumps(metrics, indent=2, ensure_ascii=False), encoding="utf-8")
    print(json.dumps(metrics, indent=2))


if __name__ == "__main__":
    main()
