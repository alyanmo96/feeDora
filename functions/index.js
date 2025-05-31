const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

exports.seedAIContent = functions.https.onRequest(async (req, res) => {
  const samplePosts = [
    {
      title: "Introducing the ErO Electric Car",
      content: "The ErO is a groundbreaking electric vehicle offering 500km range and self-driving capabilities.",
      imageUrl: "https://cdn.pixabay.com/photo/2024/03/02/07/09/car-8607713_1280.jpg",
      sourceUrl: "https://www.eroelectric.com/models",
      category: "Cars",
      keywords: ['electric car', 'ErO', 'vehicles', 'EV', 'technology'],
      likes: 0,
      dislikes:0
    },
    {
      title: "Revolution in Travel: AI Itineraries",
      content: "AI is transforming how we plan trips — real-time language translation and smart suggestions are now a reality.",
      imageUrl: "https://cdn.pixabay.com/photo/2024/02/15/14/31/donkey-8575524_1280.jpg",
      sourceUrl: "https://www.traveltech.com/ai",
      category: "Travel",
      keywords: [ 'Travel'],
      likes: 0,
      dislikes:0
    },
    {
      title: "Smart Gardens Powered by AI",
      content: "New AI systems can track plant health, water levels, and sun exposure to optimize gardening like never before.",
      imageUrl: "https://cdn.pixabay.com/photo/2023/01/10/00/17/italy-7708551_1280.jpg",
      sourceUrl: "https://www.aigardens.io/",
      category: "Garden",
      keywords: ['garden', 'AI', 'plants', 'smart tech', 'automation'],
      likes: 0,
      dislikes:0
    },
    {
      title: "AI Wins at Esports Tournament",
      content: "An AI-powered bot dominated in a competitive online game tournament, raising questions about fairness in esports.",
      imageUrl: "https://cdn.pixabay.com/photo/2021/09/07/07/11/game-console-6603120_1280.jpg",
      sourceUrl: "https://example.com/ai-esports",
      category: "Games",
      keywords: ["games", "AI", "esports", "tournament"],
      likes: 0,
      dislikes:0
    },
    {
      title: "AI Predicts Stock Market Trends",
      content: "New finance tools use AI to detect early patterns in market movements — with surprisingly accurate results.",
      imageUrl: "https://cdn.pixabay.com/photo/2016/11/23/14/37/blur-1853262_1280.jpg",
      sourceUrl: "https://example.com/ai-finance",
      category: "Finance",
      keywords: ["finance", "AI", "stocks", "markets"],
      likes: 0,
      dislikes:0
    }   ,
    {
      title: "Smart Mirrors Recommend Skin Products",
      content: "AI-powered smart mirrors now scan your face and recommend personalized skin care routines.",
      imageUrl: "https://cdn.pixabay.com/photo/2016/10/22/20/55/makeup-brushes-1761648_1280.jpg",
      sourceUrl: "https://beautytech.ai",
      category: "Beauty",
      keywords: ["beauty", "AI", "makeup", "skincare"],
      likes: [],
      dislikes: [],
    },
    {
      title: "AI Composes Billboard-Ready Songs",
      content: "Producers are now using AI tools to generate beats, lyrics, and vocals that compete with human music.",
      imageUrl: "https://cdn.pixabay.com/photo/2022/03/09/21/40/song-7058726_1280.jpg",
      sourceUrl: "https://www.musicaigenius.com",
      category: "Music",
      keywords: ["music", "AI", "songwriting", "production"],
      likes: [],
      dislikes: [],
    },
    {
      title: "AI-Generated Memes Go Viral",
      content: "Social platforms are buzzing with hilarious meme content generated daily by AI — some even hit trending charts.",
      imageUrl: "https://cdn.pixabay.com/photo/2019/07/23/08/04/charlie-chaplin-4356893_1280.jpg",
      sourceUrl: "https://memegen.ai",
      category: "Comedy",
      keywords: ["comedy", "memes", "AI", "social"],
      likes: [],
      dislikes: [],
    },
    {
      title: "AI Chef Designs Custom Meals",
      content: "A new AI-based kitchen assistant can design a meal based on your taste, mood, and dietary needs.",
      imageUrl: "https://cdn.pixabay.com/photo/2015/05/07/15/08/cookie-756601_1280.jpg",
      sourceUrl: "https://www.foodai.io/",
      category: "Food",
      keywords: ["food", "AI", "cooking", "health"],
      likes: [],
      dislikes: [],
    },
    {
      title: "Virtual Doctor Diagnoses with 90% Accuracy",
      content: "AI-powered virtual assistants are proving more accurate than some human doctors in diagnosing rare diseases.",
      imageUrl: "https://cdn.pixabay.com/photo/2016/08/10/20/26/blood-pressure-1584223_1280.jpg",
      sourceUrl: "https://www.medai.com",
      category: "Health",
      keywords: ["health", "AI", "medicine", "diagnosis"],
      likes: [],
      dislikes: [],
    },
    {
      title: "Translate Anything with AI Voice",
      content: "AI voice tools now translate between languages in real time — changing how we communicate globally.",
      imageUrl: "https://cdn.pixabay.com/photo/2017/09/07/10/07/english-2724442_1280.jpg",
      sourceUrl: "https://www.linguaai.com",
      category: "Languages",
      keywords: ["languages", "AI", "translation", "communication"],
      likes: [],
      dislikes: [],
    },
    {
      title: "AI Can Now Compose Full Novels",
      content: "A new GPT-based model just released its first 200-page science fiction novel — and readers can’t tell it’s machine-made.",
      imageUrl: "https://cdn.pixabay.com/photo/2023/11/29/22/14/ai-8420370_1280.jpg",
      sourceUrl: "https://www.aistorylabs.com",
      category: "AI",
      keywords: ["AI", "writing", "books", "language model"],
      likes: [],
      dislikes: [],
    },
    {
      title: "AI Protects Endangered Species",
      content: "New wildlife monitoring systems powered by AI are helping prevent illegal poaching and track animal health.",
      imageUrl: "https://cdn.pixabay.com/photo/2023/12/14/07/44/dog-8448345_1280.jpg",
      sourceUrl: "https://wildai.org",
      category: "Animals",
      keywords: ["animals", "AI", "wildlife", "conservation"],
      likes: [],
      dislikes: [],
    },
    {
      title: "Smart Football with AI Coaches",
      content: "AI sensors and playbooks are helping athletes train smarter — improving performance while reducing injury.",
      imageUrl: "https://cdn.pixabay.com/photo/2021/03/28/08/18/ronaldo-6130591_1280.jpg",
      sourceUrl: "https://smartsportsai.com",
      category: "Sports",
      keywords: ["sports", "AI", "training", "performance"],
      likes: [],
      dislikes: [],
    },
    {
      title: "AI Chips Are Shrinking",
      content: "The next generation of processors for artificial intelligence are becoming smaller and faster — enabling edge computing for everyone.",
      imageUrl: "https://cdn.pixabay.com/photo/2013/12/22/15/30/motherboard-232515_1280.jpg",
      sourceUrl: "https://techcrunch.com/ai-chips",
      category: "Tech",
      keywords: ["tech", "AI", "chips", "hardware"],
      likes: [],
      dislikes: [],
    }
  ];

  try {
    const batch = db.batch();
    samplePosts.forEach(post => {
      const docRef = db.collection("feedPostsByAI").doc(); // auto-id
      batch.set(docRef, post);
    });

    await batch.commit();
    res.status(200).send("Sample AI posts seeded successfully!");
  } catch (error) {
    console.error("Error seeding posts:", error);
    res.status(500).send("Error seeding posts.");
  }
});
