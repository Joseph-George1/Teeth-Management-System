import { useState } from "react";
import "../Css/DoctorBooking.css";

const staticBookings = [
  {
    patientName: "زياد جمال",
    phone: "01012345678",
    service: "تقويم اسنان",
    time: "11:30 صباحا",
    date: "2025-11-29",
    status: "مكتمل",
    statusClass: "completed",
  },
  {
    patientName: "عبدالحليم رمضان",
    phone: "01098765432",
    service: "حشو عصب",
    time: "02:45 مساءً",
    date: "2025-11-30",
    status: "انتظار",
    statusClass: "pending",
  },
  {
    patientName: "محمد اشرف",
    phone: "01156781234",
    service: "تنظيف أسنان",
    time: "10:15 صباحا",
    date: "2025-12-01",
    status: "ملغي",
    statusClass: "cancelled",
  },
  {
    patientName: "جوزيف جورح",
    phone: "01234567890",
    service: "تركيب كوبري",
    time: "04:30 مساءً",
    date: "2025-12-02",
    status: "مكتمل",
    statusClass: "completed",
  },
];

export default function Patient() {
  const [bookings] = useState(() => {
    const accepted = JSON.parse(localStorage.getItem("acceptedPatients") || "[]");
    return [...staticBookings, ...accepted];
  });
  const [selectedBooking, setSelectedBooking] = useState(null);

  const openDetails = (booking) => setSelectedBooking(booking);
  const closeDetails = () => setSelectedBooking(null);

  return (
    <div className="doctor-booking-page" dir="rtl">
      <main className="doctor-booking-content">
        <h1 className="page-title">جميع المرضى</h1>

        <div className="booking-list">
          {bookings.map((booking, index) => (
            <div
              key={index}
              className="booking-card"
              onClick={() => openDetails(booking)}
            >
              <div className="booking-card-right">
                <span className={`status-badge ${booking.statusClass}`}>
                  {booking.status}
                </span>
                <div className="booking-name-wrapper">
                  <h3 className="booking-name">{booking.patientName}</h3>
                </div>
              </div>
            </div>
          ))}
        </div>
      </main>

      {selectedBooking && (
        <div className="bottom-sheet-overlay" onClick={closeDetails}>
          <div className="bottom-sheet" onClick={(e) => e.stopPropagation()}>
            <div className="sheet-handle"></div>
            <div className="sheet-header">
              <h2 className="sheet-patient-name">{selectedBooking.patientName}</h2>
            </div>
            <div className="sheet-divider"></div>
            <div className="detail-row">
              <div className="detail-icon">📞</div>
              <div className="detail-text">
                <span className="detail-label">رقم الهاتف</span>
                <span className="detail-value">{selectedBooking.phone}</span>
              </div>
            </div>
            <div className="detail-row">
              <div className="detail-icon">📅</div>
              <div className="detail-text">
                <span className="detail-label">التاريخ</span>
                <span className="detail-value">{selectedBooking.date}</span>
              </div>
            </div>
            <div className="detail-row">
              <div className="detail-icon">⏰</div>
              <div className="detail-text">
                <span className="detail-label">الوقت</span>
                <span className="detail-value">{selectedBooking.time}</span>
              </div>
            </div>
            <div className="detail-row">
              <div className="detail-icon">🦷</div>
              <div className="detail-text">
                <span className="detail-label">التخصص</span>
                <span className="detail-value">{selectedBooking.service}</span>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}