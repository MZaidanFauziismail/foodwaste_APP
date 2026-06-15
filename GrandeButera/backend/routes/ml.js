const express = require('express');

const router = express.Router();

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const GEMINI_MODEL = process.env.GEMINI_MODEL || 'gemini-2.5-flash';

function cleanText(value) {
  return String(value || '').trim();
}

function asNumber(value) {
  const n = Number(value);
  return Number.isFinite(n) ? n : 0;
}

function formatRupiah(value) {
  const n = asNumber(value);
  if (n <= 0) return 'Free';
  return `Rp ${Math.round(n).toLocaleString('id-ID')}`;
}

function joinText(parts) {
  return parts
    .filter(Boolean)
    .map((v) => String(v))
    .join(' ')
    .toLowerCase();
}

function hasNonFoodSignal(text) {
  return /(free_nonfood|nonfood|non-food|tas|bag|backpack|ransel|pouch|totebag|sling bag|dompet|wallet|baju|shirt|kaos|clothes|jaket|jacket|sepatu|shoes|sneaker)/i.test(
    text || ''
  );
}

function detectItemType(text) {
  if (/(tas|bag|backpack|ransel|pouch|totebag|sling bag)/i.test(text)) return 'bag';
  if (/(dompet|wallet)/i.test(text)) return 'wallet';
  if (/(baju|shirt|kaos|clothes|jaket|jacket)/i.test(text)) return 'clothing';
  if (/(sepatu|shoes|sneaker)/i.test(text)) return 'shoes';
  return 'item';
}

function detectFood(category, text) {
  const all = `${category} ${text}`.toLowerCase();

  if (hasNonFoodSignal(all)) return false;

  const foodKeywords = [
    'food',
    'makanan',
    'meal',
    'rice',
    'nasi',
    'roti',
    'bread',
    'ayam',
    'chicken',
    'sayur',
    'fruit',
    'buah',
    'snack',
    'halal',
    'leftover',
  ];

  return foodKeywords.some((keyword) => all.includes(keyword));
}

function foodResponse(priceText) {
  const insight = 'Always ensure food items are safe to consume and properly stored.';

  return {
    isFood: true,
    itemType: 'food',
    possibleBrand: null,
    priceText,
    insight,
    recipes: ['Quick Snack Prep', 'Simple Meal Addition', 'Creative Leftover Dish'],
    cookingIdeas: [
      {
        title: 'Quick Snack Prep',
        subtitle: 'Use this item as a quick snack or simple side dish.',
        difficulty: 'Easy',
        time: '10 mins',
        icon: '🍽️',
      },
      {
        title: 'Simple Meal Addition',
        subtitle: 'Add it to a simple meal to reduce waste.',
        difficulty: 'Medium',
        time: '20 mins',
        icon: '🍽️',
      },
      {
        title: 'Creative Leftover Dish',
        subtitle: 'Turn it into a creative leftover-friendly dish.',
        difficulty: 'Hard',
        time: '45 mins',
        icon: '🍽️',
      },
    ],
    itemIdeas: [],
    tips: [insight],
    similarListings: [],
  };
}

function nonFoodResponse({ category, price, priceText, itemType }) {
  const categoryText = category || 'non_food';
  const saleText =
    price > 0
      ? `Although categorized as '${categoryText}', the price indicates it is for sale.`
      : `This listing appears to be offered for free.`;

  const noun = itemType === 'bag' ? 'bag' : itemType;
  const insight = `This listing is for a non-food item, a ${noun}, priced at ${priceText}. ${saleText}`;

  let itemIdeas;

  if (itemType === 'bag') {
    itemIdeas = [
      {
        title: 'Pouch Organizer',
        subtitle: 'Keep your bag tidy',
        icon: '✨',
      },
      {
        title: 'Dompet (Wallet)',
        subtitle: 'Complement your bag',
        icon: '✨',
      },
      {
        title: 'Aksesoris Tas',
        subtitle: 'Personalize your bag',
        icon: '✨',
      },
    ];
  } else {
    itemIdeas = [
      {
        title: 'Check Condition',
        subtitle: 'Inspect details before pickup',
        icon: '✨',
      },
      {
        title: 'Useful Daily Item',
        subtitle: 'Consider how it fits your needs',
        icon: '✨',
      },
      {
        title: 'Gift or Reuse Idea',
        subtitle: 'Can be reused or shared with someone else',
        icon: '✨',
      },
    ];
  }

  return {
    isFood: false,
    itemType,
    possibleBrand: null,
    priceText,
    insight,
    recipes: [],
    cookingIdeas: [],
    itemIdeas,
    tips: [insight],
    similarListings: [],
  };
}

