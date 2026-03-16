import { useState, useEffect } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import '../Css/Booking.css';

export default function Booking(){
    const navigate = useNavigate();
    const location = useLocation();
    const requestData = location.state?.request || null;

    const [formData, setFormData] = useState({ name: '', phone: '' });
    const [confirmed, setConfirmed] = useState(false);
    const [loading, setLoading] = useState(false);

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({ ...prev, [name]: value }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!formData.name.trim() || !formData.phone.trim()) {
            alert('الرجاء إدخال الاسم ورقم التليفون');
            return;
        }
        setLoading(true);
        // Simulate API call
        setTimeout(() => {
            setLoading(false);
            setConfirmed(true);
            // Redirect to home after 2 seconds
            setTimeout(() => {
                navigate('/');
            }, 2000);
        }, 1000);
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
                        {requestData.doctorPhoneNumber && (
                            <p className="booking-request-detail">📞 {requestData.doctorPhoneNumber}</p>
                        )}
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

                <p className="booking-subtitle">ادخل الاسم ورقم التليفون</p>
                <form className="booking-form" onSubmit={handleSubmit}>
                    <div className="form-group">
                        <input
                            type="text"
                            name="name"
                            placeholder="اسمك الكامل"
                            value={formData.name}
                            onChange={handleInputChange}
                            className="form-input"
                            disabled={loading}
                        />
                    </div>
                    <div className="form-group">
                        <input
                            type="tel"
                            name="phone"
                            placeholder="رقم التليفون"
                            value={formData.phone}
                            onChange={handleInputChange}
                            className="form-input"
                            disabled={loading}
                        />
                    </div>
                    <button type="submit" className="booking-button" disabled={loading}>
                        {loading ? 'جاري التأكيد...' : 'تأكيد الحجز'}
                    </button>
                </form>
            </div>
        </div>
        </>
    )

}