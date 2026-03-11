// Context/AuthContext.jsx
import { createContext, useState, useEffect } from "react";

export const AuthContext = createContext();

/**
 * Merges stored doctorFullProfile into userData so that fields like
 * universityName, phone, city, year are always available after login.
 */
const mergeStoredProfile = (userData) => {
  try {
    const raw = localStorage.getItem("doctorFullProfile");
    if (!raw) return userData;
    const profile = JSON.parse(raw);
    // Only merge if same email (or profile has no email stored)
    if (profile.email && userData.email && profile.email !== userData.email) {
      return userData;
    }
    return {
      ...userData,
      phone:          userData.phone          || profile.phone,
      universityName: userData.universityName || profile.universityName,
      faculty:        userData.faculty        || profile.universityName,
      studyYear:      userData.studyYear      || profile.studyYear,
      year:           userData.year           || profile.studyYear,
      cityName:       userData.cityName       || profile.cityName,
      city:           userData.city           || profile.cityName,
      categoryName:   userData.categoryName   || profile.categoryName,
      specialization: userData.specialization || profile.categoryName,
    };
  } catch {
    return userData;
  }
};

export function AuthProvider({ children }) {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [user, setUser] = useState(null); // حفظ بيانات المستخدم

  useEffect(() => {
    const storedStatus = localStorage.getItem("isLoggedIn");
    const storedUser = localStorage.getItem("user");
    if (storedStatus === "true" && storedUser && storedUser !== "undefined") {
      try {
        const parsedUser = JSON.parse(storedUser);
        setIsLoggedIn(true);
        setUser(mergeStoredProfile(parsedUser));
      } catch {
        localStorage.removeItem("isLoggedIn");
        localStorage.removeItem("user");
        setIsLoggedIn(false);
        setUser(null);
      }
    }
  }, []);

  const login = (userData) => {
    const enrichedUser = mergeStoredProfile(userData);
    setIsLoggedIn(true);
    setUser(enrichedUser);
    localStorage.setItem("isLoggedIn", "true");
    localStorage.setItem("user", JSON.stringify(enrichedUser));
    if (enrichedUser?.token) localStorage.setItem("token", enrichedUser.token);
  };

  const logout = () => {
    setIsLoggedIn(false);
    setUser(null);
    localStorage.removeItem("isLoggedIn");
    localStorage.removeItem("user");
    localStorage.removeItem("token");
  };

  return (
    <AuthContext.Provider value={{ isLoggedIn, user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}