function fallbackForPayload(body) {
  const title = cleanText(body.title);
  const category = cleanText(body.category);
  const description = cleanText(body.description);
  const tags = Array.isArray(body.tags) ? body.tags : [];
  const price = asNumber(body.price);
  const priceText = formatRupiah(price);
  const combinedText = joinText([title, category, description, tags.join(' ')]);
  const isFood = detectFood(category, combinedText);
  const itemType = detectItemType(combinedText);

  const data = isFood
    ? foodResponse(priceText)
    : nonFoodResponse({
        category,
        price,
        priceText,
        itemType,
      });

  data.aiSource = 'fallback';
  return data;
}

async function imageUrlToInlineData(imageUrl) {
  const url = cleanText(imageUrl);

  if (!/^https?:\/\//i.test(url)) {
    return null;
  }

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 8000);

  try {
    const response = await fetch(url, {
      signal: controller.signal,
      headers: {
        'User-Agent': 'ShareBite-AI/1.0',
      },
    });

    if (!response.ok) return null;

    const mimeType = String(response.headers.get('content-type') || 'image/jpeg')
      .split(';')[0]
      .trim();

    if (!mimeType.startsWith('image/')) return null;

    const arrayBuffer = await response.arrayBuffer();

    if (arrayBuffer.byteLength > 7 * 1024 * 1024) {
      return null;
    }

    return {
      mimeType,
      data: Buffer.from(arrayBuffer).toString('base64'),
    };
  } catch (error) {
    console.warn('Gemini image skipped:', error.message);
    return null;
  } finally {
    clearTimeout(timeout);
  }
}

