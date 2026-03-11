import { useState, useEffect, useContext } from "react";
import { useNavigate } from "react-router-dom";
import { AuthContext } from "../services/AuthContext";
import "../Css/ProfileUpdate.css";

const SERVER_URL = "https://thoutha.page/api";
const YEARS = [ "الرابعة", "الخامسة", "خريج"];

const isTokenExpired = (token) => {
  try {
    const payload = JSON.parse(atob(token.split(".")[1]));
    return payload.exp * 1000 < Date.now();
  } catch {
    return true;
  }
};

export default function ProfileUpdate() {
  const { user, login, logout } = useContext(AuthContext);
  const navigate = useNavigate();
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
    // Pre-fill from stored user
    if (user) {
      setForm({
        firstName:      user.firstName      || user.first_name  || "",
        lastName:       user.lastName       || user.last_name   || "",
        email:          user.email          || "",
        phone:          user.phone          || "",
        faculty:        user.faculty        || user.universityName || "",
        year:           user.year           || user.studyYear   || "",
        city:           user.city           || "",
        specialization: user.specialization || "",
      });
    }

    let cancelled = false;
    Promise.all([
      fetch(`${SERVER_URL}/cities/getAllCities`).then((r) => r.json()),
      fetch(`${SERVER_URL}/university/getAllUniversities`).then((r) => r.json()),
      fetch(`${SERVER_URL}/category/getCategories`).then((r) => r.json()),
    ])
      .then(([cityData, uniData, catData]) => {
        if (cancelled) return;
        setCities(Array.isArray(cityData)   ? cityData.map((c) => c.name || c)   : []);
        setUniversities(Array.isArray(uniData) ? uniData.map((u) => u.name || u) : []);
        setCategories(Array.isArray(catData)   ? catData.map((c) => c.name || c) : []);
        setLoading(false);
      })
      .catch(() => {
        if (!cancelled) {
          setError("حدث خطأ أثناء تحميل البيانات. حاول مرة أخرى.");
          setLoading(false);
        }
      });
    return () => { cancelled = true; };
  }, [user]);

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
      const token = user?.token || localStorage.getItem("token");
      if (!token || isTokenExpired(token)) {
        logout();
        navigate("/login");
        return;
      }
      const response = await fetch(`${SERVER_URL}/doctor/updateDoctor`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
          firstName:      form.firstName,
          lastName:       form.lastName,
          email:          form.email,
          phone:          form.phone,
          universityName: form.faculty,
          studyYear:      form.year,
          cityName:       form.city,
          categoryName:   form.specialization,
        }),
      });
      if (!response.ok) {
        const data = await response.json().catch(() => ({}));
        throw new Error(data?.message || data?.messageAr || "فشل حفظ البيانات");
      }
      // Update stored user with new values
      login({ ...user, ...form, faculty: form.faculty, universityName: form.faculty });
      // Store full profile so AddRequest can use it for category updates
      localStorage.setItem("doctorFullProfile", JSON.stringify({
        firstName:      form.firstName,
        lastName:       form.lastName,
        email:          form.email,
        phone:          form.phone,
        universityName: form.faculty,
        studyYear:      form.year,
        cityName:       form.city,
        categoryName:   form.specialization,
      }));
      showToast("success", "تم حفظ البيانات بنجاح ✓");
    } catch (err) {
      showToast("error", err.message || "فشل حفظ البيانات. حاول مرة أخرى.");
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
