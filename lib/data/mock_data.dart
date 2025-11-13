// Auto-generated mock data from main.dart

import '../models/offer.dart';
import '../models/product.dart';
import '../models/transaction.dart';

// --- LOCAL ASSET PDF PATHS ---
const String samplePdf1 = 'lib/assets/pdfs/sample1.pdf';
const String samplePdf2 = 'lib/assets/pdfs/sample2.pdf';
const String samplePdf3 = 'lib/assets/pdfs/sample3.pdf';
const String samplePdf4 = 'lib/assets/pdfs/sample4.pdf';
const String samplePdf5 = 'lib/assets/pdfs/sample5.pdf';

final List<Product> dummyProducts = [
  Product(
    id: 1,
    type: 'Study Material',
    title: 'Calculus I - Integrals',
    description:
        'Comprehensive Study Material covering definite and indefinite integrals.',
    price: 50,
    isFree: false,
    category: 'Math',
    tags: ['High-Demand', 'STEM'],
    rating: 4.8,
    author: 'Dr. Emily Carter',
    pages: 45,
    reviewCount: 88,
    imageUrl: 'https://picsum.photos/seed/calculus/300/200',
    details:
        'In-depth guide to Calculus I, focusing on integration techniques and fundamental theorem applications.',
    pdfUrl: samplePdf1, // ✅ Local Asset
    content: 'Comprehensive guide to Calculus I integrals and applications.',
  ),
  Product(
    id: 2,
    type: 'E-Books',
    title: 'Historical Atlas: WW2',
    description: 'Digital atlas with interactive maps and timelines.',
    price: 120,
    isFree: false,
    category: 'History',
    tags: ['Premium', 'New'],
    rating: 4.5,
    author: 'Prof. David Lee',
    pages: 300,
    reviewCount: 42,
    imageUrl: 'https://picsum.photos/seed/ww2/300/200',
    details:
        'Rich, multimedia-ready eBook detailing the major events, political dynamics, and geographical shifts of World War II.',
    content:
        '## Prelude to War\nThe 1930s saw the rapid rise of totalitarian regimes in Germany and Japan. The failure of the League of Nations was a major factor.\n\n### The Eastern Front\nThe battle for Stalingrad (1942-1943) is considered the turning point, halting the German advance.',
    pdfUrl: samplePdf2, // ✅ Local Asset
  ),
  Product(
    id: 3,
    type: 'E-Journals',
    title: 'Daily Gratitude Prompts',
    description: 'A 30-day journal template for mindfulness and productivity.',
    price: 0,
    isFree: true,
    category: 'Wellness',
    tags: ['Free', 'Popular'],
    rating: 4.9,
    author: 'Wellness Hub',
    pages: 30,
    reviewCount: 150,
    imageUrl: 'https://picsum.photos/seed/wellness/300/200',
    details:
        'Guided prompts designed to improve mental clarity, reduce stress, and foster a positive mindset.',
    content:
        '## Day 1: Grounding\n**Morning Prompt**: List three sensory details you notice right now. **Evening Reflection**: What is one small success you achieved today?',
    pdfUrl: samplePdf3,
  ),
  Product(
    id: 4,
    type: 'Study Material',
    title: 'React Hooks Deep Dive',
    description:
        'Advanced guide to custom hooks, state management, and performance optimization.',
    price: 75,
    isFree: false,
    category: 'Tech',
    tags: ['Coding', 'Advanced'],
    rating: 4.7,
    author: 'Code Master',
    pages: 62,
    reviewCount: 71,
    imageUrl: 'https://picsum.photos/seed/react/300/200',
    details:
        'For developers who already know React basics. Covers useState, useEffect, useMemo, useCallback, and creating reusable custom hooks for enterprise applications.',
    content:
        '## Custom Hooks\nCustom hooks are reusable functions for sharing stateful logic. Example: `useToggle` manages boolean state.',
    pdfUrl: samplePdf4,
  ),
  Product(
    id: 9,
    type: 'Course',
    title: 'Advanced ML & Deep Learning',
    description:
        '9-month Post Graduate Program in Machine Learning and Deep Learning, perfect for career transition.',
    price: 1500,
    isFree: false,
    category: 'Tech',
    tags: ['AI', 'Premium', 'Deep Learning'],
    rating: 4.8,
    author: 'UpSkill Academy',
    pages: 120,
    reviewCount: 190,
    imageUrl: 'https://picsum.photos/seed/deeplearning/300/200',
    details:
        'Covers Python, TensorFlow, PyTorch, CNNs, RNNs, and focuses on real-world projects in Computer Vision and NLP.',
    content:
        '## The Deep Learning Revolution\nDeep Learning (DL) uses neural networks with many layers to model complex non-linear relationships. Key libraries are TensorFlow and PyTorch.',
    pdfUrl: samplePdf5,
  ),
  Product(
    id: 10,
    type: 'Course',
    title: 'Certified AI Engineering Basics',
    description:
        'Foundational certificate course focusing on Python for AI and essential ML algorithms.',
    price: 500,
    isFree: false,
    category: 'Tech',
    tags: ['AI', 'Beginner', 'Python'],
    rating: 4.5,
    author: 'DataMites',
    pages: 80,
    reviewCount: 75,
    imageUrl: 'https://picsum.photos/seed/aibeginner/300/200',
    details:
        'A practical, hands-on course designed for beginners. Covers NumPy, Pandas, Scikit-learn, and the basics of Supervised and Unsupervised Learning.',
    content:
        '## Essential AI Toolkit\nPython is the primary language for AI/ML. Libraries like Pandas for data manipulation and Scikit-learn for model building are crucial.',
    pdfUrl: samplePdf2,
  ),
  Product(
    id: 11,
    type: 'Resource',
    title: 'Generative AI Concepts',
    description: 'Free Study Material on LLMs, Transformers, and VAEs.',
    price: 0,
    isFree: true,
    category: 'Tech',
    tags: ['AI', 'Free', 'New'],
    rating: 4.9,
    author: 'GenAI Hub',
    pages: 35,
    reviewCount: 110,
    imageUrl: 'https://picsum.photos/seed/genai/300/200',
    details:
        'An introductory overview of the latest Generative AI models, including how Large Language Models (LLMs) and diffusion models work.',
    content:
        '## The Transformer Architecture\nThe self-attention mechanism is the core innovation of the Transformer model, allowing it to weigh the importance of different words in a sequence.',
    pdfUrl: samplePdf1,
  ),
  Product(
    id: 5,
    type: 'Study Material',
    title: 'Intro to Microeconomics',
    description:
        'Key concepts of supply, demand, market equilibrium, and basic economic models.',
    price: 40,
    isFree: false,
    category: 'Economics',
    tags: ['Beginner'],
    rating: 4.2,
    author: 'The Econ Tutor',
    pages: 35,
    reviewCount: 20,
    imageUrl: 'https://picsum.photos/seed/econ/300/200',
    details:
        'A clearly articulated introduction to core Microeconomics principles. Designed to supplement introductory college lectures.',
    content:
        r'## The Law of Demand\nAs the price of a good or service increases, the quantity demanded decreases ($P \uparrow \implies Q_d \downarrow$). This inverse relationship is fundamental.',
    pdfUrl: samplePdf3,
  ),
  Product(
    id: 6,
    type: 'E-Books',
    title: 'The Art of Minimalist Design',
    description: 'Principles and case studies of modern minimalistic design.',
    price: 150,
    isFree: false,
    category: 'Design',
    tags: ['Aesthetics'],
    rating: 5.0,
    author: 'Clara Vane',
    pages: 200,
    reviewCount: 105,
    imageUrl: 'https://picsum.photos/seed/design/300/200',
    details:
        'An inspiring book exploring how less can be more in digital and physical design. Features interviews with leading designers and practical tips.',
    content:
        '## Principle 3: Intentional White Space\nWhite space (or negative space) is not merely empty area; it is a critical design element that enhances readability and visual hierarchy.',
    pdfUrl: samplePdf4,
  ),
  Product(
    id: 7,
    type: 'Study Material',
    title: 'Data Structures & Algorithms',
    description:
        'Detailed Study Material on Trees, Graphs, and Heaps for interview preparation.',
    price: 90,
    isFree: false,
    category: 'Tech',
    tags: ['Coding', 'Algorithms'],
    rating: 4.6,
    author: 'Code Master',
    pages: 75,
    reviewCount: 55,
    imageUrl: 'https://picsum.photos/seed/algo/300/200',
    details:
        'A rigorous set of Study Material focused on preparing for technical interviews. Includes complexity analysis and common interview questions.',
    content:
        '## Binary Search Trees (BST)\nA node-based binary tree data structure where the left subtree has keys < parent key and the right subtree has keys > parent key.',
    pdfUrl: samplePdf5,
  ),
  Product(
    id: 8,
    type: 'Study Material',
    title: 'The Solar System Explained',
    description:
        'Study Material on planetary science, basic astrophysics, and space exploration.',
    price: 0,
    isFree: true,
    category: 'Science',
    tags: ['Free', 'Space'],
    rating: 4.9,
    author: 'AstroKid',
    pages: 20,
    reviewCount: 95,
    imageUrl: 'https://picsum.photos/seed/space/300/200',
    details:
        'A fun and fact-filled summary of our solar system, perfect for middle school students or anyone interested in astronomy.',
    content:
        r'## The Inner Planets\nMercury, Venus, Earth, and Mars are the four inner, terrestrial planets. Venus is the hottest due to its dense $\text{CO}_2$ atmosphere causing a runaway greenhouse effect.',
    pdfUrl: samplePdf5,
  ),
];

