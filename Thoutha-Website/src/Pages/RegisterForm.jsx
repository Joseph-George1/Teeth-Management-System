import { useState, useEffect, useRef } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Helmet } from "react-helmet-async";
import '../Css/RegisterForm.css';

const SERVER_URL = 'https://thoutha.page/api';
const OTP_LENGTH = 6;

const normalizeList = (payload) => {
  if (Array.isArray(payload)) return payload;
  if (Array.isArray(payload?.data)) return payload.data;
  if (Array.isArray(payload?.content)) return payload.content;
  return [];
};

export default function RegisterForm() {
  const navigate = useNavigate();

  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('+2');
  const [city, setCity] = useState('');
  const [faculty, setFaculty] = useState('');
  const [year, setYear] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [category, setCategory] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  
  const [otp, setOtp] = useState(Array(OTP_LENGTH).fill(''));
  const [otpSent, setOtpSent] = useState(false);
  const [phoneVerified, setPhoneVerified] = useState(false);
  const [otpLoading, setOtpLoading] = useState(false);
  const [otpError, setOtpError] = useState('');
  const [otpSuccess, setOtpSuccess] = useState('');
  const inputsRef = useRef([]);

  const handlePhoneChange = (e) => {
    const value = e.target.value;
    const cleaned = value.replace(/[^\d+]/g, '');
    
    if (!cleaned.startsWith('+2')) {
      const digits = cleaned.replace(/\D/g, '');
      setPhone(`+2${digits.replace(/^2/, '')}`);
    } else {
      setPhone(`+2${cleaned.slice(2).replace(/\D/g, '')}`);
    }
    
    error && setError('');
    
    // إذا تم تغيير الهاتف بعد التفعيل، إعادة تعيين حالة التفعيل
    if (phoneVerified) {
      setPhoneVerified(false);
      setOtpSent(false);
      setOtp(Array(OTP_LENGTH).fill(''));
      setOtpSuccess('');
      setOtpError('');
    }
  };

  const handleFirstNameChange = (e) => {
    const value = e.target.value;
    if (/^[\u0600-\u06FF\s]*$/.test(value) || value === '') {
      setFirstName(value);
    }
    error && setError('');
  };

  const handleLastNameChange = (e) => {
    const value = e.target.value;
    if (/^[\u0600-\u06FF\s]*$/.test(value) || value === '') {
      setLastName(value);
    }
    error && setError('');
  };

  const sendOTP = async (e) => {
    e.preventDefault();
    setOtpError('');
    setOtpSuccess('');

    if (!/^\+20\d{10}$/.test(phone)) {
      setOtpError('رقم التليفون يجب أن يكون بصيغة +20 متبوعًا بـ 10 أرقام');
      return;
    }

    setOtpLoading(true);

    try {
      const response = await fetch(`${SERVER_URL}/otp/send`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ phone_number: phone }),
      });

      if (!response.ok) {
        const data = await response.json().catch(() => ({}));
        setOtpError(data?.messageAr || data?.messageEn || data?.message || 'فشل إرسال الكود');
        setOtpLoading(false);
        return;
      }

      setOtpSent(true);
      setOtpSuccess('تم إرسال الكود بنجاح');
      setTimeout(() => setOtpSuccess(''), 3000);
    } catch (error) {
      console.error("خطأ في إرسال الكود:", error);
      setOtpError('حدث خطأ في الاتصال بالخادم');
    } finally {
      setOtpLoading(false);
    }
  };

  const handleOtpChange = (index, value) => {
    if (!/^\d?$/.test(value)) return;

    const updated = [...otp];
    updated[index] = value;
    setOtp(updated);

    if (value && index < OTP_LENGTH - 1) {
      inputsRef.current[index + 1]?.focus();
    }
  };

  const handleOtpKeyDown = (index, e) => {
    if (e.key === 'Backspace' && !otp[index] && index > 0) {
      inputsRef.current[index - 1]?.focus();
    }
  };

  const verifyOTP = async (e) => {
    e.preventDefault();
    setOtpError('');

    const code = otp.join('').trim();

    if (code.length !== OTP_LENGTH) {
      setOtpError('يرجى إدخال الكود كاملاً');
      return;
    }

    setOtpLoading(true);

    try {
      const response = await fetch(`${SERVER_URL}/otp/verify`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ phone_number: phone, otp: code }),
      });

      if (!response.ok) {
        const data = await response.json().catch(() => ({}));
        setOtpError(data?.messageAr || data?.messageEn || data?.message || 'كود غير صحيح');
        setOtpLoading(false);
        return;
      }

      setPhoneVerified(true);
      setOtpSuccess('تم تفعيل الرقم بنجاح');
      setOtpError('');
      setTimeout(() => setOtpSuccess(''), 3000);
    } catch (error) {
      console.error("خطأ في التحقق من الكود:", error);
      setOtpError('حدث خطأ في الاتصال بالخادم');
    } finally {
      setOtpLoading(false);
    }
  };

  const [cities, setCities] = useState([]);
  const [universities, setUniversities] = useState([]);
  const [categories, setCategories] = useState([]);

  const [citiesLoading, setCitiesLoading] = useState(true);
  const [universitiesLoading, setUniversitiesLoading] = useState(true);
  const [categoriesLoading, setCategoriesLoading] = useState(true);

  useEffect(() => {
    const fetchCities = async () => {
      try {
        const response = await fetch(`${SERVER_URL}/cities/getAllCities`);
        if (!response.ok) throw new Error('Failed to load cities');
        const data = await response.json();
        setCities(normalizeList(data));
      } catch (error) {
        console.error("خطأ في جلب المدن:", error);
        setCities([]);
      } finally {
        setCitiesLoading(false);
      }
    };
    fetchCities();
  }, []);

  useEffect(() => {
    const fetchUniversities = async () => {
      try {
        const response = await fetch(`${SERVER_URL}/university/getAllUniversities`);
        if (!response.ok) throw new Error('Failed to load universities');
        const data = await response.json();
        setUniversities(normalizeList(data));
      } catch (error) {
        console.error("خطأ في جلب الجامعات:", error);
        setUniversities([]);
      } finally {
        setUniversitiesLoading(false);
      }
    };
    fetchUniversities();
  }, []);

  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const response = await fetch(`${SERVER_URL}/category/getCategories`);
        if (!response.ok) throw new Error('Failed to load categories');
        const data = await response.json();
        setCategories(normalizeList(data));
      } catch (error) {
        console.error("خطأ في جلب الفئات:", error);
        setCategories([]);
      } finally {
        setCategoriesLoading(false);
      }
    };
    fetchCategories();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    // التحقق من تفعيل الهاتف أولاً
    if (!phoneVerified) {
      setError('يجب تفعيل رقم الهاتف أولاً');
      setTimeout(() => setError(''), 5000);
      return;
    }

    if (!firstName || !lastName || !email || !phone || !city || !faculty || !year || !password || !confirmPassword || !category) {
      setError('يرجى ملء جميع الحقول');
      return;
    }

    if (!/^[\u0600-\u06FF\s]+$/.test(firstName.trim())) {
      setError('ادخل الاسم الأول باللغة العربية');
      return;
    }

    if (!/^[\u0600-\u06FF\s]+$/.test(lastName.trim())) {
      setError('ادخل الاسم الأخير باللغة العربية');
      return;
    }

    if (password !== confirmPassword) {
      setError('كلمات المرور غير متطابقة');
      return;
    }

    if (!email.endsWith('.edu.eg')) {
      setError('ادخل الايميل الجامعى');
      return;
    }

    if (!/^\+20\d{10}$/.test(phone)) {
      setError('رقم التليفون يجب أن يكون بصيغة +20 متبوعًا بـ 10 أرقام');
      return;
    }

    setLoading(true);

    try {
      const signupPayload = {
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        phoneNumber: phone,
        cityName: city,
        studyYear: year,
        categoryName: category,
        universityName: faculty,
      };

      const response = await fetch(`${SERVER_URL}/auth/signup`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(signupPayload),
      });

      const data = await response.json().catch(() => ({}));

      if (!response.ok) {
        if (Array.isArray(data) && data.length > 0) {
          const errors = data.map(err => err.messageAr || err.messageEn || err.msg || err.message || err).filter(Boolean).join(' • ');
          setError(errors || 'حدث خطأ في التسجيل');
        } else {
          setError(data?.messageAr || data?.messageEn || data?.message || 'حدث خطأ في التسجيل');
        }
        setLoading(false);
        return;
      }

      // بعد نجاح التسجيل، الانتقال مباشرة إلى صفحة النجاح
      navigate('/otp-done');

    } catch (error) {
      console.error("خطأ في التسجيل:", error);
      setError('حدث خطأ في الاتصال بالخادم');
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
    {error && (
      <div className="error-popup">
        {error}
      </div>
    )}
    {otpError && (
      <div className="error-popup">
        {otpError}
      </div>
    )}
    {otpSuccess && (
      <div className="success-popup">
        {otpSuccess}
      </div>
    )}
    
    <Helmet>
      <meta
        name="description"
        content="منصة ثوثة بتربط مرضى الأسنان بطلاب كليات طب الأسنان لعلاج الحالات مجانًا تحت الإشراف المباشر لأعضاء هيئة التدريس بالكلية، مع فرصة تعليمية عملية للطلاب"
          />
    </Helmet>
    <div className="signup-page">
      <div className="signup-container">
        <p className="signup-title">انشاء حساب</p>
        <p className="signup-subtitle">انشئ حساب للمتابعه</p>

        <form className="signup-form" onSubmit={handleSubmit}>

          <div className="input-group">
            <input
              type="text"
              placeholder="الاسم الاول باللغة العربية"
              value={firstName}
              onChange={handleFirstNameChange}
              required
              className="input-field-2"
              autoComplete="given-name"
            />
            <input
              type="text"
              placeholder="الاسم الاخير "
              value={lastName}
              onChange={handleLastNameChange}
              required
              className="input-field-2"
              autoComplete="family-name"
            />
          </div>

          <div className="input-group">
            <input
              type="email"
              placeholder="username@university.edu.eg"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              className="input-field-2"
              autoComplete="email"
            />
            <input
              type="tel"
              placeholder="+2XXXXXXXXXXX"
              value={phone}
              onChange={handlePhoneChange}
              required
              className="input-field-2"
              autoComplete="tel"
              dir="rtl"
            />
          </div>

          {/* قسم التحقق من رقم الهاتف */}
          <div className="phone-verification-section">
            {!otpSent && !phoneVerified && (
              <button
                type="button"
                onClick={sendOTP}
                disabled={otpLoading}
                className="send-otp-button"
              >
                {otpLoading ? 'جاري الإرسال...' : 'إرسال كود التفعيل'}
              </button>
            )}

            {otpSent && !phoneVerified && (
              <div className="otp-verification-form">
                <div className="otp-inputs" dir="ltr">
                  {otp.map((value, index) => (
                    <input
                      key={index}
                      ref={(el) => (inputsRef.current[index] = el)}
                      type="text"
                      maxLength="1"
                      value={value}
                      onChange={(e) => handleOtpChange(index, e.target.value)}
                      onKeyDown={(e) => handleOtpKeyDown(index, e)}
                      className="otp-input-box"
                      inputMode="numeric"
                      disabled={otpLoading}
                    />
                  ))}
                </div>
                <button
                  type="button"
                  onClick={verifyOTP}
                  disabled={otpLoading}
                  className="verify-button"
                >
                  {otpLoading ? 'جاري التحقق...' : 'تحقق من الكود'}
                </button>
              </div>
            )}

            {phoneVerified && (
              <div className="phone-verified-section">
                <button
                  type="button"
                  className="send-otp-button verified"
                  disabled
                >
                  تم التفعيل
                </button>
              </div>
            )}
          </div>

          <div className="input-group">
            <select
              value={city}
              onChange={(e) => setCity(e.target.value)}
              required
              className="input-field-2"
              disabled={citiesLoading}
            >
              <option value="">
                {citiesLoading ? 'جاري تحميل المحافظات...' : 'اختر المحافظةالتابعة لها الكلية'}
              </option>
              {cities.map((item) => (
                <option key={item.id || item.name} value={item.name}>
                  {item.name}
                </option>
              ))}
            </select>

            <select
              value={faculty}
              onChange={(e) => setFaculty(e.target.value)}
              required
              className="input-field-2"
              disabled={universitiesLoading}
            >
              <option value="">
                {universitiesLoading ? 'جاري تحميل الجامعات...' : 'اختر الجامعة'}
              </option>
              {universities.map((item) => (
                <option key={item.id || item.name} value={item.name}>
                  {item.name}
                </option>
              ))}
            </select>

            <select
              value={year}
              onChange={(e) => setYear(e.target.value)}
              required
              className="input-field-2"
            >
              <option value="">السنة الدراسية</option>
              <option value="الرابعة">الرابعة</option>
              <option value="الخامسة">الخامسة</option>
              <option value="امتياز">امتياز</option>
            </select>

            <select
              value={category}
              onChange={(e) => setCategory(e.target.value)}
              required
              className="input-field-2"
              disabled={categoriesLoading}
            >
              <option value="">
                {categoriesLoading ? 'جاري تحميل الخدمات...' : 'اختر الخدمة'}
              </option>
              {categories.map((item) => (
                <option key={item.id || item.name} value={item.name}>
                  {item.name}
                </option>
              ))}
            </select>
          </div>

          <div className="input-group password-row">
            <input
              type="password"
              placeholder="تأكيد كلمة المرور"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              required
              className="input-field-2"
              autoComplete="new-password"
            />
            <input
              type="password"
              placeholder="كلمة المرور"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              className="input-field-2"
              autoComplete="new-password"
            />
          </div>

          <button type="submit" className="signup-button" disabled={loading}>
            {loading ? 'جاري التسجيل...' : 'انشاء حساب'}
          </button>

        </form>

        <div className="login-link">
          <span>لديك حساب بالفعل؟ </span>
          <Link to="/login">تسجيل الدخول</Link>
        </div>
      </div>
    </div>
    </>
  );
}

