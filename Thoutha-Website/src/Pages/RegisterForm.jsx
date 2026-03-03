import { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import '../Css/RegisterForm.css';

const SERVER_URL = 'http://16.16.218.59:8080/api'; 

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
        const response = await fetch(`SERVER_URL/cities/getAllCities`);
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
        const response = await fetch(`SERVER_URL/university/getAllUniversities`);
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
        const response = await fetch(`SERVER_URL/category/getCategories`);
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

    if (!firstName || !lastName || !email || !phone || !city || !faculty || !year || !password || !category) {
      setError('يرجى ملء جميع الحقول');
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
        phoneNumber: phone,
        cityName: city,
        studyYear: year,
        categoryName: category,
        universityName: faculty,
      };

      console.log('Signup payload:', signupPayload);

      const response = await fetch(`SERVER_URL/auth/signup`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(signupPayload),
      });

      const data = await response.json();
      console.log('Signup response:', data);

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
      navigate('/otp', { state: { email } });

    } catch (err) {
      console.error(err);
      setError('حدث خطأ في الاتصال بالخادم');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="signup-page">
      <div className="signup-container">
        <p className="signup-title">انشاء حساب</p>
        <p className="signup-subtitle">انشئ حساب للمتابعه</p>

        {error && <div className="error-message">{error}</div>}

        <form className="signup-form" onSubmit={handleSubmit}>

          <div className="input-group">
            <input
              type="text"
              placeholder="الاسم الاول"
              value={firstName}
              onChange={(e) => setFirstName(e.target.value)}
              required
              className="input-field-2"
              autoComplete="given-name"
            />
            <input
              type="text"
              placeholder="الاسم الاخير"
              value={lastName}
              onChange={(e) => setLastName(e.target.value)}
              required
              className="input-field-2"
              autoComplete="family-name"
            />
          </div>

          <div className="input-group">
            <input
              type="email"
              placeholder="ادخل ايميل الجامعة"
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
                {citiesLoading ? 'جاري تحميل المحافظات...' : 'اختر المحافظة'}
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
              <option value="1">الاولى</option>
              <option value="2">الثانية</option>
              <option value="3">الثالثة</option>
              <option value="4">الرابعة</option>
              <option value="5">الخامسة</option>
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

          <div className="input-group">
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
  );
}