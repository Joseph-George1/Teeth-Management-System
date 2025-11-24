
import { Route, Routes } from "react-router-dom";
import NavBar from "./Components/NavBar";
import Home from "./Pages/Home";
import LoginPage from "./Pages/LoginPage";
import RegisterForm from "./Pages/RegisterForm";
import ChatBot from "./Pages/ChatBot";
import Profile from "./Pages/Profile";
import TermsConditions from "./Pages/TermsConditions";
import Footer from "./Components/Footer";
import Otp from "./Pages/Otp";

export default function App() {
  return (
    <>
    <NavBar/>
    <Routes>
      <Route path="/" element={<Home/>}/>
      <Route path="/login" element={<LoginPage/>}/>
      <Route path="/sign" element={<RegisterForm/>}/>
      <Route path="/otp" element={<Otp/>}/>
      <Route path="/profile" element={<Profile/>}></Route>
      <Route path="chatbot" element={<ChatBot/>}/>
      <Route path="/terms&conditions" element={<TermsConditions/>}></Route>
    </Routes>
    <Footer/>
    </>
  );
}
