import { useState, useEffect } from "react";
import "../Css/ProfileUpdate.css";

// ─── Mock API functions (replace with real calls later) ───────────────────────
const fetchProfile = async () => {
  await delay(600);
  return {
    firstName: "أحمد",
    lastName: "محمد",
    email: "doctor@example.com",
    phone: "01012345678",
    faculty: "",
    year: "",
    city: "",
    specialization: "",
    profileImage: null,
  };
};

const fetchCities = async () => {
  await delay(400);
  return [
    "القاهرة", "الإسكندرية", "الجيزة", "الشرقية", "الدقهلية",
    "البحيرة", "المنوفية", "القليوبية", "الغربية", "كفر الشيخ",
    "دمياط", "بورسعيد", "الإسماعيلية", "السويس", "شمال سيناء",
    "جنوب سيناء", "الفيوم", "بني سويف", "المنيا", "أسيوط",
    "سوهاج", "قنا", "الأقصر", "أسوان", "البحر الأحمر",
    "الوادي الجديد", "مطروح",
  ];
};

const fetchUniversities = async () => {
  await delay(400);
  return [
    "كلية طب الأسنان - جامعة القاهرة",
    "كلية طب الأسنان - جامعة عين شمس",
    "كلية طب الأسنان - جامعة الإسكندرية",
    "كلية طب الأسنان - جامعة المنصورة",
    "كلية طب الأسنان - جامعة أسيوط",
    "كلية طب الأسنان - جامعة طنطا",
    "كلية طب الأسنان - جامعة المنوفية",
  ];
};

const fetchCategories = async () => {
  await delay(400);
  return [
    "تقويم الأسنان",
    "زراعة الأسنان",
    "تيجان الأسنان / التركيبات",
    "حشوات الأسنان",
    "تبييض الأسنان",
    "خلع الأسنان",
    "فحص شامل للأسنان",
  ];
};

const updateProfile = async (data) => {
  await delay(800);
  // Replace with: await fetch('/api/profile', { method: 'PUT', body: JSON.stringify(data) })
  return { success: true };
};

const YEARS = ["الأولى", "الثانية", "الثالثة", "الرابعة", "الخامسة", "خريج"];

const delay = (ms) => new Promise((r) => setTimeout(r, ms));
// ─────────────────────────────────────────────────────────────────────────────

export default function ProfileUpdate() {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState(null);
  const [toast, setToast] = useState(null);

  const [cities, setCities] = useState([]);
  const [universities, setUniversities] = useState([]);
  const [categories, setCategories] = useState([]);

  const [form, setForm] = useState({
    firstName: "",
    lastName: "",
    email: "",
    phone: "",
    faculty: "",
    year: "",
    city: "",
    specialization: "",
  });

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    Promise.all([fetchProfile(), fetchCities(), fetchUniversities(), fetchCategories()])
      .then(([profile, cityList, uniList, catList]) => {
        if (cancelled) return;
        setForm((prev) => ({ ...prev, ...profile }));
        setCities(cityList);
        setUniversities(uniList);
        setCategories(catList);
        setLoading(false);
      })
      .catch(() => {
        if (!cancelled) {
          setError("حدث خطأ أثناء تحميل البيانات. حاول مرة أخرى.");
          setLoading(false);
        }
      });
    return () => { cancelled = true; };
  }, []);

  const showToast = (type, msg) => {
    setToast({ type, msg });
    setTimeout(() => setToast(null), 3500);
  };

  const handleChange = (field) => (e) =>
    setForm((prev) => ({ ...prev, [field]: e.target.value }));

  const handleSave = async () => {
    if (!form.firstName.trim() || !form.lastName.trim()) {
      showToast("error", "الاسم الأول واسم العائلة مطلوبان.");
      return;
    }
    setSaving(true);
    try {
      const result = await updateProfile(form);
      if (result.success) showToast("success", "تم حفظ البيانات بنجاح ✓");
    } catch {
      showToast("error", "فشل حفظ البيانات. حاول مرة أخرى.");
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="dp-loading-screen" dir="rtl">
        <div className="dp-spinner"></div>
        <p>جاري تحميل البيانات...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="dp-error-screen" dir="rtl">
        <p>{error}</p>
        <button onClick={() => window.location.reload()} className="dp-retry-btn">
          إعادة المحاولة
        </button>
      </div>
    );
  }

  return (
    <div className="dp-page" dir="rtl">
      {toast && (
        <div className={`dp-toast dp-toast--${toast.type}`}>{toast.msg}</div>
      )}

      <header className="dp-header">
        <span className="dp-header-title">تحديث الملف الشخصي</span>
      </header>

      <main className="dp-content">
        <div className="dp-card">

          <div className="dp-section-title">المعلومات الشخصية</div>
          <div className="dp-fields-grid">
            <Field label="الاسم الأول" required>
              <input className="dp-input" type="text" placeholder="الاسم الأول" value={form.firstName} onChange={handleChange("firstName")} />
            </Field>
            <Field label="اسم العائلة" required>
              <input className="dp-input" type="text" placeholder="اسم العائلة" value={form.lastName} onChange={handleChange("lastName")} />
            </Field>
            <Field label="البريد الإلكتروني">
              <input className="dp-input" type="email" placeholder="example@email.com" value={form.email} onChange={handleChange("email")} dir="ltr" />
            </Field>
            <Field label="رقم الهاتف">
              <input className="dp-input" type="tel" placeholder="01XXXXXXXXX" value={form.phone} onChange={handleChange("phone")} dir="ltr" />
            </Field>
          </div>

          <div className="dp-divider" />

          <div className="dp-section-title">المعلومات الأكاديمية</div>
          <div className="dp-fields-grid">
            <Field label="الكلية">
              <select className="dp-select" value={form.faculty} onChange={handleChange("faculty")}>
                <option value="">اختر الكلية</option>
                {universities.map((u) => <option key={u} value={u}>{u}</option>)}
              </select>
            </Field>
            <Field label="الفرقة الدراسية">
              <select className="dp-select" value={form.year} onChange={handleChange("year")}>
                <option value="">اختر الفرقة</option>
                {YEARS.map((y) => <option key={y} value={y}>{y}</option>)}
              </select>
            </Field>
            <Field label="المحافظة">
              <select className="dp-select" value={form.city} onChange={handleChange("city")}>
                <option value="">اختر المحافظة</option>
                {cities.map((c) => <option key={c} value={c}>{c}</option>)}
              </select>
            </Field>
            <Field label="التخصص">
              <select className="dp-select" value={form.specialization} onChange={handleChange("specialization")}>
                <option value="">اختر التخصص</option>
                {categories.map((cat) => <option key={cat} value={cat}>{cat}</option>)}
              </select>
            </Field>
          </div>

          <button className="dp-save-btn" onClick={handleSave} disabled={saving}>
            {saving ? "جاري الحفظ..." : "حفظ التغييرات"}
          </button>

        </div>
      </main>
    </div>
  );
}

function Field({ label, required, children }) {
  return (
    <div className="dp-field">
      <label className="dp-label">
        {label}
        {required && <span className="dp-required"> *</span>}
      </label>
      {children}
    </div>
  );
}
