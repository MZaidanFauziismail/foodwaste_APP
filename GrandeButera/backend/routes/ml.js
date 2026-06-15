const express = require('express');

const router = express.Router();

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

function detectItemType(text) {
  if (/(tas|bag|backpack|ransel|pouch|totebag|sling bag)/i.test(text)) {
    return 'bag';
  }
  if (/(dompet|wallet)/i.test(text)) {
    return 'wallet';
  }
  if (/(baju|shirt|kaos|clothes|jaket|jacket)/i.test(text)) {
    return 'clothing';
  }
  if (/(sepatu|shoes|sneaker)/i.test(text)) {
    return 'shoes';
  }
  return 'item';
}

function detectFood(category, text) {
  const all = `${category} ${text}`.toLowerCase();

  const nonFoodKeywords = [
    'free_nonfood',
    'nonfood',
    'non-food',
    'tas',
    'bag',
    'backpack',
    'ransel',
    'pouch',
    'dompet',
    'wallet',
    'baju',
    'shirt',
    'sepatu',
    'shoes',
  ];

  if (nonFoodKeywords.some((keyword) => all.includes(keyword))) {
    return false;
  }

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

function nonFoodResponse({ title, category, price, priceText, itemType }) {
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

router.post('/recommend', async (req, res) => {
  try {
    const body = req.body || {};

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
          title,
          category,
          price,
          priceText,
          itemType,
        });

    return res.json({
      success: true,
      data,
    });
  } catch (error) {
    console.error('ML recommend error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to generate recommendations',
    });
  }
});

module.exports = router;
