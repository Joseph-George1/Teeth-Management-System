// Context/AuthContext.jsx
import { createContext, useCallback, useEffect, useState } from "react";

export const AuthContext = createContext();

const API_BASE_URL = import.meta.env.DEV ? "/api" : "https://thoutha.page/api";
const DOCTOR_PROFILE_URL = `${API_BASE_URL}/doctor/getDoctorById`;

const clearStoredAuth = () => {
  localStorage.removeItem("token");
  localStorage.removeItem("user");
  localStorage.removeItem("isLoggedIn");
  localStorage.removeItem("doctorFullProfile");
};

const decodeJwtPayload = (token) => {
  try {
    const payloadPart = token?.split(".")?.[1];
    if (!payloadPart) return null;

    const normalized = payloadPart.replace(/-/g, "+").replace(/_/g, "/");
    const padded = normalized.padEnd(Math.ceil(normalized.length / 4) * 4, "=");

    return JSON.parse(atob(padded));
  } catch {
    return null;
  }
};

const isTokenExpired = (token) => {
  const payload = decodeJwtPayload(token);
  if (!payload) return true;
  if (!payload.exp) return false;

  return payload.exp * 1000 <= Date.now();
};

const normalizeDoctorProfile = (payload, token) => {
  const tokenPayload = decodeJwtPayload(token) || {};
  const profile = payload?.data && typeof payload.data === "object"
    ? payload.data
    : payload || {};

  const firstName = profile.firstName || profile.first_name || tokenPayload.firstName || tokenPayload.first_name || "";
  const lastName = profile.lastName || profile.last_name || tokenPayload.lastName || tokenPayload.last_name || "";
  const phone = profile.phone || profile.phoneNumber || "";
  const universityName = profile.universityName || profile.faculty || "";
  const studyYear = profile.studyYear || profile.year || "";
  const cityName = profile.cityName || profile.city || "";
  const categoryName = profile.categoryName || profile.specialization || "";

  return {
    token,
    id: tokenPayload.id || tokenPayload.doctorId || tokenPayload.userId || tokenPayload.sub || null,
    role: tokenPayload.role || profile.role || "",
    firstName,
    first_name: firstName,
    lastName,
    last_name: lastName,
    email: profile.email || tokenPayload.sub || "",
    phone,
    phoneNumber: phone,
    universityName,
    faculty: universityName,
    studyYear,
    year: studyYear,
    cityName,
    city: cityName,
    categoryName,
    specialization: categoryName,
  };
};

export function AuthProvider({ children }) {
  const storedToken = localStorage.getItem("token");
  const [isLoggedIn, setIsLoggedIn] = useState(Boolean(storedToken));
  const [user, setUser] = useState(null);
  const [authLoading, setAuthLoading] = useState(Boolean(storedToken));

  const logout = useCallback(() => {
    clearStoredAuth();
    setIsLoggedIn(false);
    setUser(null);
    setAuthLoading(false);
  }, []);

  const applyServerUserData = useCallback((payload, tokenOverride) => {
    const activeToken = tokenOverride || localStorage.getItem("token");

    if (!activeToken) {
      return null;
    }

    const normalizedUser = normalizeDoctorProfile(payload, activeToken);
    setIsLoggedIn(true);
    setUser(normalizedUser);

    return normalizedUser;
  }, []);

  const refreshUserProfile = useCallback(async (tokenOverride) => {
    const activeToken = tokenOverride || localStorage.getItem("token");

    if (!activeToken) {
      throw new Error("لم يتم العثور على جلسة تسجيل الدخول");
    }

    if (isTokenExpired(activeToken)) {
      logout();
      throw new Error("انتهت صلاحية جلسة تسجيل الدخول");
    }

    const response = await fetch(DOCTOR_PROFILE_URL, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${activeToken}`,
      },
      cache: "no-store",
    });

    if (response.status === 403) {
      logout();
      throw new Error("تم رفض الوصول من الخادم");
    }

    if (response.status === 401) {
      logout();
      throw new Error("انتهت صلاحية جلسة تسجيل الدخول");
    }

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(errorData?.message || errorData?.messageAr || "تعذر تحميل بيانات الطبيب");
    }

    const data = await response.json();
    return applyServerUserData(data, activeToken);
  }, [applyServerUserData, logout]);

  useEffect(() => {
    let isActive = true;
    const token = localStorage.getItem("token");

    localStorage.removeItem("doctorFullProfile");
    localStorage.removeItem("user");
    localStorage.removeItem("isLoggedIn");

    if (!token) {
      setIsLoggedIn(false);
      setUser(null);
      setAuthLoading(false);
      return () => {
        isActive = false;
      };
    }

    setIsLoggedIn(true);
    setAuthLoading(true);

    refreshUserProfile(token)
      .catch(() => {
        if (!isActive) return;
        setUser(null);
      })
      .finally(() => {
        if (isActive) {
          setAuthLoading(false);
        }
      });

    return () => {
      isActive = false;
    };
  }, [refreshUserProfile]);

  const login = useCallback(async (tokenOrUserData) => {
    const token = typeof tokenOrUserData === "string"
      ? tokenOrUserData
      : tokenOrUserData?.token;

    if (!token) {
      throw new Error("لم يتم استلام رمز الدخول من الخادم");
    }

    localStorage.setItem("token", token);
    localStorage.removeItem("user");
    localStorage.removeItem("isLoggedIn");
    localStorage.removeItem("doctorFullProfile");

    setIsLoggedIn(true);
    setUser(null);
    setAuthLoading(true);

    try {
      return await refreshUserProfile(token);
    } finally {
      setAuthLoading(false);
    }
  }, [refreshUserProfile]);

  return (
    <AuthContext.Provider value={{ isLoggedIn, user, authLoading, login, logout, refreshUserProfile, applyServerUserData }}>
      {children}
    </AuthContext.Provider>
 )
}
