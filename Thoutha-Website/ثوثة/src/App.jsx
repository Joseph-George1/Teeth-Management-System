
import { Route, Routes } from "react-router-dom";
import NavBar from "./Components/NavBar";
import Home from "./Pages/Home";
import LoginPage from "./Pages/LoginPage";
import RegisterForm from "./Pages/RegisterForm";
import ChatBot from "./Pages/ChatBot";
import Profile from "./Pages/Profile";
import TermsConditions from "./Pages/TermsConditions";

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
    <>
    <NavBar/>
    <Routes>
      <Route path="/" element={<Home/>}/>
      <Route path="/login" element={<LoginPage/>}/>
      <Route path="/sign" element={<RegisterForm/>}/>
      <Route path="/profile" element={<Profile/>}></Route>
      <Route path="chatbot" element={<ChatBot/>}/>
      <Route path="/terms&conditions" element={<TermsConditions/>}></Route>
    </Routes>
    </>
  );
}
