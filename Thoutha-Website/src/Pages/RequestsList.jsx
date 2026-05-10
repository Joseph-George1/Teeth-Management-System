import { useEffect, useState, useContext } from "react";
import { useNavigate } from "react-router-dom";
import { AuthContext } from "../services/AuthContext";

const API_URL = "https://thoutha.page/api/request/getRequestByCategoryId";
const API_URL_BY_NAME = "https://thoutha.page/api/request/getRequestByCategoryName";

const getName = (req) =>
  `${req?.doctorFirstName || req?.firstName || req?.first_name || req?.patientName || req?.name || ""}
   ${req?.doctorLastName  || req?.lastName  || req?.last_name  || ""}`.trim() || "مجهول";

const getUniversity = (req) =>
  req?.doctorUniversityName || req?.universityName || req?.university || req?.faculty || "";

const getCity = (req) =>
  req?.doctorCityName || req?.cityName || req?.city || "";

const getPhone = (req) =>
  req?.doctorPhoneNumber || req?.phoneNumber || req?.phone || "";

const getNotes = (req) =>
  req?.description || req?.notes || req?.note || "";

const getDate = (req) => {
  if (req?.dateTime) return req.dateTime.split("T")[0];
  return req?.date || req?.requestDate || "";
};

const getTime = (req) => {
  if (req?.dateTime) {
    const parts = req.dateTime.split("T");
    return parts[1] ? parts[1].slice(0, 5) : "";
  }
  return req?.time || req?.requestTime || "";
};

// Convert English numbers to Arabic
const toArabicNumbers = (str) => {
  if (!str) return "";
  const englishNumbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  let result = String(str);
  englishNumbers.forEach((eng, i) => {
    result = result.replace(new RegExp(eng, 'g'), arabicNumbers[i]);
  });
  return result;
};

const getTimePeriod = (req) => {
  const t = getTime(req);
  if (!t) return "";
  const [h, m] = t.split(":").map(Number);
  let hour = h;
  const period = h >= 12 ? "م" : "ص";
  if (hour > 12) hour = hour - 12;
  if (hour === 0) hour = 12;
  return toArabicNumbers(`${String(hour).padStart(2, "0")}:${String(m).padStart(2, "0")} ${period}`);
};

const getDateArabic = (req) => {
  const dateStr = getDate(req);
  if (!dateStr) return "";
  const date = new Date(dateStr + "T00:00:00");
  const arabicDays = ["الأحد", "الاثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة", "السبت"];
  const arabicMonths = ["يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو", "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"];
  return toArabicNumbers(`${arabicDays[date.getDay()]} ${date.getDate()} ${arabicMonths[date.getMonth()]} ${date.getFullYear()}`);
};

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

const normalizeList = (payload) => {
  if (Array.isArray(payload))         return payload;
  if (Array.isArray(payload?.data))   return payload.data;
  if (Array.isArray(payload?.result)) return payload.result;
  if (Array.isArray(payload?.content))return payload.content;
  return [];
};

