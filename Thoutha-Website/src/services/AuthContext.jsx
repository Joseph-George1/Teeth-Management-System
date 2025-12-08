// Context/AuthContext.jsx
import { createContext, useState, useEffect } from "react";

export const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [user, setUser] = useState(null); // حفظ بيانات المستخدم

  useEffect(() => {
    const storedStatus = localStorage.getItem("isLoggedIn");
    const storedUser = localStorage.getItem("user");
    if (storedStatus === "true" && storedUser) {
      setIsLoggedIn(true);
      setUser(JSON.parse(storedUser));
    }
  }, []);

  const login = (userData) => {
    setIsLoggedIn(true);
    setUser(userData);
    localStorage.setItem("isLoggedIn", "true");
    localStorage.setItem("user", JSON.stringify(userData));
  };

  const logout = () => {
    setIsLoggedIn(false);
    setUser(null);
    localStorage.removeItem("isLoggedIn");
    localStorage.removeItem("user");
  };

  return (
    <AuthContext.Provider value={{ isLoggedIn, user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}
