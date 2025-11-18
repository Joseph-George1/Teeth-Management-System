import { Routes, Route, Navigate } from 'react-router-dom';
import { useState, useEffect } from 'react';
import ChatBot from "./Pages/ChatBot";
import LoginPage from "./Pages/LoginPage";

export default function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(() => {
    // Check if user is authenticated from localStorage on initial load
    return localStorage.getItem('isAuthenticated') === 'true';
  });

  // Update localStorage when authentication state changes
  useEffect(() => {
    localStorage.setItem('isAuthenticated', isAuthenticated);
  }, [isAuthenticated]);

  return (
    <Routes>
      <Route 
        path="/" 
        element={
          isAuthenticated ? 
            <ChatBot setIsAuthenticated={setIsAuthenticated} /> : 
            <Navigate to="/login" replace />
        } 
      />
      <Route 
        path="/login" 
        element={
          !isAuthenticated ? 
            <LoginPage setIsAuthenticated={setIsAuthenticated} /> : 
            <Navigate to="/" replace />
        } 
      />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
