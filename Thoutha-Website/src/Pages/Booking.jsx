import { useState, useContext } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import { AuthContext } from "../services/AuthContext";
import '../Css/Booking.css';

export default function Booking() {
    const navigate = useNavigate();
    const location = useLocation();
    const { user } = useContext(AuthContext);
    const requestData = location.state?.request || null;

    const [formData, setFormData] = useState({
        patientFirstName: '',
        patientLastName: '',
        patientPhoneNumber: ''
    });
    const [fieldErrors, setFieldErrors] = useState({});
    const [confirmed, setConfirmed] = useState(false);
    const [loading, setLoading] = useState(false);
    const [apiError, setApiError] = useState(null);

    const handleInputChange = (e) => {
        const { id, value } = e.target;
        const fieldMap = {
            firstName: 'patientFirstName',
            lastName: 'patientLastName',
            phone: 'patientPhoneNumber'
        };
        setFormData(prev => ({ ...prev, [fieldMap[id]]: value }));
        setFieldErrors(prev => ({ ...prev, [id]: false }));
        setApiError(null);
    };

    const handleConfirm = async () => {
        let isValid = true;
        const errors = {};

        if (!formData.patientFirstName.trim()) {
            errors.firstName = true;
            isValid = false;
        }
        if (!formData.patientLastName.trim()) {
            errors.lastName = true;
            isValid = false;
        }
        if (!formData.patientPhoneNumber.trim()) {
            errors.phone = true;
            isValid = false;
        }

        if (!isValid) {
            setFieldErrors(errors);
            return;
        }

        setApiError(null);

        if (!requestData?.id) {
            return;
        }

        setLoading(true);
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
                let errorMessage = errorData.message || 'فشل الحجز';
                
                // إذا كانت 400 أو الرسالة تحتوي على مؤشرات حجز مسبق
                if (response.status === 400 || 
                    errorMessage.toLowerCase().includes('موجود') || 
                    errorMessage.toLowerCase().includes('مسبق') ||
                    errorMessage.toLowerCase().includes('already') ||
                    errorMessage.toLowerCase().includes('exists')) {
                    errorMessage = `تم الحجز المسبق مع د. ${requestData?.doctorFirstName} ${requestData?.doctorLastName}`;
                }
                
                setApiError(errorMessage);
                throw new Error(errorMessage);
            }

            setConfirmed(true);
        } catch (err) {
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleReset = () => {
        setConfirmed(false);
        setFormData({
            patientFirstName: '',
            patientLastName: '',
            patientPhoneNumber: ''
        });
        setFieldErrors({});
        setApiError(null);
        navigate('/');
    };

    const formatDate = (dateStr) => {
        if (!dateStr) return '';
        const date = new Date(dateStr);
        const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
        return date.toLocaleDateString('ar-EG', options);
    };

    const formatTime = (dateStr) => {
        if (!dateStr) return '';
        const date = new Date(dateStr);
        return date.toLocaleTimeString('ar-EG', { hour: '2-digit', minute: '2-digit' });
    };

    return (
        <div className="booking-wrapper">
            <div className="card1">
                {/* Top strip */}
                <div className="card-top1">
                    <div className="avatar1">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.95)" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
                            <path d="M12 2C9 2 6 4 6 7c0 1.5.5 3 1 4.5C8 14 8 17 9 19c.5 1.5 1.5 3 3 3s2.5-1.5 3-3c1-2 1-5 2-7.5.5-1.5 1-3 1-4.5 0-3-3-5-6-5z" />
                        </svg>
                    </div>
                    <div className="card-top-info">
                        <div className="doctor-name1">{requestData?.doctorFirstName} {requestData?.doctorLastName}</div>
                        <div className="spec">{requestData?.categoryName}</div>
                    </div>
                    <div className="tag">حجز موعد</div>
                </div>

                {/* Body */}
                <div className="card-body1">
                    {/* Booking view */}
                    <div className={`booking-view ${confirmed ? 'hide' : ''}`} id="bookingView">
                        {/* Doctor info rows */}
                        <div className="info-rows">
                            <div className="info-row">
                                <div className="info-cell">
                                    <span className="lbl-icon">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="var(--button-color-2)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                            <rect x="3" y="4" width="18" height="18" rx="2" />
                                            <line x1="16" y1="2" x2="16" y2="6" />
                                            <line x1="8" y1="2" x2="8" y2="6" />
                                            <line x1="3" y1="10" x2="21" y2="10" />
                                        </svg>
                                        <span>اليوم</span>
                                    </span>
                                    <span className="val accent">{formatDate(requestData?.dateTime)}</span>
                                </div>
                                <div className="info-cell">
                                    <span className="lbl-icon">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="var(--button-color-2)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                            <circle cx="12" cy="12" r="10" />
                                            <polyline points="12 6 12 12 16 14" />
                                        </svg>
                                        <span>الوقت</span>
                                    </span>
                                    <span className="val accent">{formatTime(requestData?.dateTime)}</span>
                                </div>
                            </div>
                            <div className="info-row">
                                <div className="info-cell">
                                    <span className="lbl-icon">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="var(--button-color-2)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                            <path d="M22 10v6M2 10l10-5 10 5-10 5z" />
                                            <path d="M6 12v5c3 3 9 3 12 0v-5" />
                                        </svg>
                                        <span>الجامعة</span>
                                    </span>
                                    <span className="val">{requestData?.doctorUniversityName}</span>
                                </div>
                            </div>
                            <div className="info-row">
                                <div className="info-cell">
                                    <span className="lbl-icon">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="var(--button-color-2)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                            <path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0 1 18 0z" />
                                            <circle cx="12" cy="10" r="3" />
                                        </svg>
                                        <span>المحافظة</span>
                                    </span>
                                    <span className="val">{requestData?.doctorCityName}</span>
                                </div>
                            </div>
                        </div>

                        {/* Form */}
                        <div className="divider1">بياناتك</div>

                        <div className="form-row-2">
                            <div className="form-group">
                                <label>الاسم الأول</label>
                                <div className="input-wrap">
                                    <span className="i-ico">
                                        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                                            <circle cx="12" cy="7" r="4" />
                                        </svg>
                                    </span>
                                    <input
                                        type="text"
                                        id="firstName"
                                        placeholder="الاسم الاول"
                                        value={formData.patientFirstName}
                                        onChange={handleInputChange}
                                        className={fieldErrors.firstName ? 'error' : ''}
                                        disabled={loading}
                                        className="input_11"
                                    />
                                </div>
                            </div>
                            <div className="form-group">
                                <label>الاسم الأخير</label>
                                <div className="input-wrap">
                                    <span className="i-ico">
                                        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                                            <circle cx="12" cy="7" r="4" />
                                        </svg>
                                    </span>
                                    <input
                                        type="text"
                                        id="lastName"
                                        placeholder="الاسم الاخير"
                                        value={formData.patientLastName}
                                        onChange={handleInputChange}
                                        className={fieldErrors.lastName ? 'error' : ''}
                                        disabled={loading}
                                        className="input_11"
                                    />
                                </div>
                            </div>
                        </div>

                        <div className="form-group full">
                            <label>رقم الهاتف</label>
                            <div className="input-wrap">
                                <span className="i-ico">
                                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                        <path d="M22 16.92v3a2 2 0 0 1-2.18 2A19.79 19.79 0 0 1 11.39 19a19.45 19.45 0 0 1-6-6A19.79 19.79 0 0 1 2.12 4.18 2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z" />
                                    </svg>
                                </span>
                                <input
                                    type="tel"
                                    id="phone"
                                    placeholder="01X XXXX XXXX"
                                    value={formData.patientPhoneNumber}
                                    onChange={handleInputChange}
                                    className={fieldErrors.phone ? 'error' : ''}
                                    disabled={loading}
                                    className="input_11"
                                />
                            </div>
                        </div>

                        {apiError && (
                            <div className="error-message" style={{ marginBottom: '16px', padding: '12px 14px', backgroundColor: '#fee2e2', border: '1px solid #fecaca', borderRadius: '8px', color: '#991b1b', fontSize: '14px', fontWeight: '600' }}>
                                {apiError}
                            </div>
                        )}

                        <button className="btn-confirm" onClick={handleConfirm} disabled={loading}>
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" style={{ display: 'inline-block', verticalAlign: 'middle', marginLeft: '6px' }}>
                                <polyline points="20 6 9 17 4 12" />
                            </svg>
                            تأكيد الحجز
                        </button>
                    </div>

                    {/* Success view */}
                    <div className={`success-view ${confirmed ? 'show' : ''}`} id="successView">
                        <div className="success-ring">
                            <svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="var(--button-color-1)" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
                                <polyline points="20 6 9 17 4 12" />
                            </svg>
                        </div>
                        <h3>تم الحجز بنجاح</h3>
                        <div className="success-box" id="successMsg">
                            تم حجز موعدك بنجاح مع <span className="hl">د. {requestData?.doctorFirstName} {requestData?.doctorLastName}</span> يوم <span className="hl">{formatDate(requestData?.dateTime)}</span> الساعة <span className="hl">{formatTime(requestData?.dateTime)}</span> في <span className="hl">{requestData?.doctorUniversityName}</span>.
                        </div>
                        <div className="chips">
                            <div className="chip">
                                <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                    <rect x="3" y="4" width="18" height="18" rx="2" />
                                    <line x1="16" y1="2" x2="16" y2="6" />
                                    <line x1="8" y1="2" x2="8" y2="6" />
                                    <line x1="3" y1="10" x2="21" y2="10" />
                                </svg>
                                {formatDate(requestData?.dateTime)}
                            </div>
                            <div className="chip">
                                <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                    <circle cx="12" cy="12" r="10" />
                                    <polyline points="12 6 12 12 16 14" />
                                </svg>
                                {formatTime(requestData?.dateTime)}
                            </div>
                            <div className="chip">
                                <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                    <path d="M22 10v6M2 10l10-5 10 5-10 5z" />
                                    <path d="M6 12v5c3 3 9 3 12 0v-5" />
                                </svg>
                                {requestData?.doctorUniversityName}
                            </div>
                        </div>
                        <button className="btn-done" onClick={handleReset}>تم</button>
                    </div>
                </div>
            </div>
        </div>
    );
}