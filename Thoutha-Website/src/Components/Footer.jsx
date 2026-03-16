import { Link} from "react-router-dom";
import "../Css/Footer.css";

export default function Footer() {
  return (
    <footer className="footer-container">
      <div className="footer-copy">
        &copy; 2026 ثوثة. جميع الحقوق محفوظة.
      </div>
      <Link to="/support" className="footer-copy">الدعم الفنى</Link>
    </footer>
  );
}
