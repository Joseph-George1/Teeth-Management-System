import { useRef, useState } from "react";
import emailjs from "emailjs-com";
import '../Css/TermsConditions.css';

export default function DeleteAccount() {
  const form = useRef();
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState("");

  const sendEmail = (e) => {
    e.preventDefault();
    setLoading(true);
    setError("");

    emailjs
      .sendForm(
        "service_p5uu6l9",
        "template_5pfgkta",
        form.current,
        "9YDoDCKMIYGrPnenI"
      )
      .then(
        () => {
          setLoading(false);
          setSuccess(true);
          form.current.reset();
          setTimeout(() => setSuccess(false), 3000);
        },
        (error) => {
          setLoading(false);
          setError("حدث خطأ أثناء إرسال الطلب ❌");
          console.error("EmailJS Error:", error);
          setTimeout(() => setError(""), 3000);
        }
      );
  };

  return (
    <div className="terms-container">
      <h1 className="terms-title">حذف الحساب – منصة ثوثة</h1>

      <section className="terms-section">
        <h2>طلب حذف الحساب</h2>
        <p>
          يمكنك طلب حذف حسابك في منصة ثوثة في أي وقت من خلال الإعدادات داخل المنصة أو عن طريق التواصل معنا عبر البريد الإلكتروني.
        </p>
      </section>

      <section className="terms-section">
        <h2>ماذا يحدث عند حذف الحساب؟</h2>
        <p>عند تأكيد طلب الحذف:</p>
        <ul>
          <li>سيتم حذف بيانات حسابك الشخصية من المنصة.</li>
          <li>لن تتمكن من تسجيل الدخول مرة أخرى بنفس الحساب.</li>
          <li>سيتم إلغاء أي طلبات أو مواعيد مرتبطة بالحساب.</li>
        </ul>
      </section>

      <section className="terms-section">
        <h2>مدة تنفيذ الطلب</h2>
        <p>يتم تنفيذ طلب حذف الحساب خلال مدة أقصاها (٢ أيام عمل) من تاريخ استلام الطلب.</p>
      </section>

      <section className="terms-section">
        <h2>استثناءات</h2>
        <p>قد نحتفظ ببعض البيانات لفترة محددة إذا كان ذلك مطلوبًا قانونيًا أو لحماية حقوق المنصة.</p>
      </section>

      <section className="terms-section">
        <h2>التواصل لطلب الحذف</h2>
        <p>
          يمكنك التواصل معنا عبر البريد الإلكتروني:
        </p>
        <p className="support-email" style={{ fontWeight: "600", margin: "8px 0 20px 0" }}>
          support@thoutha.page
        </p>
        
        <p style={{ marginBottom: "16px", fontSize: "15px" }}>أو استخدم النموذج أدناه:</p>
        
        <form ref={form} onSubmit={sendEmail} className="support-form" style={{ marginTop: "20px" }}>
          <input
            type="text"
            name="name"
            placeholder="الاسم"
            required
          />

          <input
            type="email"
            name="email"
            placeholder="البريد الإلكتروني"
            required
          />

          <textarea
            name="message"
            placeholder="اكتب طلب حذف الحساب هنا وأي تفاصيل إضافية"
            rows="5"
            required
          ></textarea>

          <button type="submit" disabled={loading} style={{ marginTop: "12px" }}>
            {loading ? "جاري الإرسال..." : "إرسال طلب الحذف"}
          </button>

          {success && (
            <div className="toast-message toast-success">
              تم إرسال طلب الحذف بنجاح ✅
            </div>
          )}

          {error && (
            <div className="toast-message toast-error">
              {error}
            </div>
          )}
        </form>
      </section>
    </div>
  );
}