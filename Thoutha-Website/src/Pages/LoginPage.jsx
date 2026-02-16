import { Helmet } from "react-helmet-async";
import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import '../Css/LoginPage.css';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    
    // Validation
    if (!email || !password) {
      setError('يرجى إدخال البريد الإلكتروني وكلمة المرور');
      return;
    }
    setLoading(true);
    try {
      const response = await fetch("https://thoutha.page/api/auth/login/doctor", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email: email,
          password: password,
        }),
      });

      const data = await response.json();
      console.log("Server response:", data);
      if (response.ok) {
        navigate('/'); 
      } else {
        setError(data.message || 'فشل تسجيل الدخول. يرجى التحقق من البيانات');
      }
    } catch (err) {
      if (err.message.includes('CORS') || err.message.includes('Failed to fetch')) {
        setError('مشكلة في الاتصال بالخادم. يرجى التحقق من الاتصال بالإنترنت');
      } else {
        setError('حدث خطأ في الاتصال. يرجى المحاولة مرة أخرى');
      }
      console.error('Login error:', err);
    } finally {
      setLoading(false);
    }
  };

  return ( <> 
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
            <p className="forgot-password">
              نسيت كلمة المرور؟
            </p>
            <label className="remember-me">
              <p>تذكرني</p>       
              <input
                type="checkbox"
                className='remember-me-input'
              />
            </label>
          </div>

          {/* Login Button */}
          <button 
            type="submit" 
            className="login-button"
          >
            تسجيل الدخول
          </button>
        </form>
        
        {/* Create Account Link */}
        <div className="create-account">
          <Link to="/sign" className="create-account-link">انشئ حساب  </Link>
          <span>ليس لديك حساب</span>
        </div>
      </div>
    </div>
    </>
  );
}
