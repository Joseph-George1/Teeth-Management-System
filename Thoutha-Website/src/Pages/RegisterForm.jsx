import { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Helmet } from "react-helmet-async";
import '../Css/RegisterForm.css';

const SERVER_URL = 'https://thoutha.page/api'; 

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

  const handlePhoneChange = (e) => {
    const value = e.target.value;
    const cleaned = value.replace(/[^\d+]/g, '');
    
    if (!cleaned.startsWith('+2')) {
      const digits = cleaned.replace(/\D/g, '');
      setPhone(`+2${digits.replace(/^2/, '')}`);
      return;
    }
    
    setPhone(`+2${cleaned.slice(2).replace(/\D/g, '')}`);
    error && setError('');
  };

  // التحقق من الاسم الأول - العربية فقط
  const handleFirstNameChange = (e) => {
    const value = e.target.value;
    // تقبل الأحرف العربية والمسافات فقط
    if (/^[\u0600-\u06FF\s]*$/.test(value) || value === '') {
      setFirstName(value);
    }
    error && setError('');
  };

  // التحقق من الاسم الثاني - العربية فقط
  const handleLastNameChange = (e) => {
    const value = e.target.value;
    // تقبل الأحرف العربية والمسافات فقط
    if (/^[\u0600-\u06FF\s]*$/.test(value) || value === '') {
      setLastName(value);
    }
    error && setError('');
  };

  const [cities, setCities] = useState([]);
  const [universities, setUniversities] = useState([]);
  const [categories, setCategories] = useState([]);

  const [citiesLoading, setCitiesLoading] = useState(true);
  const [universitiesLoading, setUniversitiesLoading] = useState(true);
  const [categoriesLoading, setCategoriesLoading] = useState(true);

  // 🔹 Fetch Cities
  useEffect(() => {
    const fetchCities = async () => {
      try {
        const response = await fetch(`${SERVER_URL}/cities/getAllCities`);
        if (!response.ok) throw new Error('Failed to load cities');
        const data = await response.json();
        setCities(data || []);
      } catch (err) {
        console.error('خطأ في تحميل المحافظات:', err);
        setCities([]);
      } finally {
        setCitiesLoading(false);
      }
    };
    fetchCities();
  }, []);

  // 🔹 Fetch Universities
  useEffect(() => {
    const fetchUniversities = async () => {
      try {
        const response = await fetch(`${SERVER_URL}/university/getAllUniversities`);
        if (!response.ok) throw new Error('Failed to load universities');
        const data = await response.json();
        setUniversities(data || []);
      } catch (err) {
        console.error('خطأ في تحميل الجامعات:', err);
        setUniversities([]);
      } finally {
        setUniversitiesLoading(false);
      }
    };
    fetchUniversities();
  }, []);

  // 🔹 Fetch Categories
  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const response = await fetch(`${SERVER_URL}/category/getCategories`);
        if (!response.ok) throw new Error('Failed to load categories');
        const data = await response.json();
        setCategories(data || []);
      } catch (err) {
        console.error('خطأ في تحميل الخدمات:', err);
        setCategories([]);
      } finally {
        setCategoriesLoading(false);
      }
    };
    fetchCategories();
  }, []);

  // 🔹 Handle Submit
  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    if (!firstName || !lastName || !email || !phone || !city || !faculty || !year || !password || !confirmPassword || !category) {
      setError('يرجى ملء جميع الحقول');
      return;
    }

    // التحقق من أن الاسم الأول باللغة العربية فقط
    if (!/^[\u0600-\u06FF\s]+$/.test(firstName.trim())) {
      setError('ادخل الاسم الأول باللغة العربية');
      return;
    }

    // التحقق من أن الاسم الثاني باللغة العربية فقط
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

      // Commented out to prevent user data leak
      // console.log('Signup payload:', signupPayload);

      const response = await fetch(`${SERVER_URL}/auth/signup`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(signupPayload),
      });

      const data = await response.json();
      // console.log('Signup response:', data);

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

      // لو التسجيل ناجح، نروح لصفحة OTP
      navigate('/otp', { state: { email, phone } });

    } catch (err) {
      console.error(err);
      setError('حدث خطأ في الاتصال بالخادم');
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
    {/* Error Popup */}
    {error && (
      <div className="error-popup">
        {error}
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
