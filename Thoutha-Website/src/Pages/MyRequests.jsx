import { useEffect, useState, useContext } from "react";
import { useNavigate } from "react-router-dom";
import { AuthContext } from "../services/AuthContext";
import "../Css/MyRequests.css";

const getName = (req) =>
  `${req?.doctorFirstName || req?.firstName || req?.first_name || req?.name || ""}
   ${req?.doctorLastName || req?.lastName || req?.last_name || ""}`.trim() || "مجهول";

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

const getTimePeriod = (req) => {
  const t = getTime(req);
  if (!t) return "";
  const [h] = t.split(":").map(Number);
  return h < 12 ? `${t} صباحاً` : `${t} مساءً`;
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
  if (Array.isArray(payload)) return payload;
  if (Array.isArray(payload?.data)) return payload.data;
  if (Array.isArray(payload?.result)) return payload.result;
  if (Array.isArray(payload?.content)) return payload.content;
  return [];
};

export default function MyRequests() {
  const [requests, setRequests] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [editingId, setEditingId] = useState(null);
  const [editFormData, setEditFormData] = useState({ description: "", dateTime: "" });
  const [editError, setEditError] = useState("");
  const [editLoading, setEditLoading] = useState(false);
  const navigate = useNavigate();
  const { user, isLoggedIn } = useContext(AuthContext);

  const handleDelete = (reqId) => {
    const token = user?.token || localStorage.getItem("token");
    fetch(`https://thoutha.page/api/request/deleteRequest`, {
      method: "DELETE",
      headers: { Authorization: `Bearer ${token}` },
    })
      .then((res) => {
        if (!res.ok) throw new Error("فشل حذف الطلب");
        setRequests((prev) => prev.filter((r) => r?.id !== reqId));
      })
      .catch((err) => setError(err.message));
  };

  const handleEditClick = (req) => {
    setEditingId(req?.id);
    setEditFormData({
      description: getNotes(req),
      dateTime: req?.dateTime || "",
    });
    setEditError("");
  };

  const handleCancelEdit = () => {
    setEditingId(null);
    setEditFormData({ description: "", dateTime: "" });
    setEditError("");
  };

  const handleEditSubmit = () => {
    if (!editFormData.description.trim() || !editFormData.dateTime.trim()) {
      setEditError("يرجى ملء جميع الحقول");
      return;
    }

    const token = user?.token || localStorage.getItem("token");
    setEditLoading(true);
    setEditError("");

    fetch(`https://thoutha.page/api/request/editRequest/${editingId}`, {
      method: "PUT",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        description: editFormData.description,
        dateTime: editFormData.dateTime,
      }),
    })
      .then((res) => {
        if (!res.ok) throw new Error("فشل تحديث الطلب");
        return res.json();
      })
      .then((updatedReq) => {
        setRequests((prev) =>
          prev.map((r) =>
            r?.id === editingId ? { ...r, ...updatedReq } : r
          )
        );
        handleCancelEdit();
      })
      .catch((err) => setEditError(err.message || "حدث خطأ أثناء التحديث"))
      .finally(() => setEditLoading(false));
  };

  useEffect(() => {
    if (!isLoggedIn || !user?.id) return;

    let cancelled = false;
    setLoading(true);
    setError("");

    const token = user?.token || localStorage.getItem("token");
    const headers = token && !isTokenExpired(token)
      ? { Authorization: `Bearer ${token}` }
      : {};

    fetch(`https://thoutha.page/api/request/getRequestsByDoctorId?doctorId=${user.id}`, { headers })
      .then((res) => {
        if (!res.ok) throw new Error("فشل تحميل الطلبات");
        return res.json();
      })
      .then((data) => {
        if (!cancelled) setRequests(normalizeList(data));
      })
      .catch((err) => {
        if (!cancelled) setError(err.message || "حدث خطأ أثناء تحميل الطلبات");
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });

    return () => { cancelled = true; };
  }, [isLoggedIn, user?.id, user?.token]);

  if (!isLoggedIn) {
    return (
      <div className="my-requests-container">
        <p className="requests-status">يرجى تسجيل الدخول لعرض طلباتك</p>
      </div>
    );
  }

  if (loading) return (
    <div className="my-requests-container">
      <p className="requests-status">جاري تحميل الطلبات...</p>
    </div>
  );

  if (error) return (
    <div className="my-requests-container">
      <p className="requests-status requests-status--error">{error}</p>
    </div>
  );

  if (requests.length === 0)
    return (
      <div className="my-requests-container">
        <h1 className="my-requests-title">طلباتي</h1>
        <div className="requests-list">
          <p className="requests-status">لم تضف أي طلبات حتى الآن! عندما تضيف طلبات جديدة ستظهر هنا.</p>
        </div>
      </div>
    );

  return (
    <div className="my-requests-container">
      <h1 className="my-requests-title">طلباتي</h1>
      <div className="requests-list">
        {requests.map((req, i) => {
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
                    {(req?.specialization || req?.categoryName) && (
                      <span className="spec-badge">
                        <span className="spec-dot"></span>
                        {req?.specialization || req?.categoryName}
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
                          <div className="chip-value">{getDate(req)}</div>
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

                {/* Actions */}
                <div className="request-card-actions">
                  <button
                    className="request-card-edit-btn"
                    onClick={() => handleEditClick(req)}
                  >
                    تعديل
                  </button>
                  <button
                    className="request-card-delete-btn"
                    onClick={() => handleDelete(req?.id)}
                  >
                    حذف الطلب
                  </button>
                </div>

              </div>

            </article>
          );
        })}
      </div>

      {/* ── Edit Modal ── */}
      {editingId && (
        <div className="edit-modal-overlay" onClick={handleCancelEdit}>
          <div className="edit-modal" onClick={(e) => e.stopPropagation()} dir="rtl">
            <h2 className="edit-modal-title">تعديل الطلب</h2>

            {editError && <div className="edit-modal-error">{editError}</div>}

            <div className="edit-form-group">
              <label className="edit-form-label">الوصف:</label>
              <textarea
                className="edit-form-textarea"
                value={editFormData.description}
                onChange={(e) => setEditFormData({...editFormData, description: e.target.value})}
                rows="4"
              />
            </div>

            <div className="edit-form-group">
              <label className="edit-form-label">موعد الطلب:</label>
              <input
                type="datetime-local"
                className="edit-form-input"
                value={editFormData.dateTime}
                onChange={(e) => setEditFormData({...editFormData, dateTime: e.target.value})}
              />
            </div>

            <div className="edit-modal-actions">
              <button
                className="edit-modal-btn edit-modal-btn--save"
                onClick={handleEditSubmit}
                disabled={editLoading}
              >
                {editLoading ? "جاري الحفظ..." : "حفظ التغييرات"}
              </button>
              <button
                className="edit-modal-btn edit-modal-btn--cancel"
                onClick={handleCancelEdit}
                disabled={editLoading}
              >
                إلغاء
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
