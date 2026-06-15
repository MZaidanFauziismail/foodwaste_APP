const express = require('express');

const router = express.Router();

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const GEMINI_MODEL = process.env.GEMINI_MODEL || 'gemini-2.5-flash';

function formatPrice(price) {
  const n = Number(price || 0);

  if (!n || n <= 0) {
    return 'Free';
  }

  return `Rp ${n.toLocaleString('id-ID')}`;
}

function isFoodCategory(category = '') {
  const c = String(category).toLowerCase();

  return (
    c.includes('food') &&
    !c.includes('non-food') &&
    !c.includes('nonfood')
  );
}

function fallbackAnalyze({ title, description, category, price }) {
  const text = `${title || ''} ${description || ''}`.toLowerCase();
  const priceText = formatPrice(price);
  const food = isFoodCategory(category);

  if (food) {
    return {
      isFood: true,
      itemType: 'food',
      possibleBrand: null,
      priceText,
      insight:
        priceText === 'Free'
          ? 'Free food goes fast. Message the owner quickly and confirm pickup time.'
          : `Food item listed for ${priceText}. Check freshness and pickup details.`,
      cookingIdeas: [
        {
          title: 'Simple meal idea',
          difficulty: 'Easy',
          time: '20 mins',
          emoji: '🍽️',
        },
      ],
      itemIdeas: [],
      tips: [
        'Check freshness, packaging, and pickup time before claiming this food.',
      ],
    };
  }

  let itemType = 'item';
  let icon = '✨';
  let titleText = 'Useful item';

  if (text.includes('tas') || text.includes('bag') || text.includes('backpack') || text.includes('ransel')) {
    itemType = 'backpack';
    icon = '🎒';
    titleText = 'Cool backpack';
  } else if (text.includes('sepatu') || text.includes('shoes') || text.includes('sneaker')) {
    itemType = 'shoes';
    icon = '👟';
    titleText = 'Nice shoes';
  } else if (text.includes('baju') || text.includes('kaos') || text.includes('shirt')) {
    itemType = 'clothing';
    icon = '👕';
    titleText = 'Nice clothing item';
  } else if (text.includes('buku') || text.includes('book')) {
    itemType = 'book';
    icon = '📚';
    titleText = 'Useful book';
  }

  return {
    isFood: false,
    itemType,
    possibleBrand: null,
    priceText,
    insight: `${titleText}. Listed for ${priceText}. Check condition before claiming or buying.`,
    cookingIdeas: [],
    itemIdeas: [
      {
        title: titleText,
        subtitle: `Listed for ${priceText}`,
        icon,
      },
      {
        title: 'Check condition',
        subtitle: 'Inspect details before pickup',
        icon: '🔍',
      },
    ],
    tips: [
      `${titleText}. Listed for ${priceText}. Check condition and confirm pickup details with the owner.`,
    ],
  };
}

function cleanJson(text = '') {
  return String(text)
    .replace(/```json/g, '')
    .replace(/```/g, '')
    .trim();
}

async function imageUrlToPart(imageUrl) {
  if (!imageUrl) return null;

  try {
    const response = await fetch(imageUrl);

    if (!response.ok) return null;

    const contentType = response.headers.get('content-type') || 'image/jpeg';

    if (!contentType.startsWith('image/')) return null;

    const buffer = Buffer.from(await response.arrayBuffer());

    return {
      inline_data: {
        mime_type: contentType,
        data: buffer.toString('base64'),
      },
    };
  } catch {
    return null;
  }
}

async function analyzeWithGemini(payload) {
  if (!GEMINI_API_KEY) {
    return fallbackAnalyze(payload);
  }

  const {
    title,
    description,
    category,
    price,
    imageUrl,
  } = payload;

  const priceText = formatPrice(price);

  const prompt = `
You are an AI analyzer for ShareBite, a neighborhood sharing marketplace.

Analyze this listing:
Title: ${title || ''}
Description: ${description || ''}
Category: ${category || ''}
Price: ${priceText}

Rules:
- Detect if item is food or non-food.
- If non-food, cookingIdeas MUST be [].
- If food, itemIdeas MUST be [].
- Do not say free when price is above 0.
- If image/logo clearly shows brand, detect possible brand.
- If brand unclear, use null.
- Return JSON only.

JSON schema:
{
  "isFood": boolean,
  "itemType": string,
  "possibleBrand": string | null,
  "priceText": string,
  "insight": string,
  "cookingIdeas": [
    {
      "title": string,
      "difficulty": string,
      "time": string,
      "emoji": string
    }
  ],
  "itemIdeas": [
    {
      "title": string,
      "subtitle": string,
      "icon": string
    }
  ],
  "tips": [string]
}
`;

  const parts = [{ text: prompt }];
  const imagePart = await imageUrlToPart(imageUrl);

  if (imagePart) {
    parts.push(imagePart);
  }

  try {
    const url =
      `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}`;

    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        contents: [
          {
            role: 'user',
            parts,
          },
        ],
        generationConfig: {
          temperature: 0.2,
          responseMimeType: 'application/json',
        },
      }),
    });

    if (!response.ok) {
      return fallbackAnalyze(payload);
    }

    const json = await response.json();
    const raw = json?.candidates?.[0]?.content?.parts?.[0]?.text || '';
    const parsed = JSON.parse(cleanJson(raw));

    return {
      isFood: Boolean(parsed.isFood),
      itemType: parsed.itemType || 'item',
      possibleBrand: parsed.possibleBrand || null,
      priceText: parsed.priceText || priceText,
      insight: parsed.insight || fallbackAnalyze(payload).insight,
      cookingIdeas: Array.isArray(parsed.cookingIdeas) ? parsed.cookingIdeas : [],
      itemIdeas: Array.isArray(parsed.itemIdeas) ? parsed.itemIdeas : [],
      tips: Array.isArray(parsed.tips) ? parsed.tips : [],
    };
  } catch {
    return fallbackAnalyze(payload);
  }
}

router.post('/recommend', async (req, res) => {
  try {
    const ai = await analyzeWithGemini(req.body || {});

    return res.json({
      success: true,
      data: {
        isFood: ai.isFood,
        itemType: ai.itemType,
        possibleBrand: ai.possibleBrand,
        priceText: ai.priceText,
        insight: ai.insight,
        recipes: [],
        cookingIdeas: ai.isFood ? ai.cookingIdeas : [],
        itemIdeas: ai.isFood ? [] : ai.itemIdeas,
        tips: ai.tips,
        similarListings: [],
      },
    });
  } catch {
    return res.status(500).json({
      success: false,
      message: 'AI recommendation failed',
    });
  }
});

module.exports = router;