final List<Offer> dummyOffers = [
  Offer(
    id: 201,
    title: 'Back-to-School Bundle',
    discount: '50%',
    duration: '30 Days',
    status: 'Active',
    productIds: [1, 2, 4],
    tokenPrice: 200,
  ),
  Offer(
    id: 202,
    title: 'All Tech Docs Pack',
    discount: '20%',
    duration: 'Permanent',
    status: 'Active',
    productIds: [4, 7, 9, 10],
    tokenPrice: 130,
  ),
  Offer(
    id: 203,
    title: 'Wellness Starter Kit',
    discount: 'Free Item',
    duration: 'Expired',
    status: 'Inactive',
    productIds: [3],
    tokenPrice: 0,
  ),
];

final List<Transaction> transactionHistory = [
  Transaction(
    id: 1001,
    type: 'Credit',
    amount: 500,
    date: 'Oct 28, 2025',
    description: 'Package purchase',
  ),
  Transaction(
    id: 1002,
    type: 'Debit',
    amount: 50,
    date: 'Oct 27, 2025',
    description: 'Purchased Calculus I - Integrals',
  ),
  Transaction(
    id: 1003,
    type: 'Download',
    amount: 0,
    date: 'Oct 26, 2025',
    description: 'Downloaded Daily Gratitude Prompts',
  ),
  Transaction(
    id: 1004,
    type: 'Debit',
    amount: 1500,
    date: 'Nov 03, 2025',
    description: 'Purchased Advanced ML & Deep Learning',
  ),
];
