
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
import OtpVerify from "./Pages/Otp-verify";
import NotFoundPage from "./Pages/NotFoundPage";
import OtpDone from "./Pages/OtpDone";
import DoctorHome from "./Pages/DoctorHome";
import Booking from "./Pages/Booking";
import Patient from "./Pages/Patient";
import DoctorBookings from "./Pages/DoctorBookings";
import TeethWhitening from "./Pages/TeethWhitening";
import ToothExtraction from "./Pages/ToothExtraction";
import DentalCheckUp from "./Pages/DentalCheckUp";
import DentalFilling from "./Pages/DentalFilling";
import DentalImplant from "./Pages/DentalImplant";
import CrownsBridges from "./Pages/CrownsBridges";
import Braces from "./Pages/Braces";
import Support from "./Pages/Support";
export default function App() {
  return (
    <>
    <NavBar/>
    <Routes>
      <Route path="/" element={<Home/>}/>
      <Route path="/login" element={<LoginPage/>}/>
      <Route path="/sign" element={<RegisterForm/>}/>
      <Route path="/otp" element={<Otp/>}/>
      <Route path="/otp-verify" element={<OtpVerify/>}/>
      <Route path="/profile" element={<Profile/>}></Route>
      <Route path="/chatbot" element={<ChatBot/>}/>
      <Route path="/terms&conditions" element={<TermsConditions/>}></Route>
      <Route path="/doctor-home" element={<DoctorHome/>}></Route>
      <Route path="/booking" element={<Booking/>}></Route>
      <Route path="/patients" element={<Patient/>}></Route>
      <Route path="/doctor-booking" element={<DoctorBookings/>}></Route>
      <Route path="/otp-done" element={<OtpDone/>}></Route>
      <Route path="/teeth-whitening" element={<TeethWhitening/>}></Route>
      <Route path="/tooth-extraction" element={<ToothExtraction/>}></Route>
      <Route path="/dental-implant" element={<DentalImplant/>}></Route>
      <Route path="/dental-filling" element={<DentalFilling/>}></Route>
      <Route path="/dental-checkup" element={<DentalCheckUp/>}></Route>
      <Route path="/crowns&bridges" element={<CrownsBridges/>}></Route>
      <Route path="/braces" element={<Braces/>}></Route>
      <Route path="/support" element={<Support/>}></Route>
      <Route path="*" element={<NotFoundPage/>}/>
    </Routes>
    <Footer/>
    </>
  );
}
