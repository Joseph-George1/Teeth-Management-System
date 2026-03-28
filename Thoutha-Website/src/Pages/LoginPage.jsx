import { Helmet } from "react-helmet-async";
import { useState, useContext, useEffect } from 'react';
import { Link, replace, useNavigate } from 'react-router-dom';
import { AuthContext } from "../services/AuthContext";
import '../Css/LoginPage.css';

const API_BASE_URL = import.meta.env.DEV ? '/api' : 'https://thoutha.page/api';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [rememberMe, setRememberMe] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();
  const { login } = useContext(AuthContext);

  // تحميل البيانات المحفوظة عند دخول الصفحة
  useEffect(() => {
    const savedEmail = localStorage.getItem('rememberedEmail');
    const savedPassword = localStorage.getItem('rememberedPassword');
    const wasRemembered = localStorage.getItem('rememberMe') === 'true';
    
    if (wasRemembered && savedEmail && savedPassword) {
      setEmail(savedEmail);
      setPassword(savedPassword);
      setRememberMe(true);
    }
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    if (!email || !password) {
      setError('يرجى إدخال البريد الإلكتروني وكلمة المرور');
      return;
    }

    setLoading(true);

    try {
      const response = await fetch(`${API_BASE_URL}/auth/login/doctor`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password }),
      });

      const data = await response.json().catch(() => ({}));

      if (response.ok && data?.token) {
        // حفظ البيانات إذا كان المستخدم اختار تذكره
        if (rememberMe) {
          localStorage.setItem('rememberedEmail', email);
          localStorage.setItem('rememberedPassword', password);
          localStorage.setItem('rememberMe', 'true');
        } else {
          localStorage.removeItem('rememberedEmail');
          localStorage.removeItem('rememberedPassword');
          localStorage.removeItem('rememberMe');
        }
        
        await login(data.token);
        // navigate('/doctor-home', { replace: true });
        navigate("/", {replace:true});
      } else if (response.ok) {
        setError('لم يتم استلام رمز الدخول من الخادم');
      } else {
        setError(data.message || 'فشل تسجيل الدخول. يرجى التحقق من البيانات');
      }

    } catch (err) {
      const message = err?.message || '';

      if (message.includes('CORS') || message.includes('Failed to fetch')) {
        setError('مشكلة في الاتصال بالخادم. يرجى التحقق من الاتصال بالإنترنت');
      } else {
        setError(message || 'حدث خطأ في الاتصال. يرجى المحاولة مرة أخرى');
      }
      console.error('Login error:', err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      <Helmet>
        <meta
          name="description"
          content="منصة ثوثة بتربط مرضى الأسنان بطلاب كليات طب الأسنان لعلاج الحالات مجانًا تحت الإشراف المباشر لأعضاء هيئة التدريس بالكلية، مع فرصة تعليمية عملية للطلاب"
        />
      </Helmet>

      <div className="login-page">
        <div className="login-container">

          {/* Logo */}
          <div className="logo-container">
            <img src="/ثوثة.png" alt="ثوثة Logo" className="logo" />
          </div>

          {/* Title */}
          <p className="login-title">تسجيل الدخول</p>
          <p className="login-subtitle">ادخل الرقم او الايميل</p>

          {/* Form */}
          <form className="login-form" onSubmit={handleSubmit}>

            {/* Error Message */}
            {error && (
              <div className="error-message" style={{
                color: '#d32f2f',
                backgroundColor: '#ffebee',
                padding: '12px',
                borderRadius: '8px',
                marginBottom: '20px',
                textAlign: 'center',
                fontSize: '14px',
                direction: 'rtl'
              }}>
                {error}
              </div>
            )}

            {/* Email */}
            <div className="input-group">
              <input
                type="email"
                className="input-field"
                placeholder="User@gmail.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                disabled={loading}
                required
                autoComplete="email"
              />
            </div>

            {/* Password */}
            <div className="input-group">
              <input
                type="password"
                className="input-field"
                placeholder="كلمة المرور"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                disabled={loading}
                required
                autoComplete="current-password"
              />
            </div>

            {/* Remember Me & Forgot Password */}
            <div className="form-options">
              <Link to="/forget-password" className="forgot-password">نسيت كلمة المرور؟</Link>
              <label className="remember-me">
                <p>تذكرني</p>
                <input 
                  type="checkbox" 
                  className='remember-me-input'
                  checked={rememberMe}
                  onChange={(e) => setRememberMe(e.target.checked)}
                  disabled={loading}
                />
              </label>
            </div>

            {/* Login Button */}
            <button type="submit" className="login-button" disabled={loading}>
              {loading ? 'جاري تسجيل الدخول...' : 'تسجيل الدخول'}
            </button>

          </form>

          {/* Create Account */}
          <div className="create-account">
            <span>ليس لديك حساب؟ </span>
            <Link to="/sign" className="create-account-link">انشئ حساب</Link>
          </div>

        </div>
      </div>
    </>
  );
}