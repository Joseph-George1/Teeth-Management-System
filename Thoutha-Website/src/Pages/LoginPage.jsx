
import { useContext , useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { AuthContext } from "../services/AuthContext";
import '../Css/LoginPage.css';

export default function LoginPage() {
  const { login } = useContext(AuthContext);
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
      // Determine if the login is for a doctor or patient based on email format
      // You might want to adjust this logic based on your actual requirements
      const isDoctorLogin = email.endsWith('@example.com'); // Example condition
      const endpoint = isDoctorLogin ? 
        'http://localhost:8080/api/doctor/login' : 
        'http://localhost:8080/api/patient/login';
      
      const response = await fetch(endpoint, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email: email,
          password: password,
          // For patient login, you might need to send phoneNumber instead of email
          ...(!isDoctorLogin && { phoneNumber: email }) // Use email as phoneNumber for patient login
        }),
      });

      const data = await response.json();
      console.log("Server response:", data);
      
      if (response.ok) {
        login({
          id: data.id,
          firstName: data.firstName || '',
          lastName: data.lastName || '',
          email: data.email || email,
          phoneNumber: data.phoneNumber || '',
          role: isDoctorLogin ? 'doctor' : 'patient',
          // Include any additional user data you need
          ...(isDoctorLogin && { 
            specialty: data.specialty,
            licenseNumber: data.licenseNumber
          })
        }); 
        
        // Redirect based on user role
        navigate(isDoctorLogin ? '/doctor-home' : '/patient-home'); 
      } else {
        setError(data.message || 'فشل تسجيل الدخول. يرجى التحقق من البريد الإلكتروني وكلمة المرور');
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

  return (
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
  );
}
