import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import '../Css/Login.css';

const LoginPage = ({ setIsAuthenticated }) => {
  const navigate = useNavigate();
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleLogin = (e) => {
    e.preventDefault();
    
    // For demo purposes, accept any non-empty credentials
    // In a real app, you would validate against your backend
    if (username && password) {
      setIsAuthenticated(true);
      navigate('/');
    } else {
      setError('الرجاء إدخال اسم المستخدم وكلمة المرور');
    }
  };

  return (
    <div className="login-container">
      <div className="login-box">
        <h1>تسجيل الدخول</h1>
        {error && <div className="error-message">{error}</div>}
        <form onSubmit={handleLogin}>
          <div className="form-group">
            <label htmlFor="username">اسم المستخدم:</label>
            <input
              type="text"
              id="username"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              required
            />
          </div>
          <div className="form-group">
            <label htmlFor="password">كلمة المرور:</label>
            <input
              type="password"
              id="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>
          <button type="submit" className="login-button">
            دخول
          </button>
        </form>
      </div>
    </div>
  );
};

export default LoginPage;