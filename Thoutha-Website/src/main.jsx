import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App.jsx';
import './index.css' ;
import { BrowserRouter } from 'react-router';
import { AuthProvider } from './services/AuthContext.jsx';
import { HelmetProvider } from "react-helmet-async";

if (!window.__forbiddenInterceptorInstalled) {
  const originalFetch = window.fetch.bind(window);

  window.fetch = async (...args) => {
    const response = await originalFetch(...args);

    if (response.status === 403 && window.location.pathname !== "/forbidden") {
      window.location.assign("/forbidden");
    }

    return response;
  };

  window.__forbiddenInterceptorInstalled = true;
}

createRoot(document.getElementById('root')).render(
  <StrictMode>
     <HelmetProvider>
    <BrowserRouter>
      <AuthProvider>
        <App />
      </AuthProvider>
    </BrowserRouter>
    </HelmetProvider>
  </StrictMode>,
)
