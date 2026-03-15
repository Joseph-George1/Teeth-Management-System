import { useState, useEffect, useContext } from "react";
import { useNavigate } from "react-router-dom";
import { AuthContext } from "../services/AuthContext";
import { showForbiddenPage } from "../services/forbiddenState";
import "../Css/ProfileUpdate.css";

const SERVER_URL = import.meta.env.DEV ? "/api" : "https://thoutha.page/api";
const YEAR_OPTIONS = [
  { value: "4", label: "الرابعة" },
  { value: "5", label: "الخامسة" },
  { value: "خريج", label: "خريج" },
];

const decodeTokenPayload = (token) => {
  try {
    const payloadPart = token?.split(".")?.[1];
    if (!payloadPart) return null;

    const normalized = payloadPart.replace(/-/g, "+").replace(/_/g, "/");
    const padded = normalized.padEnd(Math.ceil(normalized.length / 4) * 4, "=");

    return JSON.parse(atob(padded));
  } catch {
    return null;
  }
};

const isTokenExpired = (token) => {
  const payload = decodeTokenPayload(token);
  if (!payload) return true;
  if (!payload.exp) return false;

  return payload.exp * 1000 < Date.now();
};

const normalizeStudyYearValue = (value) => {
  const normalizedValue = value?.toString().trim() || "";

  if (normalizedValue === "الرابعة") return "4";
  if (normalizedValue === "الخامسة") return "5";

  return normalizedValue;
};

const mapUserToForm = (userData) => ({
  firstName: userData?.firstName || userData?.first_name || "",
  lastName: userData?.lastName || userData?.last_name || "",
  email: userData?.email || "",
  phone: userData?.phone || userData?.phoneNumber || "",
  faculty: userData?.faculty || userData?.universityName || "",
  year: normalizeStudyYearValue(userData?.year || userData?.studyYear || ""),
  city: userData?.city || userData?.cityName || "",
  specialization: userData?.specialization || userData?.categoryName || "",
});

const buildUpdatePayload = (formData) => {
  const payload = {
    firstName: formData.firstName.trim(),
    lastName: formData.lastName.trim(),
    email: formData.email.trim(),
    phoneNumber: formData.phone.trim(),
    cityName: formData.city.trim(),
    studyYear: normalizeStudyYearValue(formData.year),
    categoryName: formData.specialization.trim(),
    universityName: formData.faculty.trim(),
  };

  return Object.fromEntries(
    Object.entries(payload).filter(([, value]) => value !== "")
  );
};

const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
const FORBIDDEN_REQUEST_ERROR = "FORBIDDEN_REQUEST_ERROR";

const fetchJsonWithForbidden = async (url, options) => {
  const response = await fetch(url, options);

  if (response.status === 403) {
    showForbiddenPage();
    throw new Error(FORBIDDEN_REQUEST_ERROR);
  }

  return response.json();
};

export default function ProfileUpdate() {
  const { user, logout, refreshUserProfile, applyServerUserData } = useContext(AuthContext);
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
      setForm(mapUserToForm(user));
    }

    let cancelled = false;
    Promise.all([
      fetchJsonWithForbidden(`${SERVER_URL}/cities/getAllCities`),
      fetchJsonWithForbidden(`${SERVER_URL}/university/getAllUniversities`),
      fetchJsonWithForbidden(`${SERVER_URL}/category/getCategories`),
    ])
      .then(([cityData, uniData, catData]) => {
        if (cancelled) return;
        setCities(Array.isArray(cityData)   ? cityData.map((c) => c.name || c)   : []);
        setUniversities(Array.isArray(uniData) ? uniData.map((u) => u.name || u) : []);
        setCategories(Array.isArray(catData)   ? catData.map((c) => c.name || c) : []);
        setLoading(false);
      })
      .catch((requestError) => {
        if (!cancelled && requestError.message !== FORBIDDEN_REQUEST_ERROR) {
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

      const updatePayload = buildUpdatePayload(form);

      if (Object.keys(updatePayload).length === 0) {
        showToast("error", "لا توجد بيانات لإرسالها");
        setSaving(false);
        return;
      }

      const response = await fetch(`${SERVER_URL}/doctor/updateDoctor`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(updatePayload),
      });

      if (response.status === 403) {
        showForbiddenPage();
        return;
      }

      const responseData = await response.json().catch(() => null);

      if (!response.ok) {
        throw new Error(responseData?.message || responseData?.messageAr || "فشل حفظ البيانات");
      }

      let latestServerUser = null;

      if (responseData) {
        latestServerUser = applyServerUserData(responseData, token);
        if (latestServerUser) {
          setForm(mapUserToForm(latestServerUser));
        }
      }

      try {
        await wait(250);
        latestServerUser = await refreshUserProfile(token);
        setForm(mapUserToForm(latestServerUser));
      } catch (refreshError) {
        if (!latestServerUser) {
          throw refreshError;
        }
      }

      showToast("success", "تم حفظ البيانات بنجاح ✓");
    } catch (err) {
      if (err.message !== FORBIDDEN_REQUEST_ERROR) {
        showToast("error", err.message || "فشل حفظ البيانات. حاول مرة أخرى.");
      }
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
                {YEAR_OPTIONS.map((yearOption) => (
                  <option key={yearOption.value} value={yearOption.value}>{yearOption.label}</option>
                ))}
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
