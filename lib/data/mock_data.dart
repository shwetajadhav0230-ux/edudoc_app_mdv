// Auto-generated mock data from main.dart

import '../models/product.dart';
import '../models/offer.dart';
import '../models/transaction.dart';
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
    imageUrl: 'https://picsum.photos/seed/ww2/300/200',
    details:
        'In-depth guide to Calculus I, focusing on integration techniques and fundamental theorem applications.',
    content:
        r'## Chapter 1: The Antiderivative\nFormula: $\int f(x) dx = F(x) + C$. The Fundamental Theorem is $\int_{a}^{b} f(x) dx = F(b) - F(a)$.\n\n## Chapter 2: Substitution\nEffective integration uses substitution (u-substitution) to simplify functions. **Rule**: Always check your differentials.',
    pdfUrl:
        'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',

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
    details:
        'Rich, multimedia-ready eBook detailing the major events, political dynamics, and geographical shifts of World War II.',
    content:
        '## Prelude to War\nThe 1930s saw the rapid rise of totalitarian regimes in Germany and Japan. The failure of the League of Nations was a major factor.\n\n### The Eastern Front\nThe battle for Stalingrad (1942-1943) is considered the turning point, halting the German advance.',
    pdfUrl: null,
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
    details:
        'Guided prompts designed to improve mental clarity, reduce stress, and foster a positive mindset.',
    content:
        '## Day 1: Grounding\n**Morning Prompt**: List three sensory details you notice right now. **Evening Reflection**: What is one small success you achieved today?',
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
    details:
        'For developers who already know React basics. Covers useState, useEffect, useMemo, useCallback, and creating reusable custom hooks for enterprise applications.',
    content:
        '## Custom Hooks\nCustom hooks are reusable functions for sharing stateful logic. Example: `useToggle` manages boolean state.',
  ),
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
    details:
        'A clearly articulated introduction to core Microeconomics principles. Designed to supplement introductory college lectures.',
    content:
        r'## The Law of Demand\nAs the price of a good or service increases, the quantity demanded decreases ($P \uparrow \implies Q_d \downarrow$). This inverse relationship is fundamental.',
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
    details:
        'An inspiring book exploring how less can be more in digital and physical design. Features interviews with leading designers and practical tips.',
    content:
        '## Principle 3: Intentional White Space\nWhite space (or negative space) is not merely empty area; it is a critical design element that enhances readability and visual hierarchy.',
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
    details:
        'A rigorous set of notes focused on preparing for technical interviews. Includes complexity analysis and common interview questions.',
    content:
        '## Binary Search Trees (BST)\nA node-based binary tree data structure where the left subtree has keys < parent key and the right subtree has keys > parent key.',
  ),
  Product(
    id: 8,
    type: 'Notes',
    title: 'The Solar System Explained',
    description:
        'Notes on planetary science, basic astrophyics, and space exploration.',
    price: 0,
    isFree: true,
    category: 'Science',
    tags: ['Free', 'Space'],
    rating: 4.9,
    author: 'AstroKid',
    pages: 20,
    reviewCount: 95,
    details:
        'A fun and fact-filled summary of our solar system, perfect for middle school students or anyone interested in astronomy.',
    content:
        r'## The Inner Planets\nMercury, Venus, Earth, and Mars are the four inner, terrestrial planets. Venus is the hottest due to its dense $\text{CO}_2$ atmosphere causing a runaway greenhouse effect.',
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
    productIds: [4, 7],
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
];
