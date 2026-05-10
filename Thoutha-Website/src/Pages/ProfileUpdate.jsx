import { useState, useEffect, useContext } from "react";
import { useNavigate } from "react-router-dom";
import { AuthContext } from "../services/AuthContext";
import "../Css/ProfileUpdate.css";

/* ── SVG Icons ── */
const sv = (d, extra = {}) => (
  <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2} {...extra}>
    <path strokeLinecap="round" strokeLinejoin="round" d={d} />
  </svg>
);

const EditIcon = () => sv("M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z");
const UserIcon = () => sv("M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z");
const PersonIcon = () => sv("M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z");
const EmailIcon = () => sv("M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z");
const PhoneIcon = () => sv("M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z");
const MedIcon = () => sv("M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z");
const CollegeIcon = () => (
  <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
    <path d="M12 14l9-5-9-5-9 5 9 5z" /><path d="M12 14l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z" />
  </svg>
);
const BookIcon = () => sv("M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253");
const PinIcon = () => sv("M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0zM15 11a3 3 0 11-6 0 3 3 0 016 0z");
const SaveIcon = () => sv("M17 3H5a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2V7l-4-4zm-5 16a3 3 0 110-6 3 3 0 010 6zm3-10H5V5h10v4z");
const CancelIcon = () => sv("M6 18L18 6M6 6l12 12");

