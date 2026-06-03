const fs = require('fs');
const path = require('path');

const modelPath = path.resolve(__dirname, '../ml_model/food_waste_model.json');
const model = JSON.parse(fs.readFileSync(modelPath, 'utf8'));

const tokenRe = /[a-zA-ZÀ-ÿ0-9_]+/g;

function tokenize(text = '') {
  return String(text).toLowerCase().match(tokenRe)?.filter((t) => t.length > 1) || [];
}

function predictNb(nbModel, text) {
  const labels = nbModel.labels || [];
  const vocabulary = new Set(nbModel.vocabulary || []);
  const vocabSize = Math.max(vocabulary.size, 1);
  const totalDocs = Object.values(nbModel.label_counts || {}).reduce((a, b) => a + Number(b || 0), 0) || 1;
  const tokens = tokenize(text).filter((t) => vocabulary.has(t));
  const scores = {};

  for (const label of labels) {
    const docCount = Number(nbModel.label_counts?.[label] || 0);
    let score = Math.log((docCount + 1) / (totalDocs + labels.length));
    const total = Number(nbModel.total_tokens?.[label] || 0);
    const counts = nbModel.token_counts?.[label] || {};
    for (const token of tokens) {
      score += Math.log((Number(counts[token] || 0) + 1) / (total + vocabSize));
    }
    scores[label] = score;
  }

  const maxScore = Math.max(...Object.values(scores));
  const expScores = Object.fromEntries(Object.entries(scores).map(([k, v]) => [k, Math.exp(v - maxScore)]));
  const totalExp = Object.values(expScores).reduce((a, b) => a + b, 0) || 1;
  const probs = Object.fromEntries(Object.entries(expScores).map(([k, v]) => [k, Number((v / totalExp).toFixed(4))]));
  const best = Object.keys(probs).sort((a, b) => probs[b] - probs[a])[0] || labels[0];
  return { label: best, probabilities: probs };
}

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

function predictListing({ title = '', description = '', category = 'food', type = 'free' }) {
  const text = `${title} ${description}`;
  const categoryPrediction = predictNb(model.category_model, text);
  const safetyPrediction = predictNb(model.safety_model, text);

  let predictedCategory = categoryPrediction.label;
  const categoryConfidence = categoryPrediction.probabilities[predictedCategory] || 0;
  if (['food', 'non_food'].includes(category) && categoryConfidence < 0.7) predictedCategory = category;

  const tokens = new Set(tokenize(text));
  const config = model.scoring_config || {};
  const freshWords = new Set(config.fresh_words || []);
  const riskWords = new Set(config.risk_words || []);
  const freshHits = [...tokens].filter((t) => freshWords.has(t)).length;
  const riskHits = [...tokens].filter((t) => riskWords.has(t)).length;
  const isFood = predictedCategory === 'food';

  let safetyScore = isFood ? 88 : 96;
  safetyScore += freshHits * 3;
  safetyScore -= riskHits * 18;
  if (safetyPrediction.label === 'risky') safetyScore -= 25;
  if (type === 'sell') safetyScore -= 2;
  safetyScore = Math.round(clamp(safetyScore, 10, 99));

  let freshnessScore = isFood ? 82 : 94;
  freshnessScore += freshHits * 4;
  freshnessScore -= riskHits * 22;
  if (safetyPrediction.label === 'risky') freshnessScore -= 20;
  freshnessScore = Math.round(clamp(freshnessScore, 5, 99));

  let impactMeals = 0;
  if (isFood) {
    impactMeals = safetyScore >= 85 ? 4 : safetyScore >= 70 ? 3 : 1;
    if (safetyScore < 55) impactMeals = 0;
  }

  const waterPerMeal = Number(config.water_liters_per_meal || 1250);
  const nonFoodCredit = Number(config.non_food_reuse_water_credit || 420);
  const impactWaterLiters = isFood ? impactMeals * waterPerMeal : nonFoodCredit;

  const notes = [];
  if (isFood) {
    notes.push('Model mendeteksi listing makanan. Cantumkan waktu pembuatan, kondisi kemasan, dan aturan pickup.');
    if (safetyScore < 65) {
      notes.push('Safety score rendah; jangan dibagikan bila bau, warna, atau tekstur berubah.');
    } else if (freshHits > 0) {
      notes.push('Kata terkait segar/segel/baru meningkatkan confidence listing.');
    }
  } else {
    notes.push('Model mendeteksi listing non-food untuk reuse, lend, sell, wanted, atau forum.');
  }

  return {
    predicted_category: predictedCategory,
    category_confidence: Number((categoryPrediction.probabilities[predictedCategory] || categoryConfidence || 0).toFixed(4)),
    safety_label: safetyPrediction.label,
    safety_confidence: Number((safetyPrediction.probabilities[safetyPrediction.label] || 0).toFixed(4)),
    safety_score: safetyScore,
    freshness_score: freshnessScore,
    impact_meals: impactMeals,
    impact_water_liters: Math.round(impactWaterLiters),
    notes,
  };
}

module.exports = { predictListing };
