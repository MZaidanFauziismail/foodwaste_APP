"""Run EcoShare ML prediction from CLI.

Example:
    python ml/predict.py --title "Roti tawar sealed" --description "baru beli kemarin" --category food --type free
"""
from __future__ import annotations

import argparse
import json
import math
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent
MODEL_PATH = ROOT / "model_artifacts" / "food_waste_model.json"
TOKEN_RE = re.compile(r"[a-zA-ZÀ-ÿ0-9_]+")


def tokenize(text: str) -> list[str]:
    return [t.lower() for t in TOKEN_RE.findall(text or "") if len(t) > 1]


def predict_nb(model: dict, text: str) -> tuple[str, dict[str, float]]:
    labels = model["labels"]
    vocabulary = set(model["vocabulary"])
    vocab_size = max(len(vocabulary), 1)
    total_docs = sum(model["label_counts"].values())
    tokens = [t for t in tokenize(text) if t in vocabulary]
    scores = {}
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


def predict(title: str, description: str, category: str = "food", type_: str = "free") -> dict:
    model = json.loads(MODEL_PATH.read_text(encoding="utf-8"))
    text = f"{title} {description}"
    predicted_category, category_probs = predict_nb(model["category_model"], text)
    safety_label, safety_probs = predict_nb(model["safety_model"], text)

    if category in {"food", "non_food"}:
        # User-selected category is used as a weak prior; model can still warn through probabilities.
        predicted_category = category if max(category_probs.values()) < 0.70 else predicted_category

    tokens = set(tokenize(text))
    cfg = model["scoring_config"]
    fresh_hits = len(tokens.intersection(cfg["fresh_words"]))
    risk_hits = len(tokens.intersection(cfg["risk_words"]))
    food = predicted_category == "food"

    safety_score = 88 if food else 96
    safety_score += fresh_hits * 3
    safety_score -= risk_hits * 18
    if safety_label == "risky":
        safety_score -= 25
    if type_ == "sell":
        safety_score -= 2
    safety_score = max(10, min(99, round(safety_score)))

    freshness_score = 82 if food else 94
    freshness_score += fresh_hits * 4
    freshness_score -= risk_hits * 22
    if safety_label == "risky":
        freshness_score -= 20
    freshness_score = max(5, min(99, round(freshness_score)))

    impact_meals = 0
    if food:
        impact_meals = 4 if safety_score >= 85 else 3 if safety_score >= 70 else 1
        if safety_score < 55:
            impact_meals = 0
    impact_water = impact_meals * cfg["water_liters_per_meal"] if food else cfg["non_food_reuse_water_credit"]

    notes = []
    if food:
        notes.append("Model mendeteksi listing makanan. Cantumkan waktu pembuatan, kondisi kemasan, dan aturan pickup.")
        if safety_score < 65:
            notes.append("Safety score rendah; jangan dibagikan bila bau, warna, atau tekstur berubah.")
        elif fresh_hits:
            notes.append("Kata terkait segar/segel/baru meningkatkan confidence listing.")
    else:
        notes.append("Model mendeteksi listing non-food untuk reuse, lend, sell, wanted, atau forum.")

    return {
        "predicted_category": predicted_category,
        "category_confidence": category_probs.get(predicted_category, 0),
        "safety_label": safety_label,
        "safety_confidence": safety_probs.get(safety_label, 0),
        "safety_score": safety_score,
        "freshness_score": freshness_score,
        "impact_meals": impact_meals,
        "impact_water_liters": impact_water,
        "notes": notes,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--title", required=True)
    parser.add_argument("--description", default="")
    parser.add_argument("--category", default="food", choices=["food", "non_food"])
    parser.add_argument("--type", default="free", choices=["free", "sell", "lend", "wanted", "forum"])
    args = parser.parse_args()
    print(json.dumps(predict(args.title, args.description, args.category, args.type), indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
