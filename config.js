// =====================================================================
//  EDIT THIS FILE ONLY  /  केवल इसी फ़ाइल में बदलाव करें
// =====================================================================
window.APP_CONFIG = {
  // Supabase → Project Settings → API Keys
  // "Project URL" और "anon / publishable" key यहाँ डालें
  SUPABASE_URL: "https://yokzsbtvdfgzfpafiqba.supabase.co",
  SUPABASE_ANON_KEY: "sb_publishable_da6DuALcyvluwm534T10dQ_1HPEoZM3",

  // Shown on top of the form / फॉर्म के ऊपर दिखेगा
  DISTRICT_NAME: "Karnal Police / जिला पुलिस",

  // Your Police Stations / आपके थानों की सूची
  POLICE_STATIONS: [
    "PS Assandh"
    "PS Butana"
    "PS City"
    "PS Civil Line"
    "PS Cyber Crime"
    "PS Gharaunda"
    "PS Indri"
    "PS Kunjpura"
    "PS Madhuban"
    "PS Munak"
    "PS Nighdu"
    "PS Nissing"
    "PS Ram Nagar"
    "PS Sadar"
    "PS Sector 32 & 33"
    "PS Taraori"
  ],

  // OPTIONAL: fixed beat list per PS (keeps beat numbers uniform).
  // वैकल्पिक: थाना-वार बीट सूची। जिस थाने की सूची यहाँ है, स्टाफ सूची से बीट चुनेगा;
  // बाकी थानों में स्टाफ बीट नंबर/नाम खुद लिखेगा।
  BEATS: {
    // "Kotwali": [["1", "Sadar Bazar"], ["2", "Station Road"], ["3", "Old City"]],
    // "Civil Lines": [["1", "Collectorate"], ["2", "University"]]
  },

  // Map starting point (your district centre) / नक्शे का प्रारंभिक केंद्र
  MAP_CENTER: [29.6800, 76.9800],
  MAP_ZOOM: 12
};
