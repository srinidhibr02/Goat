/**
 * GOAT — Firestore Seed Script
 * Run with: node scripts/seed_data.js
 *
 * Prerequisites:
 *   npm install firebase-admin
 *   export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
 */

const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  projectId: 'goat-d3152',
});

const db = admin.firestore();

// ── Temple seed data ──────────────────────────────────────────────────────────

const temples = [
  {
    id: 'tirumala',
    name: 'Tirumala Venkateswara Temple',
    description:
      'One of the most visited pilgrimage sites in the world, dedicated to Lord Venkateswara (Vishnu). Situated on the Tirumala hills in Andhra Pradesh at an altitude of 853 metres.',
    imageUrl:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Tirumala_temple_view.jpg/640px-Tirumala_temple_view.jpg',
    latitude: 13.6837,
    longitude: 79.3474,
    city: 'Tirupati',
    state: 'Andhra Pradesh',
    category: 'vishnu',
    rating: 4.9,
    reviewCount: 158432,
    isVerified: true,
  },
  {
    id: 'meenakshi',
    name: 'Meenakshi Amman Temple',
    description:
      'A historic Hindu temple located on the southern bank of the Vaigai River. Dedicated to Goddess Meenakshi (Parvati) and her consort Sundareswarar (Shiva).',
    imageUrl:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/97/Madurai_Meenakshi_Amman_Temple_%28edit2%29.jpg/640px-Madurai_Meenakshi_Amman_Temple_%28edit2%29.jpg',
    latitude: 9.9195,
    longitude: 78.1193,
    city: 'Madurai',
    state: 'Tamil Nadu',
    category: 'shakti',
    rating: 4.8,
    reviewCount: 97210,
    isVerified: true,
  },
  {
    id: 'siddhivinayak',
    name: 'Siddhivinayak Temple',
    description:
      'A Hindu temple dedicated to Lord Ganesha in Prabhadevi, Mumbai. One of the richest temples in Maharashtra, it is said that wishes made here are always granted.',
    imageUrl:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/Siddhivinayak_Temple%2C_Mumbai.jpg/640px-Siddhivinayak_Temple%2C_Mumbai.jpg',
    latitude: 19.0172,
    longitude: 72.8302,
    city: 'Mumbai',
    state: 'Maharashtra',
    category: 'ganesha',
    rating: 4.7,
    reviewCount: 62445,
    isVerified: true,
  },
  {
    id: 'somnath',
    name: 'Somnath Temple',
    description:
      'One of the twelve Jyotirlinga shrines of Shiva and the first among them. Located on the western coast of Gujarat, it has been described as the shrine eternal.',
    imageUrl:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Somnath_temple_2014.jpg/640px-Somnath_temple_2014.jpg',
    latitude: 20.8880,
    longitude: 70.4017,
    city: 'Veraval',
    state: 'Gujarat',
    category: 'shiva',
    rating: 4.8,
    reviewCount: 51234,
    isVerified: true,
  },
  {
    id: 'kashi',
    name: 'Kashi Vishwanath Temple',
    description:
      'One of the most famous Hindu temples dedicated to Lord Shiva and is located in Vishwanath Gali, Varanasi. One of the twelve Jyotirlingas.',
    imageUrl:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9f/Kashi_Vishwanath_Temple.jpg/640px-Kashi_Vishwanath_Temple.jpg',
    latitude: 25.3109,
    longitude: 83.0107,
    city: 'Varanasi',
    state: 'Uttar Pradesh',
    category: 'shiva',
    rating: 4.9,
    reviewCount: 88760,
    isVerified: true,
  },
  {
    id: 'vaishno-devi',
    name: 'Vaishno Devi Temple',
    description:
      'A Hindu temple dedicated to the goddess Vaishno Devi, situated inside a cave in the Trikuta Mountains. One of the most visited pilgrimage sites in India.',
    imageUrl:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/10/Vaishno_Devi_Temple_Bhawan.jpg/640px-Vaishno_Devi_Temple_Bhawan.jpg',
    latitude: 32.9895,
    longitude: 74.9520,
    city: 'Katra',
    state: 'Jammu & Kashmir',
    category: 'shakti',
    rating: 4.9,
    reviewCount: 112300,
    isVerified: true,
  },
  {
    id: 'brihadeeswara',
    name: 'Brihadeeswara Temple',
    description:
      'A UNESCO World Heritage Site built by Rajaraja Chola I in 1010 CE, dedicated to Lord Shiva. Famous for its 66-metre vimana and the shadow that never falls on the ground.',
    imageUrl:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/Brihadeeswarar_Temple_Thanjavur.jpg/640px-Brihadeeswarar_Temple_Thanjavur.jpg',
    latitude: 10.7828,
    longitude: 79.1318,
    city: 'Thanjavur',
    state: 'Tamil Nadu',
    category: 'shiva',
    rating: 4.8,
    reviewCount: 43210,
    isVerified: true,
  },
  {
    id: 'jagannath',
    name: 'Jagannath Temple',
    description:
      'An important Hindu temple dedicated to Jagannath, a form of Vishnu, in Puri, Odisha. Famous for the Rath Yatra chariot festival held every year.',
    imageUrl:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/Jagannath_Temple_Puri.jpg/640px-Jagannath_Temple_Puri.jpg',
    latitude: 19.8048,
    longitude: 85.8179,
    city: 'Puri',
    state: 'Odisha',
    category: 'vishnu',
    rating: 4.8,
    reviewCount: 76540,
    isVerified: true,
  },
];

