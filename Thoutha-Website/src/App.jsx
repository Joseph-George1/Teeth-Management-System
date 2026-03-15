
import { useEffect, useState } from "react";
import { Route, Routes } from "react-router-dom";
import NavBar from "./Components/NavBar";
import Home from "./Pages/Home";
import LoginPage from "./Pages/LoginPage";
import RegisterForm from "./Pages/RegisterForm";
import ChatBot from "./Pages/ChatBot";
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
import PrivacyPolicy from "./Pages/PrivacyPolicy";
import DeleteAccount from "./Pages/DeleteAccount";
import DoctorProfile from "./Pages/DoctorProfile";
import ProfileUpdate from "./Pages/ProfileUpdate";
import DeleteMyAccount from "./Pages/DeleteMyAccount";
import ForgetPassword from "./Pages/ForgetPassword";
import ResetPassword from "./Pages/ResetPassword";
import NotFoundPages from "./Pages/NotFoundPages";
import ForbiddenPage from "./Pages/ForbiddenPage";
import { isForbiddenVisible, subscribeToForbiddenPage } from "./services/forbiddenState";
export default function App() {
  const [showForbiddenScreen, setShowForbiddenScreen] = useState(isForbiddenVisible());

  useEffect(() => subscribeToForbiddenPage(setShowForbiddenScreen), []);

  if (showForbiddenScreen) {
    return <ForbiddenPage />;
  }

  return (
    <>
    <NavBar/>
    <Routes>
      <Route path="/" element={<Home/>}/>
      <Route path="/login" element={<LoginPage/>}/>
      <Route path="/sign" element={<RegisterForm/>}/>
      <Route path="/otp" element={<Otp/>}/>
      <Route path="/otp-verify" element={<OtpVerify/>}/>
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
      <Route path="/privacy-policy" element={<PrivacyPolicy/>}></Route>
      <Route path="/delete-account" element={<DeleteAccount/>}></Route>
      <Route path="/doctor-profile" element={<DoctorProfile/>}></Route>
      <Route path="/profile-update" element={<ProfileUpdate/>}></Route>
      <Route path="/delete-my-account" element={<DeleteMyAccount/>}></Route>
      <Route path="/forget-password" element={<ForgetPassword/>}></Route>
      <Route path="/reset-password" element={<ResetPassword/>}></Route>
      <Route path="*" element={<NotFoundPage/>}/>
      <Route path="/assets" element={<NotFoundPages/>}></Route>
    </Routes>
    <Footer/>
    </>
  );
}
