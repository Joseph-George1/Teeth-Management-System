import { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import '../Css/RegisterForm.css';

export default function RegisterForm() {
  const navigate = useNavigate();
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [city, setCity] = useState('');
  const [faculty, setFaculty] = useState('');
  const [year, setYear] = useState('');
  const [password, setPassword] = useState('');
  const [category, setCategory] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [cities, setCities] = useState([]);
  const [citiesLoading, setCitiesLoading] = useState(true);
  const [universities, setUniversities] = useState([]);
  const [universitiesLoading, setUniversitiesLoading] = useState(true);
  const [categories, setCategories] = useState([]);
  const [categoriesLoading, setCategoriesLoading] = useState(true);

  useEffect(() => {
    const fetchCities = async () => {
      try {
        const response = await fetch('https://thoutha.page/api/cities/getAllCities');
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

  useEffect(() => {
    const fetchUniversities = async () => {
      try {
        const response = await fetch('https://thoutha.page/api/university/getAllUniversity');
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

  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const response = await fetch('https://thoutha.page/api/category/getCategories');
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

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    if (!firstName || !lastName || !email || !phone || !city || !faculty || !year || !password || !confirmPassword || !category) {
      setError('يرجى ملء جميع الحقول');
      return;
    }


    setLoading(true);

    try {
      const response = await fetch('https://thoutha.page/api/auth/signup', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          firstName,
          lastName,
          email,
          password,
          phoneNumber: phone,
          cityName: city,
          studyYear: year,
          categoryName: category,
          universtyName: faculty,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        setError(data.message || 'حدث خطأ في التسجيل');
        setLoading(false);
        return;
      }

      // التسجيل نجح، انتقل إلى صفحة OTP
      navigate('/otp', { state: { email } });
    } catch (err) {
      setError(err.message || 'حدث خطأ في الاتصال بالخادم');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="signup-page">
      <div className="signup-container">
        <p className="signup-title">انشاء حساب </p>
        <p className="signup-subtitle">انشئ حساب للمتابعه</p>
        {error && <div className="error-message">{error}</div>}
        <form className="signup-form" onSubmit={handleSubmit}>
          <div className="input-group">
            <input type="text" placeholder="الاسم الاول" value={firstName} onChange={(e) => {setFirstName(e.target.value); error && setError('');}} required  className="input-field-2"/>
            <input type="text" placeholder="الاسم الاخير" value={lastName} onChange={(e) => {setLastName(e.target.value); error && setError('');}} required  className="input-field-2"/>
          </div>

          <div className="input-group">
            <input type="email" placeholder="ادخل ايميل الجامعة" value={email} onChange={(e) => {setEmail(e.target.value); error && setError('');}} required  className="input-field-2"/>
            <input type="tel" placeholder="رقم التليفون" value={phone} onChange={(e) => {setPhone(e.target.value); error && setError('');}} required  className="input-field-2"/>
          </div>

          <div className="input-group">
            <select value={city} onChange={(e) => {setCity(e.target.value); error && setError('');}} required className="input-field-2" disabled={citiesLoading}>
              <option value="">{citiesLoading ? 'جاري تحميل المحافظات...' : 'اختر المحافظة'}</option>
              {cities.map((cityItem) => (
                <option key={cityItem.id || cityItem.name} value={cityItem.name}>
                  {cityItem.name}
                </option>
              ))}
            </select>
          </div>

          <div className="input-group">
            <select value={faculty} onChange={(e) => {setFaculty(e.target.value); error && setError('');}} required className="input-field-2" disabled={universitiesLoading}>
              <option value="">{universitiesLoading ? 'جاري تحميل الجامعات...' : 'اختر الجامعة'}</option>
              {universities.map((universityItem) => (
                <option key={universityItem.id || universityItem.name} value={universityItem.name}>
                  {universityItem.name}
                </option>
              ))}
            </select>

            <select value={year} onChange={(e) => {setYear(e.target.value); error && setError('');}} required className="input-field-2">
              <option value="">السنة الدراسية</option>
              <option value="1">الاولى</option>
              <option value="2">الثانية</option>
              <option value="3">الثالثة</option>
              <option value="4">الرابعة</option>
              <option value="5">الخامسة</option>
            </select>

            <select value={category} onChange={(e) => {setCategory(e.target.value); error && setError('');}} required className="input-field-2" disabled={categoriesLoading}>
              <option value="">{categoriesLoading ? 'جاري تحميل الخدمات...' : 'اختر الخدمة'}</option>
              {categories.map((categoryItem) => (
                <option key={categoryItem.id || categoryItem.name} value={categoryItem.name}>
                  {categoryItem.name}
                </option>
              ))}
            </select>
          </div>

          <div className="input-group">
            <input type="password" placeholder="كلمة المرور" value={password} onChange={(e) => {setPassword(e.target.value); error && setError('');}} required  className="input-field-2"/>
          </div>
          <button type="submit" className="signup-button" disabled={loading}>
            {loading ? 'جاري التسجيل...' : 'انشاء حساب'}
          </button>

        </form>

        <div className="login-link">
          <Link to="/login">تسجيل الدخول</Link>
          <span>لديك حساب بالفعل؟ </span>
        </div>
      </div>
    </div>
  );
}
