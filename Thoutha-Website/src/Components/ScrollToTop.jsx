import { useEffect } from 'react';
import { useLocation } from 'react-router-dom';

/**
 * ScrollToTop Component
 * Automatically scrolls to the top of the page when route changes
 * Place this component inside your <Routes> or before it in App.jsx
 * 
 * Usage: Just import and use it once in your App.jsx
 * Example: <ScrollToTop /> inside the Router provider
 */
export default function ScrollToTop() {
  const { pathname } = useLocation();

  useEffect(() => {
    // Scroll to top with smooth behavior
    window.scrollTo({
      top: 0,
      behavior: 'smooth'
    });
  }, [pathname]); // Re-run effect whenever pathname changes

  // This component doesn't render anything
  return null;
}
