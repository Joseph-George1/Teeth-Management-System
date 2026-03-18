import { useState, useEffect, useContext } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import { AuthContext } from "../services/AuthContext";
import '../Css/Booking.css';

export default function Booking(){
    const navigate = useNavigate();
    const location = useLocation();
    const { user } = useContext(AuthContext);
    const requestData = location.state?.request || null;

    const [formData, setFormData] = useState({ 
        patientFirstName: '', 
        patientLastName: '',
        patientPhoneNumber: '' 
    });
    const [error, setError] = useState("");
    const [confirmed, setConfirmed] = useState(false);
    const [loading, setLoading] = useState(false);

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({ ...prev, [name]: value }));
        setError("");
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        
        if (!formData.patientFirstName.trim()) {
            setError('الرجاء إدخال الاسم الأول');
            return;
        }
        if (!formData.patientLastName.trim()) {
            setError('الرجاء إدخال الاسم الثاني');
            return;
        }
        if (!formData.patientPhoneNumber.trim()) {
            setError('الرجاء إدخال رقم التليفون');
            return;
        }

        if (!requestData?.id) {
            setError('خطأ: لم نتمكن من الحصول على بيانات الطلب');
            return;
        }

        setLoading(true);
        setError("");

        try {
            const token = user?.token || localStorage.getItem("token");
            const headers = {
                "Content-Type": "application/json",
            };
            if (token) {
                headers.Authorization = `Bearer ${token}`;
            }

            const response = await fetch(
                `https://thoutha.page/api/appointment/createAppointment/${requestData.id}`,
                {
                    method: "POST",
                    headers,
                    body: JSON.stringify({
                        patientFirstName: formData.patientFirstName,
                        patientLastName: formData.patientLastName,
                        patientPhoneNumber: formData.patientPhoneNumber,
                    }),
                }
            );

            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                // معالجة الأخطاء الشائعة من الـ API
                if (response.status === 409 || response.status === 400) {
                    throw new Error(errorData.message || "تم الحجز مع هذا الطبيب من قبل برقم الهاتف هذا!");
                }
                throw new Error(errorData.message || 'فشل الحجز');
            }

            setConfirmed(true);
            setTimeout(() => {
                navigate('/');
            }, 2000);
        } catch (err) {
            setError(err.message || 'حدث خطأ أثناء الحجز');
        } finally {
            setLoading(false);
        }
    };

    const getDate = (dt) => dt ? dt.split('T')[0] : '';
    const getTime = (dt) => {
        if (!dt) return '';
        const parts = dt.split('T');
        return parts[1] ? parts[1].slice(0, 5) : '';
    };

    return(
        <>
        <div className="booking-page">
            <div className="booking-container">
                {confirmed && (
                    <div className="confirmation-message">
                        ✓ تم تأكيد الحجز بنجاح
                    </div>
                )}
                <p className="booking-title">تأكيد الحجز</p>

                {requestData && (
                    <div className="booking-request-info" dir="rtl">
                        <p className="booking-request-name">
                            {requestData.doctorFirstName} {requestData.doctorLastName}
                        </p>
                        {requestData.doctorCityName && (
                            <p className="booking-request-detail">📍 {requestData.doctorCityName}</p>
                        )}
                        {requestData.doctorUniversityName && (
                            <p className="booking-request-detail">🏫 {requestData.doctorUniversityName}</p>
                        )}
                        {requestData.categoryName && (
                            <p className="booking-request-detail">🦷 {requestData.categoryName}</p>
                        )}
                        {requestData.description && (
                            <p className="booking-request-notes">{requestData.description}</p>
                        )}
                        {requestData.dateTime && (
                            <p className="booking-request-detail">
                                📅 {getDate(requestData.dateTime)}{getDate(requestData.dateTime) && getTime(requestData.dateTime) ? ' — ' : ''}{getTime(requestData.dateTime)}
                            </p>
                        )}
                    </div>
                )}

                <p className="booking-subtitle">أدخل بياناتك</p>
                {error && (
                    <div className="booking-error">
                        {error}
                    </div>
                )}
                <form className="booking-form" onSubmit={handleSubmit}>
                    <div className="form-group">
                        <input
                            type="text"
                            name="patientFirstName"
                            placeholder="الاسم الأول"
                            value={formData.patientFirstName}
                            onChange={handleInputChange}
                            className="form-input"
                            disabled={loading}
                        />
                    </div>
                    <div className="form-group">
                        <input
                            type="text"
                            name="patientLastName"
                            placeholder="الاسم الثاني"
                            value={formData.patientLastName}
                            onChange={handleInputChange}
                            className="form-input"
                            disabled={loading}
                        />
                    </div>
                    <div className="form-group">
                        <input
                            type="tel"
                            name="patientPhoneNumber"
                            placeholder="رقم التليفون"
                            value={formData.patientPhoneNumber}
                            onChange={handleInputChange}
                            className="form-input"
                            disabled={loading}
                        />
                    </div>
                    <button type="submit" className="booking-button" disabled={loading}>
                        {loading ? 'جاري الحجز...' : 'تأكيد الحجز'}
                    </button>
                </form>
            </div>
        </div>
        </>
    )

}