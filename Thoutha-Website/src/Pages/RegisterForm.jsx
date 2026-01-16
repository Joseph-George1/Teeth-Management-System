import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import '../Css/RegisterForm.css';

export default function RegisterForm() {
  const navigate = useNavigate();
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [college, setCollege] = useState('');
  const [year, setYear] = useState('');
  const [governorate, setGovernorate] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    setError('');

    if (!firstName || !lastName || !email || !phone || !college || !year || !governorate || !password || !confirmPassword) {
      setError('يرجى ملء جميع الحقول');
      return;
    }

    if (password !== confirmPassword) {
      setError('كلمة المرور وتأكيد كلمة المرور غير متطابقين');
      return;
    }

    // كل حاجة صحيحة، انتقل للـ OTP
    navigate('/otp');
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
            <input type="email" placeholder="User@gmail.com" value={email} onChange={(e) => {setEmail(e.target.value); error && setError('');}} required  className="input-field-2"/>
            <input type="tel" placeholder="رقم التليفون" value={phone} onChange={(e) => {setPhone(e.target.value); error && setError('');}} required  className="input-field-2"/>
          </div>

          <div className="input-group">
            <select value={college} onChange={(e) => {setCollege(e.target.value); error && setError('');}} required className="input-field-2">
              <option value="">اختر الكلية</option>
              <option value="dentistry">طب الاسنان</option>
              <option value="medicine">الطب البشري</option>
              <option value="pharmacy">الصيدلة</option>
            </select>

            <select value={year} onChange={(e) => {setYear(e.target.value); error && setError('');}} required className="input-field-2">
              <option value="">السنة الدراسية</option>
              <option value="1">الاولى</option>
              <option value="2">الثانية</option>
              <option value="3">الثالثة</option>
              <option value="4">الرابعة</option>
              <option value="5">الخامسة</option>
            </select>

            <select value={governorate} onChange={(e) => {setGovernorate(e.target.value); error && setError('');}} required className="input-field-2">
              <option value="">اختر المحافظة</option>
              <option value="cairo">القاهرة</option>
              <option value="alex">الإسكندرية</option>
              <option value="giza">الجيزة</option>
            </select>
          </div>

          <div className="input-group">
            <input type="password" placeholder="كلمة المرور" value={password} onChange={(e) => {setPassword(e.target.value); error && setError('');}} required  className="input-field-2"/>
            <input type="password" placeholder="تأكيد كلمة المرور" value={confirmPassword} onChange={(e) => {setConfirmPassword(e.target.value); error && setError('');}} required  className="input-field-2"/>
          </div>
          <button type="submit" className="signup-button">انشاء حساب</button>

        </form>

        <div className="login-link">
          <Link to="/login">تسجيل الدخول</Link>
          <span>لديك حساب بالفعل؟ </span>
        </div>
      </div>
    </div>
  );
}