// ── Feed seed data ────────────────────────────────────────────────────────────

const now = new Date();
const daysAgo = (d) => new Date(now - d * 86400000).toISOString();
const daysFromNow = (d) => new Date(now.getTime() + d * 86400000).toISOString();

const feedPosts = [
  {
    id: 'post-1',
    templeId: 'tirumala',
    templeName: 'Tirumala Venkateswara Temple',
    templeImageUrl:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Tirumala_temple_view.jpg/640px-Tirumala_temple_view.jpg',
    title: 'Brahmotsavam 2025 — Schedule Released',
    body: 'The annual Brahmotsavam festival will be held from September 28 to October 6. Devotees are requested to book accommodation in advance via the TTD portal. Special darshan tokens will be available.',
    type: 'festival',
    publishedAt: daysAgo(1),
    eventDate: daysFromNow(60),
    imageUrl: null,
  },
  {
    id: 'post-2',
    templeId: 'meenakshi',
    templeName: 'Meenakshi Amman Temple',
    templeImageUrl:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/97/Madurai_Meenakshi_Amman_Temple_%28edit2%29.jpg/640px-Madurai_Meenakshi_Amman_Temple_%28edit2%29.jpg',
    title: 'Special Abishekam on Aadi Pooram',
    body: 'A grand Abishekam ceremony will be conducted for Goddess Meenakshi on Aadi Pooram. The event starts at 5:00 AM. Prasad distribution will be open to all devotees.',
    type: 'event',
    publishedAt: daysAgo(2),
    eventDate: daysFromNow(7),
    imageUrl: null,
  },
  {
    id: 'post-3',
    templeId: 'siddhivinayak',
    templeName: 'Siddhivinayak Temple',
    templeImageUrl: null,
    title: 'Online Darshan Booking Now Available',
    body: 'Siddhivinayak Temple Trust is pleased to announce that devotees can now book darshan slots online through the GOAT app. Walk-in queues will continue to be available every Tuesday.',
    type: 'announcement',
    publishedAt: daysAgo(3),
    eventDate: null,
    imageUrl: null,
  },
  {
    id: 'post-4',
    templeId: 'kashi',
    templeName: 'Kashi Vishwanath Temple',
    templeImageUrl: null,
    title: 'New Corridor Expansion Opens to Devotees',
    body: 'The newly built Kashi Vishwanath Corridor has been opened to the public, offering a seamless pathway from the ghats to the sanctum. Visitor capacity has tripled with the new facilities.',
    type: 'news',
    publishedAt: daysAgo(4),
    eventDate: null,
    imageUrl: null,
  },
  {
    id: 'post-5',
    templeId: 'jagannath',
    templeName: 'Jagannath Temple',
    templeImageUrl: null,
    title: 'Rath Yatra 2025 — Registration Open',
    body: 'Registration for the annual Rath Yatra procession is now open. Volunteers and devotees wishing to pull the chariot are requested to register by the 15th. Free prasad will be distributed.',
    type: 'festival',
    publishedAt: daysAgo(5),
    eventDate: daysFromNow(30),
    imageUrl: null,
  },
];

// ── Seeding functions ─────────────────────────────────────────────────────────

async function seedTemples() {
  console.log('Seeding temples...');
  const batch = db.batch();
  for (const temple of temples) {
    const { id, ...data } = temple;
    batch.set(db.collection('temples').doc(id), data);
  }
  await batch.commit();
  console.log(`✅ Seeded ${temples.length} temples`);
}

async function seedFeed() {
  console.log('Seeding feed posts...');
  const batch = db.batch();
  for (const post of feedPosts) {
    const { id, ...data } = post;
    batch.set(db.collection('feed').doc(id), data);
  }
  await batch.commit();
  console.log(`✅ Seeded ${feedPosts.length} feed posts`);
}

async function main() {
  try {
    await seedTemples();
    await seedFeed();
    console.log('\n🎉 Seeding complete!');
    process.exit(0);
  } catch (err) {
    console.error('❌ Seeding failed:', err);
    process.exit(1);
  }
}

main();
