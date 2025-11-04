// Auto-generated mock data from main.dart

import '../models/offer.dart';
import '../models/product.dart';
import '../models/transaction.dart';

// --- Reliable Dummy PDF Links ---
// NOTE: These links are necessary for the PDF Viewer to function correctly.
const String adobeDummyPdf =
    'https://www.adobe.com/support/products/enterprise/knowledgebase/pdfs/pdflyf_sample_local.pdf';
const String smallDummyPdf =
    'http://www.africau.edu/images/default/sample.pdf'; // A very small, reliable sample

// --- AI Course Brochure Link (Using your previous valid link) ---
const String aiCourseBrochurePdf =
    'https://www.halvorsen.blog/documents/tutorials/resources/ASP.NET%20and%20Web%20Programming.pdf';

final List<Product> dummyProducts = [
  // FIX: Converted content string to RAW String literal (r'...') to properly handle LaTeX characters ($ and \).
  Product(
    id: 1,
    type: 'Notes',
    title: 'Calculus I - Integrals',
    description:
        'Comprehensive notes covering definite and indefinite integrals.',
    price: 50,
    isFree: false,
    category: 'Math',
    tags: ['High-Demand', 'STEM'],
    rating: 4.8,
    author: 'Dr. Emily Carter',
    pages: 45,
    reviewCount: 88,
    // CLEANED: Only one instance of imageUrl is used
    imageUrl:
        'https://picsum.photos/seed/calculus/300/200', // Changed seed slightly for variety
    details:
        'In-depth guide to Calculus I, focusing on integration techniques and fundamental theorem applications.',
    pdfUrl: 'https://www.orimi.com/pdf-test.pdf',
    content: '', // <-- Working Adobe Dummy PDF
  ),
  Product(
    id: 2,
    type: 'Books',
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
    // CLEANED: Only one instance of imageUrl is used
    imageUrl: 'https://picsum.photos/seed/ww2/300/200',
    details:
        'Rich, multimedia-ready eBook detailing the major events, political dynamics, and geographical shifts of World War II.',
    content:
        '## Prelude to War\nThe 1930s saw the rapid rise of totalitarian regimes in Germany and Japan. The failure of the League of Nations was a major factor.\n\n### The Eastern Front\nThe battle for Stalingrad (1942-1943) is considered the turning point, halting the German advance.',
    pdfUrl: adobeDummyPdf, // <-- Working Adobe Dummy PDF
  ),
  Product(
    id: 3,
    type: 'Journals',
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
    // CLEANED: Only one instance of imageUrl is used
    imageUrl: 'https://picsum.photos/seed/wellness/300/200',
    details:
        'Guided prompts designed to improve mental clarity, reduce stress, and foster a positive mindset.',
    content:
        '## Day 1: Grounding\n**Morning Prompt**: List three sensory details you notice right now. **Evening Reflection**: What is one small success you achieved today?',
    pdfUrl: smallDummyPdf, // <-- UPDATED from null to smallDummyPdf
  ),
  Product(
    id: 4,
    type: 'Notes',
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
    // CLEANED: Only one instance of imageUrl is used
    imageUrl: 'https://picsum.photos/seed/react/300/200',
    details:
        'For developers who already know React basics. Covers useState, useEffect, useMemo, useCallback, and creating reusable custom hooks for enterprise applications.',
    content:
        '## Custom Hooks\nCustom hooks are reusable functions for sharing stateful logic. Example: `useToggle` manages boolean state.',
    pdfUrl: smallDummyPdf, // <-- Working Small Dummy PDF
  ),
  // --- NEW AI/ML COURSE ENTRIES ---
  Product(
    id: 9,
    type: 'Course',
    title: 'Advanced ML & Deep Learning',
    description:
        '9-month Post Graduate Program in Machine Learning and Deep Learning, perfect for career transition.',
    price: 1500, // Higher price for a course
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
    pdfUrl: aiCourseBrochurePdf, // <-- Uses the link provided by the user
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
    pdfUrl: adobeDummyPdf, // <-- Uses a reliable dummy PDF link
  ),
  Product(
    id: 11,
    type: 'Resource',
    title: 'Generative AI Concepts',
    description: 'Free notes on LLMs, Transformers, and VAEs.',
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
    pdfUrl: smallDummyPdf, // <-- Uses a reliable small PDF link
  ),
  // --- EXISTING PRODUCTS CONTINUED ---
  Product(
    id: 5,
    type: 'Notes',
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
    // CLEANED: Only one instance of imageUrl is used
    imageUrl: 'https://picsum.photos/seed/econ/300/200',
    details:
        'A clearly articulated introduction to core Microeconomics principles. Designed to supplement introductory college lectures.',
    content:
        r'## The Law of Demand\nAs the price of a good or service increases, the quantity demanded decreases ($P \uparrow \implies Q_d \downarrow$). This inverse relationship is fundamental.',
    pdfUrl: smallDummyPdf, // <-- UPDATED from null to smallDummyPdf
  ),
  Product(
    id: 6,
    type: 'Books',
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
    // CLEANED: Only one instance of imageUrl is used
    imageUrl: 'https://picsum.photos/seed/design/300/200',
    details:
        'An inspiring book exploring how less can be more in digital and physical design. Features interviews with leading designers and practical tips.',
    content:
        '## Principle 3: Intentional White Space\nWhite space (or negative space) is not merely empty area; it is a critical design element that enhances readability and visual hierarchy.',
    pdfUrl: adobeDummyPdf, // <-- Working Adobe Dummy PDF
  ),
  Product(
    id: 7,
    type: 'Notes',
    title: 'Data Structures & Algorithms',
    description:
        'Detailed notes on Trees, Graphs, and Heaps for interview preparation.',
    price: 90,
    isFree: false,
    category: 'Tech',
    tags: ['Coding', 'Algorithms'],
    rating: 4.6,
    author: 'Code Master',
    pages: 75,
    reviewCount: 55,
    // CLEANED: Only one instance of imageUrl is used
    imageUrl: 'https://picsum.photos/seed/algo/300/200',
    details:
        'A rigorous set of notes focused on preparing for technical interviews. Includes complexity analysis and common interview questions.',
    content:
        '## Binary Search Trees (BST)\nA node-based binary tree data structure where the left subtree has keys < parent key and the right subtree has keys > parent key.',
    pdfUrl: smallDummyPdf, // <-- Working Small Dummy PDF
  ),
  Product(
    id: 8,
    type: 'Notes',
    title: 'The Solar System Explained',
    description:
        'Notes on planetary science, basic astrophysics, and space exploration.',
    price: 0,
    isFree: true,
    category: 'Science',
    tags: ['Free', 'Space'],
    rating: 4.9,
    author: 'AstroKid',
    pages: 20,
    reviewCount: 95,
    // CLEANED: Only one instance of imageUrl is used
    imageUrl: 'https://picsum.photos/seed/space/300/200',
    details:
        'A fun and fact-filled summary of our solar system, perfect for middle school students or anyone interested in astronomy.',
    content:
        r'## The Inner Planets\nMercury, Venus, Earth, and Mars are the four inner, terrestrial planets. Venus is the hottest due to its dense $\text{CO}_2$ atmosphere causing a runaway greenhouse effect.',
    pdfUrl: null, // Still null as it's free/simple content
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
    productIds: [4, 7, 9, 10], // Added new AI product IDs
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
