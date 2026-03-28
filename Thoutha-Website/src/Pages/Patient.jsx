import { useState, useEffect, useContext } from "react";
import { AuthContext } from "../services/AuthContext";
import "../Css/DoctorBooking.css";

// Helper functions
const getDate = (dt) => dt ? dt.split('T')[0] : '';
const getTime = (dt) => {
  if (!dt) return '';
  const parts = dt.split('T');
  return parts[1] ? parts[1].slice(0, 5) : '';
};

const getTimePeriod = (dt) => {
  const t = getTime(dt);
  if (!t) return '';
  const [h] = t.split(':').map(Number);
  return h < 12 ? 'صباحاً' : h < 17 ? 'ظهراً' : 'مساءً';
};

const normalizeList = (payload) => {
  if (Array.isArray(payload)) return payload;
  if (Array.isArray(payload?.data)) return payload.data;
  if (Array.isArray(payload?.result)) return payload.result;
  if (Array.isArray(payload?.content)) return payload.content;
  return [];
};

export default function Patient() {
  const { user, authLoading, isLoggedIn } = useContext(AuthContext);
  const [patients, setPatients] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [selectedPatient, setSelectedPatient] = useState(null);

  useEffect(() => {
    if (!isLoggedIn || authLoading) return;

    let cancelled = false;
    setLoading(true);
    setError("");

    const token = user?.token || localStorage.getItem("token");
    if (!token) {
      setError("لم نتمكن من الحصول على بيانات المستخدم");
      setLoading(false);
      return;
    }

    // جلب المرضى المكتملين من API
    fetch("https://thoutha.page/api/appointment/getDone", {
      headers: { Authorization: `Bearer ${token}` }
    })
      .then(res => {
        if (!res.ok) throw new Error("فشل جلب بيانات المرضى");
        return res.json();
      })
      .then(data => {
        if (!cancelled) {
          const normalizedData = normalizeList(data);
          
          const processedData = normalizedData.map((appt) => ({
            id: appt.id,
            firstName: appt.patientFirstName || "",
            lastName: appt.patientLastName || "",
            patientName: `${appt.patientFirstName || ""} ${appt.patientLastName || ""}`.trim() || "مريض",
            phone: appt.patientPhoneNumber || "",
            service: appt.categoryName || "",
            specialty: appt.categoryName || "",
            description: appt.requestDescription || "",
            time: `${getTime(appt.appointmentDate)} ${getTimePeriod(appt.appointmentDate)}`,
            date: getDate(appt.appointmentDate),
            status: "مكتمل",
            ...appt,
          }));
          
          setPatients(processedData);
        }
      })
      .catch(err => {
        if (!cancelled) setError(err.message || "حدث خطأ أثناء جلب البيانات");
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });

    return () => { cancelled = true; };
  }, [isLoggedIn, authLoading, user]);

  const openDetails = (patient) => setSelectedPatient(patient);
  const closeDetails = () => setSelectedPatient(null);

  return (
    <div className="doctor-booking-page" dir="rtl">
      <main className="doctor-booking-content">
        <h1 className="page-title">المرضى المكتملين</h1>

        {loading ? (
          <p className="dnb-empty">جاري تحميل بيانات المرضى...</p>
        ) : error ? (
          <p className="dnb-empty dnb-error">{error}</p>
        ) : patients.length === 0 ? (
          <div style={{ textAlign: "center", padding: "40px 20px", color: "#999" }}>
            <p style={{ fontSize: "18px", fontWeight: "600" }}>لا توجد مرضى مكتملين حالياً</p>
            <p style={{ fontSize: "14px", marginTop: "10px" }}>سيظهر المرضى هنا عندما تكمل حجوزات من سجل الحجوزات</p>
          </div>
        ) : (
          <div className="booking-list">
            {patients.map((patient) => (
              <div
                key={patient.id}
                className="booking-card"
                onClick={() => openDetails(patient)}
              >
                <div className="booking-card-right">
                  <span 
                    className="status-badge completed"
                    style={{ color: "white" }}
                  >
                    مكتمل
                  </span>
                  <div className="booking-name-wrapper">
                    <h3 className="booking-name">{patient.patientName}</h3>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>

      {selectedPatient && (
        <div className="bottom-sheet-overlay" onClick={closeDetails}>
          <div className="bottom-sheet" onClick={(e) => e.stopPropagation()}>
            <div className="sheet-handle"></div>
            <div className="sheet-header">
              <h2 className="sheet-patient-name">{selectedPatient.patientName}</h2>
            </div>
            <div className="sheet-divider"></div>
            {[
              { icon: "user", label: "الاسم الأول", value: selectedPatient.firstName },
              { icon: "user", label: "الاسم الأخير", value: selectedPatient.lastName },
              { icon: "phone", label: "رقم الهاتف", value: selectedPatient.phone },
              { icon: "tooth", label: "التخصص", value: selectedPatient.specialty },
            ].map(({ icon, label, value }) => {
              const iconSVGs = {
                user: <svg viewBox="0 0 24 24" className="detail-icon-svg" aria-hidden="true"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" stroke="currentColor" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round" /><circle cx="12" cy="7" r="4" stroke="currentColor" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round" /></svg>,
                phone: <svg viewBox="0 0 24 24" className="detail-icon-svg" aria-hidden="true"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z" stroke="currentColor" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round" /></svg>,
                tooth: <svg viewBox="0 0 24 24" className="detail-icon-svg" aria-hidden="true"><path d="M12 2C12 2 10 4 10 8c0 2 1 4 2 5v5c0 1.1.9 2 2 2s2-.9 2-2v-5c1-1 2-3 2-5 0-4-2-6-2-6z" stroke="currentColor" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round" /><circle cx="12" cy="8" r="1.5" fill="currentColor" /></svg>,
              };
              return (
                <div key={label} className="detail-row">
                  <div className="detail-icon" aria-hidden="true">{iconSVGs[icon]}</div>
                  <div className="detail-text">
                    <span className="detail-label">{label}</span>
                    <span className="detail-value">{value}</span>
                  </div>
                </div>
              );
            })}
            <button 
              onClick={closeDetails}
              style={{
                width: "100%",
                marginTop: "20px",
                padding: "12px 20px",
                background: "#f3f4f6",
                color: "#333",
                border: "1px solid #e5e7eb",
                borderRadius: "10px",
                fontSize: "15px",
                fontWeight: "700",
                fontFamily: "'Cairo', sans-serif",
                cursor: "pointer",
                transition: "background 0.2s ease",
              }}
              onMouseEnter={(e) => e.target.style.background = "#e5e7eb"}
              onMouseLeave={(e) => e.target.style.background = "#f3f4f6"}
            >
              إغلاق
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
          