function parseGeminiJson(text) {
  const raw = cleanText(text)
    .replace(/^```json/i, '')
    .replace(/^```/i, '')
    .replace(/```$/i, '')
    .trim();

  try {
    return JSON.parse(raw);
  } catch (_) {
    const match = raw.match(/\{[\s\S]*\}/);
    if (!match) return null;

    try {
      return JSON.parse(match[0]);
    } catch (_) {
      return null;
    }
  }
}

async function analyzeWithGemini(payload) {
  if (!GEMINI_API_KEY) return null;

  const title = cleanText(payload.title);
  const category = cleanText(payload.category);
  const description = cleanText(payload.description);
  const tags = Array.isArray(payload.tags) ? payload.tags.join(', ') : '';
  const price = asNumber(payload.price);
  const priceText = formatRupiah(price);
  const imageInlineData = await imageUrlToInlineData(payload.imageUrl);

  const prompt = `
You are ShareBite AI.

Analyze this listing using both the text and the image when an image is provided.

Listing:
- title: ${title}
- category: ${category}
- description: ${description}
- tags: ${tags}
- price: ${priceText}

Important rules:
- Bags, wallets, clothes, shoes, pouches, and accessories are non-food.
- If price is more than 0, never call the item free.
- If the listing is non-food, recipes and cookingIdeas must be empty.
- If the listing is food, itemIdeas must be empty.
- Use the image to describe visible object type, style, color, condition, and useful details.
- Return JSON only.

Schema:
{
  "isFood": boolean,
  "itemType": "food | bag | wallet | clothing | shoes | item",
  "possibleBrand": null,
  "insight": "one useful paragraph based on the listing and image",
  "recipes": [],
  "cookingIdeas": [
    {
      "title": "short title",
      "subtitle": "short subtitle",
      "difficulty": "Easy | Medium | Hard",
      "time": "10 mins",
      "icon": "🍽️"
    }
  ],
  "itemIdeas": [
    {
      "title": "short title",
      "subtitle": "short subtitle",
      "icon": "✨"
    }
  ],
  "tips": ["short useful tip"],
  "similarListings": []
}
`.trim();

  const parts = [{ text: prompt }];

  if (imageInlineData) {
    parts.push({
      inlineData: imageInlineData,
    });
  }

  const url =
    `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}`;

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 12000);

  try {
    const response = await fetch(url, {
      method: 'POST',
      signal: controller.signal,
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
          temperature: 0.35,
          maxOutputTokens: 1200,
          responseMimeType: 'application/json',
        },
      }),
    });

    if (!response.ok) {
      const errText = await response.text().catch(() => '');
      console.warn('Gemini failed:', response.status, errText.slice(0, 300));
      return null;
    }

    const json = await response.json();
    const text =
      json?.candidates?.[0]?.content?.parts
        ?.map((part) => part.text || '')
        .join('\n') || '';

    const data = parseGeminiJson(text);
    if (!data) return null;

    return {
      data,
      usedImage: Boolean(imageInlineData),
    };
  } catch (error) {
    console.warn('Gemini error:', error.message);
    return null;
  } finally {
    clearTimeout(timeout);
  }
}

function normalizeIdea(value, fallbackIcon) {
  if (typeof value === 'string') {
    return {
      title: value,
      subtitle: '',
      icon: fallbackIcon,
    };
  }

  if (!value || typeof value !== 'object') return null;

  const title = cleanText(value.title);
  if (!title) return null;

  return {
    title,
    subtitle: cleanText(value.subtitle),
    difficulty: cleanText(value.difficulty),
    time: cleanText(value.time),
    icon: cleanText(value.icon) || fallbackIcon,
  };
}

function normalizeGeminiData(ai, payload, source) {
  const title = cleanText(payload.title);
  const category = cleanText(payload.category);
  const description = cleanText(payload.description);
  const tags = Array.isArray(payload.tags) ? payload.tags : [];
  const price = asNumber(payload.price);
  const priceText = formatRupiah(price);
  const combinedText = joinText([title, category, description, tags.join(' ')]);
  const detectedItemType = detectItemType(combinedText);

  let isFood =
    typeof ai.isFood === 'boolean'
      ? ai.isFood
      : detectFood(category, combinedText);

  if (hasNonFoodSignal(`${category} ${combinedText}`)) {
    isFood = false;
  }

  if (isFood) {
    const fallback = foodResponse(priceText);

    const cookingIdeas = Array.isArray(ai.cookingIdeas)
      ? ai.cookingIdeas
          .map((idea) => normalizeIdea(idea, '🍽️'))
          .filter(Boolean)
          .slice(0, 3)
      : [];

    const insight = cleanText(ai.insight) || fallback.insight;

    return {
      ...fallback,
      isFood: true,
      itemType: 'food',
      priceText,
      insight,
      recipes: cookingIdeas.length
        ? cookingIdeas.map((idea) => idea.title)
        : fallback.recipes,
      cookingIdeas: cookingIdeas.length ? cookingIdeas : fallback.cookingIdeas,
      itemIdeas: [],
      tips: [insight],
      aiSource: source,
    };
  }

  const itemType =
    detectedItemType !== 'item'
      ? detectedItemType
      : cleanText(ai.itemType).toLowerCase() || 'item';

  const fallback = nonFoodResponse({
    category,
    price,
    priceText,
    itemType,
  });

  let insight = cleanText(ai.insight) || fallback.insight;

  if (price > 0) {
    insight = insight.replace(/\bfree\b/gi, 'for sale');
  }

  let itemIdeas = fallback.itemIdeas;

  if (itemType !== 'bag' && Array.isArray(ai.itemIdeas)) {
    const fromAi = ai.itemIdeas
      .map((idea) => normalizeIdea(idea, '✨'))
      .filter(Boolean)
      .slice(0, 3);

    if (fromAi.length) itemIdeas = fromAi;
  }

  return {
    ...fallback,
    isFood: false,
    itemType,
    priceText,
    insight,
    recipes: [],
    cookingIdeas: [],
    itemIdeas,
    tips: [insight],
    aiSource: source,
  };
}

router.post('/recommend', async (req, res) => {
  try {
    const payload = req.body || {};
    const ai = await analyzeWithGemini(payload);

    const data = ai
      ? normalizeGeminiData(
          ai.data,
          payload,
          ai.usedImage ? 'gemini_vision' : 'gemini_text'
        )
      : fallbackForPayload(payload);

    return res.json({
      success: true,
      data,
    });
  } catch (error) {
    console.error('ML recommend error:', error);

    return res.json({
      success: true,
      data: fallbackForPayload(req.body || {}),
    });
  }
});

module.exports = router;
