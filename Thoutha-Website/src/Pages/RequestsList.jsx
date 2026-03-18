import { useEffect, useState, useContext } from "react";
import { useNavigate } from "react-router-dom";
import { AuthContext } from "../services/AuthContext";

const API_URL = "https://thoutha.page/api/request/getRequestByCategoryId";

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
    if (!categoryId) return;

    let cancelled = false;
    setLoading(true);
    setError("");

    const token = user?.token || localStorage.getItem("token");
    const headers = token && !isTokenExpired(token)
      ? { Authorization: `Bearer ${token}` }
      : {};

    fetch(`${API_URL}?categoryId=${categoryId}`, { headers })
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
  }, [categoryId, refreshKey, user]);

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

          return (
            <div key={req?.id || i} className="request-card" dir="rtl">

              {/* ── Header: name + badge ── */}
              <div className="request-card-header">
                <span className="request-card-name">د. {getName(req)}</span>
                {(req?.specialization || req?.categoryName || categoryName) && (
                  <span className="request-card-badge">
                    🦷 {req?.specialization || req?.categoryName || categoryName}
                  </span>
                )}
              </div>

              <div className="request-card-divider" />

              {/* ── Body: details ── */}
              <div className="request-card-body">
                {getCity(req) && (
                  <p className="request-card-detail">
                    <span className="rc-icon">📍</span>{getCity(req)}
                  </p>
                )}
                {getUniversity(req) && (
                  <p className="request-card-detail">
                    <span className="rc-icon">🏫</span>{getUniversity(req)}
                  </p>
                )}
                {getNotes(req) && (
                  <p className="request-card-notes">
                    <span className="rc-icon">📝</span>{getNotes(req)}
                  </p>
                )}
                {(getDate(req) || getTime(req)) && (
                  <p className="request-card-detail request-card-time">
                    <span className="rc-icon">🕐</span>
                    {getDate(req)}{getDate(req) && getTime(req) ? " · " : ""}
                    {getTimePeriod(req)}
                  </p>
                )}
              </div>

              {/* ── Footer: action buttons ── */}
              <div className="request-card-footer">
                {isOwner ? (
                  <div className="request-card-actions">
                    {isPending && (
                      <button
                        className="request-card-edit-btn"
                        onClick={() => handleEditClick(req)}
                      >
                         تعديل
                      </button>
                    )}
                    <button
                      className="request-card-delete-btn"
                      onClick={() => handleDelete(req?.id)}
                    >
                       حذف الطلب
                    </button>
                  </div>
                ) : !isLoggedIn ? (
                  <button
                    className="request-card-book-btn"
                    onClick={() => navigate("/booking", { state: { request: req } })}
                  >
                    احجز الآن
                  </button>
                ) : null}
              </div>

            </div>
          );
        })}
      </div>

      {/* ── Edit Modal ── */}
      {editingId && (
        <div className="edit-modal-overlay" onClick={handleCancelEdit}>
          <div className="edit-modal" onClick={(e) => e.stopPropagation()} dir="rtl">
            <div className="edit-modal-header">
              <h2>تعديل الطلب</h2>
              <button className="edit-modal-close" onClick={handleCancelEdit}>
                ✕
              </button>
            </div>

            <div className="edit-modal-body">
              {editError && (
                <p className="edit-modal-error">{editError}</p>
              )}

              <div className="edit-form-group">
                <label htmlFor="edit-description">الوصف</label>
                <textarea
                  id="edit-description"
                  className="edit-form-textarea"
                  value={editFormData.description}
                  onChange={(e) =>
                    setEditFormData({ ...editFormData, description: e.target.value })
                  }
                  placeholder="أدخل وصف الخدمة"
                  rows="4"
                />
              </div>

              <div className="edit-form-group">
                <label htmlFor="edit-dateTime">التاريخ والوقت</label>
                <input
                  id="edit-dateTime"
                  type="datetime-local"
                  className="edit-form-input"
                  value={editFormData.dateTime}
                  onChange={(e) =>
                    setEditFormData({ ...editFormData, dateTime: e.target.value })
                  }
                />
              </div>
            </div>

            <div className="edit-modal-footer">
              <button
                className="edit-modal-cancel-btn"
                onClick={handleCancelEdit}
                disabled={editLoading}
              >
                إلغاء
              </button>
              <button
                className="edit-modal-submit-btn"
                onClick={handleEditSubmit}
                disabled={editLoading}
              >
                {editLoading ? "جاري التحديث..." : "حفظ التعديلات"}
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
