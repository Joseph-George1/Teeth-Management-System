
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
import NotFoundPage from "./Pages/NotFoundPage";
import OtpDone from "./Pages/OtpDone";
import DoctorHome from "./Pages/DoctorHome";
import Booking from "./Pages/Booking";
import Patient from "./Pages/Patient";
import DoctorBookings from "./Pages/DoctorBookings";

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
      <Route path="404" element={<NotFoundPage/>}/>
      <Route path="/doctor-home" element={<DoctorHome/>}></Route>
      <Route path="/booking" element={<Booking/>}></Route>
      <Route path="/patients" element={<Patient/>}></Route>
      <Route path="/doctor-booking" element={<DoctorBookings/>}></Route>
      <Route path="/otp-done" element={<OtpDone/>}></Route>
    </Routes>
    <Footer/>
    </>
  );
}