const SERVER_URL = import.meta.env.DEV ? "/api" : "https://thoutha.page/api";
const YEAR_OPTIONS = [
  { value: "الرابعة", label: "الرابعة" },
  { value: "الخامسة", label: "الخامسة" },
  { value: "امتياز", label: "امتياز" },
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

  if (normalizedValue === "الرابعة") return "الرابعة";
  if (normalizedValue === "الخامسة") return "الخامسة";
   if (normalizedValue === "امتياز") return "امتياز";

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
      showToast("error", err.message || "فشل حفظ البيانات. حاول مرة أخرى.");
    } finally {
      setSaving(false);
    }
  };

  const handleCancel = () => {
    navigate(-1);
  };

  if (loading) {
    return (
      <div className="pu-loading-screen" dir="rtl">
        <div className="pu-spinner"></div>
        <p>جاري تحميل البيانات...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="pu-error-screen" dir="rtl">
        <p>{error}</p>
        <button onClick={() => window.location.reload()} className="pu-retry-btn">
          إعادة المحاولة
        </button>
      </div>
    );
  }

  const css = `
    @import url('https://fonts.googleapis.com/css2?family=Tajawal:wght@300;400;500;700;800&display=swap');

    @keyframes fadeInUp {
      from { opacity:0; transform:translateY(20px); }
      to   { opacity:1; transform:translateY(0); }
    }
    @keyframes floatA {
      0%,100% { transform:translate(0,0) scale(1); }
      50%     { transform:translate(15px,-15px) scale(1.04); }
    }
    @keyframes floatB {
      0%,100% { transform:translate(0,0) scale(1); }
      50%     { transform:translate(-12px,12px) scale(1.03); }
    }

    .primary-btn {
      transition: transform 0.2s, box-shadow 0.2s, filter 0.2s !important;
    }
    .primary-btn:hover {
      transform: translateY(-2px) !important;
      box-shadow: 0 14px 36px rgba(29,97,231,0.4) !important;
      filter: brightness(1.07);
    }
    .primary-btn:active { transform: translateY(0) !important; }

    .secondary-btn {
      transition: all 0.2s !important;
    }
    .secondary-btn:hover {
      background: rgba(29,97,231,0.07) !important;
      transform: translateY(-2px) !important;
    }
    .secondary-btn:active { transform: translateY(0) !important; }

    input::placeholder { color: #B6B6B6; font-family: 'Tajawal', sans-serif; }
    input:focus, select:focus { outline: none; }
    select option { font-family: 'Tajawal', sans-serif; }

    @media (max-width: 580px) {
      .form-row { flex-direction: column !important; }
    }
  `;

  return (
    <div className="pu-root" dir="rtl">
      <style>{css}</style>

      {/* Toast notification */}
      {toast && (
        <div className={`pu-toast pu-toast--${toast.type}`}>{toast.msg}</div>
      )}

      {/* Decorative blobs */}
      <div className="pu-blob pu-blob1" />
      <div className="pu-blob pu-blob2" />
      <div className="pu-blob pu-blob3" />

      <div className="pu-wrapper">

        {/* Page Header */}
        <div className="pu-page-header">
          <div className="pu-icon-wrap">
            <EditIcon />
          </div>
          <div>
            <h1 className="pu-page-title">تحديث الملف الشخصي</h1>
            <p className="pu-page-subtitle">قم بتحديث بيانات حسابك بسهولة</p>
          </div>
        </div>

        {/* Form Card */}
        <form onSubmit={(e) => { e.preventDefault(); handleSave(); }} className="pu-card">

          {/* Avatar Strip */}
          <div className="pu-avatar-strip">
            <div className="pu-avatar-circle">
              <span className="pu-avatar-initials">
                {form.firstName?.[0]}
              </span>
            </div>
            <div>
              <p className="pu-avatar-name">{form.firstName} {form.lastName}</p>
              <p className="pu-avatar-sub">{form.specialization || "تخصص"}</p>
            </div>
          </div>

          <div className="pu-section-divider" />

          {/* Section label */}
          <p className="pu-section-label">
            <UserIcon /> البيانات الشخصية
          </p>

          {/* Row 1 */}
          <div className="pu-row">
            <Field
              label="الاسم الأول"
              icon={<PersonIcon />}
            >
              <input
                type="text"
                name="firstName"
                value={form.firstName}
                onChange={handleChange("firstName")}
                placeholder="أدخل الاسم الأول"
                className="pu-input"
              />
            </Field>
            <Field
              label="اسم العائلة"
              icon={<PersonIcon />}
            >
              <input
                type="text"
                name="lastName"
                value={form.lastName}
                onChange={handleChange("lastName")}
                placeholder="أدخل اسم العائلة"
                className="pu-input"
              />
            </Field>
          </div>

          {/* Row 2 */}
          <div className="pu-row">
            <Field
              label="البريد الإلكتروني"
              icon={<EmailIcon />}
            >
              <input
                type="email"
                name="email"
                value={form.email}
                onChange={handleChange("email")}
                placeholder="example@email.com"
                className="pu-input"
                dir="ltr"
              />
            </Field>
            <Field
              label="رقم الهاتف"
              icon={<PhoneIcon />}
            >
              <input
                type="tel"
                name="phone"
                value={form.phone}
                onChange={handleChange("phone")}
                placeholder="+20 10XXXXXXXX"
                className="pu-input"
                dir="ltr"
              />
            </Field>
          </div>

          <div className="pu-section-divider" />
          <p className="pu-section-label">
            <MedIcon /> المعلومات الأكاديمية
          </p>

          {/* Row 3 */}
          <div className="pu-row">
            <Field
              label="التخصص"
              icon={<MedIcon />}
            >
              <select
                name="specialization"
                value={form.specialization}
                onChange={handleChange("specialization")}
                className="pu-select"
              >
                <option value="">اختر التخصص</option>
                {categories.map((cat) => (
                  <option key={cat} value={cat}>{cat}</option>
                ))}
              </select>
            </Field>
            <Field
              label="الكلية"
              icon={<CollegeIcon />}
            >
              <select
                name="faculty"
                value={form.faculty}
                onChange={handleChange("faculty")}
                className="pu-select"
              >
                <option value="">اختر الكلية</option>
                {universities.map((u) => (
                  <option key={u} value={u}>{u}</option>
                ))}
              </select>
            </Field>
          </div>

          {/* Row 4 */}
          <div className="pu-row">
            <Field
              label="السنة الدراسية"
              icon={<BookIcon />}
            >
              <select
                name="year"
                value={form.year}
                onChange={handleChange("year")}
                className="pu-select"
              >
                <option value="">اختر السنة الدراسية</option>
                {YEAR_OPTIONS.map((yearOption) => (
                  <option key={yearOption.value} value={yearOption.value}>{yearOption.label}</option>
                ))}
              </select>
            </Field>
            <Field
              label="المحافظة"
              icon={<PinIcon />}
            >
              <select
                name="city"
                value={form.city}
                onChange={handleChange("city")}
                className="pu-select"
              >
                <option value="">اختر المحافظة</option>
                {cities.map((c) => (
                  <option key={c} value={c}>{c}</option>
                ))}
              </select>
            </Field>
          </div>

          <div className="pu-section-divider" />

          {/* Buttons */}
          <div className="pu-buttons-row">
            <button
              type="submit"
              className="pu-primary-btn primary-btn"
              disabled={saving}
            >
              <SaveIcon />
              {saving ? "جاري الحفظ..." : "حفظ التغييرات"}
            </button>
            <button
              type="button"
              onClick={handleCancel}
              className="pu-secondary-btn secondary-btn"
            >
              <CancelIcon />
              إلغاء
            </button>
          </div>

        </form>

        <p className="pu-footer-note">
          ستُحفظ التغييرات وتُطبَّق على حسابك فوراً
        </p>
      </div>
    </div>
  );
}

/* ── Reusable Field ── */
const Field = ({ label, icon, children }) => {
  const [focused, setFocused] = useState(false);

  return (
    <div className="pu-field-wrap">
      <label className="pu-label">{label}</label>
      <div
        className={`pu-input-box ${focused ? "pu-input-box--focused" : ""}`}
      >
        <span className={`pu-input-icon ${focused ? "pu-input-icon--focused" : ""}`}>
          {icon}
        </span>
        <div
          onFocus={() => setFocused(true)}
          onBlur={() => setFocused(false)}
        >
          {children}
        </div>
      </div>
    </div>
  );
}
