import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";

const API_URL = "https://thoutha.page/api/request/getRequestsByCategoryId";

const getName = (req) =>
  `${req?.firstName || req?.first_name || req?.patientName || req?.name || ""}
   ${req?.lastName  || req?.last_name  || ""}`.trim() || "مجهول";

const getUniversity = (req) =>
  req?.universityName || req?.university || req?.faculty || "";

const getCity = (req) =>
  req?.cityName || req?.city || "";

const getNotes = (req) =>
  req?.notes || req?.description || req?.note || "";

const getDate = (req) =>
  req?.date || req?.requestDate || "";

const getTime = (req) =>
  req?.time || req?.requestTime || "";

const normalizeList = (payload) => {
  if (Array.isArray(payload))         return payload;
  if (Array.isArray(payload?.data))   return payload.data;
  if (Array.isArray(payload?.result)) return payload.result;
  if (Array.isArray(payload?.content))return payload.content;
  return [];
};

export default function RequestsList({ categoryName, categoryId, newRequest }) {
  const [requests, setRequests] = useState([]);
  const [loading, setLoading]   = useState(true);
  const [error, setError]       = useState("");
  const navigate = useNavigate();

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    setError("");

    const params = new URLSearchParams();
    if (categoryId)   params.set("categoryId",   categoryId);
    if (categoryName) params.set("categoryName", categoryName);

    fetch(`${API_URL}?${params.toString()}`)
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
  }, [categoryName, categoryId]);

  // Prepend freshly submitted request
  useEffect(() => {
    if (newRequest) setRequests((prev) => [newRequest, ...prev]);
  }, [newRequest]);

  if (loading) return <p className="requests-status">جاري تحميل الطلبات...</p>;
  if (error)   return <p className="requests-status requests-status--error">{error}</p>;
  if (requests.length === 0) return null;

  return (
    <div className="requests-list">
      {requests.map((req, i) => (
        <div key={req?.id || i} className="request-card" dir="rtl">
          <div className="request-card-info">
            <p className="request-card-name">{getName(req)}</p>
            {getUniversity(req) && (
              <p className="request-card-detail">🏫 {getUniversity(req)}</p>
            )}
            {getCity(req) && (
              <p className="request-card-detail">📍 {getCity(req)}</p>
            )}
            {req?.specialization || req?.categoryName ? (
              <p className="request-card-detail">
                🦷 {req?.specialization || req?.categoryName || categoryName}
              </p>
            ) : null}
            {(getDate(req) || getTime(req)) && (
              <p className="request-card-detail">
                📅 {getDate(req)}{getDate(req) && getTime(req) ? " — " : ""}{getTime(req)}
              </p>
            )}
            {getNotes(req) && (
              <p className="request-card-notes">{getNotes(req)}</p>
            )}
          </div>
          <button
            className="request-card-book-btn"
            onClick={() => navigate("/booking")}
          >
            حجز
          </button>
        </div>
      ))}
    </div>
  );
}
