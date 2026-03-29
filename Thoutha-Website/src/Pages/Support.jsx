import { useRef, useState } from "react";
import emailjs from "emailjs-com";
import "../Css/Support.css";

export default function Support(){
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
          setError("حدث خطأ أثناء إرسال الرسالة ❌");
          console.error("EmailJS Error:", error);
          setTimeout(() => setError(""), 3000);
        }
      );
  };

  return (
    <div className="support-container">
      <h1 className="support-title">الدعم الفني – منصة ثوثة</h1>

      <section className="support-section">
        <p>
          لو واجهتك أي مشكلة تقنية أثناء استخدام منصة <strong>ثوثة</strong>،
          أو عندك استفسار بخصوص التسجيل أو الحساب، فريق الدعم الفني جاهز يساعدك.
        </p>
      </section>

      <section className="support-section">
        <h2>ملاحظات مهمة</h2>
        <ul>
          <li>
            الدعم الفني يقتصر فقط على المشاكل التقنية المتعلقة باستخدام الموقع.
          </li>
          <li>
            لا يتدخل فريق الدعم في أي نزاعات أو اتفاقات بين الطلاب والمرضى.
          </li>
          <li>
            المنصة دورها يقتصر على الربط فقط بين الطرفين.
          </li>
        </ul>
      </section>

      <section className="support-section">
        <h2>وسائل التواصل</h2>
        <p>
          يمكنك التواصل معنا عبر البريد الإلكتروني:
        </p>
        <p className="support-email">
          support@thoutha.page
        </p>
      </section>

      <section className="support-section">
        <h2>نموذج التواصل</h2>

        <form ref={form} onSubmit={sendEmail} className="support-form">
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
            placeholder="اكتب رسالتك هنا"
            rows="5"
            required
          ></textarea>

          <button type="submit" disabled={loading}>
            {loading ? "جاري الإرسال..." : "إرسال"}
          </button>

          {success && (
            <div className="toast-message toast-success">
              تم إرسال رسالتك بنجاح ✅
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