export default function RequestsList({ categoryName, categoryId, refreshKey = 0 }) {
  const [requests, setRequests] = useState([]);
  const [loading, setLoading]   = useState(true);
  const [error, setError]       = useState("");
  const [editingId, setEditingId] = useState(null);
  const [editFormData, setEditFormData] = useState({ description: "", dateTime: "" });
  const [editError, setEditError] = useState("");
  const [editLoading, setEditLoading] = useState(false);
  const navigate = useNavigate();
  const { user, isLoggedIn } = useContext(AuthContext);


  useEffect(() => {
    if (!categoryId && !categoryName) return;

    let cancelled = false;
    setLoading(true);
    setError("");

    const token = user?.token || localStorage.getItem("token");
    const headers = token && !isTokenExpired(token)
      ? { Authorization: `Bearer ${token}` }
      : {};

    // Helper function to attempt fetch with fallback
    const attemptFetch = async () => {
      // Try categoryName endpoint first if available
      if (categoryName) {
        try {
          const res = await fetch(`${API_URL_BY_NAME}?categoryName=${encodeURIComponent(categoryName)}`, { headers });
          if (res.ok) {
            return await res.json();
          }
        } catch (err) {
          // Fall through to categoryId attempt
        }
      }
      
      // Fall back to categoryId endpoint
      if (categoryId) {
        const res = await fetch(`${API_URL}?categoryId=${categoryId}`, { headers });
        if (!res.ok) throw new Error("فشل تحميل الطلبات");
        return await res.json();
      }
      
      throw new Error("معرّف الفئة مفقود");
    };

    attemptFetch()
      .then((data) => {
        if (!cancelled) {
          let requests = normalizeList(data);
          if (categoryName && requests.length > 0) {
            requests = requests.filter(r => 
              (r?.categoryName === categoryName || r?.category === categoryName)
            );
          }
          setRequests(requests);
        }
      })
      .catch((err) => {
        if (!cancelled) setError(err.message || "حدث خطأ أثناء تحميل الطلبات");
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });

    return () => { cancelled = true; };
  }, [categoryId, categoryName, refreshKey, user]);

  if (loading) return <p className="requests-status">جاري تحميل الطلبات...</p>;
  if (error)   return <p className="requests-status requests-status--error">{error}</p>;
  if (requests.length === 0)
    return <p className="requests-status">لا توجد طلبات لهذه الفئة حتى الآن.</p>;

  return (
    <>
      <div className="requests-list">
        {requests.map((req, i) => {
          const isOwner = isLoggedIn && user && (
            (req?.doctorFirstName?.toLowerCase() === user?.firstName?.toLowerCase() &&
             req?.doctorLastName?.toLowerCase()  === user?.lastName?.toLowerCase())
          );
          const isPending = req?.status === "PENDING";

          const firstLetters = getName(req)
            .split(' ')
            .slice(0, 2)
            .map(w => w.charAt(0))
            .join('');

          return (
            <article key={req?.id || i} className="card" dir="rtl">

              {/* ── Header ── */}
              <header className="card-header">
                <div className="header-inner">
                  <div className="avatar" aria-hidden="true">
                    {firstLetters || 'د'}
                  </div>
                  <div className="doctor-info">
                    <h3 className="doctor-name">د. {getName(req)}</h3>
                    {(req?.specialization || req?.categoryName || categoryName) && (
                      <span className="spec-badge">
                        <span className="spec-dot"></span>
                        {req?.specialization || req?.categoryName || categoryName}
                      </span>
                    )}
                  </div>
                </div>
                <div className="status-badge">
                  <span className="pulse"></span>
                  متاح الآن
                </div>
              </header>

              {/* ── Body ── */}
              <div className="card-body">

                {/* University + Governorate Row */}
                <div className="info-row">
                  {getUniversity(req) && (
                    <div className="info-chip">
                      <div className="chip-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24">
                          <path d="M3 21V9l9-6 9 6v12M9 21V13h6v8" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" fill="none"/>
                        </svg>
                      </div>
                      <div className="chip-text">
                        <div className="chip-label">الجامعة</div>
                        <div className="chip-value">{getUniversity(req)}</div>
                      </div>
                    </div>
                  )}
                  {getCity(req) && (
                    <div className="info-chip">
                      <div className="chip-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24">
                          <path d="M12 22s-8-5.6-8-12a8 8 0 0116 0c0 6.4-8 12-8 12zM12 10a2.5 2.5 0 110-5 2.5 2.5 0 010 5z" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" fill="none"/>
                        </svg>
                      </div>
                      <div className="chip-text">
                        <div className="chip-label">المحافظة</div>
                        <div className="chip-value">{getCity(req)}</div>
                      </div>
                    </div>
                  )}
                </div>

                {/* Day + Time Row */}
                {(getDate(req) || getTime(req)) && (
                  <div className="schedule-row">
                    {getDate(req) && (
                      <div className="schedule-chip">
                        <div className="chip-icon" aria-hidden="true">
                          <svg viewBox="0 0 24 24">
                            <rect x="3" y="4" width="18" height="18" rx="2" stroke="currentColor" strokeWidth="2" fill="none"/>
                            <path d="M16 2v4M8 2v4M3 10h18" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                          </svg>
                        </div>
                        <div className="chip-text">
                          <div className="chip-label">اليوم</div>
                          <div className="chip-value">{getDateArabic(req)}</div>
                        </div>
                      </div>
                    )}
                    {getTime(req) && (
                      <div className="schedule-chip">
                        <div className="chip-icon" aria-hidden="true">
                          <svg viewBox="0 0 24 24">
                            <circle cx="12" cy="12" r="9" stroke="currentColor" strokeWidth="2" fill="none"/>
                            <path d="M12 7v5l3 3" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                          </svg>
                        </div>
                        <div className="chip-text">
                          <div className="chip-label">الساعة</div>
                          <div className="chip-value">{getTimePeriod(req)}</div>
                        </div>
                      </div>
                    )}
                  </div>
                )}

                {getNotes(req) && (
                  <>
                    <div className="divider" role="separator"></div>

                    {/* Doctor's Note */}
                    <div className="note-box" role="note">
                      <div className="note-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24">
                          <path d="M9 11l3 3L22 4M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" fill="none"/>
                        </svg>
                      </div>
                      <p className="note-text">{getNotes(req)}</p>
                    </div>
                  </>
                )}

                {/* Book Button */}
                {!isLoggedIn && (
                  <button
                    className="book-btn"
                    type="button"
                    onClick={() => navigate("/booking", { state: { request: req } })}
                  >
                    <svg className="btn-icon" viewBox="0 0 24 24" aria-hidden="true">
                      <rect x="3" y="4" width="18" height="18" rx="2" stroke="currentColor" strokeWidth="2" fill="none"/>
                      <path d="M16 2v4M8 2v4M3 10h18M8 14h.01M12 14h.01M16 14h.01M8 18h.01M12 18h.01" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                    </svg>
                    حجز موعد
                  </button>
                )}

              </div>

            </article>
          );
        })}
      </div>
    </>
  );
}
