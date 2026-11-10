# Beat Resource Mapping / बीट संसाधन मानचित्रण

Ground staff open one link on their phone → fill place details → GPS location + photo get saved.
Officers log in to the dashboard → see everything on a map, PS-wise and beat-wise → download to Excel.

स्टाफ फोन पर एक लिंक खोलकर स्थान की जानकारी, GPS लोकेशन और फोटो भरते हैं।
अधिकारी डैशबोर्ड पर लॉगिन करके थाना-वार / बीट-वार नक्शे पर सब देखते हैं और एक्सेल में डाउनलोड करते हैं।

**Cost: ₹0.** Vercel (website) + Supabase (database), both on free plans.
Free limits: 500 MB data (lakhs of entries) and 1 GB photos (about 5,000–8,000 photos).

| File | What it is |
|---|---|
| `index.html` | Staff entry form (mobile) / स्टाफ एंट्री फॉर्म |
| `dashboard.html` | Officer dashboard (map, summary, Excel) / अधिकारी डैशबोर्ड |
| `config.js` | **Only file you edit**: keys, PS list, beats / केवल यही फ़ाइल बदलें |
| `supabase_setup.sql` | Database setup, run once / डेटाबेस सेटअप, एक बार चलाएँ |

---

## STEP 1 – Create the free database (Supabase) · मुफ़्त डेटाबेस बनाएँ (≈10 min)

1. Go to **https://supabase.com** → *Start your project* → sign in with Google/GitHub.
2. **New project** → name `beat-mapping` → set a DB password (save it) → Region **Mumbai (ap-south-1)** → Create.
3. Wait ~2 minutes. Then open **SQL Editor → New query**.
4. Open `supabase_setup.sql`, and **before running it, change 1 line**:
   - `'your.email@example.com'` → **your email** (the officer who will log in) / अपना ईमेल
   (The staff PIN starts as `1234`. You will change it from the dashboard in Step 4.)
5. Paste the whole file → **Run**. You should see "Success".
6. **Authentication → Users → Add user → Create new user** → same email + a strong password → tick *Auto Confirm User*.
7. **Authentication → Sign In / Providers → turn OFF "Allow new users to sign up"** (important for security / सुरक्षा के लिए ज़रूरी).
8. **Project Settings → API Keys**: copy the **Project URL** and the **anon / publishable key**.

More officers (SP, SDOP, SHO etc.): add their email in **Table Editor → officers** and create their user in step 6.
अधिक अधिकारी जोड़ने के लिए: `officers` तालिका में ईमेल जोड़ें और Step 6 से उनका यूज़र बनाएँ।

## STEP 2 – Edit `config.js` · config.js भरें

- Paste `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
- Write your district name and the **list of police stations**.
- *(Optional, recommended)* fill `BEATS` so staff pick beats from a list. This keeps beat numbers uniform in the dashboard.
- Set `MAP_CENTER` to your district's latitude/longitude (right-click on Google Maps to copy it).

## STEP 3 – Put the website on Vercel (free) · वेबसाइट Vercel पर डालें

**Easy way (no coding):**
1. Create a free account at **https://github.com** → **New repository** → name `beat-mapping` → **Private** → Create.
2. Click **"uploading an existing file"** → drag all files from this folder → **Commit changes**.
3. Go to **https://vercel.com** → *Sign up with GitHub* → **Add New → Project** → import `beat-mapping` → **Deploy** (no settings needed).
4. You get a link like `https://beat-mapping-xyz.vercel.app`.

To change something later (e.g. add a PS): edit `config.js` on GitHub → Commit. Vercel updates the site in about 30 seconds.

## STEP 4 – Set your staff PIN and share · स्टाफ पिन तय करें और लिंक भेजें

1. Open `https://YOUR-SITE.vercel.app/dashboard` → log in → press **🔑 Staff PIN** → type your PIN (e.g. `4826`) → OK.
   डैशबोर्ड में **🔑 स्टाफ पिन** दबाएँ → अपना पिन लिखें → OK.
2. Send staff only the plain link plus the PIN. **No email or login for staff.**

| Who | What they get |
|---|---|
| **Ground staff** | `https://YOUR-SITE.vercel.app` + the PIN (say it on the phone or in the group) |
| **Officers** | `https://YOUR-SITE.vercel.app/dashboard` (email + password) |

- Staff type the PIN **once**. The phone remembers it after that.
- **To change the PIN** (e.g. someone was transferred or the PIN leaked): use 🔑 Staff PIN on the dashboard. Phones with the old PIN are asked for the new one on their next Submit. Whatever they typed is kept, and saved offline entries are sent after the new PIN is entered.
- पिन बदलने पर पुराने पिन वाले फोन अगली बार "जमा करें" दबाने पर नया पिन माँगेंगे। भरी हुई जानकारी नहीं मिटेगी।

---

## Message for staff (copy to WhatsApp) / स्टाफ के लिए संदेश

> **बीट संसाधन मानचित्रण – निर्देश**
> 1. यह लिंक खोलें: (लिंक) – पिन डालें: (पिन)। फिर पहली बार अपना नाम, थाना और बीट भरें (आगे अपने-आप भरा रहेगा)।
> 2. हर एटीएम, बैंक, स्कूल, बस स्टैंड, मंदिर, मस्जिद, हॉटस्पॉट, संवेदनशील स्थान **पर जाकर खड़े हों**।
> 3. स्थान का प्रकार चुनें → नाम लिखें → **"📍 मेरी लोकेशन लें"** दबाएँ → पिन आने तक रुकें।
> 4. फोटो लें → **"✅ जमा करें"** → **"➕ अगला स्थान जोड़ें"**।
> 5. फोन की Location (GPS) चालू रखें। इंटरनेट न हो तो भी एंट्री सेव रहेगी, बाद में अपने-आप चली जाएगी।
> 6. Tip: Chrome में ⋮ → "Add to Home screen" करने से ऐप जैसा आइकन बन जाएगा।

---

## Dashboard features / डैशबोर्ड की सुविधाएँ
- Filters: PS → Beat → Category → Sensitivity → Date → Search
- Map with coloured icons. The ring colour shows sensitivity (green / orange / red). Switch between Street and Satellite. Nearby points are grouped.
- Click a pin to see details, photo and Google Maps link, mark it verified, or delete it.
- PS / Beat-wise summary table: click any row to filter to it.
- **⬇ Excel / CSV**: downloads the filtered data (Hindi shows correctly in Excel).
- Hindi / English switch.

## Security / सुरक्षा
- Staff can **only add** entries, and only with the correct PIN. Staff can never see anyone's data or the PIN.
- Only officers can see or change the PIN.
- Only emails in the `officers` table can see the dashboard data and photos.
- Photos are kept private and open only through time-limited links.
- The site tells search engines not to list it (`noindex`).

## Troubleshooting / समस्या समाधान
- **"App is not set up yet"**: `config.js` URL/key not filled.
- **Location not coming**: turn on phone GPS, allow location for Chrome, stand in the open. Or use "Mark on map".
- **"Wrong PIN"**: check the current PIN with 🔑 Staff PIN on the dashboard.
- **Staff phone wants to lock / use a different PIN**: tap "🔒 Change PIN / lock" at the bottom of the form.
- **Dashboard says email not in officers list**: add the email to the `officers` table (spelling must match).
- **Supabase free project pauses after 7 days with no use**: open the Supabase dashboard and click *Restore*. Daily use keeps it active.
